local items = require("items")

local midiMatchers = {}

for _, item in ipairs(items) do
    midiMatchers[item.name] = item.midiMatcher
end

return midiMatchers
