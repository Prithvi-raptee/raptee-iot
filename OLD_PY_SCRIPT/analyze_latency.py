import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os
import glob
import argparse
import sys
from matplotlib.backends.backend_pdf import PdfPages
import textwrap

# Set style for professional looking plots
sns.set_theme(style="whitegrid")
# A4 Portrait size in inches
A4_PORTRAIT = (8.27, 11.69)
plt.rcParams['figure.figsize'] = A4_PORTRAIT

def load_data(data_dir):
    """Loads and combines all API latency CSV files."""
    if not os.path.exists(data_dir):
        print(f"Error: Directory not found: {data_dir}")
        return pd.DataFrame()

    all_files = glob.glob(os.path.join(data_dir, "*.csv"))
    df_list = []
    
    for filename in all_files:
        try:
            df = pd.read_csv(filename)
            # Extract API name from filename (e.g., 'google_places_api_latency.csv' -> 'google_places')
            api_name = os.path.basename(filename).replace('_api_latency.csv', '')
            df['api_name'] = api_name
            df_list.append(df)
            print(f"Loaded {filename} with {len(df)} records.")
        except Exception as e:
            print(f"Error loading {filename}: {e}")

    if not df_list:
        print(f"No CSV files found in {data_dir}!")
        return pd.DataFrame()

    combined_df = pd.concat(df_list, ignore_index=True)
    return combined_df

def clean_data(df):
    """Cleans and preprocesses the data."""
    if df.empty:
        return df

    # Convert timestamp to datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'], errors='coerce')
    
    # Ensure latency is numeric
    df['latency_ms'] = pd.to_numeric(df['latency_ms'], errors='coerce')
    
    # Drop rows with missing critical data
    df.dropna(subset=['timestamp', 'latency_ms'], inplace=True)
    
    # Filter out invalid dates - only keep dates from 2025 onwards
    # This handles cases where timestamps may be in Linux Epoch time (starting from 1970)
    valid_start_date = pd.Timestamp('2025-01-01')
    initial_count = len(df)
    df = df[df['timestamp'] >= valid_start_date]
    filtered_count = initial_count - len(df)
    
    if filtered_count > 0:
        print(f"Filtered out {filtered_count} records with invalid dates (before 2025)")



    # Ensure status_code is numeric
    if 'status_code' in df.columns:
        df['status_code'] = pd.to_numeric(df['status_code'], errors='coerce').fillna(-1).astype(int)
    else:
        # Fallback if column doesn't exist (shouldn't happen based on user request, but good for safety)
        print("Warning: 'status_code' column missing. Creating dummy column.")
        df['status_code'] = -1
        
    # --- New Fields Cleaning ---
    # Signal Strength
    if 'signal_strength' in df.columns:
        df['signal_strength'] = pd.to_numeric(df['signal_strength'], errors='coerce')
        
    # Connection State
    if 'connection_state' in df.columns:
        df['connection_state'] = df['connection_state'].fillna('Unknown').astype(str)
        
    # Speed
    if 'speed_kmph' in df.columns:
        df['speed_kmph'] = pd.to_numeric(df['speed_kmph'], errors='coerce')

    return df

def calculate_percentiles(df):
    """Calculates latency percentiles per API."""
    percentiles = df.groupby('api_name')['latency_ms'].quantile([0.5, 0.9, 0.95, 0.99]).unstack()
    percentiles.columns = ['p50', 'p90', 'p95', 'p99']
    return percentiles

def calculate_throughput(df):
    """Calculates average requests per minute."""
    if df.empty:
        return 0
    
    duration_minutes = (df['timestamp'].max() - df['timestamp'].min()).total_seconds() / 60
    if duration_minutes == 0:
        return len(df) # All in one moment
        
    return len(df) / duration_minutes

def get_slowest_endpoints(df, n=10):
    """Returns the top N slowest API calls."""
    return df.nlargest(n, 'latency_ms')[['timestamp', 'api_name', 'latency_ms', 'status_code']]

