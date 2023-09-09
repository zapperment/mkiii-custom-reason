local items = require("src.lib.items")
local handleInputQueue = require("src.lib.handleInputQueue")
-- local debugUtils = require("src.lib.debugUtils")

return function(event)
    for key, inputQueueItem in pairs(handleInputQueue) do
        if not inputQueueItem.countDown or inputQueueItem.countDown <= 0 then
            remote.handle_input({
                item = items[inputQueueItem.itemName].index,
                value = inputQueueItem.value,
                time_stamp = event.time_stamp
            })
            handleInputQueue[key] = nil
        end
    end
end
