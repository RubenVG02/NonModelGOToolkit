from revigo_plotting import main as revigo_main
from enrichment import enrichment_analysis

import os
def main():
    enrichment_analysis()
    revigo_main()
    os.system(f"Rscript src/3D_treemap.R")

    