def create_summary_page(pdf, df, output_dir_name):
    """Creates the first page of the PDF with Executive Summary and Statistical Overview."""
    print("Generating Executive Summary Page...")
    fig, ax = plt.subplots(figsize=A4_PORTRAIT)
    ax.axis('off')
    
    # Title
    ax.text(0.5, 0.95, f"{output_dir_name}", fontsize=24, fontweight='bold', ha='center', color='#2C3E50', transform=ax.transAxes)
    ax.text(0.5, 0.91, "API Latency Analysis Report", fontsize=16, ha='center', color='#7F8C8D', transform=ax.transAxes)
    
    # --- Executive Summary Section ---
    ax.text(0.10, 0.85, "Executive Summary", fontsize=18, fontweight='bold', color='#2980B9', transform=ax.transAxes)
    
    # Generate Insights
    insights = []
    
    # 1. Status Code Analysis
    total_calls = len(df)
    status_counts = df['status_code'].value_counts()
    
    # Network Errors (Status 0)
    network_errors = status_counts.get(0, 0)
    if network_errors > 0:
        rate = (network_errors / total_calls) * 100
        insights.append({"text": f"NETWORK: {rate:.1f}% calls failed due to network (Status 0).", "color": "#C0392B", "weight": "bold"})

    # Server Errors (5xx)
    server_errors = df[df['status_code'].between(500, 599)].shape[0]
    if server_errors > 0:
        rate = (server_errors / total_calls) * 100
        insights.append({"text": f"CRITICAL: {rate:.1f}% calls failed with Server Errors (5xx).", "color": "#C0392B", "weight": "bold"})

    # Client Errors (4xx)
    client_errors = df[df['status_code'].between(400, 499)].shape[0]
    if client_errors > 0:
        rate = (client_errors / total_calls) * 100
        insights.append({"text": f"WARNING: {rate:.1f}% calls failed with Client Errors (4xx).", "color": "#D35400", "weight": "normal"})

    # Success Rate (200)
    success_count = status_counts.get(200, 0)
    success_rate = (success_count / total_calls) * 100
    if success_rate < 95:
         insights.append({"text": f"STABILITY: Overall success rate is low ({success_rate:.1f}%).", "color": "#D35400", "weight": "bold"})

    # 2. Latency Checks (Only on SUCCESS calls - Status 200)
    success_df = df[df['status_code'] == 200]
    if not success_df.empty:
        avg_latencies = success_df.groupby('api_name')['latency_ms'].mean()
        max_latencies = success_df.groupby('api_name')['latency_ms'].max()
        
        for api, avg in avg_latencies.items():
            if avg > 5000:
                 insights.append({"text": f"PERFORMANCE: {api} avg latency {avg/1000:.1f}s.", "color": "#D35400", "weight": "bold"})
        
        for api, mx in max_latencies.items():
            if mx > 20000: 
                 insights.append({"text": f"SPIKE: {api} max latency {mx/1000:.1f}s.", "color": "#C0392B", "weight": "bold"})
    else:
        insights.append({"text": "No successful API calls (Status 200) found.", "color": "#7F8C8D", "weight": "normal"})

    if not insights:
        insights.append({"text": "All APIs are performing within normal parameters.", "color": "#27AE60", "weight": "bold"})

    # 3. Cellular & Connection Insights
    if 'connection_state' in df.columns:
        # Check for non-connected states
        non_connected = df[df['connection_state'] != 'connected']
        if not non_connected.empty:
            rate = (len(non_connected) / total_calls) * 100
            insights.append({"text": f"CONNECTIVITY: {rate:.1f}% calls made while NOT connected (e.g., {non_connected['connection_state'].unique()}).", "color": "#D35400", "weight": "bold"})
            
        # Failure rate in non-connected states
        if not non_connected.empty:
            failed_non_connected = non_connected[non_connected['status_code'] != 200]
            if not failed_non_connected.empty:
                fail_rate = (len(failed_non_connected) / len(non_connected)) * 100
                insights.append({"text": f"RISK: {fail_rate:.1f}% failure rate when not 'connected'.", "color": "#C0392B", "weight": "bold"})

    if 'signal_strength' in df.columns:
        # Low signal analysis
        low_signal = df[df['signal_strength'] < 20]
        if not low_signal.empty:
             insights.append({"text": f"SIGNAL: {len(low_signal)} calls made with weak signal (<20%).", "color": "#F39C12", "weight": "normal"})

    # Deduplicate (based on text) and limit
    unique_insights = []
    seen_texts = set()
    for item in insights:
        if item['text'] not in seen_texts:
            unique_insights.append(item)
            seen_texts.add(item['text'])
    unique_insights = unique_insights[:8] # Increased limit slightly
    
    # Render Insights
    y_pos = 0.80
    ax.text(0.10, y_pos, f"Analysis of {len(df['api_name'].unique())} APIs ({total_calls} total calls):", fontsize=12, transform=ax.transAxes)
    y_pos -= 0.04
    
    for item in unique_insights:
        # Wrap text to avoid overflow (approx 80 chars for A4 with this font size/margins)
        wrapped_lines = textwrap.wrap(item['text'], width=80)
        
        for i, line in enumerate(wrapped_lines):
            prefix = "• " if i == 0 else "  " # Indent subsequent lines
            ax.text(0.12, y_pos, f"{prefix}{line}", fontsize=12, color=item['color'], fontweight=item['weight'], transform=ax.transAxes)
            y_pos -= 0.035

    # --- Statistical Overview ---
    # Dynamic positioning based on where insights ended
    stats_title_y = y_pos - 0.05
    ax.text(0.10, stats_title_y, "Statistical Overview", fontsize=18, fontweight='bold', color='#2980B9', transform=ax.transAxes)

    # Prepare Data for Table
    counts = df.groupby('api_name')['latency_ms'].count()
    if not success_df.empty:
        latency_stats = success_df.groupby('api_name')['latency_ms'].agg(['mean', 'max', 'min'])
    else:
        latency_stats = pd.DataFrame(columns=['mean', 'max', 'min'])
    
    # Calculate Error % (Non-200)
    error_rates = df.groupby('api_name')['status_code'].apply(lambda x: (x != 200).mean() * 100)

    stats_table_df = pd.DataFrame({'count': counts, 'error_rate': error_rates})
    stats_table_df = stats_table_df.join(latency_stats)
    
    pd.set_option('future.no_silent_downcasting', True)
    stats_table_df['mean'] = stats_table_df['mean'].fillna(0).infer_objects(copy=False)
    stats_table_df['max'] = stats_table_df['max'].fillna(0).infer_objects(copy=False)
    stats_table_df['min'] = stats_table_df['min'].fillna(0).infer_objects(copy=False)
    
    table_data = []
    for index, row in stats_table_df.reset_index().iterrows():
        table_data.append([
            row['api_name'],
            f"{int(row['count'])}",
            f"{row['mean']:.0f}",
            f"{row['max']:.0f}",
            f"{row['error_rate']:.1f}%"
        ])
    
    col_labels = ["API Name", "Count", "Mean (ms)", "Max (ms)", "Error %"]
    col_widths = [0.35, 0.1, 0.2, 0.2, 0.15]
    col_colors = ['#ECF0F1'] * 5
    
    # Table Positioning
    # Calculate dynamic bbox for table
    table_top = stats_title_y - 0.05
    table_height = 0.35
    table_bottom = table_top - table_height
    
    # Ensure it doesn't go off page
    if table_bottom < 0.05:
        table_bottom = 0.05
        table_height = max(0.1, table_top - table_bottom)

    table = ax.table(cellText=table_data, colLabels=col_labels, colWidths=col_widths, 
                      loc='center', cellLoc='left', bbox=[0.05, table_bottom, 0.90, table_height],
                      colColours=col_colors)
    
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 1.8)
    
    # Style Headers and Cells
    for (row, col), cell in table.get_celld().items():
        if row == 0:
            cell.set_text_props(weight='bold', color='#2C3E50')
            cell.set_facecolor('#BDC3C7')
            cell.set_edgecolor('white')
        else:
            cell.set_edgecolor('#BDC3C7')
            if row % 2 == 0:
                cell.set_facecolor('#F7F9F9')
    
    pdf.savefig(fig)
    plt.close(fig)

