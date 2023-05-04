FROM golang:1.20.4-bullseye AS build
WORKDIR /app
COPY go.* ./
COPY cmd/ping/*.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/bin/ping

FROM alpine:3
COPY --from=build /app/bin/ping /usr/local/bin/ping
CMD ["/usr/local/bin/ping"]
