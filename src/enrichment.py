import pandas as pd
import subprocess
import tempfile
import os
from eggnog_to_gsc import process_eggnog

def select_files():
    '''
    Function to select the candidates, universe and background files for the enrichment analysis

    Returns:

    - candidates: List with the candidate transcripts 
    - universe: List with the universe transcripts 
    - background: DataFrame with the background transcripts 
    
    '''

    #if there are files in data folder
    if os.path.exists('data'):
        #get the files in the data folder
        files = os.listdir('data')
        if len(files) == 0:
            print('No files in the data folder')
            return None, None, None




def enrichment_analysis(candidates, universe, background):
    '''
    Function to perform the enrichment analysis

    Args:

    - candidates: List with the candidate transcripts 
    - universe: List with the universe transcripts 
    - background: DataFrame with the background transcripts 

    Returns:

    - results: DataFrame with the results of the enrichment analysis

    '''

    # Perform the enrichment analysis