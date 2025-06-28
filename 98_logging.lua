Logger = {}
Logger.__index = Logger

LOG_ERROR = 0
LOG_WARN = 1
LOG_INFO = 2
LOG_DEBUG = 3

local LOGLEVEL_ENUMS = {
    [0] = "ERROR",
    [1] = "WARN",
    [2] = "INFO",
    [3] = "DEBUG"

}

debug_level = LOG_DEBUG

function Logger:new(prefix)
    local log = setmetatable({}, Logger)
    log.prefix = ""
    if prefix ~= nil then
        log.prefix = prefix
    end
    return log
end

function Logger:log(level, ...)
    if level <= debug_level then
        if self.prefix ~= "" then
            Printf("%s - %s: %s", LOGLEVEL_ENUMS[level], self.prefix, string.format(...))
            return
        end
        Printf("%s: %s", LOGLEVEL_ENUMS[level], string.format(...))
    end
end

function Logger:debug(...)
    self:log(LOG_DEBUG, ...)
end

function Logger:info(...)
    self:log(LOG_INFO, ...)
end

