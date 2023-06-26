# for one seller_id find items from xlsx file and set new shipping template

import json

import requests
import pandas as pd

url = "link_to_api" # input here link to api
headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

# Read the data from the Excel file
df = pd.read_excel('items.xlsx')

# Iterate over each row in the DataFrame
for index, row in df.iterrows():
    item_id = row['item_id']

    # Create the payload data for the request
    data = {"seller_id": "4344523493","product_ids": [str(item_id)],"shipment_template_id": "34030978001"}

    # Make the POST request
    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        print(f"Item with ID {item_id} updated successfully!")
    else:
        print(f"Failed to update item with ID {item_id}. Error code: {response.status_code}")
