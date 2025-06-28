Macro = {}
Macro.__index = Macro

function Macro:from(obj)
    local instance = setmetatable({}, Macro)
    instance.id = obj.No
    instance.obj = obj
    return instance
end

function Macro:get(id)
    local obj = DataPool().Macros[id]
    if obj == nil then
        return nil
    end
    local instance = setmetatable({}, Macro)
    instance.id = id
    instance.obj = obj
    return instance
end

function Macro:create(id, name)
    local instance = setmetatable({}, Macro)
    instance.id = id
    Cmd(string.format("ClearAll; Store Macro %d", id))
    local obj = DataPool().Macros[id] --DataPool().Macros:Create(id)

    obj.Name = name
    instance.obj = obj
    return instance
end

function Macro:acquire(name)
    local macro = Macro:from(DataPool().Macros:Acquire())
    if name ~= nil then
        macro:setName(name)
    end
    return macro
end

function Macro:getOrCreate(id, name)
    local instance = Macro:get(id)
    if instance == nil then
        return Macro:create(id, name)
    end
    return instance
end

function Macro:address()
    return ToAddr(self.obj, false)
end

function Macro:addLine(cmd)
    local line = self.obj:Acquire()
    line.Command = cmd
    return MacroLine:from(line)
end

function Macro:setLineOrCreate(n, cmd)
    local lineObj = self.obj[n]
    while lineObj == nil do
        self.obj:Acquire()
        lineObj = self.obj[n]
    end

    local line = MacroLine:from(lineObj)
    line:set(cmd)

    return line
end

function Macro:setAppearance(appearance)
    self.obj.Appearance = appearance.obj
end

function Macro:setName(name)
    self.obj.Name = name
end

function Macro:Delete()
    self.obj:Delete()
end

MacroLine = {}
MacroLine.__index = MacroLine

function MacroLine:from(line)
    local instance = setmetatable({}, MacroLine)
    instance.obj = line
    return instance
end

function MacroLine:set(line)
    self.obj.Command = line
end

function MacroLine:disable()
    self.obj.Enabled = false
end

function MacroLine:enable()
    self.obj.Enabled = false
end

function MacroLine:address()
    return ToAddr(self.obj)
end

function MacroLine:delete()
    self.obj:Delete()
end

