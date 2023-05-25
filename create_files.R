#!/usr/bin/env Rscript

##########
## Imports
##########

# Parallel
library(foreach)
library(doParallel)
library(parallel)

# Data 
library(jsonlite)
library(stringr)
library(uuid)

############
## Constants
############

N_REPLICATES <- 1000

BASE_FILE_NAME <- "base_file.json"
FILE_SUFFIX <- ".json"
OUT_DIR <- "out"

N_CORES <- detectCores() - 1

ARGS <- commandArgs(trailingOnly = TRUE)

#######
## Main
#######

create_json_files <- function(
  n_replicates, base_file_name, file_suffix, out_dir, n_cores) {
  
  unlink(out_dir, recursive = T, force = T)
  dir.create(out_dir, showWarnings = F, recursive = T)
  
  start_time <- Sys.time()
  
  exec_parallel <- ARGS[1]
  if(!is.na(exec_parallel)) {
    job_cluster <- makeCluster(n_cores)
    registerDoParallel(cl = job_cluster)
    message(getDoParWorkers())
  } else {
    registerDoSEQ()
  }

  base_json <- read_json(base_file_name)
  uuids <- UUIDgenerate(n = n_replicates)
  foreach(
    new_uuid = uuids,
    .combine = 'c',
    .packages = c("stringr", "jsonlite", "data.table")
  ) %dopar% {
    json_copy <- copy(base_json)
    json_copy$id <- new_uuid
    json_copy$value <- "Copy"
    
    write_json(
      json_copy,
      file.path(out_dir, str_c(new_uuid, file_suffix)),
      simplifyVector = T,
      auto_unbox = T
    )
  }

  if(!is.na(exec_parallel)) {
    parallel::stopCluster(cl = job_cluster)
  }
  
  run_time <- Sys.time() - start_time
  message(str_c("Run time (seconds): ", run_time))
}

create_json_files(N_REPLICATES, BASE_FILE_NAME, FILE_SUFFIX, OUT_DIR, N_CORES)
