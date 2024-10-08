# Function to check and install missing packages
check_and_install_packages <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE)) {
      install.packages(package, dependencies = TRUE)
      library(package, character.only = TRUE)
    }
  }
}

# List of required packages
required_packages <- c("treemap", "d3treeR", "xml2", "htmltools", "tools", "jsonlite")

# Check and install packages
check_and_install_packages(required_packages)

# Load the libraries
library(treemap)
library(d3treeR)
library(xml2)
library(htmltools)
library(tools)
library(jsonlite)

generate_treemap <- function(file_path) {
  print(paste("Processing file:", file_path))
  title_name <- paste(strsplit(basename(file_path), "_")[[1]][1:3], collapse="_")
  
  data <- tryCatch(
    read.table(file_path, header = TRUE, stringsAsFactors = FALSE, sep = "\t", skip = 4),
    error = function(e) {
      print(paste("Error reading the file:", file_path))
      return(NULL)
    }
  ) 
  if (is.null(data)) {
    return(NULL)
  }
  data$Value <- abs(data$Value)
  
  revigo.names <- c("term_ID", "description", "frequency", "value", "uniqueness", "dispensability", "representative")
  
  revigo.data <- data[data[, ncol(data)] != "null", ]
  stuff <- data.frame(revigo.data)
  names(stuff) <- revigo.names
  
  stuff$value <- as.numeric(as.character(stuff$value))
  stuff$frequency <- as.numeric(as.character(stuff$frequency))
  stuff$uniqueness <- as.numeric(as.character(stuff$uniqueness))
  stuff$dispensability <- as.numeric(as.character(stuff$dispensability))
  
  file_name <- tools::file_path_sans_ext(basename(file_path))
  title_name <- paste(strsplit(file_name, "_")[[1]][1:3], collapse="_")
  ns <- (strsplit(file_name, "_")[[1]])[6]
  
  if (nrow(stuff) > 0) {
    treemap_plot <- treemap(
      stuff,
      index = c("representative", "description"),
      vSize = "value",
      type = "categorical",
      vColor = "representative",
      title = title_name,
      inflate.labels = FALSE,
      lowerbound.cex.labels = 0,
      bg.labels = "#CCCCCCAA",
      position.legend = "none"
    )
    
    treemap_plot <- d3tree(treemap_plot, rootname = paste0(title_name, " ", ns), width = "50%", height = "100%")
    
    output_dir <- file.path(dirname(dirname(file_path)), "results_revigo", "3d_results")
    print(output_dir)
    if (!file.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }
    html_file_path <- file.path(output_dir, paste0(tools::file_path_sans_ext(file_name), ".html"))
    print(html_file_path)
    htmltools::save_html(treemap_plot, file = html_file_path)
    
    modify_html_style(html_file_path)
  } else {
    print("The dataframe is empty.")
  }
}

modify_html_style <- function(html_file_path) {
  doc <- xml2::read_html(html_file_path)
  
  nodes <- xml2::xml_find_all(doc, ".//div[contains(@class, 'd3tree')]")
  for (node in nodes) {
    xml2::xml_set_attr(node, "style", "font-size: 15px;")
  }
  
  style <- "
    body {
        background-color: white;
        margin: 0;
        overflow: hidden;
    }
    .d3tree {
        width: 100%;
        height: 100vh;
    }
    
    .label {
        font-family: Arial, sans-serif;
    }
    
    .d3tree .child .label {
        font-size: 12px;
        font-family: Arial, sans-serif;
    }
  "
  xml2::xml_add_child(xml2::xml_find_first(doc, "//head"), "style", style)
  xml2::write_html(doc, html_file_path)
}

json_data <- jsonlite::fromJSON("params.json")
out_folder <- json_data$output_folder

path_dir <- file.path(getwd(), out_folder)

file_list <- list.files(path = path_dir, pattern = "_TreeMap\\.tsv$", recursive = TRUE, full.names = TRUE)

lapply(file_list, generate_treemap)
