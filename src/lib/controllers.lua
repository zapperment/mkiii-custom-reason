local items = require("items")

local controllers = {}

for _, item in ipairs(items) do
    controllers[item.name] = item.controller
end

return controllers
