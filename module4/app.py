import pandas as pd
import plotly.graph_objs as go
from dash import dash, dcc, html
from dash.dependencies import Input, Output

soql_url = ('https://data.cityofnewyork.us/resource/nwxe-4ae8.json?' +\
        '$select=coalesce(spc_common,"Unknown") as spc_common,boroname,steward,count(tree_id),\
                sum(case when health = "Fair" then 1 else 0 end) as fair_health,\
                sum(case when health = "Good" then 1 else 0 end) as good_health,\
                sum(case when health = "Poor" then 1 else 0 end) as poor_health,\
                sum(case when steward = "1or2" then 1 else 0 end) as one_two_stewards,\
                sum(case when steward = "3or4" then 1 else 0 end) as three_four_stewards,\
                sum(case when steward = "4orMore" then 1 else 0 end) as four_or_more_stewards,\
                round(100 * SUM(CASE WHEN health = "Poor" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_poor_health,\
                round(100 * SUM(CASE WHEN health = "Fair" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_fair_health,\
                round(100 * SUM(CASE WHEN health = "Good" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_good_health,\
                round(100 * SUM(CASE WHEN steward = "1or2" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_one_two_stewards,\
                round(100 * SUM(CASE WHEN steward = "3or4" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_three_four_stewards,\
                round(100 * SUM(CASE WHEN steward = "4orMore" THEN 1 ELSE 0 END) / COUNT(tree_id),2) AS percent_four_or_more_stewards' +\
        '&$group=spc_common,boroname,steward').replace(' ', '%20')

df= pd.read_json(soql_url)

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
    dcc.Graph(
        id='health-graph'
    )
])

# define the callback function for the graph
@app.callback(
    Output('health-graph', 'figure'),
    Input('species-dropdown', 'value'),
    Input('borough-dropdown', 'value')
)
def update_graph(species, borough):
    # filter the data based on the selected species and borough
    df_filtered = df[(df['spc_common'] == species) & (df['boroname'] == borough)]
    good_pct = df_filtered['percent_good_health'].iloc[0]
    fair_pct = df_filtered['percent_fair_health'].iloc[0]
    poor_pct = df_filtered['percent_poor_health'].iloc[0]
    
    # create the bar chart trace
    data = [
        go.Bar(
            x=['Good', 'Fair', 'Poor'],
            y=[good_pct, fair_pct, poor_pct],
            marker_color=['green', 'yellow', 'red']
        )
    ]
    
    # update the layout
    layout = go.Layout(
        title=f'Health Percentage of {species} Trees in {borough}',
        xaxis_title='Health',
        yaxis_title='Percentage',
        bargap=0.1,
        bargroupgap=0.1
    )
    
    # return the figure
    return {'data': data, 'layout': layout}

# run the app
if __name__ == '__main__':
    app.run_server(debug=True)