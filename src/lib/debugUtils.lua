local midiUtils = require("src.lib.midiUtils")

local logMessages = {}
local maxLogMessages = 100

-- this function accepts a table and returns a string with
-- all the keys in the table; you can specify keys to exclude
-- in the output by providing a second argument
local function concatenateKeys(tbl, excludeKeys)
    local keys = {}
    local exclude = {}

    -- Populate the exclude table for O(1) lookups
    for _, key in ipairs(excludeKeys or {}) do
        exclude[key] = true
    end

    for key, _ in pairs(tbl) do
        if not exclude[key] then
            table.insert(keys, tostring(key))
        end
    end

    return table.concat(keys, ",")
end

local function midiEventToString(event)
    local hexStrings = {}
    for i = 1, #event do
        table.insert(hexStrings, string.format("%02X", event[i]))
    end
    return table.concat(hexStrings, " ")
end

local function log(message)
    table.insert(logMessages, message)
    -- if the codec is not running in debug mode, the logs are never dumped
    -- we need to limit the number of log messages to prevent memory leaks
    if #logMessages > maxLogMessages then
        table.remove(logMessages, 1)
    end
end

local function dumpLog()
    local events = {}
    for _, message in pairs(logMessages) do
        table.insert(events, midiUtils.makeLogEvent(message))
    end
    logMessages = {}
    return events
end

return {
    concatenateKeys = concatenateKeys,
    midiEventToString = midiEventToString,
    log = log,
    dumpLog = dumpLog
}
