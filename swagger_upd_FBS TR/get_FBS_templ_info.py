# download template details for list of sellers and templates
# print results

import pandas as pd
import numpy as np
import json
import requests

# read a template
templates = pd.read_excel('templates.xlsx', sheet_name='done')
for index, row in templates.iterrows():

    user_id = int(row['seller_id'])
    print(user_id)

    # seller_id = str(row['seller_id'])
    # url = 'http://dbg-sc-seller-api.dev1.k8s.ae-rus.net/v1/antifraud/seller/login/account_info'
    # headers = {'accept': 'application/json', 'Content-Type': 'application/json'}
    # data = '{"seller_login": "' + seller_id + '"}'
    # response = requests.post(url, headers=headers, data=data)
    # # convert response to json object, print the value ug user_id
    # response_json = response.json()
    # user_id = response_json['user_id']

    headers = {'User-Agent': 'Ilgiz tool', 'accept': 'application/json',
               'x-aer-seller-info': '{"user_id": ' + str(user_id) + ', "seller_id":' + str(
                   user_id) + ', "parent_seller_id":' + str(
                   user_id) + ',"havana_id":0,"session_id":"","intl_locale":"ru_RU","ip":""}',
               'Content-Type': 'application/json'}
    template_id = int(row['template_id'])

    data = '{"template_delivery_id": ' + str(template_id) + '}'
    url = 'http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/get-detail-template-delivery'
    response = requests.post(url, headers=headers, data=data)
    template_data = response.json()
    # if error code 400, then skip the following code
    if response.status_code == 400:
        print(response.text)
        continue

    if response.status_code == 500:
        print(response.text)
        continue

    # Append the result to the results list
    if len(template_data) > 0:
        result = {
            'seller_id': user_id,
            'template_id': template_id,
            'template_info': template_data['data']['template_name'],
            'warehouse_id': template_data['data']['warehouse'].get('id'),
            'name': template_data['data']['warehouse'].get('name'),
            'postcode': template_data['data']['warehouse'].get('postcode'),
            'country_code': template_data['data']['warehouse'].get('country_code'),
            'street_address': template_data['data']['warehouse'].get('street_address')
        }
        # print(template_data)
        print(result)