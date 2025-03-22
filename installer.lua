-- installer.lua
-- Automated installer for AutoDialer CC: Tweaked program

-- Configuration
local GITHUB_USERNAME = "Minecrafter8001"  -- Your GitHub username
local REPOSITORY_NAME = "autodialer"      -- Your repository name
local BRANCH = "main"                     -- Repository branch
local TARGET_DIR = "autoDialer"           -- Installation directory

-- Core files needed for the program
local REQUIRED_FILES = {
    "main.lua",
    "config.lua",
    "addressManager.lua",
    "dialing.lua"
}

-- Utility functions
local function constructUrl(filename)
    return string.format(
        "https://raw.githubusercontent.com/%s/%s/%s/%s",
        GITHUB_USERNAME, REPOSITORY_NAME, BRANCH, filename
    )
end

local function fileExists(filename)
    return fs.exists(filename)
end

local function deleteFile(filename)
    if fileExists(filename) then
        print("Removing existing: " .. filename)
        fs.delete(filename)
    end
end

local function createDirectory()
    if not fileExists(TARGET_DIR) then
        print("Creating directory: " .. TARGET_DIR)
        fs.makeDir(TARGET_DIR)
    end
end

-- File management functions
local function downloadFile(url, filePath)
    print("Downloading: " .. filePath)
    local response = http.get(url)
    
    if not response then
        print("Failed to download: " .. filePath)
        return false
    end
    
    local content = response.readAll()
    response.close()
    
    local fileHandle = fs.open(filePath, "w")
    fileHandle.write(content)
    fileHandle.close()
    
    print("Successfully downloaded: " .. filePath)
    return true
end

local function createLauncher()
    local launcherPath = "dialer.lua"
    print("Creating launcher: " .. launcherPath)
    
    local launcher = fs.open(launcherPath, "w")
    launcher.write([[
        -- Auto-generated launcher
        local main = require("autoDialer.main")
        main.mainMenu()
    ]])
    launcher.close()
end

-- Startup management
local function hasStartupEntry()
    if not fileExists("startup") then return false end
    
    local startupFile = fs.open("startup", "r")
    local content = startupFile.readAll()
    startupFile.close()
    
    return content:find("dialer%.lua") ~= nil
end

local function addToStartup()
    if hasStartupEntry() then
        print("Startup entry already exists")
        return
    end
    
    print("Adding to startup...")
    local startupFile = fs.open("startup", "a")
    startupFile.write("\nshell.run(\"dialer.lua\")")
    startupFile.close()
end

-- Main installation process
local function install()
    print("\n=== AutoDialer Installation ===")
    
    -- Set up directory structure
    createDirectory()
    deleteFile("dialer.lua")
    
    -- Download required files
    local allSuccess = true
    for _, filename in ipairs(REQUIRED_FILES) do
        local url = constructUrl(filename)
        local filePath = fs.combine(TARGET_DIR, filename)
        deleteFile(filePath)
        
        if not downloadFile(url, filePath) then
            allSuccess = false
        end
    end
    
    if not allSuccess then
        print("\nError: Some files failed to download!")
        print("Installation aborted.")
        return
    end
    
    -- Create launcher
    createLauncher()
    
    -- Startup configuration
    print("\nStartup configuration:")
    if hasStartupEntry() then
        print("Dialer is already configured to run at startup")
    else
        local add = getYesNoInput("Run dialer automatically on startup?")
        if add then
            addToStartup()
            print("Added to startup sequence")
        else
            print("Skipping startup configuration")
        end
    end
    
    print("\nInstallation completed successfully!")
    print("Run 'dialer.lua' to start the program.")
end

-- User prompt function
function getYesNoInput(prompt)
    while true do
        write(prompt .. " (y/n): ")
        local input = read():lower()
        if input == "y" then return true end
        if input == "n" then return false end
        print("Invalid input, please enter y or n")
    end
end

-- Start installation if internet is available
if http then
    install()
else
    print("Error: Internet access required for installation")
end