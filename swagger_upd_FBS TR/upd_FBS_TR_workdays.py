# update FBS TR shipping template settings
# change working days only

import pandas as pd
import json
import requests

# Read the template schema edit JSON
with open('template_schema_edit.json') as json_file:
    edit_schema = json.load(json_file)

# Read the templates from the Excel file
templates = pd.read_excel('templates.xlsx', sheet_name='done')

for index, row in templates.iterrows():
    seller_id = str(row['seller_id'])
    url = 'http://dbg-sc-seller-api.dev1.k8s.ae-rus.net/v1/antifraud/seller/login/account_info'
    headers = {'accept': 'application/json', 'Content-Type': 'application/json'}
    data = '{"seller_login": "' + seller_id + '"}'
    response = requests.post(url, headers=headers, data=data)

    # Convert response to JSON object
    response_json = response.json()
    user_id = response_json['user_id']

    headers = {
        'User-Agent': 'Ilgiz tool',
        'accept': 'application/json',
        'x-aer-seller-info': json.dumps({
            "user_id": user_id,
            "seller_id": user_id,
            "parent_seller_id": user_id,
            "havana_id": 0,
            "session_id": "",
            "intl_locale": "ru_RU",
            "ip": ""
        }),
        'Content-Type': 'application/json'
    }

    template_id = str(row['template_id'])
    data = '{"template_delivery_id": ' + template_id + '}'
    url = 'http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/get-detail-template-delivery'
    response = requests.post(url, headers=headers, data=data)
    template = response.json()

    # If error code 400, then skip the following code
    if response.status_code == 400:
        print(response.text)
        continue

    edit_schema['template_delivery_id'] = template_id
    edit_schema['warehouse'] = template['data']['warehouse']
    edit_schema['warehouse']['address_id'] = edit_schema['warehouse']['id']

    # Modify only the regular_schedule days
    regular_schedule = edit_schema['warehouse']['work_schedule']['regular_schedule']
    for schedule in regular_schedule:
        schedule['days'] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

    data = json.dumps(edit_schema, ensure_ascii=False).encode('utf8')
    url = 'http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/edit-template-delivery'
    response = requests.post(url, headers=headers, data=data)

    print(response.text)
