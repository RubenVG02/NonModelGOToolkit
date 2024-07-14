# A treemap R script produced by the Revigo server at http://revigo.irb.hr/
# If you found Revigo useful in your work, please cite the following reference:
# Supek F et al. "REVIGO summarizes and visualizes long lists of Gene Ontology
# terms" PLoS ONE 2011. doi:10.1371/journal.pone.0021800

# author: Anton Kratz <anton.kratz@gmail.com>, RIKEN Omics Science Center, Functional Genomics Technology Team, Japan
# created: Fri, Nov 02, 2012  7:25:52 PM
# last change: Fri, Nov 09, 2012  3:20:01 PM

# -----------------------------------------------------------------------------
# If you don't have the treemap package installed, uncomment the following line:
# install.packages( "treemap" );
library(treemap) 								# treemap package by Martijn Tennekes

# Set the working directory if necessary
# setwd("C:/Users/username/workingdir");

# --------------------------------------------------------------------------
# Here is your data from Revigo. Scroll down for plot configuration options.

revigo.names <- c("term_ID","description","frequency","value","uniqueness","dispensability","representative");
revigo.data <- rbind(c("GO:0003735","structural constituent of ribosome",2.128498588986873,17.417117096372536,1,0,"structural constituent of ribosome"),
c("GO:0019843","rRNA binding",1.1153325776412018,3.187700808793338,0.7248105052897127,-0,"rRNA binding"),
c("GO:0003723","RNA binding",6.099813894661886,15.6547024908192,0.6866031660463722,0.3443017,"rRNA binding"),
c("GO:0003746","translation elongation factor activity",0.305002890945944,2.1906419285922536,0.7524976135556621,0.24405291,"rRNA binding"),
c("GO:1901363","heterocyclic compound binding",20.072278748835316,4.845982324898668,0.8430027324413142,0.07292911,"heterocyclic compound binding"),
c("GO:0097159","organic cyclic compound binding",39.22969739688024,3.2573011882519256,0.830878432193855,0.17508979,"heterocyclic compound binding"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$value <- as.numeric( as.character(stuff$value) );
stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="/Users/rubenvg/Desktop/NonModelGOToolkit-1/examples/output/bbb/bbb.candidates/results_revigo/bbb.candidates_0.01_IDs_Pvalues_MF_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "value",
  type = "categorical",
  vColor = "representative",
  title = "bbb.candidates_0.01_IDs_Pvalues MF TreeMap",
  inflate.labels = FALSE,      # set this to TRUE for space-filling group labels - good for posters
  lowerbound.cex.labels = 0,   # try to draw as many labels as possible (still, some small squares may not get a label)
  bg.labels = "#CCCCCCAA",   # define background color of group labels
								 # "#CCCCCC00" is fully transparent, "#CCCCCCAA" is semi-transparent grey, NA is opaque
  position.legend = "none", fontsize.labels = c(12,15), align.labels = list(c("left","top"),c("center","center")),
)

dev.off()

