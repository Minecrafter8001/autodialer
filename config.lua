-- config.lua

local config = {
    isMilkyWay = false, -- Default to false
    addressDir = "./addresses.txt",
    interface = "advanced_crystal_interface"
}

-- Get the Stargate peripheral
local sg = peripheral.find(config.interface)

-- Check if the Stargate peripheral is present
if sg then
    -- Get the Stargate type using getStargateType
    local stargateType = sg.getStargateType()

    -- Check if the Stargate is a Milky Way Stargate
    if stargateType == "sgjourney:milky_way_stargate" then
        config.isMilkyWay = true
    end
end

return config
