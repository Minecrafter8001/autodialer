-- dialing.lua

local function fastDialStargate(address)
    local sg = peripheral.find("advanced_crystal_interface")
    print("Dialing Stargate...")

    for _, symbol in ipairs(address) do
        sg.engageSymbol(symbol)
        sleep(0.5)
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
        sg.encodeChevron()
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

return {
    fastDialStargate = fastDialStargate,
    slowDialStargate = slowDialStargate
}
