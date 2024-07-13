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
revigo.data <- rbind(c("GO:0004252","serine-type endopeptidase activity",0.881063286237177,2.1292777084679,0.9827718032827208,-0,"serine-type endopeptidase activity"),
c("GO:0004497","monooxygenase activity",1.3240297369392198,2.1056655927710057,0.9827718032827208,0.04325761,"monooxygenase activity"),
c("GO:0005041","low-density lipoprotein particle receptor activity",0.00904515494800577,5.544598944436708,1,-0,"low-density lipoprotein particle receptor activity"),
c("GO:0017080","sodium channel regulator activity",0.02598458584965227,6.6023331374047505,1,0,"sodium channel regulator activity"),
c("GO:0042302","structural constituent of cuticle",0.05498274501980953,2.1460872669792286,0.8403047172953938,-0,"structural constituent of cuticle"),
c("GO:0008010","structural constituent of chitin-based larval cuticle",0.017828645693053785,2.187858423030374,0.8403047172953938,0.4165932,"structural constituent of cuticle"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$value <- as.numeric( as.character(stuff$value) );
stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="c:\Users\ASUS\Desktop\NonModelGOToolkit\NonModelGOToolkit\output\aa.candidates\results_revigo\aa.candidates_0.01_IDs_Pvalues_MF_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "value",
  type = "categorical",
  vColor = "representative",
  title = "aa.candidates_0.01_IDs_Pvalues MF TreeMap",
  inflate.labels = FALSE,      # set this to TRUE for space-filling group labels - good for posters
  lowerbound.cex.labels = 0,   # try to draw as many labels as possible (still, some small squares may not get a label)
  bg.labels = "#CCCCCCAA",   # define background color of group labels
								 # "#CCCCCC00" is fully transparent, "#CCCCCCAA" is semi-transparent grey, NA is opaque
  position.legend = "none", fontsize.labels = c(12,15), align.labels = list(c("left","top"),c("center","center")),
)

dev.off()

