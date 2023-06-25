import json

import pandas as pd
import requests

# Read Excel file as a DataFrame
df = pd.read_excel('data_fbs_tr.xlsx')

# Convert DataFrame to list of dictionaries
records = df.to_dict('records')

# Print the records row by row
for record in records:
    seq = record['seq']
    xphone = record['xphone']
    xemail = record['xemail']
    xstreet_address = record['xstreet_address']
    xcontact_name = record['xcontact_name']
    a = json.dumps({"user_id": str(seq) , "seller_id": str(seq) , "parent_seller_id": str(seq) ,"havana_id":0,"session_id":"","intl_locale":"ru_RU","ip":""})

    # Make the API call using the extracted information
    url = "http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/create-template-delivery"
    headers = {"accept": "application/json", "x-aer-seller-info": a, "Content-Type": "application/json"}
    data = json.dumps({"template_type":"FBS_DROPOFF_COURIER","warehouse":{"name":"PTS 1","postcode":"101000","phone": str(xphone) ,"email": str(xemail) ,"country_code":"TR","provider_id":17,"province_code":"921800010000000000","city_code":"921800010001000000","street_address": str(xstreet_address) ,"is_default":False,"type":"SENDER","contact":"string","work_schedule":{"regular_schedule":[{"days":["FRIDAY","MONDAY","WEDNESDAY"],"intervals":[{"start":"10:00:00","end":"19:00:00"}]}]},"entry_comment":"","sla_hours":9,"admission_instructions":{"require_pass":False,"partially_loaded_vehicle_allowed":False},"dropoff_location_code":None,"first_mile_option":"DROPOFF","drop_off_point_id":1797620,"is_oversize":False,"contact_name": str(xcontact_name)}})

    response = requests.post(url, headers=headers, data=data)

    print(f"Response for row {record}: {response.status_code}")
    print(response.json())