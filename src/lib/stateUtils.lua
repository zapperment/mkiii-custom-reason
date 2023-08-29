local states = require("lib.states")
local tableUtils = require("lib.tableUtils")

local function hasChanged(path)
    local item = tableUtils.getValueFromPath(states, path)
    return item.next ~= item.current
end

local function update(path)
    local item = tableUtils.getValueFromPath(states, path)
    item.current = item.next
    return item.current
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
end

return {
    hasChanged = hasChanged,
    update = update,
    get = get,
    getNext = getNext,
    set = set,
    add = add,
    flip = flip
}
