import pandas as pd
import plotly.graph_objs as go
from dash import dash, dcc, html
from dash.dependencies import Input, Output

# fetch data
soql_url = ('https://data.cityofnewyork.us/resource/nwxe-4ae8.json?' +\
        '$select=coalesce(spc_common, "Unknown") as spc_common,boroname,count(tree_id),\
                sum(case when health = "Fair" then 1 else 0 end) as fair_health,\
                sum(case when health = "Good" then 1 else 0 end) as good_health,\
                sum(case when health = "Poor" then 1 else 0 end) as poor_health,\
                round(100 * SUM(CASE WHEN health = "Poor" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_poor_health,\
                round(100 * SUM(CASE WHEN health = "Fair" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_fair_health,\
                round(100 * SUM(CASE WHEN health = "Good" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_good_health' +\
        '&$group=spc_common,boroname').replace(' ', '%20')

# convert to df
df=pd.read_json(soql_url)

# fetch data for 2nd graph
soql_url_2 = ('https://data.cityofnewyork.us/resource/nwxe-4ae8.json?' +\
        '$select=coalesce(spc_common, "Unknown") as spc_common,boroname,count(tree_id),steward,\
                round(100 * SUM(CASE WHEN health = "Poor" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_poor_health,\
                round(100 * SUM(CASE WHEN health = "Fair" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_fair_health,\
                round(100 * SUM(CASE WHEN health = "Good" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_good_health' +\
        '&$group=spc_common,boroname,steward').replace(' ', '%20')

# convert to df_2
df_2= pd.read_json(soql_url_2)

# create a list of tree species for the dropdown menu
species_list = df['spc_common'].unique()
species_options = [{'label': species, 'value': species} for species in species_list]

# create a list of boroughs for the dropdown menu
borough_list = df['boroname'].unique()
borough_options = [{'label': borough, 'value': borough} for borough in borough_list]

# create the Dash app
app = dash.Dash(__name__)

# define the app layout
app.layout = html.Div([
    html.H1('Tree Health in NYC'),
    html.Div([
        html.Label('Select Tree Species:'),
        dcc.Dropdown(
            id='species-dropdown',
            options=species_options,
            value=species_list[0]
        )
    ], style={'width': '40%', 'display': 'inline-block'}),
    html.Div([
        html.Label('Select Borough:'),
        dcc.Dropdown(
            id='borough-dropdown',
            options=borough_options,
            value=borough_list[0]
        )
    ], style={'width': '40%', 'display': 'inline-block'}),
    dcc.Graph(id='health-graph'),
    dcc.Graph(id='steward-graph')
    ])

# define the callback function for the health graph
@app.callback(
    Output('health-graph', 'figure'),
    Input('species-dropdown', 'value'),
    Input('borough-dropdown', 'value')
)
def update_health_graph(species, borough):
    # filter the data based on the selected species and borough
    df_filtered = df[(df['spc_common'] == species) & (df['boroname'] == borough)]
    good_pct = df_filtered['percent_good_health'].iloc[0]
    fair_pct = df_filtered['percent_fair_health'].iloc[0]
    poor_pct = df_filtered['percent_poor_health'].iloc[0]
    
    # create the bar chart trace
    fig = go.Figure()

    fig.add_trace(
        go.Bar(
            x=['Good', 'Fair', 'Poor'],
            y=[good_pct, fair_pct, poor_pct],
            marker_color=['green', 'orange', 'red']
        )
   )
    
    # update the layout
    fig.update_layout(
        title=f'Health Percentage of {species} Trees in {borough}',
        xaxis_title='Health',
        yaxis_title='Percentage',
        bargap=0.1,
        bargroupgap=0.1
    )
    
    # return the figure
    return fig

# define callback section for steward graph
@app.callback(
    Output('steward-graph', 'figure'),
    Input('species-dropdown', 'value'),
    Input('borough-dropdown', 'value')
)

def update_steward_graph(species, borough):
    # filter the data based on the selected species and borough
    df_2_filtered = df_2[(df_2['spc_common'] == species) & (df_2['boroname'] == borough)]

    # Create the bar chart
    fig = go.Figure()

    # Add the "Poor" health status bar
    fig.add_trace(
        go.Bar(
        x=df_2_filtered['steward'].unique(),
        y=df_2_filtered['percent_poor_health'],
        name='Poor',
        marker_color='red'
    )
)

    # Add the "Fair" health status bar
    fig.add_trace(
        go.Bar(
        x=df_2_filtered['steward'].unique(),
        y=df_2_filtered['percent_fair_health'],
        name='Fair',
        marker_color='orange'
    )
)

    # Add the "Good" health status bar
    fig.add_trace(
        go.Bar(
        x=df_2_filtered['steward'].unique(),
        y=df_2_filtered['percent_good_health'],
        name='Good',
        marker_color='green'
    )
)

    
# Update the layout
    fig.update_layout(
        title=f'Health Status of {species} Percentage by Steward Type in {borough}',
        xaxis_title='Steward Type',
        yaxis_title='Percentage (%)',
        barmode='group',
        bargap=0.15,
        bargroupgap=0.1,
        legend=dict(
            x=0,
            y=1.15,
            orientation='h'
    )
)
    
    # return the figure
    return fig

# run the app
if __name__ == '__main__':
    app.run_server(debug=True)