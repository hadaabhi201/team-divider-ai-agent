# Use official Go image as builder
FROM golang:1.24.4 AS builder

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum first to leverage cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o authify ./cmd

# Final image
FROM alpine:latest

# Set working directory in container
WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/authify .

# Copy .env file (optional; only for local dev/testing)
COPY .env .

# Expose port (should match your .env PORT)
EXPOSE 8080

# Run the binary
CMD ["./authify"]
