import json
import requests
from datetime import datetime
from pytz import timezone
from google.cloud import bigquery
from google.oauth2 import service_account
from twilio.rest import Client

def decrypt(value):
  if value == None: return None
  result = ""
  array = value.split("|")
  for i in range(len(array)):
    result += chr(int(array[i]) -10)
  return result

def form_miracle_get(data_form_request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    
    data_e_hora_atuais = datetime.now()
    fuso_horario = timezone('America/Sao_Paulo')
    data_e_hora_sao_paulo = data_e_hora_atuais.astimezone(fuso_horario)

    # pega o valor do request do formulario
    data_form = data_form_request.get_json()
    nome = data_form_request.args.get('nome')
    telefone = data_form_request.args.get('telefone')
    email = data_form_request.args.get('email')
    canal_entrada = data_form_request.args.get('url')
    parametros = data_form_request.args.get('utm')
    data_e_hora_sao_paulo_em_texto = data_e_hora_sao_paulo.strftime('%Y-%m-%d %H:%M:%S')
    timestamp = data_e_hora_sao_paulo.timestamp()
    nome = decrypt(nome);
    telefone = decrypt(telefone);
    email = decrypt(email);

    credentials = service_account.Credentials.from_service_account_file('authentic-realm-329801-cd338ce36762.json')
    client = bigquery.Client(project='authentic-realm-329801', credentials=credentials)
    table_id = "authentic-realm-329801.projeto_mensageria.miracle_form"

    rows_to_insert = [{u"timestamp": timestamp,
                    u"nome": nome,
                    u"telefone": telefone,
                    u"email": email,
                    u"canal_entrada": canal_entrada,
                    u"utm": parametros},]
    errors = client.insert_rows_json(table_id, rows_to_insert)  # Make an API request.
    
    # Mandando o SMS
    account_sid = 'AC507d744e26d6afaab40daed9e628ecd0' 
    auth_token = '6cec36e2b06bc4fde3d59c93ba2b4284' 
    client = Client(account_sid, auth_token) 
    
    full_telefone = '+55'+telefone

    message = client.messages.create(  
                                messaging_service_sid='MGdfdb772929ce7c97a87c3f581e05cba0', 
                                body='Hello from Yo Labs!',      
                                to=full_telefone 
                            ) 
    
    print(message.sid)

    return 'ok'
