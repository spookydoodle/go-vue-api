# go-vue
Example backend server for a typical full stack application which allows to write and read data to/from a postgres data base.

# Dependencies
Go, Make, Docker

# Install dependencies
Run `go get -u -v -f all`

# DB setup
For local development, create local folder `db-data/postgres` in root of `api` to store data.
Start the data base and mailhog by running `docker-compose up --build`
Run setup commands from `db.sql` for data base and table structure. You can now log in using e-mail `john.smith@example.com` and password `password`.

# Start server
Run `make start` (or `make restart` if server is already running)