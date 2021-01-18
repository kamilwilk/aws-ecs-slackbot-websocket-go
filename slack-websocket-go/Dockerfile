FROM --platform=linux/amd64 golang:1.18

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o /usr/local/bin/app ./...

ENV DEBUG = 1

CMD ["app"]
