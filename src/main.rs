use actix_files as fs;
use actix_web::{App, HttpServer};
use std::{env};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env::set_var("RUST_LOG", "actix_web=debug,actix_server=info");
    env_logger::init();

    HttpServer::new(|| App::new().service(fs::Files::new("/", "./static").index_file("index.html")))
        .bind(("0.0.0.0", 8080))?
        .run()
        .await
}
