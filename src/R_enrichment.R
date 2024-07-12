# Define una función para cargar las bibliotecas necesarias
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

# Define las opciones de línea de comandos
if (!require("optparse")) install.packages("optparse", repos="http://R-Forge.R-project.org")
library(optparse)
option_list <- list(
  make_option(c("--genes_folder"), type = "character", default = NULL, help = "Path to the genes folder. This folder should contain gene files in text format."),
  make_option(c("--universes_folder"), type = "character", default = NULL, help = "Path to the universes folder. This folder should contain universe files in text format."),
  make_option(c("--output_folder"), type = "character", default = NULL, help = "Path to the output folder where results will be saved."),
  make_option(c("--gsc_file"), type = "character", default = NULL, help = "Path to the GSC (Gene Set Collection) file. This file should contain GO terms and gene identifiers, obtained from the transcriptome annotation."),
  make_option(c("--pvalue_cutoff"), type = "numeric", default = 0.01, help = "P-value cutoff for the analysis. Default is 0.01."),
  make_option(c("--category_size"), type = "numeric", default = 5, help = "Category size for the summary. Default is 5."),
  make_option(c("--help"), action = "store_true", default = FALSE, help = "Show this help message and exit.")
)

# Analiza los argumentos de línea de comandos
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Si se solicita ayuda o faltan argumentos obligatorios, muestra la ayuda y espera la entrada del usuario
if (opt$help || is.null(opt$genes_folder) || is.null(opt$universes_folder) || is.null(opt$output_folder) || is.null(opt$gsc_file)) {
  print_help(opt_parser)
  
  # Función para esperar que el usuario presione una tecla
  cat("Press [Enter] to exit...")
  readline()
  
  quit("no")
}

# Carga las bibliotecas necesarias después de la validación
load_required_libraries()

# Función para procesar archivos según el patrón del nombre
process_files <- function(base_name, genes_folder, universe_file, output_folder, universe_folder, gsc, pvalue_cutoff, category_size) {
  genes_file_path <- file.path(genes_folder, paste0(base_name, ".txt"))
  print(genes_file_path)
  
  universe_file_path <- file.path(universe_folder, paste0(base_name, ".txt"))
  print(universe_file_path)
  
  # Lee los archivos de genes y universos
  genes <- readLines(genes_file_path)
  universe <- readLines(universe_file_path)
  
  # Convierte el universo en una lista
  universe <- unlist(strsplit(universe, "\n"))
  universe <- universe[universe != ""]
  
  output_name <- base_name
  
  # Define los valores de corte de p-valor
  pvalue_cutoffs <- c(pvalue_cutoff)
  
  tryCatch({
    # Recorre cada valor de corte de p-valor
    for (pvalue_cutoff in pvalue_cutoffs) {
      
      # Lista para almacenar resultados para cada ontología
      results_list <- list()
      
      # Ontologías a procesar
      ontologies <- c("BP", "MF", "CC")
      
      # Recorre cada ontología
      for (ontology in ontologies) {
        # Realiza el análisis para la ontología actual
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
          
          results_list[[ontology]] <- summary(Over, categorySize = category_size) # Usa category_size
          
        }, error = function(e) {
          # Maneja errores en el resumen
          cat("Error in summary for ontology", ontology, "\n")
          cat("Error message:", conditionMessage(e), "\n")
        })
      }
      
      # Combina resultados en un solo dataframe por ontología
      combined_results <- bind_rows(results_list, .id = "Ontology")
      
      # Verifica si hay resultados en alguna ontología
      if (any(sapply(results_list, nrow) > 0)) {
        print("Combined results")
        
        # Crea la carpeta de salida si no existe
        dir.create(file.path(output_folder, output_name), showWarnings = FALSE, recursive = TRUE)
        output_folder_final <- file.path(output_folder, output_name)
        
        # Nombre del archivo para los resultados combinados
        combined_output_filename <- paste0(output_name, "_", pvalue_cutoff, ".txt")
        
        # Escribe los resultados combinados en un archivo
        write.table(combined_results, file.path(output_folder, output_name, combined_output_filename), sep = "\t", row.names = FALSE, quote = FALSE)
        
        # Lee el archivo combinado para extraer IDs y p-valores
        combined_data <- read.table(file.path(output_folder, output_name, combined_output_filename), header = TRUE, sep = "\t", stringsAsFactors = FALSE)
        
        # Filtra IDs no-NA de las columnas GOBPID, GOCCID y GOMFID
        filtered_ids <- na.omit(c(combined_data$GOBPID, combined_data$GOCCID, combined_data$GOMFID))
        
        # Crea un vector de p-valores
        pvalues <- combined_data$Pvalue
        
        # Crea un dataframe con GOs y p-valores
        output_df <- data.frame(GOs = filtered_ids, Pvalues = pvalues)
        
        # Escribe el dataframe en un archivo txt
        output_txt_filename <- paste0(output_name, "_", pvalue_cutoff, "_IDs_Pvalues.txt")
        write.table(output_df, file.path(output_folder, output_name, output_txt_filename), sep = "\t", row.names = FALSE, quote = FALSE)
        
        # Crea un histograma de p-valores
        plot <- ggplot(data = NULL, aes(x = pvalues)) +
          geom_histogram(binwidth = 0.05, fill = "skyblue", color = "black") +
          labs(title = paste("Histogram of p-values (pvalue =", pvalue_cutoff, ")", sep = " "), x = "P-value", y = "Frequency") +
          theme_minimal()
        
        # Nombre del archivo para el histograma
        histogram_output_filename <- paste0(output_name, "_", pvalue_cutoff, ".png")
        
        # Guarda el histograma en un archivo PNG
        ggsave(file.path(output_folder, output_name, histogram_output_filename), plot, width = 8, height = 6, dpi = 300)
      }
    }
  }, error = function(e) {
    # Maneja errores durante la ejecución
    cat("Error with file:", file.path(genes_folder, paste0(base_name, ".txt")), "\n")
    cat("Error message:", conditionMessage(e), "\n")
  })
}

# Lee el archivo GSC
gsc_file <- opt$gsc_file
data <- read.table(gsc_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
colnames(data) <- c("go", "evidence", "ids")

# Elimina las comillas de las columnas de ID
data$ids <- gsub("\"", "", data$ids)
data$evidence <- str_trim(data$evidence)

goframeData <- data.frame(data$go, data$evidence, data$ids)
goFrame <- GOFrame(goframeData)
goAllFrame <- GOAllFrame(goFrame)
gsc <- GeneSetCollection(goAllFrame, setType = GOCollection())

print("GSC file created")

# Lista de archivos de genes en la carpeta de genes
gene_files <- list.files(opt$genes_folder, pattern = ".txt", full.names = TRUE)

# Itera sobre archivos de genes
for (gene_file in gene_files) {
  base_name <- basename(tools::file_path_sans_ext(gene_file))
  universe_file <- file.path(opt$universes_folder, paste0(base_name, ".txt"))
  process_files(base_name, opt$genes_folder, universe_file, opt$output_folder, opt$universes_folder, gsc, opt$pvalue_cutoff, opt$category_size)
}
