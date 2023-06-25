# get list of templates for list of sellers

import pandas as pd
import numpy as np
import json
import requests

# read a template
templates = pd.read_excel('templates.xlsx', sheet_name='done')
for index, row in templates.iterrows():

    seller_id = str(row['seller_id'])
    url = 'http://dbg-sc-seller-api.dev1.k8s.ae-rus.net/v1/antifraud/seller/login/account_info'
    headers = {'accept': 'application/json', 'Content-Type': 'application/json'}
    data = '{"seller_login": "' + seller_id + '"}'
    response = requests.post(url, headers=headers, data=data)
    # convert response to json object, print the value ug user_id
    response_json = response.json()
    user_id = response_json['user_id']

    a = json.dumps({"user_id": str(user_id), "seller_id": str(user_id), "havana_id": 0, "session_id": "", "intl_locale": "ru_RU","ip": "", "parent_seller_id": str(user_id)})

    headers = {'User-Agent': 'Ilgiz tool', 'accept': 'application/json','x-aer-seller-info': a , 'Content-Type': 'application/json'}
    template_id = str(row['template_id'])
    data = '{"only_available": false}'

    url = 'http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/sellercenter/get-info-templates-by-seller'
    response = requests.post(url, headers=headers, data=data)
    template = response.json()
    # if error code 400, then skip the following code
    if response.status_code == 400:
        print(response.text)
        continue

    print(response.text)