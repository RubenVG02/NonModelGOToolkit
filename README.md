# NonModelGOToolkit: Non-model species Gene Ontology enrichment analysis pipeline

## Overview

This project provides an automated comprehensive pipeline for conducting Gene Ontology (GO) enrichment analysis on a set of candidate genes. By leveraging functional annotations from transcriptome data, the pipeline identifies enriched GO terms across Biological Processes (BP), Cellular Components (CC), and Molecular Functions (MF). It incorporates tools in both R and Python to generate 2D treemaps and interactive 3D visualizations for an intuitive representation of the GO terms.

## Usage

### Preparing Data

1. **Candidate Transcripts**: A list of candidate transcripts or genes in txt format. These transcripts will be used for the enrichment analysis

2. **Universe Transcripts**: A list of universe transcripts in txt format. Universe transcripts are used to determine the statistical significance of the enrichment by comparing the candidate transcripts to the total pool of transcripts. 

3. **Background**: a tab-separated txt file containing the relationship between transcripts and GO terms obtained from the species transcriptome. The background can be directly processed from `eggNOG-mapper` output by using the `process_eggnog` function.
   The required format of the background file contains 3 type of data:
   - **GO terms**: GO terms from each annotated transcript.
   - **Evidence code**: Methodology used to determine the GO terms. By default, IEA (electronic).
   - **Transcript ID**: Annotated transcripts from the annotation procedure.