def create_failure_analysis_page(pdf, df):
    """Creates a page focusing on failures (Non-200) and high latency (>20s)."""
    # Filter for failures or high latency
    failure_df = df[(df['status_code'] != 200) | (df['latency_ms'] >= 20000)].copy()
    
    if failure_df.empty:
        return # No failures to plot

    plt.figure(figsize=A4_PORTRAIT)
    # Increase bottom margin to make room for the legend
    plt.subplots_adjust(left=0.25, right=0.95, top=0.9, bottom=0.2, hspace=0.4)
    
    plt.suptitle("Failure & High Latency Analysis", fontsize=20, fontweight='bold', color='#C0392B')
    
    # 1. Count of Incidents per API
    plt.subplot(2, 1, 1)
    plt.title("Incident Count per API", fontsize=14, fontweight='bold')
    sns.countplot(y='api_name', data=failure_df, hue='api_name', palette='Reds_r', order=failure_df['api_name'].value_counts().index, legend=False)
    plt.xlabel("Count of Incidents")
    plt.ylabel("API Name")
    
    # 2. Timeline of Incidents
    plt.subplot(2, 1, 2)
    plt.title("Incident Timeline", fontsize=14, fontweight='bold')
    
    # Map status/type to color
    def get_incident_type(row):
        if row['status_code'] == 0: return 'Network Error (0)'
        if 400 <= row['status_code'] < 500: return f'Client Error ({row["status_code"]})'
        if 500 <= row['status_code'] < 600: return f'Server Error ({row["status_code"]})'
        if row['latency_ms'] >= 20000: return 'High Latency (>20s)'
        return 'Other Error'

    failure_df['type'] = failure_df.apply(get_incident_type, axis=1)
    
    sns.scatterplot(x='timestamp', y='api_name', hue='type', style='type', data=failure_df, s=100)
    plt.xlabel("Time")
    plt.ylabel("API Name")
    # Move legend to bottom to avoid cutoff
    plt.legend(title="Incident Type", loc='upper center', bbox_to_anchor=(0.5, -0.3), ncol=2)
    plt.xticks(rotation=45)
    
    pdf.savefig()
    plt.close()

