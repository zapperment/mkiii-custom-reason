local lu = require("test.lib.luaunit")

require("src.codecs.SL MkIII")
require("test.TestStateManagement")
require("test.TestRemoteInit")

os.exit(lu.LuaUnit.run())
