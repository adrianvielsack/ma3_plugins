Builder = {}
Builder.__index = Builder

function Builder:new()
    local builder = setmetatable({}, Builder)
    builder.op = {}
    return builder
end

function Builder:debug()
    Printf("Would exec %s", self:str())
    return self
end

function Builder:delete(obj)
    table.insert(self.op, "Delete")
    self:addItem(obj)
    return self
end

function Builder:ifTag(tag)
    table.insert(self.op, string.format("If Tag \"%s\"", tag))
    return self
end

function Builder:str()
    return table.concat(self.op, " ")
end

function Builder:debug()
    Printf("Debug %s", self:str())
    return self
end

function Builder:exec()
    Cmd(self:str())
end

function Builder:obj(obj)
    table.insert(self.op, obj:address())
    return self
end

function Builder:store(obj)
    table.insert(self.op, "Store")
    self:addItem(obj)
    return self
end

function Builder:add(str)
    table.insert(self.op, str)
    return self
end

function Builder:merge()
    table.insert(self.op, "/merge")
    return self
end

function Builder:assign(obj)
    table.insert(self.op, "Assign")
    self:addItem(obj)
    return self
end

function Builder:copy(obj)
    table.insert(self.op, "Copy")
    table.insert(self.op, obj:address())
    return self
end

function Builder:thru(obj)
    table.insert(self.op, "Thru")
    if type(obj) == "string" then
        table.insert(self.op, obj)
    elseif type(obj) == "number" then
        table.insert(self.op, string.format("%d", obj))
    else
        table.insert(self.op, string.format("%d", obj.obj.No))
    end
    return self
end

function Builder:at(obj)
    table.insert(self.op, "At")
    self:addItem(obj)
    return self
end

function Builder:gotoObj()
    table.insert(self.op, "goto")
    return self
end

function Builder:sequence(seq)
    table.insert(self.op, seq:address())
    return self
end

function Builder:cue(id)
    table.insert(self.op, string.format("Cue %d", id))
    return self
end

function Builder:part(id, elem)
    if elem ~= nil then
        table.insert(self.op, string.format("Part %d.%d", id, elem))
    else
        table.insert(self.op, string.format("Part %d", id))
    end
    return self
end

function Builder:layoutItem(obj)
    self:addItem(obj, "Layout")
    return self
end

function Builder:addItem(obj)
    if type(obj) == "table" then
        if obj[1] == nil then
            table.insert(self.op, obj:address())
        else
            objects = {}
            for _, o in pairs(obj) do
                table.insert(objects, o:address())
            end
            table.insert(self.op, table.concat(objects, " + "))
        end
    elseif type(obj) == "string" then
        table.insert(self.op, obj)
    elseif type(obj) == "number" then
        table.insert(self.op, string.format("%d", obj))
    end
    return self
end

function Builder:noConfirm()
    table.insert(self.op, "/nc")
    return self
end

function Builder:noUndo()
    return self:noOops()
end

function Builder:noOops()
    table.insert(self.op, "/NoOops")
    return self
end

function Builder:next()
    table.insert(self.op, ";")
    return self
end

function Builder:noteOn(channel, note, velocity)
    table.insert(self.op, string.format("SendMidi \"Note\" %d/%d %d; ", channel, note, velocity))
    return self
end

function Builder:go(obj)
    table.insert(self.op, "Go+")
    table.insert(self.op, obj:address())
    return self
end

function Builder:set(obj)
    table.insert(self.op, "Set")
    self:addItem(obj)
    return self
end

function Builder:property(prop, obj)
    table.insert(self.op, "Property")
    table.insert(self.op, string.format("'%s'", prop))
    table.insert(self.op, string.format("'%s'", obj))
    return self
end



