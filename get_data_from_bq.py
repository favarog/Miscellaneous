from google.cloud import bigquery

def get_bq_data(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
        Args:
            event (dict): Event payload.
            context (google.cloud.functions.Context): Metadata for the event.
    """
    sql_query = "SELECT nome, email, telefone FROM `authentic-realm-329801.projeto_mensageria.miracle_form` ORDER BY timestamp DESC LIMIT 1"
    bq_client = bigquery.Client(project = 'authentic-realm-329801')
    query_job = bq_client.query(sql_query) # API request
    rows_df = query_job.result().to_dataframe() # Waits for query to finish

    print(rows_df.iloc[0]['nome'])
    print(rows_df.iloc[0]['telefone'])
    print(rows_df.iloc[0]['email'])
