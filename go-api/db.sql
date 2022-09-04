CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    password VARCHAR(60) NOT NULL,
    created_on TIMESTAMP NOT NULL,
    updated_on TIMESTAMP NOT NULL
);

ALTER TABLE users ALTER COLUMN created_on SET DEFAULT NOW();
ALTER TABLE users ALTER COLUMN updated_on SET DEFAULT NOW();
ALTER TABLE users ADD COLUMN user_active INTEGER NOT NULL DEFAULT 0;
UPDATE users SET user_active = 1;


CREATE TABLE tokens ( 
    id SERIAL PRIMARY KEY, 
    user_id INTEGER, 
    email VARCHAR(255) NOT NULL, 
    token VARCHAR(255) NOT NULL, 
    token_hash BYTEA, 
    created_on TIMESTAMP NOT NULL, 
    updated_on TIMESTAMP NOT NULL, 
    expired TIMESTAMP WITHOUT TIME ZONE
);

ALTER TABLE tokens ALTER COLUMN created_on SET DEFAULT NOW();
ALTER TABLE tokens ALTER COLUMN updated_on SET DEFAULT NOW();

ALTER TABLE tokens ADD CONSTRAINT tokens_user FOREIGN KEY (user_id) REFERENCES users (id);

INSERT INTO users(id, email, first_name, last_name, password) VALUES (1, 'admin@example.com', 'admin', 'adminski', '@Dmin1234');

ALTER TABLE tokens ALTER COLUMN expired TYPE TIMESTAMP WITH TIME ZONE;





-- Books





--
-- Name: authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authors (id integer NOT NULL, author_name character varying(512), created_at timestamp without time zone, updated_at timestamp without time zone);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE authors ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY ( SEQUENCE NAME authors_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1);


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE books ( id integer NOT NULL, title character varying(512), author_id integer, publication_year integer, created_at timestamp without time zone, updated_at timestamp without time zone, slug character varying(512), description text);


--
-- Name: books_genres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE books_genres (id integer NOT NULL, book_id integer, genre_id integer, created_at timestamp without time zone, updated_at timestamp without time zone);


--
-- Name: books_genres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE books_genres ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (SEQUENCE NAME books_genres_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE books ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (SEQUENCE NAME books_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1);


--
-- Name: genres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE genres (id integer NOT NULL, genre_name character varying(255), created_at timestamp without time zone, updated_at timestamp without time zone);


--
-- Name: genres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE genres ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (SEQUENCE NAME genres_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1);

--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors ADD CONSTRAINT authors_pkey PRIMARY KEY (id);

--
-- Name: books_genres books_genres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books_genres ADD CONSTRAINT books_genres_pkey PRIMARY KEY (id);

--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: genres genres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genres ADD CONSTRAINT genres_pkey PRIMARY KEY (id);


--
-- Name: books books_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books ADD CONSTRAINT books_author_id_fkey FOREIGN KEY (author_id) REFERENCES authors(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: books_genres books_genres_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books_genres ADD CONSTRAINT books_genres_book_id_fkey FOREIGN KEY (book_id) REFERENCES books(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: books_genres books_genres_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books_genres ADD CONSTRAINT books_genres_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES genres(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--




-- Books inserts




INSERT INTO "authors"("author_name","created_at","updated_at") VALUES (E'Stephen King',E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (E'Mark Twain',E'2022-02-21 00:00:00',E'2022-02-21 00:00:00');


INSERT INTO "genres"("genre_name","created_at","updated_at") VALUES (E'Science Fiction',E'2022-02-13 00:00:00',E'2022-02-13 00:00:00'), (E'Fantasy',E'2022-02-13 00:00:00',E'2022-02-13 00:00:00'), (E'Romance',E'2022-02-13 00:00:00',E'2022-02-13 00:00:00'), (E'Thriller',E'2022-02-13 00:00:00',E'2022-02-13 00:00:00'), (E'Mystery',E'2022-02-13 00:00:00',E'2022-02-13 00:00:00'), (E'Horror',E'2022-02-13 00:00:00',E'2022-02-13 00:00:00'), (E'Classic',E'2022-02-13 00:00:00',E'2022-02-13 00:00:00');


INSERT INTO "books"("title","author_id","publication_year","created_at","updated_at","slug","description") VALUES (E'The Shining',1,1977,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00',E'the-shining',E'Jack Torrance, his wife Wendy, and their young son Danny move into the Overlook Hotel, where Jack has been hired as the winter caretaker. Cut off from civilization for months, Jack hopes to battle alcoholism and uncontrolled rage while writing a play. Evil forces residing in the Overlook – which has a long and violent history – covet young Danny for his precognitive powers and exploit Jack’s weaknesses to try to claim the boy.'), (E'\'Salem\'s Lot',1,1975,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00',E'salems-lot',E'Author Ben Mears returns to ‘Salem\'s Lot to write a book about a house that has haunted him since childhood only to find his isolated hometown infested with vampires. While the vampires claim more victims, Mears convinces a small group of believers to combat the undead.'),  (E'The Stand',1,1979,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00',E'the-stand',E'One man escapes from a biological weapon facility after an accident, carrying with him the deadly virus known as Captain Tripps, a rapidly mutating flu that - in the ensuing weeks - wipes out most of the world\'s population. In the aftermath, survivors choose between following an elderly black woman to Boulder or the dark man, Randall Flagg, who has set up his command post in Las Vegas. The two factions prepare for a confrontation between the forces of good and evil.'), (E'The Gunslinger',1,1982,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00',E'the-gunslinger',E'The opening chapter in the epic Dark Tower series. Roland, the last gunslinger, in a world where time has moved on, pursues his nemesis, The Man in Black, across a desert. Roland\'s ultimate goal is the Dark Tower, the nexus of all universes. This mysterious icon\'s power is failing, threatening everything in existence. '), (E'IT',1,1986,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00',E'it',E' A promise made twenty-eight years ago calls seven adults to reunite in Derry, Maine, where as teenagers they battled an evil creature that preyed on the city\'s children. Unsure that their Losers Club had vanquished the creature all those years ago, the seven had vowed to return to Derry if IT should ever reappear. Now, children are being murdered again and their repressed memories of that summer return as they prepare to do battle with the monster lurking in Derry\'s sewers once more.'), (E'The Dead Zone',1,1979,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00',E'the-dead-zone',E'Waking up from a five-year coma after a car accident, former schoolteacher Johnny Smith discovers that he can see people\'s futures and pasts when he touches them. Many consider his talent a gift; Johnny feels cursed. His fiance married another man during his coma and people clamor for him to solve their problems. When Johnny has a disturbing vision after he shakes the hand of an ambitious and amoral politician, he must decide if he should take drastic action to change the future.'); 

INSERT INTO "books_genres"("book_id","genre_id","created_at","updated_at") VALUES (1,6,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (1,4,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (2,6,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (3,2,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (3,6,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (4,4,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (5,4,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'), (6,6,E'2022-02-21 00:00:00',E'2022-02-21 00:00:00'); 