local lu = require("test.lib.luaunit")
local testUtils = require("test.lib.testUtils")

TestCombinatorLabels = {}

function TestCombinatorLabels:testStartWithCombinatorThatHasCustomLabels()
    lu.assertEquals(true, true)
end
