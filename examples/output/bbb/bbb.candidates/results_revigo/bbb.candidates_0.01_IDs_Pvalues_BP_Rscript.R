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
revigo.data <- rbind(c("GO:0002181","cytoplasmic translation",0.3974763229665376,17.14274818234325,0.5164752700491048,0,"cytoplasmic translation"),
c("GO:0002182","cytoplasmic translational elongation",0.009651922492400466,4.4285476623748155,0.6301040263110808,0.40463405,"cytoplasmic translation"),
c("GO:0009067","aspartate family amino acid biosynthetic process",0.7567688912721283,2.212843943007506,0.5976722519376751,0.32334479,"cytoplasmic translation"),
c("GO:0010467","gene expression",12.663260691525247,4.138339328135457,0.4805618916947253,0.45657675,"cytoplasmic translation"),
c("GO:0019538","protein metabolic process",14.600987650961638,3.304756031450534,0.5814010917657237,0.25311126,"cytoplasmic translation"),
c("GO:0043043","peptide biosynthetic process",4.592791896959665,12.285368524645675,0.4486401026509288,0.64900656,"cytoplasmic translation"),
c("GO:0043603","amide metabolic process",6.707376287050344,11.79550256030971,0.7467108711500258,0.13247309,"cytoplasmic translation"),
c("GO:0044237","cellular metabolic process",46.10331480933213,2.503313577130516,0.7803212979260934,0.13458491,"cytoplasmic translation"),
c("GO:0044271","cellular nitrogen compound biosynthetic process",12.957025677761646,5.19493801069893,0.5190400599529365,0.27730588,"cytoplasmic translation"),
c("GO:1901576","organic substance biosynthetic process",28.21764434528959,3.2318278568551717,0.5334216187336361,0.53115188,"cytoplasmic translation"),
c("GO:0042254","ribosome biogenesis",2.136224808753416,2.515962051932293,0.8566775221218071,0.01124266,"ribosome biogenesis"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$value <- as.numeric( as.character(stuff$value) );
stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="/Users/rubenvg/Desktop/NonModelGOToolkit-1/examples/output/bbb/bbb.candidates/results_revigo/bbb.candidates_0.01_IDs_Pvalues_BP_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "value",
  type = "categorical",
  vColor = "representative",
  title = "bbb.candidates_0.01_IDs_Pvalues BP TreeMap",
  inflate.labels = FALSE,      # set this to TRUE for space-filling group labels - good for posters
  lowerbound.cex.labels = 0,   # try to draw as many labels as possible (still, some small squares may not get a label)
  bg.labels = "#CCCCCCAA",   # define background color of group labels
								 # "#CCCCCC00" is fully transparent, "#CCCCCCAA" is semi-transparent grey, NA is opaque
  position.legend = "none", fontsize.labels = c(12,15), align.labels = list(c("left","top"),c("center","center")),
)

dev.off()

