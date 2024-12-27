import sys
import requests

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
        return response.text  # Pastebin URL
    else:
        raise Exception(f"Failed to upload to Pastebin: {response.text}")

def update_readme(readme_path, pastebin_url):
    with open(readme_path, 'r') as file:
        lines = file.readlines()
    
    with open(readme_path, 'w') as file:
        for line in lines:
            if line.startswith("Pastebin URL:"):
                file.write(f"Pastebin URL: {pastebin_url}\n")
            else:
                file.write(line)

if __name__ == "__main__":
    api_key = os.getenv("PASTEBIN_API_KEY")
    if not api_key:
        print("PASTEBIN_API_KEY not set in environment variables.")
        sys.exit(1)

    file_to_upload = sys.argv[1]
    readme_path = sys.argv[2]

    pastebin_url = upload_to_pastebin(api_key, file_to_upload)
    update_readme(readme_path, pastebin_url)
