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
revigo.data <- rbind(c("GO:0003735","structural constituent of ribosome",2.128498588986873,2.3063453870079487,1,-0,"structural constituent of ribosome"),
c("GO:0003955","NAD(P)H dehydrogenase (quinone) activity",0.32041890398799755,5.946673441464065,0.7400056158989043,0.03782958,"NAD(P)H dehydrogenase (quinone) activity"),
c("GO:0016765","transferase activity, transferring alkyl or aryl (other than methyl) groups",0.9927517685284755,14.124351859826227,0.9772580570277989,0,"transferase activity, transferring alkyl or aryl (other than methyl) groups"),
c("GO:0016846","carbon-sulfur lyase activity",0.2130833609374284,2.6890263909525376,0.9794484639599235,0.03639583,"carbon-sulfur lyase activity"),
c("GO:0019843","rRNA binding",1.1153325776412018,6.900720816804705,0.835202566885766,0.05274861,"rRNA binding"),
c("GO:0003723","RNA binding",6.099813894661886,2.125599608641549,0.8072398915118998,0.3443017,"rRNA binding"),
c("GO:0003743","translation initiation factor activity",0.37315089336372126,2.506156090153474,0.7572032240364351,0.24893209,"rRNA binding"),
c("GO:0051540","metal cluster binding",1.944298077570841,12.725269847452662,0.8954228081211022,-0,"metal cluster binding"),
c("GO:0051539","4 iron, 4 sulfur cluster binding",1.062682635515558,2.054019641899559,0.9024681871410898,0.15455964,"metal cluster binding"),
c("GO:1901363","heterocyclic compound binding",20.072278748835316,2.125599608641549,0.8620729997677683,0.23645146,"metal cluster binding"),
c("GO:0097159","organic cyclic compound binding",39.22969739688024,2.0791220405935267,0.8960665321996599,0.09126372,"organic cyclic compound binding"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$value <- as.numeric( as.character(stuff$value) );
stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="/Users/rubenvg/Desktop/NonModelGOToolkit-1/examples/output/aa/aa.candidates/results_revigo/aa.candidates_0.01_IDs_Pvalues_MF_treemap.pdf", width=16, height=9 ) # width and height are in inches

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

