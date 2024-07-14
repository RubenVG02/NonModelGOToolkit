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
revigo.data <- rbind(c("GO:0005737","cytoplasm",43.076660800468886,2.421761796101055,0.8888902750046057,0.08859538,"cytoplasm"),
c("GO:0022625","cytosolic large ribosomal subunit",1.014469728138433,12.113076227493746,0.33018935796424503,0,"cytosolic large ribosomal subunit"),
c("GO:0000322","storage vacuole",0.2661182824452727,3.996407586417781,0.8555104067946925,0.12655094,"cytosolic large ribosomal subunit"),
c("GO:0005852","eukaryotic translation initiation factor 3 complex",0.08561256229366826,2.840897860731786,0.6744908630409379,0.22333355,"cytosolic large ribosomal subunit"),
c("GO:0030687","preribosome, large subunit precursor",0.1323907395608457,4.0721192326205085,0.4963716015302116,0.53614612,"cytosolic large ribosomal subunit"),
c("GO:1990904","ribonucleoprotein complex",4.315842197772249,3.3638802864553807,0.6093677891596602,0.33654169,"cytosolic large ribosomal subunit"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$value <- as.numeric( as.character(stuff$value) );
stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="/Users/rubenvg/Desktop/NonModelGOToolkit-1/examples/output/aa/aa.candidates/results_revigo/aa.candidates_0.01_IDs_Pvalues_CC_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "value",
  type = "categorical",
  vColor = "representative",
  title = "aa.candidates_0.01_IDs_Pvalues CC TreeMap",
  inflate.labels = FALSE,      # set this to TRUE for space-filling group labels - good for posters
  lowerbound.cex.labels = 0,   # try to draw as many labels as possible (still, some small squares may not get a label)
  bg.labels = "#CCCCCCAA",   # define background color of group labels
								 # "#CCCCCC00" is fully transparent, "#CCCCCCAA" is semi-transparent grey, NA is opaque
  position.legend = "none", fontsize.labels = c(12,15), align.labels = list(c("left","top"),c("center","center")),
)

dev.off()

