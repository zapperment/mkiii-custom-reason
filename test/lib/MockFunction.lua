local MockFunction = {}

function MockFunction:new()
    local instance = {
        calls = {}
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function MockFunction:call(...)
    local args = {...}
    table.insert(self.calls, args)
end

function MockFunction:clear()
  self.calls = {}
end

return MockFunction