def create_percentile_plot(pdf, df):
    """Creates a plot showing P50, P90, P95, P99 latencies."""
    success_df = df[df['status_code'] == 200]
    if success_df.empty:
        return

    # Calculate percentiles
    percentiles = success_df.groupby('api_name')['latency_ms'].quantile([0.5, 0.9, 0.95, 0.99]).unstack()
    percentiles.columns = ['P50', 'P90', 'P95', 'P99']
    percentiles = percentiles.reset_index()
    
    # Melt for plotting
    melted_df = percentiles.melt(id_vars='api_name', var_name='Percentile', value_name='Latency')
    
    plt.figure(figsize=A4_PORTRAIT)
    plt.subplots_adjust(left=0.1, right=0.9, top=0.85, bottom=0.2) 
    
    plt.title("Latency Percentiles (P50, P90, P95, P99) - Success Only", fontsize=18, fontweight='bold', pad=20)
    
    sns.barplot(x='api_name', y='Latency', hue='Percentile', data=melted_df, palette='viridis')
    
    plt.xlabel("API Name", fontsize=12)
    plt.ylabel("Latency (ms)", fontsize=12)
    plt.xticks(rotation=45)
    plt.legend(title="Percentile")
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    
    pdf.savefig()
    plt.close()



def create_cellular_connectivity_page(pdf, df):
    """Creates Page 1 of Cellular Analysis: Connectivity & Failure Rates."""
    if 'connection_state' not in df.columns:
        return

    plt.figure(figsize=A4_PORTRAIT)
    # Ample spacing as requested
    plt.subplots_adjust(left=0.05, right=0.95, top=0.9, bottom=0.1, hspace=0.4, wspace=0.3)
    plt.suptitle("Cellular Connectivity Overview", fontsize=22, fontweight='bold', color='#2980B9')

    # --- Top Section: Pie Chart (Left) & Table (Right) ---
    
    # 1. Connection State Distribution (Pie Chart)
    ax1 = plt.subplot(2, 2, 1)
    plt.title("Connection State Distribution", fontsize=14, fontweight='bold')
    state_counts = df['connection_state'].value_counts()
    total_counts = state_counts.sum()
    colors = sns.color_palette('pastel', n_colors=len(state_counts))
    
    # Pie chart WITHOUT labels/autopct inside
    wedges, _ = plt.pie(state_counts, colors=colors, startangle=90)
    
    # 2. Data Table (Right)
    ax2 = plt.subplot(2, 2, 2)
    plt.axis('off')
    plt.title("State Statistics", fontsize=14, fontweight='bold', pad=20)
    
    # Prepare table data
    table_data = []
    for i, (state, count) in enumerate(state_counts.items()):
        percentage = (count / total_counts) * 100
        table_data.append([state, f"{count}", f"{percentage:.1f}%"])
    
    col_labels = ["State", "Count", "%"]
    col_colors = ['#ECF0F1'] * 3
    
    # Create table
    table = plt.table(cellText=table_data, colLabels=col_labels, loc='center', 
                      cellLoc='center', colColours=col_colors, bbox=[0.1, 0.2, 0.8, 0.6])
    
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1, 2)
    
    # Color the "State" cells to match the pie chart
    for i in range(len(state_counts)):
        # Cell (row, col) - row 0 is header, so data starts at 1
        # Column 0 is "State"
        cell = table[(i+1, 0)]
        cell.set_facecolor(colors[i])
        cell.set_text_props(color='black', fontweight='bold') # Ensure text is readable
        cell.set_alpha(0.7)

    # --- Bottom Section: Bar Chart ---
    
    # 3. Failure Rate by Connection State (Bar Chart)
    ax3 = plt.subplot(2, 1, 2)
    plt.title("Failure Rate by Connection State", fontsize=16, fontweight='bold', pad=20)
    
    failure_rates = df.groupby('connection_state')['status_code'].apply(lambda x: (x != 200).mean() * 100).reset_index()
    failure_rates.columns = ['State', 'Failure Rate (%)']
    
    sns.barplot(x='State', y='Failure Rate (%)', data=failure_rates, palette='Reds', hue='State', legend=False)
    plt.ylim(0, 100)
    plt.grid(axis='y', linestyle='--', alpha=0.5)
    plt.xticks(rotation=0, fontsize=11) 
    plt.ylabel("Failure Rate (%)", fontsize=12)
    plt.xlabel("Connection State", fontsize=12)
    
    for index, row in failure_rates.iterrows():
        plt.text(index, row['Failure Rate (%)'] + 2, f"{row['Failure Rate (%)']:.1f}%", ha='center', color='black', fontsize=11, fontweight='bold')

    pdf.savefig()
    plt.close()

