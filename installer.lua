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

-- Function to delete a file if it exists
local function deleteFileIfExists(filename)
    if fs.exists(filename) then
        print("Deleting existing file: " .. filename)
        fs.delete(filename)
    end
end

-- Create the autoDialer folder if it doesn't exist
local function createAutoDialerFolder()
    if not fs.exists("autoDialer") then
        fs.makeDir("autoDialer")
    end
end

-- Function to prompt user for yes/no input
local function getYesNoInput(prompt)
    while true do
        print(prompt .. " (y/n)")
        local input = read()
        if input == "y" or input == "Y" then
            return true
        elseif input == "n" or input == "N" then
            return false
        else
            print("Invalid input. Please enter 'y' or 'n'.")
        end
    end
end

-- Main installation function
local function install()
    print("Starting installer...")

    -- Create the autoDialer directory
    createAutoDialerFolder()

    -- Delete existing files if they exist before downloading
    deleteFileIfExists("dialer.lua")
    deleteFileIfExists("startup")

    -- Delete all files in the autoDialer folder if they exist
    for _, filename in ipairs(files) do
        deleteFileIfExists("autoDialer/" .. filename)
    end

    -- Download each file and save it in the appropriate directory
    for _, filename in ipairs(files) do
        local url = constructUrl(filename)
        downloadFile(url, "autoDialer/" .. filename)
    end

    -- Create a dialer.lua file that simply calls main.lua
    local dialerFile = fs.open("dialer.lua", "w")
    dialerFile.write([[
        -- dialer.lua
        local main = require("autoDialer.main")
        main.mainMenu()
    ]])
    dialerFile.close()
    print("dialer.lua created successfully!")

    -- Prompt user for adding to startup
    local addToStartup = getYesNoInput("Would you like to add the dialer to startup?")

    if addToStartup then
        local startupFile = fs.open("startup", "w")
        startupFile.write([[
            -- startup
            shell.run("dialer.lua")
        ]])
        startupFile.close()
        print("Dialer added to startup.")
    else
        print("Dialer was not added to startup.")
    end

    print("Installation complete!")
end

-- Check for internet access
if http then
    install()
else
    print("Error: No internet access detected.")
end
