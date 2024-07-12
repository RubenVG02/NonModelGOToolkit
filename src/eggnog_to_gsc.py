def process_eggnog(file_path, output_file):
    '''
    Function to process the Eggnog output file to extract an annotation file
    that can be used in the enrichment analysis.

    Args:
    - file_path: Path to the Eggnog output file
    - output_file: Path to the annotation file in tab-separated format
    '''
    import os
    
    with open(file_path, 'r') as file:
        # Skip the first 4 lines of metadata or header
        for _ in range(4):
            next(file)
        

        lines = file.readlines()
    
    with open(output_file, 'w') as out_file:

        for line in lines:
            if line.startswith('#'):
                continue    # Skip header   
            parts = line.strip().split('\t')  
            if len(parts) < 2:
                continue  
            
            transcript_id = parts[0]
            go_terms = parts[9]
            

            if go_terms != '-':
                go_terms_list = go_terms.split(',') 
                
                # In the case of using electronic evidence, use IEA as evidence code
                for go_term in go_terms_list:
                    out_file.write(f'{go_term.strip()}\tIEA\t{transcript_id}\n')
    

#Example of usage: process_eggnog('sample_examples\eggnog_annotation_example.emapper.annotation', 'sample_examples\example_annot.txt')
