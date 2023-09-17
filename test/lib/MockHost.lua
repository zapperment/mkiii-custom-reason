-- Mocks the remote host, i.e. Reason
local items = require("src.lib.items")

local MockHost = {}

function MockHost:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

-- Simulates Reason starting up with a single Combinator device loaded;
-- the indices of all the remote items that are mapped are passed to 
-- remote_set_state
function MockHost:startup()
    local changedItems = {items.altTakeButton.index, items.button1.index, items.button2.index, items.button3.index,
                          items.button4.index, items.button5.index, items.button6.index, items.button7.index,
                          items.button8.index, items.buttonLayerA.index, items.buttonLayerB.index,
                          items.clipDownButton.index, items.clipUpButton.index, items.deviceName.index,
                          items.deviceType.index, items.fastForwardButton.index, items.footSwitch.index,
                          items.gridButton.index, items.knob1.index, items.knob2.index, items.knob3.index,
                          items.knob4.index, items.knob5.index, items.knob6.index, items.knob7.index, items.knob8.index,
                          items.loopButton.index, items.optionsButton.index, items.overdubButton.index,
                          items.pad1.index, items.pad10.index, items.pad11.index, items.pad12.index, items.pad13.index,
                          items.pad14.index, items.pad15.index, items.pad16.index, items.pad2.index, items.pad3.index,
                          items.pad4.index, items.pad5.index, items.pad6.index, items.pad7.index, items.pad8.index,
                          items.pad9.index, items.patchName.index, items.playButton.index, items.recordButton.index,
                          items.rewindButton.index, items.stopButton.index, items.trackLeftButton.index,
                          items.trackRightButton.index}
    remote_set_state(changedItems)
end

return MockHost
