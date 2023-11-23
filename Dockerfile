# Build stage
FROM debian:bookworm-slim

ARG HUGO_VERSION="0.119.0"
ARG ARCH="amd64"

RUN apt update && apt install -y wget git
RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${ARCH}.deb
RUN dpkg -i hugo_extended_${HUGO_VERSION}_linux-${ARCH}.deb

COPY . powerfulfamily.net/
WORKDIR powerfulfamily.net/
RUN hugo --minify

# Run stage
FROM nginx:1.25.3
COPY powerfulfamily.net/public/ /usr/share/nginx/html/
EXPOSE 80
