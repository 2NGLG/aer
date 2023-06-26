# get seller_id from slr_list.xlsx to open seller files with item_id
# for items downloads images, makes resize and adds tags

import glob
import os
import pandas as pd
import requests
from PIL import Image


def download_image(media_url, file_path):
    response = requests.get(media_url)
    with open(file_path, 'wb') as file:
        file.write(response.content)

def resize_image(image, size):
    width, height = image.size
    new_size = (size, size)
    if width > height:
        ratio = float(size) / width
        new_height = int(ratio * height)
        resized_image = image.resize((size, new_height))
        top_padding = int((size - new_height) / 2)
        new_image = Image.new('RGB', (size, size), (255, 255, 255))
        new_image.paste(resized_image, (0, top_padding))
    else:
        ratio = float(size) / height
        new_width = int(ratio * width)
        resized_image = image.resize((new_width, size))
        left_padding = int((size - new_width) / 2)
        new_image = Image.new('RGB', (size, size), (255, 255, 255))
        new_image.paste(resized_image, (left_padding, 0))
    return new_image


def add_tag_to_image(file_path, tag_path):
    image = Image.open(file_path)
    # image = image.resize((1000, 1000))
    max_size = 1000
    image = resize_image(image, max_size)

    tag_image = Image.open(tag_path)
    combined_image = Image.new('RGB', image.size)
    combined_image.paste(image, (0, 0))
    combined_image.paste(tag_image, (0, 0), tag_image)

    combined_image.save(file_path)


slr_df = pd.read_excel('slr_list.xlsx')
seller_seqs = slr_df['seller_seq']

for seller_seq in seller_seqs:
    print(seller_seq)
    file_path = f"{seller_seq}.xlsx"
    if os.path.isfile(file_path):
        df = pd.read_excel(file_path)
        item_ids = df['item_id'].tolist()

        data_list = []

        # Create the folder for the seller_seq if it doesn't exist
        seller_folder = str(seller_seq)
        if not os.path.exists(seller_folder):
            os.makedirs(seller_folder)

        # Create the 'original_new' folder if it doesn't exist
        original_new_folder = os.path.join(seller_folder, 'original_new')
        if not os.path.exists(original_new_folder):
            os.makedirs(original_new_folder)

        # Create the 'with_tag_new' folder if it doesn't exist
        with_tag_new_folder = os.path.join(seller_folder, 'with_tag_new')
        if not os.path.exists(with_tag_new_folder):
            os.makedirs(with_tag_new_folder)

        # Create list of lost items
        lost_items = []

        for item_id in item_ids:
            print(item_id)
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


            # Download and save the original image
            json_data = response.json()
            if len(json_data['data']['products']) > 0:
                media_url = json_data['data']['products'][0]['media'][0]['url']
                data_list.append((str(item_id), media_url))

                image_data = requests.get(media_url).content
                file_path = os.path.join(original_new_folder,
                                         f"{item_id}_1.jpg")  # Modify the file extension if necessary
                with open(file_path, 'wb') as file:
                    file.write(image_data)
            else:
                lost_items.append(str(item_id))

        output_df = pd.DataFrame(data_list, columns=['item_id', 'data'])
        output_df.to_excel('./'+seller_folder+'/output_df.xlsx', index=False)

        if len(lost_items) > 0:
            lost_items_df = pd.DataFrame(lost_items, columns=['item_id'])
            lost_items_df.to_excel('./'+seller_folder+'/lost_items_df.xlsx', index=False)

        data_list = []
        for _, row in output_df.iterrows():
            item_id = row['item_id']
            media_url = row['data']
            # print(json_data['data'])

            # Download and save the images with the tag
            file_extension = media_url.split('.')[-1]
            filename = f'{item_id}_1.jpg'
            file_path = os.path.join(with_tag_new_folder, filename)

            download_image(media_url, file_path)

            tag_path = "tags/1001.png"
            if os.path.isfile(tag_path):
                add_tag_to_image(file_path,tag_path)
