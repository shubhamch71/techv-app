# backend/Dockerfile
# Stage 1: build stage
FROM golang:1.19-alpine AS builder

# Install required packages
RUN apk add --no-cache build-base git ca-certificates

WORKDIR /app

# Cache dependencies
COPY go.mod go.sum ./
RUN go env -w GOPROXY=https://proxy.golang.org && go mod download

# Copy application source
COPY . .

# Build optimized static binary
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -trimpath -ldflags="-s -w" -o server ./main.go

# Stage 2: minimal runtime image
FROM alpine:3.20

# Install only necessary packages for minimal runtime (and debugging tools if needed)
RUN apk add --no-cache ca-certificates tzdata curl

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/server /app/server

# Use non-root user for security
USER appuser

# Expose app port
EXPOSE 8080

# Run the binary
ENTRYPOINT ["./server"]
