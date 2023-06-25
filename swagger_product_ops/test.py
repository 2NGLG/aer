import requests
import pandas as pd

url = 'http://dbg-sc-product-api.prod1.k8s.ae-rus.net/v1/product/seller-info/get-products'
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
        'lastId': '0',
        'limit': '1000',
        'withoutIds': True
    }

    all_products = []  # To store all products for a seller

    while True:
        response = requests.post(url, headers=headers, json=data)
        response_data = response.json()

        # Extract the products from the response
        products = response_data['data']
        all_products.extend(products)

        # Check if there are more products to fetch
        if len(products) < 1000:
            break

        # Update the lastId to fetch the next page
        last_id = products[-1]
        data['lastId'] = last_id

    # Save the products to a separate Excel file
    filename = f'seller_id_{seller_seq}.xlsx'
    with pd.ExcelWriter(filename) as writer:
        df_products = pd.DataFrame(all_products, columns=['Product'])
        df_products.to_excel(writer, index=False, sheet_name='Products')

    print(f"Saved results for sellerId {seller_seq} to {filename}")
