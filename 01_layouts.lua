require("98_logging")

--- @class Layout
--- @field obj table|nil
Layout = {}
Layout.__index = Layout

--- @class LayoutElement
--- @field obj table|nil
LayoutElement = {}
LayoutElement.__index = LayoutElement

local log = Logger:new("Layout")

function Layout:get(id)
    local instance = setmetatable({}, Layout)
    instance.id = id
    local layoutElem = DataPool().Layouts[id]
    if layoutElem == nil then
        return nil
    end
    instance.obj = layoutElem
    return instance
end

--- @param id any
--- @param name string
--- @return Layout
function Layout:getOrCreate(id, name)
    local instance = setmetatable({}, Layout) -- Erstellt eine neue Instanz von Layout

    instance.id = id
    local layoutElem = DataPool().Layouts[id] -- Holt das Layout-Element aus dem DataPool

    if layoutElem == nil then
        return Layout:create(id, name) -- Erstellt und gibt eine neue Layout-Instanz zurück
    end

    instance.obj = layoutElem
    return instance
end

function Layout:create(id, name)
    local instance = setmetatable({}, Layout)
    instance.id = id
    Cmd(string.format("Store Layout %d", id))
    local obj = DataPool().Layouts[id]
    obj.Name = name
    return Layout:from(obj)
end

function Layout:acquire(name)
    local obj = DataPool().Layouts:Acquire()
    obj.Name = name
    return Layout:from(obj)
end

function Layout:byName(name)
    local layoutObj = ObjectList(string.format('Layout "%s"', name))
    if layoutObj == nil then
        return nil
    end
    if #layoutObj == 0 then
        return nil
    end
    return Layout:from(layoutObj[1])
end

function Layout:getOrCreateByName(name)
    local layout = Layout:byName(name)
    if layout == nil then
        layout = Layout:acquire(name)
    end
    return layout
end

function Layout:from(obj)
    local instance = setmetatable({}, Layout)
    instance.obj = obj
    return instance
end

function Layout:address()
    return ToAddr(self.obj)
end

function Layout:clear()
    Builder:new():delete(string.format("%s.1 Thru", self:address())):noConfirm():exec()
end

function Layout:lastElement()
    -- ToDo: There has to be a better way
    return string.format("%s.%d", self:address(), #DataPool().Layouts[self.obj.No])
end

--- @return LayoutElement
function Layout:assign(elem, posX, posY, width, height)
    local layoutElement = LayoutElement:newByAssign(self, elem)

    if posX ~= nil and posY ~= nil then
        layoutElement:setPosition(posX, posY)
    end

    if width ~= nil and height ~= nil then
        layoutElement:setSize(width, height)
    end

    return layoutElement
end

function Layout:label(posX, posY, width, height)
    local elem = self.obj:Acquire()
    local layoutElement = LayoutElement:from(self, elem)

    if posX ~= nil and posY ~= nil then
        layoutElement:setPosition(posX, posY)
    end

    if width ~= nil and height ~= nil then
        layoutElement:setSize(width, height)
    end

    return layoutElement
end
function LayoutElement:from(layout, obj)

    local instance = setmetatable({}, LayoutElement)
    instance.parent = layout
    instance.obj = obj

    return instance
end

function LayoutElement:newByAssign(layout, elem)
    local obj = layout.obj:Append("Element")
    obj.Object = elem.obj

    local instance = setmetatable({}, LayoutElement)
    instance.parent = layout
    instance.obj = obj

    return instance
end

function LayoutElement:address()
    return ToAddr(self.obj)
end

function LayoutElement:setPosition(x, y)
    self.obj.PosX = x
    self.obj.PosY = y
end

function LayoutElement:setSize(w, h)
    self.obj:Set('width', w)
    self.obj:Set('height', h)
end

function LayoutElement:hideDecorations()
    self.obj:Set("VisibilityBorder", "0")
end

function LayoutElement:id()
    return self.obj.No
end

function LayoutElement:setTextVisibility(visible)
    visible = visible or false
    if visible then
        self.obj:Set("VisibilityObjectName", "Visible")
    else
        self.obj:Set("VisibilityObjectName", "Hidden")
    end
end

function LayoutElement:setVisibilityBar(visible)
    visible = visible or false
    if visible then
        self.obj:Set("VisibilityBar", "Visible")
    else
        self.obj:Set("VisibilityBar", "Hidden")
    end
end

function LayoutElement:setAppearance(appearance)
    self.obj.Appearance = appearance.obj
end

function LayoutElement:setText(text)
    self:setTextVisibility(false)
    self.obj:Set("CustomTextText", text)
    self.obj:Set("CustomTextAlignmentH", "Center")
    self.obj:Set("CustomTextAlignmentV", "Center")
    self.obj:Set("CustomTextSize", 18)


end