def create_cellular_signal_page(pdf, df):
    """Creates Page 2 of Cellular Analysis: Latency & Signal Strength."""
    if 'connection_state' not in df.columns:
        return

    plt.figure(figsize=A4_PORTRAIT)
    # Ample spacing
    plt.subplots_adjust(left=0.1, right=0.9, top=0.9, bottom=0.15, hspace=0.4)
    plt.suptitle("Cellular Signal & Latency Analysis", fontsize=22, fontweight='bold', color='#2980B9')

    # 1. Latency Distribution by Connection State (Box Plot) - Top Half
    plt.subplot(2, 1, 1)
    plt.title("Latency Distribution by Connection State", fontsize=16, fontweight='bold', pad=20)
    sns.boxplot(x='connection_state', y='latency_ms', data=df, palette='Set2', hue='connection_state', legend=False)
    plt.yscale('log')
    plt.ylabel("Latency (ms) - Log Scale", fontsize=12)
    plt.xlabel("Connection State", fontsize=12)
    plt.grid(True, which="both", ls="-", alpha=0.2)

    # 2. Signal Strength vs Latency (Scatter Plot) - Bottom Half
    if 'signal_strength' in df.columns:
        plt.subplot(2, 1, 2)
        plt.title("Signal Strength vs Latency", fontsize=16, fontweight='bold', pad=20)
        
        valid_signal = df[df['signal_strength'] > 0] 
        
        if not valid_signal.empty:
            sns.scatterplot(x='signal_strength', y='latency_ms', hue='connection_state', data=valid_signal, alpha=0.7, s=80)
            
            try:
                sns.regplot(x='signal_strength', y='latency_ms', data=valid_signal, scatter=False, color='red', line_kws={'alpha':0.5})
            except:
                pass

            plt.xlabel("Signal Strength (%)", fontsize=12)
            plt.ylabel("Latency (ms)", fontsize=12)
            # Legend at the bottom with ample space
            plt.legend(title="Connection State", loc='upper center', bbox_to_anchor=(0.5, -0.2), ncol=4, fontsize=11)
    
    pdf.savefig()
    plt.close()

