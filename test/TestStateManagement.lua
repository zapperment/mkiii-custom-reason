local lu = require("test.lib.luaunit")
local stateUtils = require("src.lib.stateUtils")
local testUtils = require("test.lib.testUtils")

TestStateManagement = {}

function TestStateManagement:setUp()
    testUtils.resetState()
end

function TestStateManagement:testChangingTheStateWithSetAndUpdating()
    local current, next, hasChanged, updated, errorMessage
    stateUtils.set("knob1.value", 127)
    current = stateUtils.get("knob1.value")
    next = stateUtils.getNext("knob1.value")
    hasChanged = stateUtils.hasChanged("knob1.value")
    errorMessage = "after setting the state to 127, the current state should still be 0, but it is " .. current
    lu.assertEquals(current, 0, errorMessage)
    errorMessage = "after setting the state to 127, the next state should now be 127, but it is " .. next
    lu.assertEquals(next, 127, errorMessage)
    errorMessage = "after setting the state, 'hasChanged' should be true, but it is " .. hasChanged
    lu.assertEquals(hasChanged, true, errorMessage)
    updated = stateUtils.update("knob1.value")
    current = stateUtils.get("knob1.value")
    next = stateUtils.getNext("knob1.value")
    hasChanged = stateUtils.hasChanged("knob1.value")
    errorMessage =
        "after setting the state to 127, calling 'update' should return the new current state 127, but it returned " ..
            updated
    lu.assertEquals(updated, 127, errorMessage)
    errorMessage =
        "after setting the state to 127 and calling 'update', the current state should now be 127, but it is " ..
            current
    lu.assertEquals(current, 127, errorMessage)
    errorMessage =
        "after setting the state to 127 and calling 'update', the next state should still be 127, but it is " .. next
    lu.assertEquals(next, 127, errorMessage)
    errorMessage = "after setting the state and calling 'update', 'hasChanged' should be false, but it is " ..
                       hasChanged
    lu.assertEquals(hasChanged, false, errorMessage)
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
