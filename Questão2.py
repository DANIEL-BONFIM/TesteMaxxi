# Importando bibliotecas
#%%
import pandas as pd
import requests

# URL Base https://www.swapi.tech/api/

# Função para percorrer cada API
def handler(rotas,pags):
  r = requests.get(f'https://www.swapi.tech/api/{rotas}?page={pags}&limit=5')
  infos = r.json()
  return infos #infos.get('result',[]).get('properties',[])

def pegando_infos (rotas,uid):
  r = requests.get(f'https://www.swapi.tech/api/{rotas}/{uid}')
  infos = r.json()
  return infos.get('result',[])

def obtendo_resultados (rotas):
# Guardando as informações
  df_uid = []
  df = []

  if rotas == 'films':
# Obtendo as listas até a 5º pagina
    for i in range(1,6):
      info = handler(rotas,i)
      response = info['result']
      df_uid.extend(response)

    df_uid = pd.DataFrame(df_uid)
    uids = df_uid['uid'].to_list()

    for j in uids:
      response = pegando_infos(rotas,j)
      df.append(response['properties'])

    df = pd.DataFrame(df)  
    df.to_csv(f'Raw\\{rotas}.csv', sep=';')
  
  else:
    for i in range(1,6):
      info = handler(rotas,i)
      response = info['results']
      df_uid.extend(response)

    df_uid = pd.DataFrame(df_uid)
    uids = df_uid['uid'].to_list()

    for j in uids:
      response = pegando_infos(rotas,j)
      df.append(response['properties'])

    df = pd.DataFrame(df)  
    df.to_csv(f'Raw\\{rotas}.csv', sep=';', index=False)

rotas = ('people','films','planets')

for rot in rotas:
  obtendo_resultados(rot)
  