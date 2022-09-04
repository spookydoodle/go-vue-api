# go-vue
Example backend server for a typical full stack application which allows to write and read data to/from a postgres data base.

# Dependencies
Go, Make, Docker

# Install dependencies
Run `go get -u -v -f all`

# DB setup
Start the data base and mailhog by running `docker-compose up --build`
See `db.sql` for data base and table structure

# Start server
Run `make start` (or `make restart` if server is already running)