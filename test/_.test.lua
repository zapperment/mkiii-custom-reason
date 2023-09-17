local lu = require("test.lib.luaunit")

require("test.TestStateManagement")
require("test.TestRemoteInit")
require("test.TestMockFunction")
require("test.TestStringUtils")
require("test.TestLayerButtons")
require("test.TestCombinatorUtils")

os.exit(lu.LuaUnit.run())
