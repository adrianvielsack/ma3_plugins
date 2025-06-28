require("21_launchpad_defines")
require("08_midi")
LaunchPad = {}
LaunchPad.__index = LaunchPad

function LaunchPad:setLed(x, y, clr)
    LaunchPadCmd:new():setLed(x, y, clr):exec()
end
function LaunchPad:setLedRGB(x, y, r, g, b, dim)
    LaunchPadCmd:new():setLedRGB(x, y, r, g, b, dim):exec()
end

function LaunchPad:setMapping(x, y, obj)
    MidiInput:set(1, x + y * 10, obj)
end

function LaunchPad:unsetMapping(x, y, obj)
    MidiInput:unset(1, x + y * 10)
end

function LaunchPad:clear()
    LaunchPadCmd:new():clear():exec()
end

LaunchPadCmd = {}
LaunchPadCmd.__index = LaunchPadCmd

function LaunchPadCmd:new()
    local lpcmd = setmetatable({}, LaunchPadCmd)
    lpcmd.op = Builder:new()
    return lpcmd
end

function LaunchPadCmd:from(op)
    local lpcmd = setmetatable({}, LaunchPadCmd)
    lpcmd.op = op
    return lpcmd
end

function LaunchPadCmd:setLed(x, y, clr)
    self.op:noteOn(1, x + y * 10, clr)
    return self
end

function LaunchPadCmd:setLedRGB(x, y, r, g, b, dim)
    self.op:noteOn(1, x + y * 10, matchColor(r, g, b, dim or 255))
    return self
end

function LaunchPadCmd:clear()
    for x = 1, 9 do
        for y = 1, 9 do
            self:setLed(x, y, 0)
        end
    end
    return self
end

function LaunchPadCmd:exec()
    self.op:exec()
end

function LaunchPadCmd:copyToCmd(cmd)
    for _, op in pairs(self.op.op) do
        table.insert(cmd.op, op)
    end
end