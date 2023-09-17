local lu = require("test.lib.luaunit")
local MockFunction = require("test.lib.MockFunction")

TestMockFunction = {}

function TestMockFunction:testRecordsNumberOfCalls()
    local mockFunction = MockFunction:new()
    mockFunction:call()
    local errorMessage = "After calling the mock function, got an unexpected number of calls"
    lu.assertEquals(#mockFunction.calls, 1, errorMessage)
end

function TestMockFunction:testRecordsArgumentsOfCalls()
    local mockFunction = MockFunction:new()
    mockFunction:call("foo")
    local errorMessage = "After calling the mock function, got unexpected arguments data for call"
    lu.assertEquals(mockFunction.calls[1], {"foo"}, errorMessage)
end

function TestMockFunction:testReturnsFakeData1()
    local mockFunction = MockFunction:new()
    mockFunction:fake({"foo"}, "bar")
    local result = mockFunction:call("foo")
    local errorMessage =
        "After calling the mock function with fake return value for a call with one string argument, got unexpected return value"
    lu.assertEquals(result, "bar", errorMessage)
end

function TestMockFunction:testReturnsFakeData2()
    local mockFunction = MockFunction:new()
    mockFunction:fake({"foo"}, "bar")
    local result = mockFunction:call("baz")
    local errorMessage =
        "After calling the mock function with fake return value for a call with one string argument, passing a non-matching argument, got unexpected return value"
    lu.assertEquals(result, nil, errorMessage)
end

function TestMockFunction:testReturnsFakeData3()
    local mockFunction = MockFunction:new()
    mockFunction:fake({}, "bar")
    local result = mockFunction:call()
    local errorMessage =
        "After calling the mock function with fake return value for a call with no arguments, got unexpected return value"
    lu.assertEquals(result, "bar", errorMessage)
end

function TestMockFunction:testClear()
    local mockFunction = MockFunction:new()
    mockFunction:call()
    mockFunction:clear()
    local errorMessage = "After calling the mock function, then clearing, got an unexpected number of calls"
    lu.assertEquals(#mockFunction.calls, 0, errorMessage)
end

function TestMockFunction:testReset1()
    local mockFunction = MockFunction:new()
    mockFunction:call()
    mockFunction:reset()
    local errorMessage = "After calling the mock function, then resetting, got an unexpected number of calls"
    lu.assertEquals(#mockFunction.calls, 0, errorMessage)
end

function TestMockFunction:testReset2()
    local mockFunction = MockFunction:new()
    mockFunction:fake({}, "bar")
    mockFunction:reset()
    local result = mockFunction:call()
    local errorMessage =
        "After setting a fake, then resetting, then calling the mock function, got an unexpected result"
    lu.assertEquals(result, nil, errorMessage)
end
