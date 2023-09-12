local lu = require("test.lib.luaunit")
local testUtils = require("test.lib.testUtils")

Account = {
    balance = 0
}

function Account:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Account:withdraw(amount)
    self.balance = self.balance - amount
end

function Account:deposit(amount)
    self.balance = self.balance + amount
end

function Account:getBalance()
    return self.balance
end

TestCombinatorLabels = {}

function TestCombinatorLabels:testStartWithCombinatorThatHasCustomLabels()
    account = Account:new({
        balance = 0
    })
    account:deposit(100)
    account:withdraw(50)
    lu.assertEquals(account:getBalance(), 50)
    account2 = Account:new()
    lu.assertEquals(account2.balance, 0)
end
