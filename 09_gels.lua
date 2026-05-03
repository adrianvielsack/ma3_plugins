--- @class Gel
--- @field obj table|nil
Gel = {}
Gel.__index = Gel
Gel.PREDEFINED_MALIGHTING = 1
Gel.PREDEFINED_CINEGEL = 4
Gel.PREDEFINED_LEEGEL = 7
Gel.PREDEFINED_CUSTOM = 11

function Gel:getAllFromBook(id)
    gels = {}
    local consoleGels = ShowData().GelPools[id]:Children()
    if consoleGels == nil then
        return {}
    end
    for i, consoleGel in pairs(consoleGels) do
        table.insert(gels, Gel:from(consoleGel))
    end
    return gels
end

function Gel:byNameOrCreate(name)
    local obj = ObjectList(string.format("Gel \"%s\"", name))
    if obj == nil or #obj == 0 then
        obj = Gel:getCustomPool():Acquire()
        obj.Name = name
    else
        obj = obj[1]
    end
    local Gel = setmetatable({}, Gel)
    Gel.obj = obj
    return Gel
end

function Gel:byId(id)
    local pool = Gel:getCustomPool()
    local item = pool[id]
    if item == nil then
        return nil
    end
    local gel =  Gel:from(item)
    return gel
end

function Gel:from(obj)
    local gel = setmetatable({}, Gel)
    gel.obj = obj

    return gel
end

function Gel:getCustomPool()
    local list = ObjectList("Gel Custom")
    -- assert list == 1
    return list[1]
end

function Gel:setRGB(r,g,b)
    self.obj.R=r
    self.obj.G=g
    self.obj.B=b
end

function Gel:getRGB()
    return self.obj.R, self.obj.G, self.obj.B
end

function Gel:getName()
    return self.obj.Name
end

function Gel:address()
    return ToAddr(self.obj)
end
