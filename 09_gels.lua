Gel = {}
Gel.__index = Gel

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

function Gel:from(obj)
    local gel = setmetatable({}, Gel)
    gel.obj = obj

    return gel
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