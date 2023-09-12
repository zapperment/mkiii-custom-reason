local lu = require("test.lib.luaunit")

require("src.codecs.SL MkIII")
require("test.TestStateManagement")
require("test.TestCombinatorLabels")

os.exit(lu.LuaUnit.run())
