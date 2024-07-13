import pandas as pd
import subprocess
import os
from eggnog_to_gsc import process_eggnog
import glob
from tkinter import Tk, filedialog
import shutil
import rpy2.robjects as robjects


def select_files():
    '''
    Function to select the candidates, universe and background files for the enrichment analysis. All files must contain the same ID format.

    Returns:

    - candidates: List with the candidate transcripts 
    - universe: List with the universe transcripts 
    - background: DataFrame with the background transcripts 
    '''
    candidates = []
    universe = []
    background = pd.DataFrame()

    # Ensure the 'data' directory exists
    if not os.path.exists('data'):
        os.makedirs('data')

    # Check if there are files in the data folder
    if os.path.exists('data'):
        # Get the files in the data folder
        files = os.listdir('data')
        if len(files) != 0:
            candidate_files = glob.glob('data/*_candidates.txt')
            universe_files = glob.glob('data/*_universe.txt')
            annotation_files = glob.glob('data/*.annotation')

            if candidate_files and universe_files and annotation_files:
                candidates = [line.strip() for line in open(candidate_files[0])]
                universe = [line.strip() for line in open(universe_files[0])]
                process_eggnog(annotation_files[0], 'data/background.txt')
                background = pd.read_csv('data/background.txt', sep='\t', header=None, names=['GO', 'Evidence', 'Transcript'])
                
                return candidates, universe, background

    # If the files are not found, open file dialog for user to select the files
    root = Tk()
    root.withdraw()  # Hide the root window

    candidate_file = filedialog.askopenfilename(title="Select candidates file", filetypes=[("Text files", "*.txt")])
    if candidate_file:
        shutil.copy(candidate_file, 'data/')
        candidates = [line.strip() for line in open(candidate_file)]

    universe_file = filedialog.askopenfilename(title="Select universe file", filetypes=[("Text files", "*.txt")])
    if universe_file:
        shutil.copy(universe_file, 'data/')
        universe = [line.strip() for line in open(universe_file)]

    annotation_file = filedialog.askopenfilename(title="Select annotation file", filetypes=[("Annotation files", "*.annotation")])
    if annotation_file:
        shutil.copy(annotation_file, 'data/') #Copy all used files to the data folder
        process_eggnog(annotation_file, 'data/background.txt')
        background = pd.read_csv('data/background.txt', sep='\t', header=None, names=['GO', 'Evidence', 'Transcript'])

    return candidates, universe, background



def enrichment_analysis():
    '''
    Function to perform the enrichment analysis

    Args:

    - pvalue: P-value threshold for the enrichment analysis
    - category_size: Minimum number of genes in a category to be considered in the analysis
    - output_dir: Directory to save the results of the analysis

    Returns:

    - results: DataFrame with the results of the enrichment analysis

    '''


    candidates, universe, background = select_files()

    parameters = {}

    with open('params.txt', 'r') as file:
        for line in file:
            key, value = line.strip().split('=', 1)
            parameters[key] = value
    
    print(parameters)

    command = [
    "Rscript", "src\R_enrichment.R",
    "--genes_ids", candidates,
    "--universe_ids", universe,
    "--output_folder", "output",
    "--annotation_df", background,
    "--pvalue_cutoff", 0.01,
    "--category_size", 5,
]
    try:
        subprocess.call(command, shell=True)
    except subprocess.CalledProcessError as e:
        print(e)
        return None
    


enrichment_analysis()