def analyze_and_plot(df, output_dir):
    """Generates statistics, plots, and a PDF report."""
    if df.empty:
        print("No data to analyze.")
        return

    # Prepare output paths
    output_txt_path = os.path.join(output_dir, 'analysis_output.txt')
    output_pdf_path = os.path.join(output_dir, 'analysis_report.pdf')
    
    with PdfPages(output_pdf_path) as pdf:
        # 1. Executive Summary
        create_summary_page(pdf, df, os.path.basename(output_dir))
        
        # 2. Failure Analysis
        create_failure_analysis_page(pdf, df)
        
        # 3. Percentile Analysis
        # 3. Percentile Analysis
        create_percentile_plot(pdf, df)

        # 4. Cellular Analysis (Split into 2 pages)
        create_cellular_connectivity_page(pdf, df)
        create_cellular_signal_page(pdf, df)

        # Common Plot Settings
        def setup_plot(title):
            plt.figure(figsize=A4_PORTRAIT)
            plt.subplots_adjust(left=0.1, right=0.9, top=0.75, bottom=0.35)
            plt.title(title, fontsize=16, fontweight='bold', pad=20)

        # --- Plot 1: Latency Distribution (Box Plot) - All Data ---
        setup_plot('API Latency Distribution by API (All Data)')
        sns.boxplot(x='api_name', y='latency_ms', data=df)
        plt.ylabel('Latency (ms)', fontsize=12)
        plt.xlabel('API Name', fontsize=12)
        plt.xticks(rotation=45)
        pdf.savefig()
        plt.close()

        # --- Plot 1b: Latency Distribution (Box Plot) - Success Only ---
        setup_plot('API Latency Distribution by API (Success Only)')
        sns.boxplot(x='api_name', y='latency_ms', data=df[df['status_code'] == 200])
        plt.ylabel('Latency (ms)', fontsize=12)
        plt.xlabel('API Name', fontsize=12)
        plt.xticks(rotation=45)
        pdf.savefig()
        plt.close()

        # --- Plot 2: Latency Over Time (Line Plot) - All Data ---
        setup_plot('API Latency Over Time (All Data)')
        sns.lineplot(x='timestamp', y='latency_ms', hue='api_name', data=df, marker='o', alpha=0.7)
        plt.ylabel('Latency (ms)', fontsize=12)
        plt.xlabel('Time', fontsize=12)
        plt.xticks(rotation=45)
        pdf.savefig()
        plt.close()

        # --- Plot 2b: Latency Over Time (Success Only) ---
        setup_plot('API Latency Over Time (Success Only)')
        success_df = df[df['status_code'] == 200]
        if not success_df.empty:
            sns.lineplot(x='timestamp', y='latency_ms', hue='api_name', data=success_df, marker='o', alpha=0.7)
            plt.ylabel('Latency (ms)', fontsize=12)
            plt.xlabel('Time', fontsize=12)
            plt.xticks(rotation=45)
            pdf.savefig()
        plt.close()

        # --- Plot 3: Average Latency Comparison (Bar Plot) - All Data ---
        setup_plot('Average API Latency (All Data)')
        avg_latency_all = df.groupby('api_name')['latency_ms'].mean().reset_index()
        sns.barplot(x='api_name', y='latency_ms', data=avg_latency_all)
        plt.ylabel('Average Latency (ms)', fontsize=12)
        plt.xlabel('API Name', fontsize=12)
        plt.xticks(rotation=45)
        pdf.savefig()
        plt.close()

        # --- Plot 3b: Average Latency Comparison (Bar Plot) - Success Only ---
        setup_plot('Average API Latency (Success Only)')
        if not success_df.empty:
            avg_latency = success_df.groupby('api_name')['latency_ms'].mean().reset_index()
            sns.barplot(x='api_name', y='latency_ms', data=avg_latency)
            plt.ylabel('Average Latency (ms)', fontsize=12)
            plt.xlabel('API Name', fontsize=12)
            plt.xticks(rotation=45)
            pdf.savefig()
        plt.close()

        # --- Plot 4: Status Code Distribution ---
        setup_plot('API Call Status Code Distribution')
        # Count plot for status codes
        sns.countplot(x='api_name', hue='status_code', data=df)
        plt.ylabel('Count', fontsize=12)
        plt.xlabel('API Name', fontsize=12)
        plt.xticks(rotation=45)
        plt.legend(title='Status Code')
        pdf.savefig()
        plt.close()
        
        # Also write the text report for backup
        with open(output_txt_path, 'w') as f:
            f.write(f"Analysis Report for {os.path.basename(output_dir)}\n")
            f.write("=" * 40 + "\n")
            f.write(df.groupby('api_name')['latency_ms'].describe().to_string() + "\n")

        print(f"\nAnalysis complete. Report saved to {output_pdf_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Analyze API Latency Logs from a specific folder.")
    parser.add_argument("target_folder", nargs='?', help="Path to the folder containing the api_latency logs (e.g., e:\\T30_APP_LOGS\\15_NOV_BIKE_8)")
    
    args = parser.parse_args()
    
    if not args.target_folder:
        print("Please provide the target folder path as an argument.")
        print("Usage: python analyze_latency.py <path_to_folder>")
        sys.exit(1)

    target_folder = args.target_folder
    folder_name = os.path.basename(os.path.normpath(target_folder))
    
    # Define paths based on user requirements
    DATA_DIR = os.path.join(target_folder, 'api_latency')
    REPORTS_BASE = r"e:\T30_APP_LOGS\REPORTS"
    OUTPUT_DIR = os.path.join(REPORTS_BASE, folder_name)
    
    print(f"Target Folder: {target_folder}")
    print(f"Data Directory: {DATA_DIR}")
    print(f"Output Directory: {OUTPUT_DIR}")

    # Ensure output directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("Starting API Latency Analysis...")
    df = load_data(DATA_DIR)
    df = clean_data(df)
    analyze_and_plot(df, OUTPUT_DIR)
