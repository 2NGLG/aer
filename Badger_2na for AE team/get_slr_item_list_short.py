import requests
import pandas as pd

url = "link_to_api" # input here link to api
headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json'
}

# Read the Excel file containing the sellerIds
df = pd.read_excel('slr_list.xlsx')
seller_ids = df['seller_seq'].tolist()

# Iterate over the sellerIds and send requests
for seller_seq in seller_ids:
    data = {
        'sellerId': str(seller_seq),
        "status": "ONLINE",
        'lastId': '0',
        'limit': '1000',
        'withoutIds': True
    }

    all_items = []  # To store all item_id for a seller

    while True:
        response = requests.post(url, headers=headers, json=data)
        response_data = response.json()

        # Extract the item_id from the response
        item_id = response_data['data']
        all_items.extend(item_id)

        # Check if there are more item_id to fetch
        if len(item_id) < 1000:
            break

        # Update the lastId to fetch the next page
        last_id = item_id[-1]
        data['lastId'] = last_id

    # Save the item_id to a separate Excel file
    filename = f'{seller_seq}.xlsx'
    with pd.ExcelWriter(filename) as writer:
        df_products = pd.DataFrame(all_items, columns=['item_id'])
        df_products.to_excel(writer, index=False, sheet_name='products')

    print(f"Saved results for sellerId {seller_seq} to {filename}")
