sg = peripheral.wrap("right")
if sg.isStargateConnected() then
    sg.disconnectStargate()
end
print("Address:")
local input = read()
local address = {}
for num in string.gmatch(input, "%d+") do
    table.insert(address, tonumber(num))
end
while #address < 9 do
    table.insert(address, 0)
end

print("Dialing...")
for _, symbol in ipairs(address) do
    sg.engageSymbol(symbol)
    sleep(0.5)
end

while not sg.isWormholeOpen() do
    sleep(0.5)
end

print("SG connected")
