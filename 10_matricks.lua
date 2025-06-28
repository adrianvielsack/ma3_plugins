require("05_tags")
MATricks = {}
MATricks.__index = MATricks

function MATricks:from(obj)
    local mtx = setmetatable({}, MATricks)
    mtx.obj = obj

    return mtx
end

function MATricks:findWithTag(tag)
    ret = {}

    for _, matrick in pairs(DataPool().MATricks:Children()) do
        if HasTag(matrick.Tags, tag) then
            table.insert(ret, MATricks:from(matrick))
        end
    end

    return ret
end

function MATricks:getName()
    return self.obj.Name
end

function MATricks:address()
    return ToAddr(self.obj)
end