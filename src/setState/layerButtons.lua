local stateUtils = require("lib.stateUtils")
local items = require("lib.items")
local constants = require("lib.constants")

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for _, button in ipairs({ "buttonLayerA", "buttonLayerB" }) do
            if changedItemIndex == items[button].index then
                local layer = changedItem.value == 0 and constants.layerA or constants.layerB
                stateUtils.set("layer", layer)
            end
        end
    end
end
