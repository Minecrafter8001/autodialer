-- main.lua

local dialing = require("autoDialer.dialing")
local addressManager = require("autoDialer.addressManager")
local config = require("autoDialer.config")

local function mainMenu()
    while true do
        print("\nStargate Dialer Menu:")
        print("1. Dial Stargate")
        print("2. Dial Stargate (Slow Dial)")
        print("3. Save an address")
        print("4. List saved addresses")
        print("5. Rename an address alias")
        print("6. Exit")
        print("Choose an option (1/2/3/4/5/6):")
        local choice = read()

        if choice == "1" then
            print("Enter Stargate address to dial (separated by dashes, e.g., 1-2-3):")
            local input = read()
            local address = {}
            for num in string.gmatch(input, "%d+") do
                local symbol = tonumber(num)
                if symbol < 0 or symbol > 38 then
                    error("Invalid symbol: " .. symbol)
                end
                table.insert(address, symbol)
            end
            while #address < 9 do
                table.insert(address, 0)
            end
            dialing.fastDialStargate(address)
        elseif choice == "2" then
            if config.isMilkyWay then
            print("Enter Stargate address to dial (separated by dashes, e.g., 1-2-3):")
            local input = read()
            local address = {}
            for num in string.gmatch(input, "%d+") do
                local symbol = tonumber(num)
                if symbol < 0 or symbol > 38 then
                    error("Invalid symbol: " .. symbol)
                end
                table.insert(address, symbol)
            end
            while #address < 9 do
                table.insert(address, 0)
            end
            dialing.slowDialStargate(address)
            else
                print("Slow dialing only avaliable on milky way stargates")
            end
        elseif choice == "3" then
            print("Enter a new Stargate address to save (separated by dashes, e.g., 1-2-3):")
            local input = read()
            local address = {}
            for num in string.gmatch(input, "%d+") do
                local symbol = tonumber(num)
                if symbol < 0 or symbol > 38 then
                    error("Invalid symbol: " .. symbol)
                end
                table.insert(address, symbol)
            end
            while #address < 9 do
                table.insert(address, 0)
            end
            print("Enter an alias for this address:")
            local alias = read()
            addressManager.saveAddress(address, alias)
        elseif choice == "4" then
            addressManager.listSavedAddresses()
        elseif choice == "5" then
            print("Enter the alias of the address you want to rename:")
            local oldAlias = read()
            print("Enter the new alias for this address:")
            local newAlias = read()
            addressManager.renameAddress(oldAlias, newAlias)
        elseif choice == "6" then
            print("Exiting...")
            break
        else
            print("Invalid option, please try again.")
        end
    end
end

-- Start the main menu
mainMenu()
