#!/bin/sh

openssl req -x509 -nodes -newkey rsa:2048 -keyout key.pem -out cert.pem -sha256 -days 365 \
    -subj "/C=US/ST=Columbus/L=Columbus/O=Syncopated/OU=Dev Department/CN=localhost"
