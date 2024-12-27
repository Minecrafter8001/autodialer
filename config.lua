-- config.lua

local config = {
    isMilkyWay = false -- Default to false
}

-- Get the Stargate peripheral
local sg = peripheral.find("advanced_crystal_interface")

-- Check if the Stargate peripheral is present
if sg then
    -- Get the Stargate type using getStargateType
    local stargateType = sg.getStargateType()

    -- Check if the Stargate is a Milky Way Stargate
    if stargateType == "sgjourney:milky_way_stargate" then
        config.isMilkyWay = true
    end
end
addressDir = "./addresses.txt"

return config
