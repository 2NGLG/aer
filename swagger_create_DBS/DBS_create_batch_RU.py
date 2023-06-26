# create NEW DBS RU template (we used this for CN sellers who wanted to ship from RU WH)
# using the data from data_dbs.xlsx (seller_seq, phone, street_address, contact_name, postcode)

import json
import pandas as pd
import requests

# Read Excel file as a DataFrame
df = pd.read_excel('data_dbs.xlsx')

# Convert DataFrame to list of dictionaries
records = df.to_dict('records')

# Print the records row by row
for record in records:
    seq = record['seq']
    xphone = record['xphone']
    xstreet_address = record['xstreet_address']
    xcontact_name = record['xcontact_name']
    xpostcode = record['xpostcode']
    a = json.dumps({"user_id": str(seq) , "seller_id": str(seq) , "parent_seller_id": str(seq) ,"havana_id":0,"session_id":"","intl_locale":"ru_RU","ip":""})

    # Make the API call using the extracted information
    url = "link_to_api" # input here link to api
    headers = {"accept": "application/json", "x-aer-seller-info": a, "Content-Type": "application/json"}
    data = json.dumps({"custom_shipping_promises": [{"destination_zone_id": 1,"shipping_fee": 0,"commit_day": 15},{"destination_zone_id": 2,"shipping_fee": 0,"commit_day": 25},{"destination_zone_id": 3,"shipping_fee": 0,"commit_day": 30},{"destination_zone_id": 4,"shipping_fee": 0,"commit_day": 30},{"destination_zone_id": 5,"shipping_fee": 0,"commit_day": 30}],"warehouse": {"name": "dbs wh","phone": str(xphone),"country_code": "RU","city_code": "917477670000000000","province_code": "917477670000000000","street_address": str(xstreet_address),"contact": str(xcontact_name),"entry_comment": "","post_code": str(xpostcode)}})

    response = requests.post(url, headers=headers, data=data)

    print(f"Response for row {record}: {response.status_code}")
    print(response.json())
