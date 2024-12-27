-- installer.lua

-- Set your GitHub username and repository name here
local username = "Minecrafter8001"   -- Replace with your GitHub username
local repoName = "autodialer"       -- Replace with your GitHub repository name

-- List of filenames to download (relative to the repo root)
local files = {
    "main.lua",
    "config.lua",
    "addressManager.lua",
    "dialing.lua"
}

-- Function to construct the raw GitHub URL for each file
local function constructUrl(filename)
    return "https://raw.githubusercontent.com/" .. username .. "/" .. repoName .. "/main/" .. filename
end

-- Function to download and save a file
local function downloadFile(url, filename)
    print("Downloading " .. filename .. "...")
    local response = http.get(url)
    if response then
        local content = response.readAll()
        local file = fs.open(filename, "w")
        file.write(content)
        file.close()
        print(filename .. " downloaded successfully!")
    else
        print("Failed to download " .. filename)
    end
end

-- Main installation function
local function install()
    print("Starting installer...")

    -- Download each file in the list
    for _, filename in ipairs(files) do
        local url = constructUrl(filename)
        downloadFile(url, filename)
    end

    print("Installation complete!")
end

-- Check for internet access
if http then
    install()
else
    print("Error: No internet access detected.")
end
