-- addressManager.lua
local config = require("autoDialer.config")
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
local function listSavedAddresses()
    if next(addresses) == nil then  -- Using next() to check for empty tables
        print("No addresses saved.")
        return
    end
    print("Saved addresses:")
    for alias, _ in pairs(addresses) do
        print("- " .. alias)
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

-- Load addresses at start
loadAddresses()

return {
    saveAddress = saveAddress,
    listSavedAddresses = listSavedAddresses,
    renameAddress = renameAddress
}
