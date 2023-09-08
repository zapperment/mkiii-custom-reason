local handleInputQueue = require("lib.handleInputQueue")

return function()
    for _, inputQueueItem in pairs(handleInputQueue) do
        inputQueueItem.countDown = inputQueueItem.countDown - 1
    end
end
