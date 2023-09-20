local lu = require("test.lib.luaunit")
local combinatorUtils = require("src.lib.combinatorUtils")

TestCombinatorUtils = {}

function TestCombinatorUtils:testFindMatchingCombinatorConfig1()
    local patchName = "X-Touch Quad Piano"
    local result = combinatorUtils.findMatchingCombinatorConfig(patchName)
    local errorMessage =
        "Failed to find matching combinator config for a patch name that is defined in the combinators module"
    lu.assertNotIsNil(result, errorMessage)
end

function TestCombinatorUtils:testFindMatchingCombinatorConfig2()
    local patchName = "Afro Cumbria Tron Kit [UCLUB]"
    local result = combinatorUtils.findMatchingCombinatorConfig(patchName)
    local errorMessage = "Failed to find matching combinator config for a patch name that matches a key " ..
                             "with placeholder that is defined in the combinators module"
    lu.assertNotIsNil(result, errorMessage)
end

function TestCombinatorUtils:testFindMatchingCombinatorConfig3()
    local patchName = "Afro Cumbria Tron Kit"
    local result = combinatorUtils.findMatchingCombinatorConfig(patchName)
    local errorMessage = "Trying to find a combinator for a patch name that is not configured, did not get nil as expected"
    lu.assertIsNil(result, errorMessage)
end
