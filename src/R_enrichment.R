load_required_libraries <- function() {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  library(BiocManager)
  
  required_packages <- c("dplyr", "GOstats", "AnnotationDbi", "GSEABase", "qvalue", "ggplot2", "stringr")
  
  install_if_missing <- function(package) {
    if (!require(package, character.only = TRUE)) {
      if (package %in% c("GOstats", "AnnotationDbi", "GSEABase", "qvalue")) {
        BiocManager::install(package)
      } else {
        install.packages(package, dependencies = TRUE)
      }
      library(package, character.only = TRUE)
    }
  }
  
  invisible(lapply(required_packages, install_if_missing))
}

if (!require("optparse")) install.packages("optparse", repos="http://R-Forge.R-project.org")
library(optparse)
option_list <- list(
  make_option(c("--candidates_ids"), type = "character", default = NULL, help = "Path to the genes file. This file should contain gene identifiers in text format."),
  make_option(c("--universe_ids"), type = "character", default = NULL, help = "Path to the universe file. This file should contain universe gene identifiers in text format."),
  make_option(c("--output_folder"), type = "character", default = NULL, help = "Path to the output folder where results will be saved."),
  make_option(c("--annotation_df"), type = "character", default = NULL, help = "Path to the GSC (Gene Set Collection) file. This file should contain GO terms and gene identifiers, obtained from the transcriptome annotation."),
  make_option(c("--pvalue_cutoff"), type = "numeric", default = 0.01, help = "P-value cutoff for the analysis. Default is 0.01."),
  make_option(c("--category_size"), type = "numeric", default = 5, help = "Category size for the summary. Default is 5."),
  make_option(c("--help"), action = "store_true", default = FALSE, help = "Show this help message and exit.")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (opt$help || is.null(opt$candidates_ids) || is.null(opt$universe_ids) || is.null(opt$output_folder) || is.null(opt$annotation_df)) {
  print_help(opt_parser)
  cat("Press [Enter] to exit...")
  readline()
  quit("no")
}

load_required_libraries()

process_files <- function(candidates_ids, universe_ids, output_folder, gsc, pvalue_cutoffs, category_size) {
  base_name <- basename(tools::file_path_sans_ext(candidates_ids))
  genes <- readLines(candidates_ids)
  universe <- readLines(universe_ids)
  universe <- unlist(strsplit(universe, "\n"))
  universe <- universe[universe != ""]
  output_name <- base_name
  
  tryCatch({
    for (pvalue_cutoff in pvalue_cutoffs) {
      results_list <- list()
      ontologies <- c("BP", "MF", "CC")
      
      for (ontology in ontologies) {
        tryCatch({
          params <- GSEAGOHyperGParams(
            name = paste("My Custom GSEA based annot Params -", ontology),
            geneSetCollection = gsc,
            geneIds = genes,
            universeGeneIds = universe,
            ontology = ontology,
            pvalueCutoff = as.numeric(pvalue_cutoff),
            conditional = TRUE,
            testDirection = "over"
          )
          
          Over <- hyperGTest(params)
          results_list[[ontology]] <- summary(Over, categorySize = category_size)
        }, error = function(e) {
          cat("Error in summary for ontology", ontology, "\n")
          cat("Error message:", conditionMessage(e), "\n")
        })
      }
      
      combined_results <- bind_rows(results_list, .id = "Ontology")
      
      if (any(sapply(results_list, nrow) > 0)) {
        dir.create(file.path(output_folder, output_name), showWarnings = FALSE, recursive = TRUE)
        output_folder_final <- file.path(output_folder, output_name)
        combined_output_filename <- paste0(output_name, "_", pvalue_cutoff, ".txt")
        write.table(combined_results, file.path(output_folder, output_name, combined_output_filename), sep = "\t", row.names = FALSE, quote = FALSE)
        combined_data <- read.table(file.path(output_folder, output_name, combined_output_filename), header = TRUE, sep = "\t", stringsAsFactors = FALSE)
        filtered_ids <- na.omit(c(combined_data$GOBPID, combined_data$GOCCID, combined_data$GOMFID))
        pvalues <- combined_data$Pvalue
        output_df <- data.frame(GOs = filtered_ids, Pvalues = pvalues)
        output_txt_filename <- paste0(output_name, "_", pvalue_cutoff, "_IDs_Pvalues.txt")
        write.table(output_df, file.path(output_folder, output_name, output_txt_filename), sep = "\t", row.names = FALSE, quote = FALSE)
        plot <- ggplot(data = NULL, aes(x = pvalues)) +
          geom_histogram(binwidth = as.numeric(pvalue_cutoff), fill = "skyblue", color = "black") +
          labs(title = paste("Histogram of p-values (pvalue =", pvalue_cutoff, ")", sep = " "), x = "P-value", y = "Frequency") +
          theme_minimal()
        histogram_output_filename <- paste0(output_name, "_", pvalue_cutoff, ".png")
        ggsave(file.path(output_folder, output_name, histogram_output_filename), plot, width = 8, height = 6, dpi = 300)
      }
    }
  }, error = function(e) {
    cat("Error with file:", candidates_ids, "\n")
    cat("Error message:", conditionMessage(e), "\n")
  })
}

gsc <- opt$annotation_df
data <- read.table(gsc, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
colnames(data) <- c("go", "evidence", "ids")
data$ids <- gsub("\"", "", data$ids)
data$evidence <- str_trim(data$evidence)
goframeData <- data.frame(data$go, data$evidence, data$ids)
goFrame <- GOFrame(goframeData)
goAllFrame <- GOAllFrame(goFrame)
gsc <- GeneSetCollection(goAllFrame, setType = GOCollection())

pvalue_cutoffs <- strsplit(opt$pvalue_cutoff, ",")[[1]]
process_files(opt$candidates_ids, opt$universe_ids, opt$output_folder, gsc, pvalue_cutoffs, opt$category_size)
