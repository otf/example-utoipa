use axum::extract::Path;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::Json;
use axum::{routing::get, Router};

use serde::Serialize;
use utoipa::OpenApi;
use utoipa::ToSchema;
use utoipa_swagger_ui::SwaggerUi;

#[derive(ToSchema, Serialize)]
struct Pet {
    id: u64,
    name: String,
    age: Option<i32>,
}

#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Pet found succesfully", body = Pet),
        (status = NOT_FOUND, description = "Pet was not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database id to get Pet for"),
    )
)]
async fn get_pet_by_id(Path(pet_id): Path<u64>) -> impl IntoResponse {
    let result = Pet {
        id: pet_id,
        age: None,
        name: "lightning".to_string(),
    };
    (StatusCode::OK, Json(result).into_response())
}

#[tokio::main]
async fn main() {
    #[derive(OpenApi)]
    #[openapi(paths(get_pet_by_id), components(schemas(Pet)))]
    struct ApiDoc;

    // build our application with a single route
    let app = Router::new()
        .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()))
        .route("/pets/:pet_id", get(get_pet_by_id));

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
