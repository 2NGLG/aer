# create FBS TR shipping template
# input seller_id in header manually
# change shipping template details manually in body

import json
import requests

url_swagger = "http://logistics-sx-web-onboarding.prod1.k8s.ae-rus.net/api/v1/onboarding/create-template-delivery"

# check seller_id in header
header = {
    "accept": "application/json",
    "x-aer-seller-info": '{"user_id": 4437451693, "seller_id":4437451693, "parent_seller_id":4437451693,"havana_id":0,"session_id":"","intl_locale":"ru_RU","ip":""}',
    "Content-Type": "application/json"
}

# check the info in data
data_raw = json.dumps(
    {
        "template_type": "FBS_DROPOFF_COURIER",
        "warehouse": {
            "name": "PTS 1",
            "postcode": "101000", # check
            "phone": "905066680930", # check
            "email": "aliexpress@sefertur.com", # check
            "country_code": "TR",
            "provider_id": 17,
            "province_code": "921800010000000000",
            "city_code": "921800010001000000",
            "street_address": "MALTEPE MAH. G.M.K. BULV. NO:31/2 ÇANKAYA / ANKARA", # check
            "is_default": False,
            "type": "SENDER",
            "contact": "string", # check
            "work_schedule": {
                "regular_schedule": [
                    {
                        "days": [
                            "FRIDAY",
                            "THURSDAY",
                            "MONDAY",
                            "TUESDAY",
                            "WEDNESDAY"
                        ],
                        "intervals": [
                            {
                                "start": "10:00:00",
                                "end": "19:00:00"
                            }
                        ]
                    }
                ]
            },
            "entry_comment": "",
            "sla_hours": 9,
            "admission_instructions": {
                "require_pass": False,
                "partially_loaded_vehicle_allowed": False
            },
            "dropoff_location_code": None,
            "first_mile_option": "DROPOFF",
            "drop_off_point_id": 1797620,
            "is_oversize": False,
            "contact_name": "string"
        }
    }
)

response = requests.post(url_swagger, headers=header, data=data_raw)

print(response.status_code)
print(response.json())
