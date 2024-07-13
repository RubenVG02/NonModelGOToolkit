import os
import requests
import time
import json
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import json
import plotly.graph_objects as go
import csv 
from concurrent.futures import ThreadPoolExecutor

def process_file(file_path, ns):
    with open(file_path, 'r') as file:
        userData = file.read()

    namespace_names = {1: 'BP', 2: 'CC', 3: 'MF'}

    payload = {'cutoff': '0.7', 'valueType': 'pvalue', 'speciesTaxon': '0', 'measure': 'SIMREL', 'goList': userData}
    r = requests.post("http://revigo.irb.hr/StartJob", data=payload)
    jobid = r.json()['jobid']
    print("Job submitted with ID", jobid, "for namespace", namespace_names[ns])

    running = 1
    while running != 0:
        r = requests.get("http://revigo.irb.hr/QueryJob", params={'jobid': jobid, 'type': 'jstatus'})
        running = r.json()['running']
        time.sleep(1)

    r_table = requests.get("http://revigo.irb.hr/QueryJob", params={'jobid': jobid, 'type': 'table', 'namespace': ns})
    r_scatterplot = requests.get("http://revigo.irb.hr/QueryJob", params={'jobid': jobid, 'type': 'scatterPlot', 'namespace': ns})
    r_jTreeMap = requests.get("http://revigo.irb.hr/QueryJob", params={'jobid': jobid, 'type': 'TreeMap', 'namespace': ns})
    r_Rscript = requests.get("http://revigo.irb.hr/QueryJob", params={'jobid': jobid, 'type': 'RTreeMap', 'namespace': ns})

    if "error" in r_table.text or "error" in r_scatterplot.text or "error" in r_jTreeMap.text:
        print("Error occurred while fetching results for namespace", namespace_names[ns])
        return

    output_folder = os.path.join(os.path.dirname(file_path), "results_revigo")
    graphics_folder = os.path.join(output_folder, "obtained_graphics")
    os.makedirs(graphics_folder, exist_ok=True)

    file_name = os.path.splitext(os.path.basename(file_path))[0]
    graphic_name = file_name.split('_')
    graphic_name = graphic_name[0] + ' ' + graphic_name[1] + ' ' + graphic_name[2]
    namespace_name = namespace_names[ns]
    
    output_file_table = os.path.join(output_folder, f"{file_name}_{namespace_name}_table.tsv")
    output_file_jTreeMap = os.path.join(output_folder, f"{file_name}_{namespace_name}_TreeMap.tsv")
    output_file_scatterplot = os.path.join(output_folder, f"{file_name}_{namespace_name}_scatterPlot.tsv")
    output_file_Rscript = os.path.join(output_folder, f"{file_name}_{namespace_name}_Rscript.R")
    print(output_file_Rscript)

    with open(output_file_table, 'w') as f:
        f.write(r_table.text)
        print("Table results written to", output_file_table)
    with open(output_file_jTreeMap, 'w') as f:
        f.write(r_jTreeMap.text)    
        print("jTreeMap results written to", output_file_jTreeMap)
    with open(output_file_scatterplot, 'w') as f:
        f.write(r_scatterplot.text)
        print("Scatterplot results written to", output_file_scatterplot)
    pdf_destination = os.path.join(output_folder, f"{file_name}_{namespace_name}_treemap.pdf")
    with open(output_file_Rscript, 'w') as f:
        script_content = r_Rscript.text.replace('pdf( file="revigo_treemap.pdf", width=16, height=9 )',
                                                f'pdf( file="{pdf_destination}", width=16, height=9 )')
        script_content = script_content.replace('title = "Revigo TreeMap"', f'title = "{file_name} {namespace_name} TreeMap"')
        script_content = script_content.replace ('position.legend = "none"', 'position.legend = "none", fontsize.labels = c(12,15), align.labels = list(c("left","top"),c("center","center")),')
        f.write(script_content)
        print("Rscript results written to", output_file_Rscript)

    os.system(f"Rscript {output_file_Rscript}")
    print("Treemap created and saved.")

    with open(output_file_scatterplot, 'r') as tsv_file:
        scatterplot_data = pd.read_csv(tsv_file, sep='\t')

    scatterplot_data = scatterplot_data.dropna(subset=['PC_0', 'PC_1'])
    
    x_values = scatterplot_data['PC_0']
    y_values = scatterplot_data['PC_1']
    log_size = scatterplot_data['LogSize']
    term = scatterplot_data['TermID']

    plt.scatter(x_values, y_values, s=abs(log_size*30), c='blue', edgecolors='black', alpha=0.6, linewidth=0.5)
    plt.xlabel('Semantic Space X')
    plt.ylabel('Semantic Space Y')
    plt.title(f'{graphic_name} {namespace_name} PC_0 vs PC_1')
    plt.savefig(os.path.join(graphics_folder, f"{file_name}_{namespace_name}_scatterplot.png"))
    plt.close()
    print("Scatterplot created and saved.")

    with open(output_file_jTreeMap, encoding='utf-8') as inputfile:
        data = json.load(inputfile)
        json_to_csv(output_file_jTreeMap, f'{output_file_jTreeMap}.csv')

def json_to_csv(json_file, csv_file):
    with open(json_file) as json_file:
        data = json.load(json_file)

    employee_data = data['children']

    with open(csv_file, 'w', newline='') as data_file:
        csv_writer = csv.writer(data_file)
        count = 0
        for emp in employee_data:
            if count == 0:
                header = emp.keys()
                csv_writer.writerow(header)
                count += 1
            csv_writer.writerow(emp.values())

def create_treemap_from_csv(csv_file, output_file):
    sizes = []
    labels = []
    parents = []
    values = []

    print("Reading CSV...")

    with open(csv_file, 'r') as f:
        csv_reader = csv.DictReader(f)
        for row in csv_reader:
            labels.append(row['name'])
            parents.append("")
            values.append(0)
            sizes.append(1)

    fig = go.Figure(go.Treemap(
        labels=labels,
        parents=parents,
        values=sizes,
        textinfo="label+value+percent root",
        marker=dict(
            colorscale="Viridis",
            cmid=0,
            showscale=True
        )
    ))

    fig.update_layout(title_text="Treemap Title")

    fig.write_image(output_file)

    print("Treemap created and saved.")

def make_request(file_path):
    process_file(file_path, 1)
    process_file(file_path, 2)
    process_file(file_path, 3)

def main():
    input_folder = "output"
    
    files_to_process = []
    for root, dirs, files in os.walk(input_folder):
        for file in files:
            if file.endswith('IDs_Pvalues.txt'):
                file_path = os.path.join(root, file)
                files_to_process.append(file_path)

    with ThreadPoolExecutor(max_workers=3) as executor:
        executor.map(make_request, files_to_process)

if __name__ == "__main__":
    main()
