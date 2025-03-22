-- Advanced Stargate Control System
-- Requires Advanced Crystal Interface
-- Optional Transceiver support

-- Configuration Files
local ADDRESS_BOOK_FILE = "stargate/address_book.json"
local IDC_LIST_FILE = "stargate/authorized_idcs.json"
local CONFIG_FILE = "stargate/config.json"
local DEFAULT_FREQUENCY = 1234

-- Peripheral Initialization
local interface = peripheral.find("advanced_crystal_interface")
local transceiver = peripheral.find("transceiver")
local hasTransceiver = transceiver ~= nil

-- System State
local addressBook = {}
local authorizedIDCs = {}
local config = {
    autoOpenIris = true,
    autoCloseIris = true,
    dialmode = "fast"
}
local ignorableErrors = {
    0,
    1,
    -2
}

-- File Operations
local function loadJSONFile(path, default)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local data = textutils.unserializeJSON(file.readAll()) or default
        file.close()
        return data
    end
    return default
end

local function valueIn(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local function saveJSONFile(path, data)
    local file = fs.open(path, "w")
    file.write(textutils.serializeJSON(data))
    file.close()
end

-- System Initialization
local function initializeSystem()
    local i = 0
    term.setCursorPos(1, 1)
    term.write("\n=== Stargate Control System ===")

    addressBook = loadJSONFile(ADDRESS_BOOK_FILE, {})
    authorizedIDCs = loadJSONFile(IDC_LIST_FILE, {})
    config = loadJSONFile(CONFIG_FILE, config)
    
    if hasTransceiver then
        transceiver.setFrequency(DEFAULT_FREQUENCY)
        transceiver.setCurrentCode("")
    end
    while i <= 100 do
        sleep(0.05)
        local barLength = 25
        local bar = ""
        for _ = 1, math.floor(i / 100 * barLength) do
            bar = bar .. "="
        end
        for _ = 1, barLength - #bar do
            bar = bar .. " "
        end
        term.setCursorPos(1, 2)
        term.write(string.format("Initializing... [%s] %d%%", bar, i))
        i = i + 1
    end
end

local function error(msg)
    print("\nERROR: " .. msg)
    input = read()
end

-- Event Handlers
local function handleTransmissions()
    print("Listening for IDC transmissions...")
    while true do
        local event, freq, idc = os.pullEvent("transceiver_transmission_received")
        print(string.format("\n[RX] Frequency: %d | IDC: %s", freq, idc))
        
        local valid = false
        for _, v in ipairs(authorizedIDCs) do
            if idc == v then
                valid = true
                break
            end
        end

        if valid then
            if config.autoOpenIris then
                if interface.isStargateConnected() then
                    print(" Valid IDC authenticated! Opening iris...")
                    interface.openIris()
                else
                    print(" Valid IDC received but no active connection")
                end
            else
                print(" Valid IDC received (auto-open disabled)")
            end
        else
            print(" Invalid IDC - not in authorized list")
        end
    end
end

local function handleConnections()
    print("Listening for incoming connections...")
    while true do
        local event, connected, outgoing = os.pullEvent("stargate_connected")
        if connected and not outgoing and config.autoCloseIris then
            print("\nIncoming connection detected! Closing iris...")
            interface.closeIris()
        else
            print("\nIncoming connection detected (auto-close disabled)")
        end
    end
end

-- Dialing Functions
local function slowDial(address)
    for i, symbol in ipairs(address) do
        local feedback, msg = interface.rotateClockwise(symbol)
        print(string.format("Rotating to symbol %d: %d", i, symbol))
        
        while not interface.isCurrentSymbol(symbol) do
            sleep(0.1)
        end
        interface.endRotation()
        
        feedback, msg = interface.openChevron()
        if feedback ~= 0 then
            print("Error opening chevron:", msg)
            return false
        end
        
        feedback, msg = interface.closeChevron()
        if feedback ~= 0 then
            print("Error closing chevron:", msg)
            return false
        end
    end
    return true
end

local function fastDial(address)
    for _, symbol in ipairs(address) do
        local feedback, msg = interface.engageSymbol(symbol)
        if not valueIn(ignorableErrors, feedback) and feedback < 0 then
            error("Dialing failed\n" .. msg)
            return false
        elseif feedback == -2 then
        end
        sleep(0.5)
    end
    return true
end

-- Command Handlers
local function handleAddressBook(subcmd)
    if subcmd == "" then
    print("\nAddress Book Commands: add, remove, list")
    write("> ")
    subcmd = read()
    end
    
    if subcmd == "add" then
        print("Enter location name:")
        local name = read()
        print("Enter address (dash-separated):")
        local input = read()
        
        local address = {}
        for s in input:gmatch("%d+") do
            table.insert(address, tonumber(s))
        end
        
        if #address >= 6 and #address <= 9 then
            if #address < 9 then
                if address[#address] ~= 0 then
                    table.insert(address, 0)
                end
            end
            addressBook[name] = address
            saveJSONFile(ADDRESS_BOOK_FILE, addressBook)
            print("Address saved")
        else
            print("Invalid address length (6-9 symbols)")
        end
        
    elseif subcmd == "remove" then
        print("Enter location name:")
        local name = read()
        if addressBook[name] then
            addressBook[name] = nil
            saveJSONFile(ADDRESS_BOOK_FILE, addressBook)
            print("Address removed")
        else
            print("Address not found")
        end
        
    elseif subcmd == "list" then
        print("\nSaved Addresses:")
        for name, addr in pairs(addressBook) do
            print(string.format("  %-15s %s", name, interface.addressToString(addr)))
        end
        
    else
        print("Unknown book command")
    end
end

local function handleIris(subcmd)
    if subcmd == "" then
    print("\nIris Commands: open, close, status, autoopen, autoclose")
    write("> ")
    subcmd = read()
    end
    
    if subcmd == "open" then
        interface.openIris()
        print("Iris opening...")
    elseif subcmd == "close" then
        interface.closeIris()
        print("Iris closing...")
    elseif subcmd == "status" then
        local progress = interface.getIrisProgressPercentage()
        print(string.format("Iris: %d%% closed", progress))
    elseif subcmd == "autoopen" then
        config.autoOpenIris = not config.autoOpenIris
        saveJSONFile(CONFIG_FILE, config)
        print("Auto-open", config.autoOpenIris and "enabled" or "disabled")
    elseif subcmd == "autoclose" then
        config.autoCloseIris = not config.autoCloseIris
        saveJSONFile(CONFIG_FILE, config)
        print("Auto-close", config.autoCloseIris and "enabled" or "disabled")
    else
        print("Unknown iris command")
    end
end

local function handleRadio(subcmd)
    if not hasTransceiver then
        error("Transceiver not connected")
    end
    if subcmd == "" then
    print("\nRadio Commands: freq, idc, send, list")
    write("> ")
    subcmd = read()
    end
    if subcmd == "freq" then
        print("Enter new frequency:")
        local freq = tonumber(read())
        if freq then
            transceiver.setFrequency(freq)
            print("Frequency set to", freq)
        else
            print("Invalid frequency")
        end
        
    elseif subcmd == "idc" then
        print("Enter new IDC code:")
        local idc = read()
        transceiver.setCurrentCode(idc)
        print("IDC set to", idc)
        
    elseif subcmd == "send" then
        transceiver.sendTransmission()
        print("Transmission sent")
        
    elseif subcmd == "list" then
        print("\nAuthorized IDCs:")
        if #authorizedIDCs > 0 then
            for _, idc in ipairs(authorizedIDCs) do
                print("  "..idc)
            end
        else
            print("  No authorized IDCs configured")
        end
        
    else
        error("Unknown radio command")
    end
end

-- Main Interface
local function showStatus()
    print("\nSystem Status:")
    print("Connected:", interface.isStargateConnected() and "Yes" or "No")
    print("Auto-Open:", config.autoOpenIris and "ENABLED" or "DISABLED")
    print("Auto-Close:", config.autoCloseIris and "ENABLED" or "DISABLED")
    print("Chevrons Engaged:", interface.getChevronsEngaged())
    
    if hasTransceiver then
        print(string.format("\nTransceiver: %dMHz", transceiver.getFrequency()))
        print("Authorized IDCs:", #authorizedIDCs)
    end
end

local function switchdialmode(mode)
    if mode == "fast" or mode == "slow" then
        config.dialmode = mode
        saveJSONFile(CONFIG_FILE, config)
        print("Dialing mode:", config.dialmode)
    elseif mode == "" then
        if config.dialmode == "fast" then
            config.dialmode = "slow"
        else
            config.dialmode = "fast"
        end
        saveJSONFile(CONFIG_FILE, config)
        print("Dialing mode:", config.dialmode)
    else
        print("Invalid dialing mode")
    end
end

local function exit()
    interface.disconnectStargate()
    print("\nControl system shutdown complete")
    shell.exit()
end

local function dial(address)
    if config.dialmode == "fast" then
       return fastDial(address)
    else
        return slowDial(address)
    end
end

local function handleDialing(subcmd)
    if subcmd == "" then
    print("\nDialing Commands: dial, book")
    write("> ")
    subcmd = read()
    end

    if subcmd == "dial" then
        print("Enter address to dial (7-9 symbols):")
        write("> ")
        local input = read()
        local address = {}
        for s in input:gmatch("%d+") do
            table.insert(address, tonumber(s))
        end
        if address[#address] ~= 0 then
            table.insert(address, 0)
        end
        if #address >= 7 and #address <= 9 then
            if dial(address) then
                print("Dialing complete")
            else
                print("Dialing failed")
            end
        else
            print("Invalid address length (7-9 symbols)")
        end
    elseif subcmd == "book" then
        print("Enter address name to dial:")
        write("> ")
        subcmd = read()
    else
        print("Unknown dialing command")
        return
    end

    if addressBook[subcmd] then
        local address = addressBook[subcmd]
        if address[#address] ~= 0 then
            table.insert(address, 0)
        end
        if dial(address) then
            print("Dialing complete")
        else
            print("Dialing failed")
        end
    else
        print("Address not found")
    end

end
local function main()
while true do
    term.clear()
    print("\n=== Stargate Control System ===")
    showStatus()
    local commandList = {"dialer", "book", "iris", "dialmode", "close", "status", "exit"}
    if hasTransceiver then
        table.insert(commandList, #commandList-1, "idc")
    end
    print("\nCommands: " .. table.concat(commandList, ", "))
    write("> ")
    local command = read():lower()
    local cmd, subcmd = command:match("([^ ]*) *(.*)")
    if not subcmd then
        subcmd = ""
    end

    if cmd == "exit" then
        exit()

    elseif cmd == "status" then
        showStatus()

    elseif cmd == "dialmode" then
        switchdialmode(subcmd)

    elseif cmd == "dialer" then
        handleDialing(subcmd)

    elseif cmd == "book" then
        handleAddressBook(subcmd)

    elseif cmd == "iris" then
        handleIris(subcmd)

    elseif cmd == "idc" then
        handleRadio(subcmd)

    else
        print("Unknown command")
    end
end
end
term.clear()
initializeSystem()
parallel.waitForAll(handleTransmissions, handleConnections, main)