#!/usr/bin/env sh
#
# Usage: regenerate.sh
#
# regenerate.sh regenerates certificates that are used to test gRPC with TLS
# Make sure you run it in test/certs directory.
# It also serves as a documentation on how existing certificates were generated.
#
# The certificates here were regenerated with a 100-year validity (-days 36500)
# because the originals expired on 2023-06-08 and the gRPC TLS tests cannot
# establish a connection with expired certificates.
# Keys are generated unencrypted and non-interactively: under OpenSSL 3 the old
# `genrsa -des3` prompts for a passphrase, and `x509 -req -nodes` is rejected
# outright, so both flags are gone.

rm ca.crt ca.key client.crt client.csr client.key server.crt server.csr server.key

openssl genrsa -out ca.key 4096
openssl req -nodes -new -x509 -days 36500 -key ca.key -out ca.crt -subj "/C=CL/ST=RM/L=OpenTelemetryTest/O=Root/OU=Test/CN=ca"

openssl genrsa -out server.key 4096
openssl req -nodes -new -key server.key -out server.csr -subj "/C=CL/ST=RM/L=OpenTelemetryTest/O=Test/OU=Server/CN=localhost"
openssl x509 -req -sha256 -days 36500 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

openssl genrsa -out client.key 4096
openssl req -nodes -new -key client.key -out client.csr -subj "/C=CL/ST=RM/L=OpenTelemetryTest/O=Test/OU=Client/CN=localhost"
openssl x509 -req -sha256 -days 36500 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
