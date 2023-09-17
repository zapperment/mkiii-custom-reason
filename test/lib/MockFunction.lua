local stringUtils = require("src.lib.stringUtils")
local MockFunction = {}

function MockFunction:new()
    local instance = {
        calls = {},
        fakes = {}
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function MockFunction:fake(input, output)
    local key = stringUtils.serialise(input)
    self.fakes[key] = output
end

-- invoke the mock function; the arguments provided are
-- stored for later examination; if a fake has been set up
-- for the provided argument, returns the fake data
function MockFunction:call(...)
    local args = {...}
    table.insert(self.calls, args)
    local key = stringUtils.serialise(args)
    if self.fakes[key] then
        return self.fakes[key]
    end
end

function MockFunction:clear()
    self.calls = {}
end

function MockFunction:reset()
    self:clear()
    self.fakes = {}
end

return MockFunction
