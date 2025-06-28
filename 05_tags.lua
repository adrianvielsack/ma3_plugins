require("99_builder")

--- @class Tag
--- @field obj table|nil
Tag = {}
Tag.__index = Tag

function HasTag(tags, tag)
    if string.len(tags) == 0 then
        return false
    end
    for elemTag in string.gmatch(tags, "([^,:]+):[0-9]+") do
        if elemTag == tag then
            return true
        end
    end
    return false
end

function Tag:byTagName(tagName)
    local tags = {}
    local allTags = ObjectList('Tag Thru')
    for _, tag in pairs(allTags) do
        if HasTag(tag.Tags, tagName) then
            table.insert(tags, Tag:from(tag))
        end
    end
    return tags
end

function Tag:from(obj)
    local tag = setmetatable({}, Tag)
    tag.obj = obj
    return tag
end

function Tag:byId(id)
    local obj = ShowData()[5][id]
    return Tag:from(obj)
end

--- @return Tag
function Tag:byName(name)
    local obj = ObjectList(string.format("Tag \"%s\"", name))[1]
    local tag = setmetatable({}, Tag)
    tag.obj = obj
    return tag
end

--- @return Tag
function Tag:byNameOrCreate(name)
    local obj = ObjectList(string.format("Tag \"%s\"", name))
    if obj == nil or #obj == 0 then
        obj = ShowData()[5]:Acquire()
        obj.Name = name
    else
        obj = obj[1]
    end
    local tag = setmetatable({}, Tag)
    tag.obj = obj
    return tag
end

function Tag:getName()
    return self.obj.Name
end

function Tag:address()
    return ToAddr(self.obj)
end

function Tag:assign(obj)
    Builder:new():assign(self):at(obj):exec()
end

function Tag:getGroups()
    local groups = {}
    local allGroups = ObjectList('Group Thru')
    for _, group in pairs(allGroups) do
        if HasTag(group.Tags, self.obj.Name) then
            table.insert(groups, Group:from(group))
        end
    end
    return groups
end

function Tag:getLayouts()
    local layouts = {}
    local allLayouts = ObjectList('Layout Thru')
    for _, layout in pairs(allLayouts) do
        if HasTag(layout.Tags, self.obj.Name) then
            table.insert(layouts, Layout:from(layout))
        end
    end
    return layouts
end