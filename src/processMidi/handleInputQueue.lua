local items = require("lib.items")
local handleInputQueue = require("lib.handleInputQueue")
--local debugUtils = require("lib.debugUtils")

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
