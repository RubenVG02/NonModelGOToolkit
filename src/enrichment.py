import pandas as pd
import subprocess
import tempfile
import os

def select_files():
    '''
    Function to select the candidates, universe and background files for the enrichment analysis

    Returns:

    - candidates: List with the candidate transcripts 
    - universe: List with the universe transcripts 
    - background: DataFrame with the background transcripts 
    
    '''

    # Select the candidate file


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