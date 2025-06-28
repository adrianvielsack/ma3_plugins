PRESET_DIMMER = 1
PRESET_POSITION = 2
PRESET_GOBO = 3
PRESET_COLOR = 4
PRESET_BEAM = 5
PRESET_FOCUS = 6
PRESET_CONTROL = 7

PRESET_PHASER = 21
PRESET_GENERIC_23 = 23

Color = {}
Color.__index = Color

function Color:byId(no)
    local obj = DataPool().PresetPools[PRESET_COLOR][no]
    if obj == nil then
        return nil
    end
    return Color:from(obj)
end

function Color:from(obj)
    local preset = setmetatable({}, Color)
    preset.obj = obj
    return preset
end

function Color:findWithTag(tag)
    local colors = {}
    local allColors = ObjectList('Preset 4.1 Thru')
    for _, color in pairs(allColors) do
        if HasTag(color.Tags, tag) then
            table.insert(colors, Color:from(color))
        end
    end
    return colors
end

function Color:byRange(start, stop)
    ret = {}
    for n = start, stop do
        table.insert(ret, Color:byId(n))
    end
    return ret
end

function Color:setName(name)
    self.obj.Name = name
end

function Color:getName()
    return self.obj.Name
end

function Color:address()
    return ToAddr(self.obj, false)
end

function Color:setNote(note)
    self.obj.Note = note
end

function Color:getNote()
    return self.obj.Note
end

GenericPreset = {}
GenericPreset.__index = GenericPreset

function GenericPreset:byId(pool, no)
    local obj = DataPool().PresetPools[pool][no]
    if obj == nil then
        return nil
    end
    return GenericPreset:from(obj)
end

function GenericPreset:from(obj)
    local preset = setmetatable({}, GenericPreset)
    preset.obj = obj
    return preset
end

function GenericPreset:findWithTag(tag, pool)
    local colors = {}
    local allGenericPresets = ObjectList(string.format('Preset %d.1 Thru', pool))
    for _, color in pairs(allGenericPresets) do
        if HasTag(color.Tags, tag) then
            table.insert(colors, GenericPreset:from(color))
        end
    end
    return colors
end

function GenericPreset:byRange(pool, start, stop)
    ret = {}
    for n = start, stop do
        table.insert(ret, GenericPreset:byId(pool, n))
    end
    return ret
end

function GenericPreset:setName(name)
    self.obj.Name = name
end

function GenericPreset:getName()
    return self.obj.Name
end

function GenericPreset:address()
    return ToAddr(self.obj, false)
end

function GenericPreset:setNote(note)
    self.obj.Note = note
end

function GenericPreset:getNote()
    return self.obj.Note
end