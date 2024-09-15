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
revigo.data <- rbind(c("GO:0022625","cytosolic large ribosomal subunit",0.6422496099261846,12.113076227493746,0.34085524602774525,0,"cytosolic large ribosomal subunit"),
c("GO:0000322","storage vacuole",0.1778201926099983,3.996407586417781,0.8428127851699823,0.12770953,"cytosolic large ribosomal subunit"),
c("GO:0005737","cytoplasm",36.38509412593251,2.421761796101055,0.8619152465722402,0.10701902,"cytosolic large ribosomal subunit"),
c("GO:0005852","eukaryotic translation initiation factor 3 complex",0.09985555503264143,2.840897860731786,0.6456414810665522,0.23478132,"cytosolic large ribosomal subunit"),
c("GO:0030687","preribosome, large subunit precursor",0.10178817133005495,4.0721192326205085,0.5094292084898253,0.50042336,"cytosolic large ribosomal subunit"),
c("GO:1990904","ribonucleoprotein complex",4.396406893146647,3.3638802864553807,0.592507283898729,0.34351463,"cytosolic large ribosomal subunit"));

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

