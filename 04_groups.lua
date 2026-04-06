Group = {}
Group.__index = Group

function Group:byId(id)
    local group = DataPool().Groups[id]
    if group ~= nil then
        return Group:from(group)
    end
    return nil
end

function Group:create(groupId, name)
    local obj = DataPool().Groups:Create(groupId)
    obj.Name = name
    return Group:from(obj)
end

function Group:getOrCreate(id, name)
    local group = Group:byId(id)
    if group ~= nil then
        return group
    end
    return Group:create(id, name)
end

function Group:address()
    return ToAddr(self.obj)
end

function Group:from(group)
    local instance = setmetatable({}, Group)
    instance.obj = group
    return instance
end

function Group:getName()
    return self.obj.Name
end

function Group:findWithTag(tag)
    local groups = {}
    local allGroups = ObjectList('Group Thru')
    if (type(tag) == "table" and tag.obj ~= nil) then
        tag = tag.obj.name
    end
    for _, group in pairs(allGroups) do
        if HasTag(group.Tags, tag) then
            table.insert(groups, Group:from(group))
        end
    end
    return groups
end

function Group:setAppearance(appearance)
    self.obj.Appearance = appearance.obj
end

function Group:addFixture(fixture)
    Cmd("ClearAll")
    Cmd("Fixture " .. fixture.obj.index)
    Cmd("Store Group " .. self.obj.index .. " /m")
end

function Group:select()
    Cmd("ClearAll")
    Cmd("SelectFixtures Group " .. self.obj.index)
end
