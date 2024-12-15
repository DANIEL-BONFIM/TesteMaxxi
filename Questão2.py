# Importando bibliotecas
#%%
import pandas as pd
import requests
import unicodedata

# URL Base https://www.swapi.tech/api/

# Função para percorrer cada paginca da API
def handler(rotas,pags):
  r = requests.get(f'https://www.swapi.tech/api/{rotas}?page={pags}&limit=5')
  infos = r.json()
  return infos 

# Função que busca as informações pertinentes para as rotas pelos id's, do planeta, pessoas e filmes
def pegando_infos (rotas,uid):
  r = requests.get(f'https://www.swapi.tech/api/{rotas}/{uid}')
  infos = r.json()
  return infos.get('result',[])

# Buscando as informações relevantes para cada rota
def obtendo_resultados (rotas):

# Guardando as informações
  df_uid = []
  df = []

# Para rota 'films' o resultado desejado está armazenado como 'result', e as outras rotas são armazenados como 'results'
  if rotas == 'films':

# Obtendo as listas até a 5º pagina
    for i in range(1,6):
      info = handler(rotas,i)
      response = info['result']
      df_uid.extend(response)

# Armazenando os ids para cada componente das rotas
    df_uid = pd.DataFrame(df_uid)
    uids = df_uid['uid'].to_list()

# Usando os ids armazenados para buscar as informações relevantes em "properties"
    for j in uids:
      response = pegando_infos(rotas,j)
      df.append(response['properties'])

# Armazenando o csv na pasta Raw
    df = pd.DataFrame(df)  
    df.to_csv(f'Raw\\{rotas}.csv', sep=';')


  else:
    for i in range(1,6):
      info = handler(rotas,i)
      response = info['results'] # 'People' e 'Planets' são armazenados como 'results'
      df_uid.extend(response)

    df_uid = pd.DataFrame(df_uid)
    uids = df_uid['uid'].to_list()

    for j in uids:
      response = pegando_infos(rotas,j)
      df.append(response['properties'])

    df = pd.DataFrame(df)  
    df.to_csv(f'Raw\\{rotas}.csv', sep=';', index=False)


# Realizando o processo de extração, armazenamento e tratamento

# Rotas desejadas
rotas = ('people','films','planets')

for rot in rotas:
  # Extraindo os dados 
  obtendo_resultados(rot)

  # Lendo os arquivos para tratá-los
  df = pd.read_csv(f'Raw\\{rot}.csv',sep=';')

  # Pegando as colunas string(object)
  colunas_lower = df.select_dtypes(include=object).columns

  for colunas in colunas_lower:
  # Padronização para lower case  
    df[colunas] = df[colunas].str.lower()

  # Tirando caracteres especiais
    df[colunas] = df[colunas].str.normalize('NFKD').str.encode('ASCII', 'ignore').str.decode('ASCII')   

  df.to_csv(f'Work\\{rot}_tratado.csv',sep=';', index=False)

# %%
