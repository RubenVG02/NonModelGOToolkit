# List of required packages
required_packages <- c("dplyr", "GOstats", "AnnotationDbi", "GSEABase", "qvalue", "ggplot2", "stringr", "optparse")

# Function to check and install missing packages
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  }
}

# Install missing packages
invisible(lapply(required_packages, install_if_missing))

# Now you can load the libraries
library(dplyr)
library(GOstats)
library(AnnotationDbi)
library(GSEABase)
library(qvalue)
library(ggplot2)
library(stringr)
library(optparse)


# Function to process files based on the name pattern
process_files <- function(base_name, genes_folder, universe_file, output_folder, universe_folder, gsc, pvalue_cutoff, category_size) {
  genes_file_path <- file.path(genes_folder, paste0(base_name, ".txt"))
  print(genes_file_path)
  
  universe_file_path <- file.path(universe_folder, paste0(base_name, ".txt"))
  print(universe_file_path)
  
  # Read genes and universe files
  genes <- readLines(genes_file_path)
  universe <- readLines(universe_file_path)
  
  # Convert the universe into a list
  universe <- unlist(strsplit(universe, "\n"))
  universe <- universe[universe != ""]
  
  output_name <- base_name
  
  # Define p-value cutoff values
  pvalue_cutoffs <- c(pvalue_cutoff)
  
  tryCatch({
    # Loop through each p-value cutoff
    for (pvalue_cutoff in pvalue_cutoffs) {
      
      # List to store results for each ontology
      results_list <- list()
      
      # Ontologies to process
      ontologies <- c("BP", "MF", "CC")
      
      # Loop through each ontology
      for (ontology in ontologies) {
        # Perform analysis for the current ontology
        print("Attempting ontology analysis")
        tryCatch({
          params <- GSEAGOHyperGParams(
            name = paste("My Custom GSEA based annot Params -", ontology),
            geneSetCollection = gsc,
            geneIds = genes,
            universeGeneIds = universe,
            ontology = ontology,
            pvalueCutoff = pvalue_cutoff,
            conditional = TRUE,
            testDirection = "over"
          )
          
          Over <- hyperGTest(params)
          print(Over)
          
          results_list[[ontology]] <- summary(Over, categorySize = category_size) # Use category_size
          
        }, error = function(e) {
          # Handle error in summary
          cat("Error in summary for ontology", ontology, "\n")
          cat("Error message:", conditionMessage(e), "\n")
        })
      }
      
      # Combine results into a single dataframe by ontology
      combined_results <- bind_rows(results_list, .id = "Ontology")
      
      # Check if there are results in any ontology
      if (any(sapply(results_list, nrow) > 0)) {
        print("Combined results")
        
        # Create output folder if it does not exist
        dir.create(file.path(output_folder, output_name), showWarnings = FALSE, recursive = TRUE)
        output_folder_final <- file.path(output_folder, output_name)
        
        # File name for combined results
        combined_output_filename <- paste0(output_name, "_", pvalue_cutoff, ".txt")
        
        # Write combined results to a file
        write.table(combined_results, file.path(output_folder, output_name, combined_output_filename), sep = "\t", row.names = FALSE, quote = FALSE)
        
        # Read combined file to extract IDs and p-values
        combined_data <- read.table(file.path(output_folder, output_name, combined_output_filename), header = TRUE, sep = "\t", stringsAsFactors = FALSE)
        
        # Filter non-NA IDs from GOBPID, GOCCID, and GOMFID columns
        filtered_ids <- na.omit(c(combined_data$GOBPID, combined_data$GOCCID, combined_data$GOMFID))
        
        # Create vector of p-values
        pvalues <- combined_data$Pvalue
        
        # Create dataframe with GOs and p-values
        output_df <- data.frame(GOs = filtered_ids, Pvalues = pvalues)
        
        # Write dataframe to a txt file
        output_txt_filename <- paste0(output_name, "_", pvalue_cutoff, "_IDs_Pvalues.txt")
        write.table(output_df, file.path(output_folder, output_name, output_txt_filename), sep = "\t", row.names = FALSE, quote = FALSE)
        
        # Create histogram of p-values
        plot <- ggplot(data = NULL, aes(x = pvalues)) +
          geom_histogram(binwidth = 0.05, fill = "skyblue", color = "black") +
          labs(title = paste("Histogram of p-values (pvalue =", pvalue_cutoff, ")", sep = " "), x = "P-value", y = "Frequency") +
          theme_minimal()
        
        # File name for histogram
        histogram_output_filename <- paste0(output_name, "_", pvalue_cutoff, ".png")
        
        # Save the histogram to a PNG file
        ggsave(file.path(output_folder, output_name, histogram_output_filename), plot, width = 8, height = 6, dpi = 300)
      }
    }
  }, error = function(e) {
    # Handle errors during execution
    cat("Error with file:", file.path(genes_folder, paste0(base_name, ".txt")), "\n")
    cat("Error message:", conditionMessage(e), "\n")
  })
}

option_list <- list(
  make_option(c("--genes_folder"), type = "character", default = NULL, help = "Path to the genes folder. This folder should contain gene files in text format."),
  make_option(c("--universes_folder"), type = "character", default = NULL, help = "Path to the universes folder. This folder should contain universe files in text format."),
  make_option(c("--output_folder"), type = "character", default = NULL, help = "Path to the output folder where results will be saved."),
  make_option(c("--gsc_file"), type = "character", default = NULL, help = "Path to the GSC (Gene Set Collection) file. This file should contain GO terms and gene identifiers."),
  make_option(c("--pvalue_cutoff"), type = "numeric", default = 0.01, help = "P-value cutoff for the analysis. Default is 0.01."),
  make_option(c("--category_size"), type = "numeric", default = 5, help = "Category size for the summary. Default is 5.")
  make_option(c("--help", action = "store_true", default = FALSE, help = "Show this help message and exit.")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$genes_folder) || is.null(opt$universes_folder) || is.null(opt$output_folder) || is.null(opt$gsc_file)) {
  print_help(opt_parser)
  stop("Error: All required arguments must be provided.")
}

# Read the GSC file
gsc_file <- opt$gsc_file
data <- read.table(gsc_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
colnames(data) <- c("go", "evidence", "ids")

# Remove quotes from ID columns
data$ids <- gsub("\"", "", data$ids)
data$evidence <- str_trim(data$evidence)

goframeData <- data.frame(data$go, data$evidence, data$ids)
goFrame <- GOFrame(goframeData)
goAllFrame <- GOAllFrame(goFrame)
gsc <- GeneSetCollection(goAllFrame, setType = GOCollection())

print("GSC file created")

# List of gene files in the genes folder
gene_files <- list.files(opt$genes_folder, pattern = ".txt", full.names = TRUE)

# Iterate over gene files
for (gene_file in gene_files) {
  base_name <- basename(tools::file_path_sans_ext(gene_file))
  universe_file <- file.path(opt$universes_folder, paste0(base_name, ".txt"))
  process_files(base_name, opt$genes_folder, universe_file, opt$output_folder, opt$universes_folder, gsc, opt$pvalue_cutoff, opt$category_size)
}
