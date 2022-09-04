package data

import (
	"context"
	"database/sql"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/mozillazg/go-slugify"
)

// Book is the definition of a single book
type Book struct {
	ID              int       `json:"id"`
	Title           string    `json:"title"`
	AuthorID        int       `json:"author_id"`
	PublicationYear int       `json:"publication_year"`
	Slug            string    `json:"slug"`
	Author          Author    `json:"author"`
	Description     string    `json:"description"`
	Genres          []Genre   `json:"genres"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	GenreIDs        []int     `json:"genre_ids,omitempty"`
}

// Author is the definition of a single author
type Author struct {
	ID         int       `json:"id"`
	AuthorName string    `json:"author_name"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// Genre is the definition of a single genre type
type Genre struct {
	ID        int       `json:"id"`
	GenreName string    `json:"genre_name"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// GetAll returns a slice of all books
func (b *Book) GetAll(genreIDs ...int) ([]*Book, error) {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	// if we have params, we are limiting by genre,
	// so build the where clause
	where := ""
	if len(genreIDs) > 0 {
		var IDs []string
		for _, x := range genreIDs {
			IDs = append(IDs, strconv.Itoa(x))
		}
		where = fmt.Sprintf("where b.id in (%s)", strings.Join(IDs, ","))
	}

	// (select array_to_string(array_agg(genre_id), ',') from books_genres where book_id = b.id)
	query := fmt.Sprintf(`select b.id, b.title, b.author_id, b.publication_year, b.slug, b.description, b.created_at, b.updated_at,
            a.id, a.author_name, a.created_at, a.updated_at
            from books b
            left join authors a on (b.author_id = a.id)
            %s
            order by b.title`, where)

	var books []*Book

	rows, err := db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var book Book
		err := rows.Scan(
			&book.ID,
			&book.Title,
			&book.AuthorID,
			&book.PublicationYear,
			&book.Slug,
			&book.Description,
			&book.CreatedAt,
			&book.UpdatedAt,
			&book.Author.ID,
			&book.Author.AuthorName,
			&book.Author.CreatedAt,
			&book.Author.UpdatedAt)
		if err != nil {
			println(err.Error())
			return nil, err
		}

		// get genres
		genres, genreIDs, err := b.genresForBook(book.ID)
		if err != nil {
			return nil, err
		}
		book.Genres = genres
		book.GenreIDs = genreIDs

		books = append(books, &book)
	}

	return books, nil
}

// GetOneById returns one book by its id
func (b *Book) GetOneById(id int) (*Book, error) {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	query := `select b.id, b.title, b.author_id, b.publication_year, b.slug, b.description, b.created_at, b.updated_at,
            a.id, a.author_name, a.created_at, a.updated_at
            from books b
            left join authors a on (b.author_id = a.id)
            where b.id = $1`

	row := db.QueryRowContext(ctx, query, id)

	var book Book

	err := row.Scan(
		&book.ID,
		&book.Title,
		&book.AuthorID,
		&book.PublicationYear,
		&book.Slug,
		&book.Description,
		&book.CreatedAt,
		&book.UpdatedAt,
		&book.Author.ID,
		&book.Author.AuthorName,
		&book.Author.CreatedAt,
		&book.Author.UpdatedAt)
	if err != nil {
		return nil, err
	}

	// get genres
	genres, genreIDs, err := b.genresForBook(id)
	if err != nil {
		return nil, err
	}

	book.Genres = genres
	book.GenreIDs = genreIDs

	return &book, nil
}

// GetOneBySlug returns one book by slug
func (b *Book) GetOneBySlug(slug string) (*Book, error) {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	query := `select b.id, b.title, b.author_id, b.publication_year, b.slug, b.description, b.created_at, b.updated_at,
            a.id, a.author_name, a.created_at, a.updated_at
            from books b
            left join authors a on (b.author_id = a.id)
            where b.slug = $1`

	row := db.QueryRowContext(ctx, query, slug)

	var book Book

	err := row.Scan(
		&book.ID,
		&book.Title,
		&book.AuthorID,
		&book.PublicationYear,
		&book.Slug,
		&book.Description,
		&book.CreatedAt,
		&book.UpdatedAt,
		&book.Author.ID,
		&book.Author.AuthorName,
		&book.Author.CreatedAt,
		&book.Author.UpdatedAt)
	if err != nil {
		return nil, err
	}

	// get genres
	genres, genreIDs, err := b.genresForBook(book.ID)
	if err != nil {
		return nil, err
	}

	book.Genres = genres
	book.GenreIDs = genreIDs

	return &book, nil
}

// genresForBook returns all genres for a given book id
func (b *Book) genresForBook(id int) ([]Genre, []int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	// get genres
	var genres []Genre
	var genreIDs []int
	genreQuery := `select id, genre_name, created_at, updated_at from genres where id in (select genre_id 
                from books_genres where book_id = $1) order by genre_name`

	gRows, err := db.QueryContext(ctx, genreQuery, id)
	if err != nil && err != sql.ErrNoRows {
		return nil, nil, err
	}
	defer gRows.Close()

	var genre Genre
	for gRows.Next() {

		err = gRows.Scan(
			&genre.ID,
			&genre.GenreName,
			&genre.CreatedAt,
			&genre.UpdatedAt)
		if err != nil {
			return nil, nil, err
		}
		genres = append(genres, genre)
		genreIDs = append(genreIDs, genre.ID)
	}

	return genres, genreIDs, nil
}

// Insert saves one book to the database
func (b *Book) Insert(book Book) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	stmt := `insert into books (title, author_id, publication_year, slug, description, created_at, updated_at)
            values ($1, $2, $3, $4, $5, $6, $7) returning id`

	var newID int
	err := db.QueryRowContext(ctx, stmt,
		book.Title,
		book.AuthorID,
		book.PublicationYear,
		slugify.Slugify(book.Title),
		book.Description,
		time.Now(),
		time.Now(),
	).Scan(&newID)
	if err != nil {
		return 0, err
	}

	// update genres
	println(len(book.GenreIDs))
	if len(book.GenreIDs) > 0 {
		// add new genres
		for _, x := range book.GenreIDs {
			stmt = `insert into books_genres (book_id, genre_id, created_at, updated_at)
                values ($1, $2, $3, $4)`
			_, err = db.ExecContext(ctx, stmt, newID, x, time.Now(), time.Now())
			println(stmt)
			println(book.ID, b.ID, newID, x)
			if err != nil {
				return newID, fmt.Errorf("book added, but genres not: %s")
			}
		}
	}

	return newID, nil
}

// Update updates one book in the database
func (b *Book) Update() error {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	stmt := `update books set
        title = $1,
        author_id = $2,
        publication_year = $3,
        slug = $4,
        description = $5,
        updated_at = $6
        where id = $7`

	_, err := db.ExecContext(ctx, stmt,
		b.Title,
		b.AuthorID,
		b.PublicationYear,
		slugify.Slugify(b.Title),
		b.Description,
		time.Now(),
		b.ID)
	if err != nil {
		return err
	}

	// update genres
	if len(b.GenreIDs) > 0 {
		// delete existing genres
		stmt = `delete from books_genres where book_id = $1`
		_, err := db.ExecContext(ctx, stmt, b.ID)
		if err != nil {
			return fmt.Errorf("book updated, but genres not: %s", err.Error())
		}

		// add new genres
		for _, x := range b.GenreIDs {
			stmt = `insert into books_genres (book_id, genre_id, created_at, updated_at)
                values ($1, $2, $3, $4)`
			_, err = db.ExecContext(ctx, stmt, b.ID, x, time.Now(), time.Now())
			if err != nil {
				return fmt.Errorf("book updated, but genres not: %s", err.Error())
			}
		}
	}

	return nil
}

// DeleteByID deletes a book by id
func (b *Book) DeleteByID(id int) error {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	stmt := `delete from books where id = $1`
	_, err := db.ExecContext(ctx, stmt, id)
	if err != nil {
		return err
	}
	return nil
}

// All returns a list of all authors
func (a *Author) All() ([]*Author, error) {
	ctx, cancel := context.WithTimeout(context.Background(), dbTimeout)
	defer cancel()

	query := `select id, author_name, created_at, updated_at  from authors order by author_name`
	rows, err := db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var authors []*Author

	for rows.Next() {
		var author Author
		err := rows.Scan(&author.ID, &author.AuthorName, &author.CreatedAt, &author.UpdatedAt)
		if err != nil {
			return nil, err
		}
		authors = append(authors, &author)
	}
	return authors, nil
}
