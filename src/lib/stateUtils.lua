local states = require("states")
local tableUtils = require("tableUtils")

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

return {
    hasChanged = hasChanged,
    update = update,
    get = get,
    set = set,
    add = add
}
