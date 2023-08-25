local combinators = require("combinators")
local stateUtils = require("stateUtils")

local function getLabel(itemName)
    local patchName = stateUtils.getNext("patchName")
    local combinatorConfig = combinators[patchName]
    return combinatorConfig and combinatorConfig[itemName] or nil
end

return {
    getLabel = getLabel
}
