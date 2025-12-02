# Stage 1: Build the Go application
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o main .

# Stage 2: Create a minimal final image
FROM alpine:latest
WORKDIR /root/
# Install ca-certificates needed for HTTPS/TLS connection to RDS
RUN apk add --no-cache ca-certificates
# Copy the compiled executable from the builder stage
COPY --from=builder /app/main .
# Expose the port (default 8080)
EXPOSE 8080
# Run the application
CMD ["./main"]