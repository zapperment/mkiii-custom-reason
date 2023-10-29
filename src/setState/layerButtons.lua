local stateUtils = require("src.lib.stateUtils")
local items = require("src.lib.items")
local constants = require("src.lib.constants")
--local log = require("src.lib.debugUtils").log

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for _, button in ipairs({"buttonLayerA", "buttonLayerB"}) do
            if changedItemIndex == items[button].index and changedItem.value > 0 then
                local layer = button == "buttonLayerA" and constants.layerA or constants.layerB
                stateUtils.set("layer", layer)
            end
        end
    end
end
