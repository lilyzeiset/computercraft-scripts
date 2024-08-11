-----
----- mestatus.lua
----- by lillory
-----

sleepTime = 3
shouldLog = true

ae2 = peripheral.find("meBridge")
mon = peripheral.find("monitor")

items = require("items")
row = 1

function main()
    mon.clear()
    while true do
        cpuDetails()
        itemsToCraft()
        clearToEnd(row+1)
        sleep(sleepTime)
    end
end

--Loop through the items and check if they need to be crafted
function itemsToCraft()
    advAndClear()
    putText("Crafting Status", row, "center", colors.white)
    for i = 1, #items do
        tName = items[i][2]
        dName = items[i][1]
        amt = items[i][3]
        stockItem(tName, dName, amt)
    end
end

function cpuDetails()
    cpus = ae2.getCraftingCPUs()
    if cpus then
        advAndClear()
        putText("Crafting CPUs", row, "center", colors.white)
        for i=1,#cpus do
            stor = cpus[i].storage
            proc = cpus[i].coProcessors
            busy = cpus[i].isBusy

            --convert number to thous(k) or mils(M)
            if stor > 999999 then
                storStr = math.floor(stor/1000000).."M"
            elseif stor > 999 then
                storStr = math.floor(stor/1000).."k"
            else
                storStr = stor
            end

            --show if busy
            color = colors.white
            extra = ""
            if busy then
                color = colors.orange
                extra = " [Busy]"
            end

            --write cpu to monitor
            advAndClear()
            putText("CPU #"..i..extra, row, "left", color)
            putText(storStr.."|"..proc, row, "right", colors.lightGray)
        end
    end
end

function stockItem(name, displayName, amountToStock)
    --check system, do nothing if not found/cant craft
    item = ae2.getItem({name = name})
    if not item or not item.amount then
        log("Item not in system: " .. name)
        return
    end
    
    --craft items if needed
    amount = item.amount
    crafting = false
    color = colors.green
    if amount < amountToStock then
        --Dont try to craft if not possible
        craftable = ae2.isItemCraftable({name = name})
        if not craftable then
            log("Item not craftable: " .. name)
            color = colors.red
        end

        --Craft if possible and not already crafting
        crafting = ae2.isItemCrafting({name = name})
        if craftable and not crafting then
            amountToCraft = amountToStock - amount
            craftedItem = {name = name, amountToCraft = amountToCraft}
            log("Crafting " .. amountToCraft .. "x " .. name)
            ae2.craftItem(craftedItem)
            color = colors.blue
        end
    end

    --write item to monitor
    amountStr = amount.." / "..amountToStock
    advAndClear()
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

    monW, _ = mon.getSize()
    length = string.len(text)

    if pos == "center" then
        x = 1+math.floor((monW-length)/2)
    elseif pos == "left" then
        x = 1
    elseif pos == "right" then
        x = monW-length-(gap*2)
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



--advance and clear line
function advAndClear()
    row = row + 1
    mon.setCursorPos(1,row)
    mon.clearLine()
end

--Clear lines from startLine to end of monitor
function clearToEnd(startLine)
    _, monH = mon.getSize()

    for i=startLine,monH do
        mon.setCursorPos(1,i)
        mon.clearLine()
    end
end


--log function
function log(text)
    if shouldLog then
        print(text)
    end
end

main()
