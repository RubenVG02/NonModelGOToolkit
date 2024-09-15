import os
import pandas as pd
import matplotlib.pyplot as plt
import plotly.graph_objs as go
import plotly.io as pio

def wrap_labels(label, max_words=4):
    words = label.split()
    if len(words) > max_words:
        label = "\n".join([" ".join(words[i:i+max_words]) for i in range(0, len(words), max_words)])
    return label

def create_individual_barplot(df, title, filename, color):
    df['WrappedName'] = df['Name'].apply(wrap_labels)
    df_sorted = df.sort_values(by='Value', key=abs)

    # Create the static plot with matplotlib
    plt.figure(figsize=(14, 12))
    bars = plt.barh(df_sorted['WrappedName'], abs(df_sorted['Value']), color=color, height=0.6)
    for bar in bars:
        width = bar.get_width()
        plt.text(width + 0.5 if width > 0 else width - 0.5, 
                 bar.get_y() + bar.get_height() / 2, 
                 f'{width:.2f}', 
                 va='center', 
                 ha='right' if width > 0 else 'left', 
                 fontsize=8)
    plt.xlabel('Value')
    plt.title(title)
    plt.yticks(fontsize=6)
    plt.xticks(fontsize=10)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.savefig(filename)
    plt.close()

    # Create an interactive plot with plotly
    fig = go.Figure()

    fig.add_trace(go.Bar(
        y=df_sorted['WrappedName'],
        x=abs(df_sorted['Value']),
        orientation='h',
        marker=dict(color=color),
        text=abs(df_sorted['Value']),
        textposition='outside',
        hoverinfo='text',
        hovertemplate='<b>%{text:.2f}</b><br>GO Term: %{customdata}<extra></extra>',
        customdata=df_sorted['Name']
    ))

    fig.update_layout(
        title=title,
        xaxis_title='Value',
        yaxis_title='GO Terms',
        yaxis=dict(tickfont=dict(size=10)),
        xaxis=dict(tickfont=dict(size=10)),
        template="plotly_white",
        hovermode="closest",
        hoverlabel=dict(
            bgcolor="white",
            font_size=14,
            font_family="Arial",
        ),
        barmode='overlay'
    )

    # Hide other bars on hover
    fig.update_traces(
        marker=dict(opacity=0.3),
        selector=dict(type='bar')
    )

    # Make hovered bar full opacity
    fig.update_traces(
        marker=dict(opacity=1),
        hoverinfo='text+name',
        hovertemplate='<b>%{customdata}</b><br>Value: %{x:.2f}<extra></extra>'
    )

    # Save as interactive HTML
    interactive_filename = filename.replace('.png', '.html')
    pio.write_html(fig, file=interactive_filename)

    return interactive_filename

