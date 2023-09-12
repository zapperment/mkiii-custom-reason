local StateManager = require("src.lib.StateManager")

local stateManager = StateManager:new()

return {
    hasChanged = function(path)
        return stateManager:hasChanged(path)
    end,
    update = function(path)
        return StateManager:update(path)
    end,
    updateAll = function()
        StateManager:updateAll()
    end,
    get = function(path)
        return StateManager:get(path)
    end,
    getNext = function(path)
        return StateManager:getNext(path)
    end,
    set = function(path, next)
        StateManager:set(path, next)
    end,
    add = function(path, delta, min, max)
        StateManager:add(path, delta, min, max)
    end,
    flip = function(path)
        return StateManager:flip(path)
    end,
    inc = function(path)
        StateManager:inc(path)
    end,
    dec = function(path)
        StateManager:dec(path)
    end
}
