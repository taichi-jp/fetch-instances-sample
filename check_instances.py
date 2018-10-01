import gspread
from oauth2client.service_account import ServiceAccountCredentials
import pandas as pd

scope = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
credentials = ServiceAccountCredentials.from_json_keyfile_name('sails-24e7e534a19d.json', scope)
gc = gspread.authorize(credentials)

allowed_instances = gc.open('無用GCE発見機 監視除外対象インスタンス').sheet1.get_all_values()
allowed_instances.pop(0)

df_allow = pd.DataFrame(allowed_instances, columns=['project', 'instance'])
df_running = pd.read_csv('./running_instances.csv')

df_disallowed = df_running[~df_running[['project','instance']].isin(df_allow.values.ravel()).all(1)]
df_disallowed.columns=['PROJECT', 'INSTANCE', 'ZONE', 'MACHINE_TYPE']

df_disallowed.to_csv('./disallowed_instances.csv', index=False)
