# get product main image url for list of items from xlsx file
# results save in output.xlsx file

import requests
import pandas as pd
import json

# Read the Excel file with item IDs
df = pd.read_excel('items.xlsx')

# Initialize an empty list to store the data
data_list = []

# Iterate over the item IDs in the Excel file
for item_id in df['item_id']:
    url = "link_to_api" # input here link to api
    headers = {
        "accept": "application/json",
        "Content-Type": "application/json"
    }
    data = {
        "ids": [str(item_id)],
        "contentTypes": [0],
        "locales": ["string"]
    }

    response = requests.post(url, headers=headers, json=data)
    data_list.append((str(item_id), response.json()))

# Create a new DataFrame with the item ID and data
output_df = pd.DataFrame(data_list, columns=['item_id', 'data'])

# Extract the required fields from the JSON data
data_list = []
for _, row in output_df.iterrows():
    item_id = row['item_id']
    json_data = row['data']
    media_url = json_data['data']['products'][0]['media'][0]['url']
    data_list.append({'item_id': item_id, 'media_url': media_url})

# Create a new DataFrame from the extracted data
final_df = pd.DataFrame(data_list)

# Save the final DataFrame to a new Excel file
final_df.to_excel('output_file.xlsx', index=False)
