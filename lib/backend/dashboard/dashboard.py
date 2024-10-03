import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly.express as px
from dash.exceptions import PreventUpdate

# Initialize Firebase Admin SDK with the service account key
cred = credentials.Certificate("/Users/isha/Documents/my codes/cstain/lib/backend/dashboard/cstain firebase-adminsdk.json")  # Replace with your actual path
firebase_admin.initialize_app(cred)

# Initialize Firestore Client
db = firestore.client()

# Function to fetch user-specific data from Firestore
def fetch_user_data(user_id):
    collection_ref = db.collection('user_contributions')
    docs = collection_ref.where('user_id', '==', user_id).stream()

    data = []
    for doc in docs:
        doc_data = doc.to_dict()
        doc_data['id'] = doc.id  # Add document ID to the data
        data.append(doc_data)

    return pd.DataFrame(data)

# Create the Dash app for interactive visualization
app = dash.Dash(__name__)

# Layout of the dashboard
app.layout = html.Div([
    html.H1("C-Stain User Contribution Dashboard"),

    dcc.Input(id='user-id-input', type='text', placeholder='Enter User ID'),
    html.Button('Load Data', id='load-data-button'),

    dcc.Dropdown(id='category-filter', clearable=False),

    dcc.Graph(id='co2-saved-graph'),

    html.Label("Select Date Range:"),
    dcc.RangeSlider(id='date-slider'),

    dcc.Graph(id='duration-graph'),

    html.H4("User Action Logs"),
    html.Div(id='action-log-output'),

    dcc.Interval(
        id='interval-component',
        interval=60*1000,  # in milliseconds, update every 1 minute
        n_intervals=0
    )
])

# Callback to load user data and update dashboard components
@app.callback(
    [Output('category-filter', 'options'),
     Output('category-filter', 'value'),
     Output('date-slider', 'min'),
     Output('date-slider', 'max'),
     Output('date-slider', 'value'),
     Output('date-slider', 'marks')],
    [Input('load-data-button', 'n_clicks'),
     Input('interval-component', 'n_intervals')],
    [dash.dependencies.State('user-id-input', 'value')]
)
def load_user_data(n_clicks, n_intervals, user_id):
    if not user_id:
        raise PreventUpdate

    df = fetch_user_data(user_id)
    
    if df.empty:
        raise PreventUpdate

    df['created_at'] = pd.to_datetime(df['created_at'], unit='s')

    categories = [{'label': category, 'value': category} for category in df['category'].unique()]
    default_category = df['category'].unique()[0]

    min_date = df['created_at'].min().timestamp()
    max_date = df['created_at'].max().timestamp()

    marks = {
        int(min_date): str(df['created_at'].min().date()),
        int(max_date): str(df['created_at'].max().date())
    }

    return categories, default_category, min_date, max_date, [min_date, max_date], marks

# Callback for updating the dashboard
@app.callback(
    [Output('co2-saved-graph', 'figure'),
     Output('duration-graph', 'figure'),
     Output('action-log-output', 'children')],
    [Input('category-filter', 'value'),
     Input('date-slider', 'value'),
     Input('interval-component', 'n_intervals')],
    [dash.dependencies.State('user-id-input', 'value')]
)
def update_dashboard(selected_category, date_range, n_intervals, user_id):
    if not user_id:
        raise PreventUpdate

    df = fetch_user_data(user_id)
    df['created_at'] = pd.to_datetime(df['created_at'], unit='s')

    start_date = pd.to_datetime(date_range[0], unit='s')
    end_date = pd.to_datetime(date_range[1], unit='s')

    filtered_df = df[(df['category'] == selected_category) & 
                     (df['created_at'] >= start_date) & 
                     (df['created_at'] <= end_date)]

    co2_saved_fig = px.bar(filtered_df, x='created_at', y='co2_saved', color='action',
                           title='CO2 Saved over Time')

    duration_fig = px.line(filtered_df, x='created_at', y='duration', color='action',
                           title='Duration of Actions over Time')

    action_logs = filtered_df[['action', 'co2_saved', 'created_at']].to_dict('records')
    action_logs_output = [html.P(f"Action: {log['action']}, CO2 Saved: {log['co2_saved']}, Date: {log['created_at']}") for log in action_logs]

    return co2_saved_fig, duration_fig, action_logs_output

# Run the dashboard app
if __name__ == '__main__':
    app.run_server(debug=True)