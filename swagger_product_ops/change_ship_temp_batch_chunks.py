# for one seller update items from xlsx to set up new shipping template.
# use chunker to speed up the process

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

# Define a function to process items in chunks
def chunker(seq, size):
    return (seq[pos:pos + size] for pos in range(0, len(seq), size))

# Iterate over the items in chunks of 10
for item_chunk in chunker(df['item_id'], 10):
    item_ids = item_chunk.tolist()

    # Create the payload data for the request
    data = {
        "seller_id": "4038571206",
        "product_ids": [str(item_id) for item_id in item_ids],
        "shipment_template_id": "34030980001"
    }

    # Make the POST request
    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        print(f"Items {item_ids} updated successfully!")
    else:
        print(f"Failed to update items {item_ids}. Error code: {response.status_code}")
