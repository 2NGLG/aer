# show warehouse details for one warehouse

import requests

url = 'http://dbg-lp-api-tarifficator.prod1.k8s.ae-rus.net/api/v2/warehouses/get-warehouses'
headers = {
    'accept': 'text/plain',
    'x-aer-sample-trace': 'true',
    'Content-Type': 'application/json-patch+json'
}
data = {
    'buyer_id': None,
    'warehouses': [
        {
            'first_mile_option': 'dropoff',
            'warehouse_id': 800000006133 # check warehouse id
        }
    ]
}

response = requests.post(url, headers=headers, json=data)

if response.status_code == 200:
    print('Request successful!')
    print('Response:')
    print(response.text)
else:
    print('Request failed with status code:', response.status_code)

