# change shipping template for one seller and one item

import requests
import json

url = "link_to_api" # input here link to api

headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

data = {
    "seller_id": "4344523493",
    "product_ids": ["1005005154149813", "1005005154168606", "1005005154178568"],
    "shipment_template_id": "34030978001"
}

response = requests.post(url, headers=headers, data=json.dumps(data))

if response.status_code == 200:
    print("Request successful!")
    print("Response:")
    print(response.json())
else:
    print("Request failed with status code:", response.status_code)

