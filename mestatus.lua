-----
----- mestatus.lua
----- by lillory
-----

title = "Crafting Status"
sleepTime = 3
shouldLog = true

ae2 = peripheral.find("meBridge")
mon = peripheral.find("monitor")

items = require("items")

function main()
    prepareMonitor()

    while true do
        checkTable()
        sleep(sleepTime)
    end
end


function prepareMonitor()
    mon.clear()
    putText(title, 1, "center", color)
end

function checkTable()
    row = 2
    --Loop through the items and check if they need to be crafted
    for i = 1, #items do
        tName = items[i][2]
        dName = items[i][1]
        amt = items[i][3]
        stockItem(tName, dName, amt)
    end

    --Check if anything is currently crafting
    --[[
    craftable = ae2.listCraftableItems()
    for i = 1, #craftable do
        tName = items[i].name
        dName = items[i][1]
        amt = items[i][3]
        checkCrafting(tName, dName, amt)
    end
    --]]
end

function stockItem(name, displayName, amountToStock)
    --check system, do nothing if not found/cant craft
    item = ae2.getItem({name = name})
    if not item.amount then
        log("Item not in system: " .. name)
        return
    end
    
    --craft items if needed
    amount = item.amount
    crafting = false
    if amount < amountToStock then
        crafting = ae2.isItemCrafting({name = name})
        if not crafting then
            count = amountToStock - amount
            craftedItem = {name = name, count = count}
            ae2.craftItem(craftedItem)
            log("Crafting " .. count .. "x " .. name)
            color = colors.blue
        end
    end

    --write to monitor
    row = row + 1
    amountStr = amount.." / "..amountToStock
    putText(displayName, row, "left", colors.lightGray)
    putText(amountStr, row, "right", color)
end





--Puts text on connected monitor
-- text: string
-- line: number
-- pos: "left", "right", "center"
-- fgColor: colors.*
-- ?bgColor: colors.*
-- ?gap: number
function putText(text, line, pos, fgColor, bgColor, gap)
    bgColor = bgColor or colors.black
    gap = gap or 1

    monW, _monH = mon.getSize()
    length = string.len(text)

    if pos == "center" then
        x = math.floor((monW-length)/2)+1
    elseif pos == "left" then
        x = 2
    elseif pos == "right" then
        x=0
    end
    clearBox(fgColor, bgColor, x, x+length+(2*gap), line, line)
    mon.setCursorPos(x, line)
    mon.write(text)
end

--Clear a specific area, prevents flickering
function clearBox(fgColor, bgColor, xMin, xMax, yMin, yMax)
    mon.setTextColor(fgColor)
    mon.setBackgroundColor(bgColor)
    for xPos = xMin, xMax, 1 do
        for yPos = yMin, yMax do
            mon.setCursorPos(xPos, yPos)
            mon.write(" ")
        end
    end
end


--log function
function log(text)
    if shouldLog then
        print(text)
    end
end

main()