def create_combined_barplot(dataframes, output_folder):
    colors = {'BP': 'skyblue', 'MF': 'lightcoral', 'CC': 'lightgreen'}
    combined_df = pd.concat([
        dataframes['BP'].assign(Ontology='BP'),
        dataframes['MF'].assign(Ontology='MF'),
        dataframes['CC'].assign(Ontology='CC')
    ])

    ontology_order = {'BP': 1, 'MF': 2, 'CC': 3}
    combined_df['OntologyOrder'] = combined_df['Ontology'].map(ontology_order)
    combined_df = combined_df.reset_index(drop=True)
    combined_df['WrappedName'] = combined_df['Name'].apply(wrap_labels)
    combined_df_sorted = combined_df.sort_values(by=['OntologyOrder', 'Value'], key=abs)

    # Static plot with matplotlib
    plt.figure(figsize=(14, 12))
    bars = plt.barh(combined_df_sorted['WrappedName'], abs(combined_df_sorted['Value']),
                    color=combined_df_sorted['Ontology'].map(colors), height=0.6)
    for bar in bars:
        width = bar.get_width()
        plt.text(width + 0.5 if width > 0 else width - 0.5, 
                 bar.get_y() + bar.get_height() / 2, 
                 f'{width:.2f}', 
                 va='center', 
                 ha='right' if width > 0 else 'left', 
                 fontsize=8)

    handles = [plt.Line2D([0], [0], color=colors[ont], lw=4) for ont in ['BP', 'MF', 'CC']]
    labels = ['BP', 'MF', 'CC']
    plt.legend(handles, labels, title='Ontology', title_fontsize='13', fontsize='11', loc='best')

    plt.xlabel('Value')
    plt.title('GO Terms Bar Plot - Combined')
    plt.yticks(fontsize=6)
    plt.xticks(fontsize=10)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.savefig(os.path.join(output_folder, 'combined_barplot.png'))
    plt.close()

    # Interactive plot with plotly
    fig = go.Figure()

    fig.add_trace(go.Bar(
        y=combined_df_sorted['WrappedName'],
        x=abs(combined_df_sorted['Value']),
        orientation='h',
        marker=dict(color=combined_df_sorted['Ontology'].map(colors)),
        text=abs(combined_df_sorted['Value']),
        textposition='outside',
        hoverinfo='text',
        hovertemplate='<b>%{text:.2f}</b><br>GO Term: %{customdata}<extra></extra>',
        customdata=combined_df_sorted['Name']
    ))

    fig.update_layout(
        title='GO Terms Bar Plot - Combined',
        xaxis_title='Value',
        yaxis_title='GO Terms',
        yaxis=dict(tickfont=dict(size=10)),
        xaxis=dict(tickfont=dict(size=10)),
        template="plotly_white",
        hovermode="closest",
        hoverlabel=dict(
            bgcolor="white",
            font_size=14,
            font_family="Arial",
        )
    )

    # Hide other bars on hover
    fig.update_traces(
        marker=dict(opacity=0.3),
        selector=dict(type='bar')
    )

    # Make hovered bar full opacity
    fig.update_traces(
        marker=dict(opacity=1),
        hoverinfo='text+name',
        hovertemplate='<b>%{customdata}</b><br>Value: %{x:.2f}<extra></extra>'
    )

    # Save as interactive HTML
    interactive_filename = os.path.join(output_folder, 'combined_barplot.html')
    pio.write_html(fig, file=interactive_filename)

    return interactive_filename

def process_and_plot(bp_path, mf_path, cc_path, output_folder):
    os.makedirs(output_folder, exist_ok=True)

    dataframes = {'BP': pd.DataFrame(), 'MF': pd.DataFrame(), 'CC': pd.DataFrame()}
    colors = {'BP': 'skyblue', 'MF': 'lightcoral', 'CC': 'lightgreen'}

    # Process and create individual bar plots
    for ontology, path in {'BP': bp_path, 'MF': mf_path, 'CC': cc_path}.items():
        df = pd.read_csv(path, sep='\t')
        if all(col in df.columns for col in ['Name', 'Value']):
            dataframes[ontology] = df[['Name', 'Value']]
            output_file = os.path.join(output_folder, f'{ontology}_barplot.png')
            create_individual_barplot(df[['Name', 'Value']], f'GO Terms Bar Plot - {ontology}', output_file, colors[ontology])
        else:
            raise ValueError(f"The file {path} does not contain the required columns.")

    # Create combined bar plot
    create_combined_barplot(dataframes, output_folder)

# Example usage
bp_path = 'examples/output/aa/aa.candidates/results_revigo/aa.candidates_0.01_IDs_Pvalues_BP_table.tsv'
mf_path = 'examples/output/aa/aa.candidates/results_revigo/aa.candidates_0.01_IDs_Pvalues_MF_table.tsv'
cc_path = 'examples/output/aa/aa.candidates/results_revigo/aa.candidates_0.01_IDs_Pvalues_CC_table.tsv'
output_folder = 'examples/output/ccc'

#process_and_plot(bp_path, mf_path, cc_path, output_folder)
