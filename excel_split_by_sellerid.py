import pandas as pd

# Read the data from the input Excel file
df = pd.read_excel('temp_min_item_price_1685032904470.xlsx')

# Group the data by unique seller_admin_id
grouped_data = df.groupby('seller_admin_id')

# Save data in separate Excel files for each unique seller_admin_id
for seller_admin_id, group in grouped_data:
    # Create a new Excel file name using the seller_admin_id
    output_file_name = f'seller_{seller_admin_id}.xlsx'

    # Save the group data to the new Excel file, setting the data type as string
    group.astype(str).to_excel(output_file_name, index=False)

