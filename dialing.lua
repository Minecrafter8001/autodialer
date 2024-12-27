local addressManager = require("addressManager")
local config = require("config")

-- Fast dialing for Stargate
local function fastDialStargate(address)
    local sg = peripheral.find("advanced_crystal_interface")
    print("Dialing Stargate...")

    for _, symbol in ipairs(address) do
        sg.engageSymbol(symbol)
        sleep(0.5)
    end

    while not sg.isWormholeOpen() do
        sleep(0.5)
    end

    print("Stargate connected!")
end

-- Slow dialing for Stargate with optimized rotation direction
local function slowDialStargate(address)
    local sg = peripheral.find("advanced_crystal_interface")
    print("Slow dialing Stargate...")

    for i, symbol in ipairs(address) do
        -- Get the current symbol and calculate the fastest direction (clockwise or counter-clockwise)
        local currentSymbol = sg.getCurrentSymbol()
        local clockwiseDist = (symbol - currentSymbol) % 8
        local counterClockwiseDist = (currentSymbol - symbol) % 8

        -- Determine the fastest direction
        local rotateDirection = clockwiseDist <= counterClockwiseDist and "clockwise" or "counterClockwise"

        -- Rotate to the correct symbol
        if rotateDirection == "clockwise" then
            sg.rotateClockwise(symbol)
            while not sg.isCurrentSymbol(symbol) do
                sleep(0.1)
            end
        else
            sg.rotateAntiClockwise(symbol)
            while not sg.isCurrentSymbol(symbol) do
                sleep(0.1)
            end
        end

        sg.openChevron()
        sleep(0.1)
        sg.encodeChevron()
        sleep(0.1)
        sg.closeChevron()
    end

    -- Wait for wormhole to open with a timeout of 8 seconds using a counter
    local counter = 0
    local timeoutLimit = 8  -- 8 seconds timeout limit
    
    while not sg.isWormholeOpen() and counter < timeoutLimit do
        sleep(0.5)
        counter = counter + 0.5  -- increment by sleep time (0.5 seconds)
    end

    if sg.isWormholeOpen() then
        print("Stargate connected!")
    else
        print("Failed to connect to Stargate: Timeout.")
    end
end

-- Prompt user for dialer mode (Fast or Slow)
local function dialermode(address)
    while true do
        print("Choose dialing mode: (1) Fast, (2) Slow")
        local mode = read()
        if mode == "1" then
            fastDialStargate(address)
            break
        elseif mode == "2" then
            slowDialStargate(address)
            break
        else
            print("Invalid option, please try again.")
        end
    end
end

-- Main menu for dialing
local function dialermenu()
    while true do
        term.clear()
        print("\nStargate Dialer Menu:")
        print("1. Dial Saved Address")
        print("2. Dial Address")
        print("3. Close Connection")
        print("4. Exit")

        local choice = read()
        if choice == "1" then
            print("Enter the alias of the address you want to dial:")
            local alias = read()
            local address = addressManager.getAddress(alias)
            if address then
                dialermode(address)
            else
                print("Alias not found.")
            end
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
                dialermode(address)
            else
                print("Sorry, this feature is only available for Milky Way Stargates.")
            end
        elseif choice == "3" then
            if sg.isWormholeOpen() then
                address = sg.getConnectedAddress()
                sg.disconnectStargate()
                print("Disconnected Stargate from:")
                print(" " .. table.concat(address, "-"))
            else
                print("Stargate is not connected.")
            end    
            while true do
                os.pullEvent("key")
                print("Press any key to continue...")
            end
        elseif choice == "4" then
            print("Exiting...")
            break
        else
            print("Invalid option, please try again.")
        end
    end
end

return {
    fastDialStargate = fastDialStargate,
    slowDialStargate = slowDialStargate,
    dialermenu = dialermenu
}
