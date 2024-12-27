import os
import sys
import requests
import re

PASTEBIN_API_URL = "https://pastebin.com/api/api_post.php"

def upload_to_pastebin(api_key, file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    
    data = {
        'api_dev_key': api_key,
        'api_option': 'paste',
        'api_paste_code': content,
    }
    response = requests.post(PASTEBIN_API_URL, data=data)
    
    if response.status_code == 200:
        return response.text.split('/')[-1]  # Extract and return the Paste ID
    else:
        raise Exception(f"Failed to upload to Pastebin: {response.text}")

def update_readme_with_paste_id(readme_path, paste_id):
    with open(readme_path, 'r') as file:
        content = file.read()
    
    # Update the Paste ID in the "install:" line
    updated_content = re.sub(
        r'(pastebin run )\w+',
        rf'\1{paste_id}',
        content
    )
    
    with open(readme_path, 'w') as file:
        file.write(updated_content)

if __name__ == "__main__":
    api_key = os.getenv("PASTEBIN_API_KEY")
    if not api_key:
        print("PASTEBIN_API_KEY not set in environment variables.")
        sys.exit(1)

    file_to_upload = sys.argv[1]
    readme_path = sys.argv[2]

    paste_id = upload_to_pastebin(api_key, file_to_upload)
    update_readme_with_paste_id(readme_path, paste_id)
