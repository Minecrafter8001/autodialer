import requests

def delete_paste(api_key, paste_id):
    """Deletes an existing paste."""
    url = "https://pastebin.com/api/api_post.php"
    data = {
        "api_dev_key": api_key,
        "api_paste_key": paste_id,
        "api_option": "delete",
    }

    response = requests.post(url, data=data)

    if response.status_code == 200 and response.text.strip() == "Paste Removed":
        print("Successfully deleted the existing paste.")
    else:
        raise Exception(f"Failed to delete paste: {response.text}")

def create_paste(api_key, file_path):
    """Creates a new paste and returns the paste ID."""
    with open(file_path, 'r') as file:
        content = file.read()

    url = "https://pastebin.com/api/api_post.php"
    data = {
        "api_dev_key": api_key,
        "api_paste_code": content,
        "api_option": "paste",
        "api_paste_name": "Installer Script",  # Optional: Name for the paste
        "api_paste_expire_date": "N",         # Optional: Expiry date
    }

    response = requests.post(url, data=data)

    if response.status_code == 200 and not response.text.startswith("Bad API request"):
        return response.text.strip().split("/")[-1]  # Extract the paste ID
    else:
        raise Exception(f"Failed to create paste: {response.text}")

def upload_or_update_pastebin(api_key, file_path, existing_paste_id=None):
    """Deletes the old paste if it exists and creates a new one."""
    if existing_paste_id:
        delete_paste(api_key, existing_paste_id)  # Delete the existing paste

    new_paste_id = create_paste(api_key, file_path)  # Create a new paste
    return new_paste_id

# Example usage
if __name__ == "__main__":
    import sys

    if len(sys.argv) < 3:
        print("Usage: python pastebin-sync.py <file_to_upload> <readme_file>")
        sys.exit(1)

    api_key = "your_api_key_here"  # Replace with your Pastebin API key
    file_to_upload = sys.argv[1]
    readme_file = sys.argv[2]

    # Extract existing paste ID from README
    with open(readme_file, 'r') as readme:
        content = readme.read()
    existing_paste_id = None
    if "pastebin run " in content:
        existing_paste_id = content.split("pastebin run ")[1].split('"')[0]

    try:
        # Upload or update the paste
        updated_paste_id = upload_or_update_pastebin(api_key, file_to_upload, existing_paste_id)

        # Update README with new Paste ID
        updated_content = content.replace(existing_paste_id, updated_paste_id) if existing_paste_id else content
        with open(readme_file, 'w') as readme:
            readme.write(updated_content)
        print(f"Updated README with new Paste ID: {updated_paste_id}")

    except Exception as e:
        print(str(e))
