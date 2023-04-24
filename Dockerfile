FROM rust:1.69.0-bullseye AS build

RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid 65532 \
    small-user

WORKDIR /usr/src/app

COPY src src/
COPY static static/
COPY Cargo.toml ./
COPY Cargo.lock ./

RUN cargo build --target x86_64-unknown-linux-musl --release

FROM scratch

COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/target/x86_64-unknown-linux-musl/release/main ./
COPY --from=build /usr/src/app/static static/

USER small-user:small-user

CMD ["./main"]
