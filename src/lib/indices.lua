local items = require("items")

local indices = {}

for i, item in ipairs(items) do
    indices[item.name] = i
end

return indices
