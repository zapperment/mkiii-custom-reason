local lu = require("test.lib.luaunit")
local stringUtils = require("src.lib.stringUtils")

TestStringUtils = {}

function TestStringUtils:testSerialise01()
    local result = stringUtils.serialise("foo")
    local errorMessage = "Serialisation of string failed"
    lu.assertEquals(result, "\"foo\"", errorMessage)
end

function TestStringUtils:testSerialise02()
    local result = stringUtils.serialise(666)
    local errorMessage = "Serialisation of number failed"
    lu.assertEquals(result, "666", errorMessage)
end

function TestStringUtils:testSerialise03()
    local result = stringUtils.serialise(false)
    local errorMessage = "Serialisation of boolean false failed"
    lu.assertEquals(result, "false", errorMessage)
end

function TestStringUtils:testSerialise04()
    local result = stringUtils.serialise(true)
    local errorMessage = "Serialisation of boolean true failed"
    lu.assertEquals(result, "true", errorMessage)
end

function TestStringUtils:testSerialise05()
    local result = stringUtils.serialise()
    local errorMessage = "Serialisation without argument failed"
    lu.assertEquals(result, "nil", errorMessage)
end

function TestStringUtils:testSerialise06()
    local result = stringUtils.serialise(nil)
    local errorMessage = "Serialisation of nil failed"
    lu.assertEquals(result, "nil", errorMessage)
end

function TestStringUtils:testSerialise07()
    local result = stringUtils.serialise({})
    local errorMessage = "Serialisation of empty table failed"
    lu.assertEquals(result, "{}", errorMessage)
end

function TestStringUtils:testSerialise08()
    local result = stringUtils.serialise({1, 2, 3})
    local errorMessage = "Serialisation of list of numbers failed"
    lu.assertEquals(result, "{[1]=1,[2]=2,[3]=3}", errorMessage)
end

function TestStringUtils:testSerialise09()
    local result = stringUtils.serialise({"foo", "bar", "baz"})
    local errorMessage = "Serialisation of list of strings failed"
    lu.assertEquals(result, "{[1]=\"foo\",[2]=\"bar\",[3]=\"baz\"}", errorMessage)
end

function TestStringUtils:testSerialise10()
    local result = stringUtils.serialise({
        foo = 1,
        bar = 2,
        baz = 3
    })
    local errorMessage = "Serialisation of simple key-value table failed"
    lu.assertEquals(result, "{[\"baz\"]=3,[\"bar\"]=2,[\"foo\"]=1}", errorMessage)
end

function TestStringUtils:testSerialise11()
    local result = stringUtils.serialise({
        foo = {
            bar = "baz"
        }
    })
    local errorMessage = "Serialisation of nested key-value table failed"
    lu.assertEquals(result, "{[\"foo\"]={[\"bar\"]=\"baz\"}}", errorMessage)
end

function TestStringUtils:testSerialise12()
    local Foo = {}
    function Foo:new()
        local instance = {
            calls = {},
            fakes = {}
        }
        setmetatable(instance, self)
        self.__index = self
        return instance
    end
    function Foo:bar(...)
        return stringUtils.serialise(...)
    end
    local foo = Foo:new()
    local result = foo:bar({
        foo = {
            bar = "baz"
        }
    })
    local errorMessage = "Serialisation of nested key-value table in class method failed"
    lu.assertEquals(result, "{[\"foo\"]={[\"bar\"]=\"baz\"}}", errorMessage)
end

