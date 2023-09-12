local constants = require("src.lib.constants")
local faderStates = require("src.lib.faderStates")
local tableUtils = require("src.lib.tableUtils")

local StateManager = {
    knob1 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    knob2 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    knob3 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    knob4 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    knob5 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    knob6 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    knob7 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    knob8 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = 0,
            next = 0
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button1 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button2 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button3 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button4 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button5 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button6 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button7 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    button8 = {
        label = {
            current = " ",
            next = " "
        },
        value = {
            current = false,
            next = false
        },
        enabled = {
            current = false,
            next = false
        }
    },
    deviceType = {
        current = " ",
        next = " "
    },
    deviceName = {
        current = " ",
        next = " "
    },
    patchName = {
        current = " ",
        next = " "
    },
    buttonColour = {
        current = constants.mainColour,
        next = constants.mainColour
    },
    layer = {
        current = constants.layerA,
        next = constants.layerA
    },
    fader1 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    },
    fader2 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    },
    fader3 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    },
    fader4 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    },
    fader5 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    },
    fader6 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    },
    fader7 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    },
    fader8 = {
        current = faderStates.unassigned,
        next = faderStates.unassigned
    }

}

function StateManager:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function StateManager:hasChanged(path)
    local item = tableUtils.getValueFromPath(self, path)
    return item.next ~= item.current
end

function StateManager:update(path)
    local item = tableUtils.getValueFromPath(self, path)
    if not item then
        return
    end
    item.current = item.next
    return item.current
end

function StateManager:updateAll()
    for i = 1, 8 do
        self:update("knob" .. i .. ".label")
        self:update("knob" .. i .. ".value")
        self:update("knob" .. i .. ".enabled")
        self:update("button" .. i .. ".label")
        self:update("button" .. i .. ".value")
        self:update("button" .. i .. ".enabled")
        self:update("fader" .. i)
    end
    self:update("deviceType")
    self:update("deviceName")
    self:update("patchName")
    self:update("buttonColour")
    self:update("layer")
end

function StateManager:get(path)
    return tableUtils.getValueFromPath(self, path).current
end

function StateManager:getNext(path)
    return tableUtils.getValueFromPath(self, path).next
end

function StateManager:set(path, next)
    local item = tableUtils.getValueFromPath(self, path)
    item.next = next
end

function StateManager:inc(path)
    local item = tableUtils.getValueFromPath(self, path)
    local next = item.current + 1
    if next > 127 then
        next = 127
    end
    item.next = next
end

function StateManager:dec(path)
    local item = tableUtils.getValueFromPath(self, path)
    local next = item.current - 1
    if next < 0 then
        next = 0
    end
    item.next = next
end

function StateManager:add(path, delta, min, max)
    local item = tableUtils.getValueFromPath(self, path)
    local next = item.current + delta
    if min ~= nil and next < min then
        next = min
    end
    if max ~= nil and next > max then
        next = max
    end
    item.next = next
end

function StateManager:flip(path)
    local item = tableUtils.getValueFromPath(self, path)
    if item.current then
        item.next = false
    else
        item.next = true
    end
    return item.next
end

return StateManager
