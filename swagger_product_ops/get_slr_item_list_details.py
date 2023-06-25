# for list of sellers from slr_list.xlsx get product list with page size
# results save in xlsx file

import requests
import pandas as pd

# Read the Excel file
df = pd.read_excel('slr_list.xlsx')

# Get the sellerId values from the 'seller_seq' column
seller_ids = df['seller_seq'].tolist()

# Create an empty list to store the results
results = []

url = "http://dbg-sc-product-api.prod1.k8s.ae-rus.net/v1/scroll-short-product-by-filter"
headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

for seller_id in seller_ids:
    data = {
        "filter": {
            "sellerId": str(seller_id),
            "status": "ONLINE"
        },
        "lastProductId": "0",
        "pageSize": "2",
        "stockNotReturning": True
    }

    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 200:
        json_data = response.json()
        results.append(json_data)
    else:
        print("Error:", response.status_code)

# Create a DataFrame from the results
results_df = pd.DataFrame(results)

# Save the results to a new Excel file
results_df.to_excel('results.xlsx', index=False)

print("Results saved to results.xlsx")
