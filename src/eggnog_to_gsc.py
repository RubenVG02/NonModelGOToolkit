def process_eggnog(file_path, output_file):
    '''
    Function to process the Eggnog output file to extract an annotation file
    that can be used in the enrichment analysis.

    Args:
    - file_path: Path to the Eggnog output file
    - output_file: Path to the annotation file in tab-separated format
    '''
    import os

    # Define the output file path
    output_file = file_path.replace('.annotation', '_annotations.tsv')
    
    with open(file_path, 'r') as file:
        # Skip the first 4 lines of metadata or header
        for _ in range(4):
            next(file)
        
        # Read the remaining lines
        lines = file.readlines()
    
    with open(output_file, 'w') as out_file:
        # Write header for the output file
        for line in lines:
            if line.startswith('#'):
                continue    # Skip header   
            parts = line.strip().split('\t')  # Assuming tab-separated values
            if len(parts) < 2:
                continue  # Skip lines that don't have enough columns
            
            transcript_id = parts[0]
            go_terms = parts[9]
            
            # Check if GO terms are present
            if go_terms != '-':
                # Split GO terms if they are separated by commas or other delimiters
                go_terms_list = go_terms.split(',')  # Change delimiter if needed
                
                # Write each GO term in a new line with the transcript ID and "IEA"
                for go_term in go_terms_list:
                    out_file.write(f'{go_term.strip()}\tIEA\t{transcript_id}\n')
    

#Example usage: process_eggnog('sample_examples\eggnog_annotation_example.emapper.annotation', 'filtered_annotations.annotation')
