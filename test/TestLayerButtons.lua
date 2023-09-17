local lu = require("test.lib.luaunit")
local testUtils = require("test.lib.testUtils")
local MockHost = require("test.lib.MockHost")
local stateUtils = require("src.lib.stateUtils")

require("test.lib.mockRemote")
require("src.codecs.SL MkIII")

local host = MockHost:new()

TestLayerButtons = {}

function TestLayerButtons:setUp()
    testUtils.resetState()
    remote.clearMocks()
    remote_init()
end

function TestLayerButtons:testSettingInitialLayerState()
    local errorMessage
    host:startup()
    errorMessage = "After starting up the host, got an unexpected layer state"
    lu.assertEquals(stateUtils.getNext("layer"), "layerA", errorMessage)
    local events = remote_deliver_midi(1)
    errorMessage = "After starting up the host, unexpected MIDI data was created for delivery to remote surface; " ..
                       "expected control change 0x51 with non-zero value to light up layer button A"
    lu.assertEquals(events[1], "BF 51 09", errorMessage)
    errorMessage = "After starting up the host, unexpected MIDI data was created for delivery to remote surface; " ..
                       "expected control change 0x53 with zero value to turn off layer button B"
    lu.assertEquals(events[2], "BF 52 00", errorMessage)
end
