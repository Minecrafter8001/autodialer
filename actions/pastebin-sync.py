import os
import sys
import requests
import re

PASTEBIN_API_URL = "https://pastebin.com/api/api_post.php"

def extract_paste_id_from_readme(readme_path):
    """Extract the existing Paste ID from the README.md file."""
    with open(readme_path, 'r') as file:
        content = file.read()
    
    match = re.search(r'pastebin run (\w+)', content)
    if match:
        return match.group(1)
    else:
        return None

def upload_or_update_pastebin(api_key, file_path, paste_id=None):
    """Upload a new paste or update an existing paste on Pastebin."""
    with open(file_path, 'r') as file:
        content = file.read()
    
    data = {
        'api_dev_key': api_key,
        'api_paste_code': content,
    }
    
    # Use 'edit' option if updating an existing paste
    if paste_id:
        data['api_option'] = 'edit'
        data['api_paste_key'] = paste_id
    else:
        data['api_option'] = 'paste'
    
    response = requests.post(PASTEBIN_API_URL, data=data)
    
    if response.status_code == 200:
        if paste_id:
            print(f"Successfully updated paste: {paste_id}")
            return paste_id
        else:
            new_paste_id = response.text.split('/')[-1]
            print(f"Successfully created new paste: {new_paste_id}")
            return new_paste_id
    else:
        raise Exception(f"Failed to upload/update paste: {response.text}")

def update_readme_with_paste_id(readme_path, paste_id):
    """Update the README.md with the new Paste ID."""
    with open(readme_path, 'r') as file:
        content = file.read()
    
    # Replace the Paste ID in the "install:" line
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

    # Extract the existing Paste ID from the README.md
    existing_paste_id = extract_paste_id_from_readme(readme_path)
    if existing_paste_id:
        print(f"Found existing Paste ID in README: {existing_paste_id}")
    else:
        print("No existing Paste ID found in README. A new paste will be created.")

    # Upload or update the paste on Pastebin
    updated_paste_id = upload_or_update_pastebin(api_key, file_to_upload, existing_paste_id)

    # Update the README.md with the new Paste ID
    update_readme_with_paste_id(readme_path, updated_paste_id)
