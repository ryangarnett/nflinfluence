library(gargle)
library(googleCloudStorageR)
library(lubridate)
library(glue)

# Authenticate and list objects in the bucket
gcs_auth()
bucket_name <- "datify_data"
gcs_list_objects(bucket_name)



# Temp file
temp_parquet <- tempfile(fileext = ".parquet")

# write_parquet(my_data, temp_parquet)

# bucket_name <- "datify_data"
# object_name <- "my_data.parquet"

# gcs_upload(
#   file = temp_parquet,
#   bucket = bucket_name,
#   name = object_name
# )

# unlink(temp_parquet)


# Download logic
bucket_name <- "datify_data"
current_year <- lubridate::year(Sys.Date())
current_file_name <- glue::glue("play_by_play_{current_year}.parquet")

temp_parquet <- tempfile(fileext = ".parquet")
download_url <- glue::glue("https://github.com/nflverse/nflverse-data/releases/download/pbp/{current_file_name}")
download.file(
  download_url,
  temp_parquet
)

arrow::read_parquet(temp_parquet) |>
  dplyr::filter(week == max(week, na.rm = TRUE)) |>
  arrow::write_dataset(
    "nflinfluence/nfl_pbp_trans",
    partitioning = c("season", "week")
  )

