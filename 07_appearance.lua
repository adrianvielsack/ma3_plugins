Appearance = {}
Appearance.__index = Appearance

function Appearance:byName(name)
    local obj = ObjectList(string.format("Appearance \"%s\"", name))
    if obj == nil then
        return nil
    end
    return Appearance:from(obj[1])
end

function Appearance:from(obj)
    local appearance = setmetatable({}, Appearance)
    appearance.obj = obj
    return appearance
end

function Appearance:byId(id)
    local obj = ShowData().Appearances[id]
    if obj == nil then
        return nil
    end
    local appearance = setmetatable({}, Appearance)
    appearance.obj = obj
    return appearance
end

function Appearance:byRange(start, stop)
    ret = {}
    for n = start, stop do
        table.insert(ret, Appearance:byId(n))
    end
    return ret
end

function Appearance:getOrCreate(id, name)
    local appearance = Appearance:byId(id)
    if appearance == nil then
        appearance = Appearance:create(id)
    end
    appearance:setName(name)
    return appearance
end

function Appearance:create(id)
    local obj = ShowData().Appearances:Create(id)
    return Appearance:from(obj)
end

function Appearance:setName(name)
    self.obj.Name = name
end

function Appearance:address()
    return ToAddr(self.obj, false)
end

function Appearance:setFgColor(r, g, b)
    self.obj.Color = string.format("%f,%f,%f,1.0", r, g, b)
end

function Appearance:setBgColor(r, g, b)
    self.obj.BackR = math.floor(r * 255)
    self.obj.BackG = math.floor(g * 255)
    self.obj.BackB = math.floor(b * 255)
    self.obj.BackAlpha = 255
end