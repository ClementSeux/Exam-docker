FROM golang:1.24-alpine AS builder

# Installer git si besoin (dépendances Go modules)
RUN apk add --no-cache git

WORKDIR /app

# 1. Go modules
COPY go.mod go.sum ./
RUN go mod download

# 2. Code source et compilation statique
COPY . .
RUN CGO_ENABLED=0 \
  GOOS=linux \
  GOARCH=amd64 \
  go build -ldflags="-s -w" -o /app/app

# ─── Étape 2 : runtime ───────────────────────────────────────
FROM scratch
# Copier le binaire pur
COPY --from=builder /app/app /app/app

# Port exposé (doit correspondre à PORT dans l’app)
EXPOSE 8080

# Point d’entrée
ENTRYPOINT ["/app/app"]


