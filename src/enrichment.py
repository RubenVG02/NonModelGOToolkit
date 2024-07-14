import os
import pandas as pd
from eggnog_to_gsc import process_eggnog
from tkinter import Tk, filedialog
import shutil
import glob
import json

def select_files():
    '''
    Function to select the candidates, universe, and background files for the enrichment analysis. 
    All files must contain the same ID format.

    Returns:

    - grouped_files: Dictionary with basenames as keys and sub-dictionaries as values. 
      Each sub-dictionary contains paths for 'candidates' and 'universe' files.
    - background: DataFrame with the background transcripts 
    '''
    grouped_files = {}
    background = pd.DataFrame()

    # Ensure the 'data' directory exists
    if not os.path.exists('data'):
        os.makedirs('data')

    if os.path.exists('data') and len(os.listdir('data')) != 0:
        candidate_files = glob.glob('data/candidates/*.candidates.txt')
        universe_files = glob.glob('data/universe/*.universe.txt')
        annotation_files = glob.glob('data/annotation/*.annotation*')

        if candidate_files and universe_files and annotation_files:
            for file in candidate_files:
                basename = os.path.basename(file).replace('.candidates.txt', '')
                if basename not in grouped_files:
                    grouped_files[basename] = {'candidates': [], 'universe': []}
                grouped_files[basename]['candidates'].append(file)
            
            for file in universe_files:
                basename = os.path.basename(file).replace('.universe.txt', '')
                if basename not in grouped_files:
                    grouped_files[basename] = {'candidates': [], 'universe': []}
                grouped_files[basename]['universe'].append(file)

            # Process the annotation file
            print(f"Performing Background Filtering from {annotation_files[0]}...")
            process_eggnog(annotation_files[0], 'data/annotation/background.txt')
            background = pd.read_csv('data/annotation/background.txt', sep='\t', header=None, names=['GO', 'Evidence', 'Transcript'])
            
            return grouped_files, background
        

    # If the files are not found, open file dialog for user to select the files
    root = Tk()
    root.withdraw()  

    group_file = {}

    candidate_file = filedialog.askopenfilename(title="Select candidates file", filetypes=[("Text files", "*.txt")])
    if candidate_file:
        shutil.copy(candidate_file, 'data/candidates/')


    universe_file = filedialog.askopenfilename(title="Select universe file", filetypes=[("Text files", "*.txt")])
    if universe_file:
        shutil.copy(universe_file, 'data/universe/')

    annotation_file = filedialog.askopenfilename(title="Select annotation file", filetypes=[("Annotation files", "*.annotation")])
    if annotation_file:
        shutil.copy(annotation_file, 'data/annotation/') 
        print(f"Performing Background Filtering from {annotation_file}...")
        process_eggnog(annotation_file, 'data/annotation/background.txt')
        background = pd.read_csv('data/annotation/background.txt', sep='\t', header=None, names=['GO', 'Evidence', 'Transcript'])

    group_file["selected"] = {'candidates': [candidate_file], 'universe': [universe_file]}

    return group_file, background

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
    # Assuming select_files() returns the file paths for candidates, universe, and background
    grouped_files, background =select_files()

    parameters = {}
    with open('params.json', 'r') as file:
        parameters = json.load(file)

        
    for group, files in grouped_files.items():
        for candidate_file, universe_file in zip(files['candidates'], files['universe']):
            output_folder = os.path.join(parameters["output_folder"], group)
            os.makedirs(output_folder, exist_ok=True)
            print(f"Performing enrichment analysis for {group} with candidates {candidate_file} and universe {universe_file}...")
            background = r"data/annotation/background.txt"

            os.system(f"Rscript src/R_enrichment.R --candidates_ids {candidate_file} --universe_ids {universe_file} --output_folder {output_folder} --annotation_df {background} --pvalue_cutoff {parameters['pvalue_cutoff']} --category_size {parameters['category_size']}")

