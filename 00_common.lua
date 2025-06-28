BaseObject = {}
BaseObject.__index = BaseObject

function BaseObject:address()
    return ToAddr(self.obj)
end

function BaseObject:from(obj, subClass)
    local newObject = setmetatable({}, { __index = BaseObject })
    setmetatable(newObject, subClass)
    newObject.obj = obj

    return newObject
end

