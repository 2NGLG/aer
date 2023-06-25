# update FBS TR shipping template settings
# added postcode formatting
# fixed contact name field

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

    headers = {'User-Agent': 'Ilgiz tool', 'accept': 'application/json',
               'x-aer-seller-info': '{"user_id": ' + str(user_id) + ', "seller_id":' + str(
                   user_id) + ', "parent_seller_id":' + str(
                   user_id) + ',"havana_id":0,"session_id":"","intl_locale":"ru_RU","ip":""}',
               'Content-Type': 'application/json'}
    template_id = str(row['template_id'])

    data = '{"template_delivery_id": ' + str(template_id) + '}'
    url = 'http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/get-detail-template-delivery'
    response = requests.post(url, headers=headers, data=data)
    template = response.json()
    # if error code 400, then skip the following code
    if response.status_code == 400:
        print(response.text)
        continue

    with open('template_schema_edit.json') as json_file:
        edit_schema = json.load(json_file)
    edit_schema['template_delivery_id'] = template_id
    edit_schema['warehouse'] = template['data']['warehouse']
    edit_schema['warehouse']['address_id'] = edit_schema['warehouse']['id']
    print(edit_schema['warehouse']['address_id'])

    # dropp edit_schema['warehouse']['address_id'] from the array
    del edit_schema['warehouse']['id']
    edit_schema['warehouse']['drop_off_point_id'] = 1797620
    edit_schema['warehouse']['contact'] = row['contact_name']

    # set row['postcode'] equal to edit_schema['warehouse']['postcode'] . if the length is less than 5, then add leading zeros
    if len(str(row['postcode'])) < 6:
        edit_schema['warehouse']['postcode'] = str(row['postcode']).zfill(5)
    else:
        edit_schema['warehouse']['postcode'] = str(row['postcode'])

    edit_schema['warehouse']['sla_hours'] = 9

    # if edit_schema['warehouse']['dropoff_location_code'] exists then drop it
    if 'dropoff_location_code' in edit_schema['warehouse']:
        del edit_schema['warehouse']['dropoff_location_code']

    data = json.dumps(edit_schema, ensure_ascii=False).encode('utf8')
    url = 'http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/edit-template-delivery'
    response = requests.post(url, headers=headers, data=data)

    print(response.text)