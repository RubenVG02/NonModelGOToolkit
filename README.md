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

All input files must be placed in their respective subfolders within the data folder. The universe and candidates files must have the same base name. Candidates files should be named with the extension `*.candidates.txt`, universe files with `*.universe.txt`, and eggNOG-mapper annotation files with `*.annotation*`.

### Enrichment Procedure
Once all files are created with the correct format, modify the parameters of the enrichment by using the `params.json` file. To proceed with the encrichment, use the following command:

```bash
python3 src/main.py
```

The pipeline includes:
   - **GO enrichment of the candidate transcripts using Biological process (BP), Cellular Components (CC), and Molecular Functions (MF) ontologies**
   - **Grouping the enriched terms form 3 ontologies using the REVIGO API, obtaining 2D scatterplots and treemaps**
   - **3D representation of the enriched GO terms**

Example outputs and data can be found in the `examples` folder.


## Installation

Via Git Clone:
```bash
git clone https://github.com/RubenVG02/NonModelGOToolkit.git
```

Via Lastest Release:

```bash
https://github.com/RubenVG02/NonModelGOToolkit/releases
```

To use this project, you need to have Python 3.7 or higher installed.


To install the required libraries, use:

```bash
pip install requirements.txt
```


## Authors

- [@RubenVG02](https://www.github.com/RubenVG02)

## Features

- Automated GO enrichment pipeline
- 2D and 3D visualization of the results
- Interactive visualization of the outputs
- Fast and easy to use

## License

[MIT](https://choosealicense.com/licenses/mit/)

## How to cite?

```bash
RubenVG02. (2024). *NonModelGOToolkit*. https://github.com/RubenVG02/NonModelGOToolkit
```




