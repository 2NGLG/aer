# download template details into xlsx file

import pandas as pd
import json
import requests

# Read a template
templates = pd.read_excel('templates.xlsx', sheet_name='done')

# Create a list to store template info
template_info_list = []

for index, row in templates.iterrows():

    user_id = int(row['seller_id'])
    template_id = int(row['template_id'])

    headers = {
        'User-Agent': 'Ilgiz tool',
        'accept': 'application/json',
        'x-aer-seller-info': json.dumps({
            "user_id": str(user_id),
            "seller_id": str(user_id),
            "parent_seller_id": str(user_id),
            "havana_id": 0,
            "session_id": "",
            "intl_locale": "ru_RU",
            "ip": ""
        }),
        'Content-Type': 'application/json'
    }

    data = '{"template_delivery_id": ' + str(template_id) + '}'
    url = 'http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/get-detail-template-delivery'
    response = requests.post(url, headers=headers, data=data)

    # If the response is successful, extract and append template info to the list
    if response.status_code == 200:
        try:
            template = response.json()

            # Extract template information using error handling for missing keys
            template_info = {
                'seller_id': user_id,
                'template_id': template_id,
                'template_name': template['data'].get('template_name'),
                'warehouse_id': template['data']['warehouse'].get('id'),
                'name': template['data']['warehouse'].get('name'),
                'postcode': template['data']['warehouse'].get('postcode'),
                'phone': template['data']['warehouse'].get('phone'),
                'email': template['data']['warehouse'].get('email'),
                'country_code': template['data']['warehouse'].get('country_code'),
                'province': template['data']['warehouse'].get('province'),
                'province_code': template['data']['warehouse'].get('province_code'),
                'city': template['data']['warehouse'].get('city'),
                'city_code': template['data']['warehouse'].get('city_code'),
                'street_address': template['data']['warehouse'].get('street_address'),
                'work_schedule': json.dumps(template['data']['warehouse'].get('work_schedule')),
                'drop_off_point_id': template['data']['warehouse'].get('drop_off_point_id')
            }

            template_info_list.append(template_info)
        except KeyError:
            print(f"Error: Required key not found in template_info for seller_id={user_id}, template_id={template_id}")

# Create a DataFrame from the template info list
template_info_df = pd.DataFrame(template_info_list)

# Save template info to Excel file
template_info_df.to_excel('template_info.xlsx', index=False)

print("Template info saved to 'template_info.xlsx' file.")
