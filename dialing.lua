-- dialing.lua

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

local function slowDialStargate(address)
    local sg = peripheral.find("advanced_crystal_interface")
    print("Slow dialing Stargate...")

    for i, symbol in ipairs(address) do
        -- Rotate to the correct symbol
        sg.rotateClockwise(symbol)
        while not sg.isCurrentSymbol(symbol) do
            sleep(0.5)
        end
        sg.openChevron()
        sg.encodeChevron()
        sleep(0.5)
        sg.closeChevron()
    end

    while not sg.isWormholeOpen() do
        sleep(0.5)
    end

    print("Stargate connected!")
end

return {
    fastDialStargate = fastDialStargate,
    slowDialStargate = slowDialStargate
}
