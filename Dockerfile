FROM golang:1.11-alpine AS builder

# Install some dependencies needed to build the project
RUN apk add bash ca-certificates gcc g++ libc-dev

ENV GO111MODULE=on

WORKDIR /go/src/github.com/clivern/beaver

COPY . .

# Building using -mod=vendor, which will utilize the vendor dir
RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -o beaver beaver.go

FROM alpine:3.8 as clivern_beaver

WORKDIR /go/src/github.com/clivern/beaver

RUN apk add ca-certificates

EXPOSE 8080

# Add user
RUN addgroup -g 1000 -S app && adduser -u 1000 -S app -G app
RUN mkdir -p /var/logs && chown app:app /var/logs
USER app

COPY --from=builder --chown=app:app /go/src/github.com/clivern/beaver .

CMD ["./beaver"]
