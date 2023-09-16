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
    errorMessage = "after setting the state to 127, the current state should still be 0, but it is " ..
                       tostring(current)
    lu.assertEquals(current, 0, errorMessage)
    errorMessage = "after setting the state to 127, the next state should now be 127, but it is " .. tostring(next)
    lu.assertEquals(next, 127, errorMessage)
    errorMessage = "after setting the state, 'hasChanged' should be true, but it is " .. tostring(hasChanged)
    lu.assertEquals(hasChanged, true, errorMessage)
    updated = stateUtils.update("knob1.value")
    current = stateUtils.get("knob1.value")
    next = stateUtils.getNext("knob1.value")
    hasChanged = stateUtils.hasChanged("knob1.value")
    errorMessage =
        "after setting the state to 127, calling 'update' should return the new current state 127, but it returned " ..
            tostring(updated)
    lu.assertEquals(updated, 127, errorMessage)
    errorMessage =
        "after setting the state to 127 and calling 'update', the current state should now be 127, but it is " ..
            tostring(current)
    lu.assertEquals(current, 127, errorMessage)
    errorMessage =
        "after setting the state to 127 and calling 'update', the next state should still be 127, but it is " ..
            tostring(next)
    lu.assertEquals(next, 127, errorMessage)
    errorMessage = "after setting the state and calling 'update', 'hasChanged' should be false, but it is " ..
                       tostring(hasChanged)
    lu.assertEquals(hasChanged, false, errorMessage)
end

function TestStateManagement:testChangingTheStateWithInc()
    local next
    stateUtils.inc("knob1.value")
    next = stateUtils.getNext("knob1.value")
    local errorMessage = "after changing the state with 'inc', expected the next value to be 1, but it is " ..
                             tostring(next)
    lu.assertEquals(next, 1, errorMessage)
end

function TestStateManagement:testMaximumValueForDecIs127()
    local next
    stateUtils.set("knob1.value", 127)
    stateUtils.update("knob1.value")
    stateUtils.inc("knob1.value")
    stateUtils.update("knob1.value")
    stateUtils.inc("knob1.value")
    stateUtils.update("knob1.value")
    stateUtils.inc("knob1.value")
    next = stateUtils.getNext("knob1.value")
    local errorMessage = "after increasing the state several times, beyond the maximum value of 127, " ..
                             "expected the next value to be 127, but it is " .. tostring(next)
    lu.assertEquals(next, 127, errorMessage)
end

function TestStateManagement:testChangingTheStateWithDec()
    local next
    stateUtils.set("knob1.value", 127)
    stateUtils.update("knob1.value")
    stateUtils.dec("knob1.value")
    next = stateUtils.getNext("knob1.value")
    local errorMessage = "after changing the state with 'dec', expected the next value to be 126, but it is " ..
                             tostring(next)
    lu.assertEquals(next, 126, errorMessage)
end

function TestStateManagement:testMinimumValueForDecIs0()
    local next
    stateUtils.dec("knob1.value")
    stateUtils.update("knob1.value")
    stateUtils.dec("knob1.value")
    stateUtils.update("knob1.value")
    stateUtils.dec("knob1.value")
    next = stateUtils.getNext("knob1.value")
    local errorMessage = "after decreasing the state several times, beyond the minimum value of 0, " ..
                             "expected the next value to be 0, but it is " .. tostring(next)
    lu.assertEquals(next, 0, errorMessage)
end

function TestStateManagement:testAddAndSubtract()
    local value, errorMessage
    stateUtils.add("knob1.value", 20)
    value = stateUtils.update("knob1.value")
    errorMessage = "after adding 20 using 'add', 'update' returned an incorrect value"
    lu.assertEquals(value, 20, errorMessage)
    stateUtils.add("knob1.value", 20, 0, 30)
    value = stateUtils.update("knob1.value")
    errorMessage =
        "after adding 20 to 30 using 'add', while the maximum value is 30, 'update' returned an incorrect value"
    lu.assertEquals(value, 30, errorMessage)
    stateUtils.add("knob1.value", -40, 0, 30)
    value = stateUtils.update("knob1.value")
    errorMessage =
        "after adding -40 to 30 using 'add', while the minimum value is 0, 'update' returned an incorrect value"
    lu.assertEquals(value, 0, errorMessage)
    stateUtils.add("knob1.value", -1)
    value = stateUtils.update("knob1.value")
    errorMessage = "after adding -1 to 0 using 'add', 'update' returned an incorrect value"
    lu.assertEquals(value, -1, errorMessage)
    stateUtils.add("knob1.value", 1001)
    value = stateUtils.update("knob1.value")
    errorMessage = "after adding 1001 to -1 using 'add', 'update' returned an incorrect value"
    lu.assertEquals(value, 1000)
end

function TestStateManagement:testFlip()
    local value, errorMessage
    stateUtils.flip("knob1.enabled")
    value = stateUtils.update("knob1.enabled")
    errorMessage = "after calling 'flip' on a state with value 'false', 'update' returned an incorrect value"
    lu.assertEquals(value, true, errorMessage)
    stateUtils.flip("knob1.enabled")
    value = stateUtils.update("knob1.enabled")
    errorMessage = "after calling 'flip' on a state with value 'true', 'update' returned an incorrect value"
    lu.assertEquals(value, false, errorMessage)
end
