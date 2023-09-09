local states = require("src.lib.states")
local tableUtils = require("src.lib.tableUtils")

local function hasChanged(path)
    local item = tableUtils.getValueFromPath(states, path)
    return item.next ~= item.current
end

local function update(path)
    local item = tableUtils.getValueFromPath(states, path)
    if not item then
        return
    end
    item.current = item.next
    return item.current
end

local function updateAll()
    for i = 1, 8 do
        update("knob" .. i .. ".label")
        update("knob" .. i .. ".value")
        update("knob" .. i .. ".enabled")
        update("button" .. i .. ".label")
        update("button" .. i .. ".value")
        update("button" .. i .. ".enabled")
        update("fader" .. i)
    end
    update("deviceType")
    update("deviceName")
    update("patchName")
    update("buttonColour")
    update("layer")
end

local function get(path)
    return tableUtils.getValueFromPath(states, path).current
end

local function getNext(path)
    return tableUtils.getValueFromPath(states, path).next
end

local function set(path, next)
    local item = tableUtils.getValueFromPath(states, path)
    item.next = next
end

local function inc(path)
    local item = tableUtils.getValueFromPath(states, path)
    local next = item.current + 1
    if next > 127 then
        next = 127
    end
    item.next = next
end

local function dec(path)
    local item = tableUtils.getValueFromPath(states, path)
    local next = item.current - 1
    if next < 0 then
        next = 0
    end
    item.next = next
end

local function add(path, delta, min, max)
    local item = tableUtils.getValueFromPath(states, path)
    local next = item.current + delta
    if min ~= nil and next < min then
        next = min
    end
    if max ~= nil and next > max then
        next = max
    end
    item.next = next
end

local function flip(path)
    local item = tableUtils.getValueFromPath(states, path)
    if item.current then
        item.next = false
    else
        item.next = true
    end
    return item.next
end

return {
    hasChanged = hasChanged,
    update = update,
    updateAll = updateAll,
    get = get,
    getNext = getNext,
    set = set,
    add = add,
    flip = flip,
    inc = inc,
    dec = dec
}
