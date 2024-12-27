-- addressManager.lua
local config = require("config")
local addresses = {}

-- Load addresses from file
local function loadAddresses()
    if fs.exists(config.addressDir) then
        local file = fs.open(config.addressDir, "r")  -- Fixed the quotation marks
        local content = file.readAll()
        file.close()

        if content ~= "" then
            addresses = textutils.unserialize(content)
        end
    end
end

-- Save addresses to file
local function saveAddresses()
    local file = fs.open(config.addressDir, "w")  -- Fixed the quotation marks
    file.write(textutils.serialize(addresses))
    file.close()
end

-- Save a new address with alias
local function saveAddress(address, alias)
    addresses[alias] = address
    saveAddresses()
    print("Address saved with alias: " .. alias)
end

-- List saved addresses
local function listSavedAddresses(enable)
    
    if next(addresses) == nil then  -- Using next() to check for empty tables
        print("No addresses saved.")
        
    else
        print("Saved addresses:")
        for alias, address in pairs(addresses) do
            print("- " .. alias)
            print("--> " .. table.concat(address, "-"))

        end
    end
    while true do
        if enable and enable == true then
            print("Press any button to return...")
            os.pullEvent("key")
        end
    break
    end
end

-- Rename an address alias
local function renameAddress(oldAlias, newAlias)
    if addresses[oldAlias] then
        addresses[newAlias] = addresses[oldAlias]
        addresses[oldAlias] = nil
        saveAddresses()
        print("Alias renamed to: " .. newAlias)
    else
        print("Alias not found: " .. oldAlias)
    end
end

-- Get address by alias
local function getAddress(alias)
    return addresses[alias]
end

-- Load addresses at start
loadAddresses()

return {
    saveAddress = saveAddress,
    listSavedAddresses = listSavedAddresses,
    renameAddress = renameAddress,
    getAddress = getAddress
}

