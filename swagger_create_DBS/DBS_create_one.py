# Create NEW DBS template with manually filled data
# Use if need to create one DBS template

import json
import requests

url_swagger = "link_to_api" # input here link to api
header = {
    "accept": "application/json",
    "x-aer-seller-info": '{"user_id": 4126555948, "seller_id":4126555948, "parent_seller_id":4126555948,"havana_id":0,"session_id":"","intl_locale":"ru_RU","ip":""}',
    "Content-Type": "application/json"
}
data_raw = json.dumps(
    {
        "custom_shipping_promises": [
            {
                "destination_zone_id": 1,
                "shipping_fee": 0,
                "commit_day": 20
            },
            {
                "destination_zone_id": 2,
                "shipping_fee": 0,
                "commit_day": 20
            },
            {
                "destination_zone_id": 3,
                "shipping_fee": 0,
                "commit_day": 40
            },
            {
                "destination_zone_id": 4,
                "shipping_fee": 0,
                "commit_day": 40
            },
            {
                "destination_zone_id": 5,
                "shipping_fee": 0,
                "commit_day": 40
            }
        ],
        "warehouse": {
            "name": "Test dbs wh",
            "phone": "909991112233",
            "country_code": "TR",
            "city_code": "921800340039000000",
            "province_code": "900100020000000000",
            "street_address": "Уральская ул дом 119/2",
            "contact": "Ванко Иван Иванович",
            "entry_comment": "",
            "post_code": "10005"
        }
    }
)

response = requests.post(url_swagger, headers=header, data=data_raw)

print(response.status_code)
print(response.json())
