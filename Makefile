DSN="host=localhost port=5432 user=postgres password=password dbname=vueapi sslmode=disable timezone=Europe/Amsterdam connect_timeout=5"
BINARY_NAME=vueapi.exe
ENV=development

# indentation must be tabs
build:
	@echo "Building back end..."
	go build -o ${BINARY_NAME} ./cmd/api/
	@echo "Binary built!"

run: build
	@echo "Starting back end..."
	@env DSN=${DSN} ENV=${ENV} ./${BINARY_NAME} &
	@echo "Back end started!"

clean:
	@echo "Cleaning..."
	@go clean
	@rm ${BINARY_NAME}
	@echo "Cleaned!"

## start: an alias to run (in cmd 'make start')
start: run

## make stop
stop:
	@echo "Stopping back end..."
	@-pkill -SIGTERM -f "./${BINARY_NAME}"
	@echo "Stopped back end!"

## make restart
restart: stop start