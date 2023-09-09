local lu = require("test.lib.luaunit")
local stateUtils = require("src.lib.stateUtils")
local testUtils = require("test.lib.testUtils")

TestStateManagement = {}

function TestStateManagement:setUp()
    testUtils.resetState()
end

function TestStateManagement:testChangingTheStateWithSetAndUpdating()
    local current, next, hasChanged, updated
    stateUtils.set("knob1.value", 127)
    current = stateUtils.get("knob1.value")
    next = stateUtils.getNext("knob1.value")
    hasChanged = stateUtils.hasChanged("knob1.value")
    lu.assertEquals(current, 0)
    lu.assertEquals(next, 127)
    lu.assertEquals(hasChanged, true)
    updated = stateUtils.update("knob1.value")
    current = stateUtils.get("knob1.value")
    next = stateUtils.getNext("knob1.value")
    hasChanged = stateUtils.hasChanged("knob1.value")
    lu.assertEquals(updated, 127)
    lu.assertEquals(current, 127)
    lu.assertEquals(next, 127)
    lu.assertEquals(hasChanged, false)
end

function TestStateManagement:testChangingTheStateWithInc()
    local next
    stateUtils.inc("knob1.value")
    next = stateUtils.getNext("knob1.value")
    lu.assertEquals(next, 1)
end

function TestStateManagement:testMaximumValueForDecIs127()
    local next
    stateUtils.set("knob1.value", 127)
    stateUtils.update("knob1.value")
    stateUtils.inc("knob1.value")
    stateUtils.inc("knob1.value")
    stateUtils.inc("knob1.value")
    next = stateUtils.getNext("knob1.value")
    lu.assertEquals(next, 127)
end

function TestStateManagement:testChangingTheStateWithDec()
    local next
    stateUtils.set("knob1.value", 127)
    stateUtils.update("knob1.value")
    stateUtils.dec("knob1.value")
    next = stateUtils.getNext("knob1.value")
    lu.assertEquals(next, 126)
end

function TestStateManagement:testMinimumValueForDecIs0()
    local next
    stateUtils.dec("knob1.value")
    stateUtils.dec("knob1.value")
    stateUtils.dec("knob1.value")
    next = stateUtils.getNext("knob1.value")
    lu.assertEquals(next, 0)
end

function TestStateManagement:testAddAndSubtract()
    local value
    stateUtils.add("knob1.value", 20)
    value = stateUtils.update("knob1.value")
    lu.assertEquals(value, 20)
    stateUtils.add("knob1.value", 20, 0, 30)
    value = stateUtils.update("knob1.value")
    lu.assertEquals(value, 30)
    stateUtils.add("knob1.value", -40, 0, 30)
    value = stateUtils.update("knob1.value")
    lu.assertEquals(value, 0)
    stateUtils.add("knob1.value", -1)
    value = stateUtils.update("knob1.value")
    lu.assertEquals(value, -1)
    stateUtils.add("knob1.value", 1001)
    value = stateUtils.update("knob1.value")
    lu.assertEquals(value, 1000)
end

function TestStateManagement:testFlip()
    local value
    stateUtils.flip("knob1.enabled")
    value = stateUtils.update("knob1.enabled")
    lu.assertEquals(value, true)
    stateUtils.flip("knob1.enabled")
    value = stateUtils.update("knob1.enabled")
    lu.assertEquals(value, false)
end
