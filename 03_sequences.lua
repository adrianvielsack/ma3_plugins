Sequence = {}
Sequence.__index = Sequence

function Sequence:from(obj)
    local instance = setmetatable({}, Sequence)
    instance.id = obj.No
    instance.obj = obj
    return instance
end

function Sequence:byNameOrCreate(name)
    local seq = Sequence:byName(name)
    if seq == nil then
        seq = Sequence:acquire(name)
    end
    return seq
end

function Sequence:byName(name)
    local objs = ObjectList(string.format('Sequence "%s"', name))

    if objs == nil then
        return nil
    end
    if #objs == 0 then
        return nil
    end
    return Sequence:from(objs[1])
end

function Sequence:acquire(name)
    local seqRaw = DataPool().Sequences:Acquire()
    Printf(tostring(seqRaw == nil))

    local seq = Sequence:from(seqRaw)
    seq.obj.Name = name
    return seq
end

function Sequence:get(id)
    local obj = DataPool().Sequences[id]
    if obj == nil then
        return nil
    end
    local instance = setmetatable({}, Sequence)
    instance.id = id
    instance.obj = obj
    return instance
end

--- @return Sequence
function Sequence:create(id, name)
    local instance = setmetatable({}, Sequence)
    instance.id = id
    Cmd(string.format("ClearAll; Store Sequence %d", id))

    instance.obj = DataPool().Sequences[id]--DataPool().Sequences:Create(id)
    instance.obj:Dump()
    instance.obj.Name = name

    return instance
end

function Sequence:findWithTag(tag)
    local sequences = {}
    local allSequences = ObjectList('Sequence Thru')
    for _, sequence in pairs(allSequences) do
        if HasTag(sequence.Tags, tag) then
            table.insert(sequences, Sequence:from(sequence))
        end
    end
    return sequences
end

function Sequence:getOrCreate(id, name)
    local instance = Sequence:get(id)
    if instance == nil then
        return Sequence:create(id, name)
    end
    return instance
end

function Sequence:address()
    return ToAddr(self.obj, false)
end

function Sequence:setTracking(enabled)
    if enabled then
        self.obj.Tracking = 1
    else
        self.obj.Tracking = 0
    end
end

function Sequence:setPreferCueAppearance(b)
    self.obj.PreferCueAppearance = b
end

function Sequence:setAppearance(appearance)
    self.obj.Appearance = appearance.obj
end

function Sequence:addCue()
    local obj = self.obj:Insert(#self.obj + 1)
    obj.No = string.format("%i.0", #self.obj - 2)
    obj:Create(1).Part = 0

    return Cue:from(obj)
end

function Sequence:getCue(cueId)
    local cue = self.obj[cueId + 2]
    if cue ~= nil then
        return Cue:from(cue)
    end
    return nil
end

function Sequence:getOrCreateCue(cueId)
    if #self.obj - 2 >= cueId then
        local cue = self:getCue(cueId)
        if cue ~= nil then
            return cue
        end
    end
    while #self.obj < cueId + 2 do
        cue = self:addCue()
    end
    return cue
end

function Sequence:getName()
    return self.obj.Name
end

function Sequence:children()
    local ret = {}
    for _, cue in pairs(self.obj:Children())
    do
        table.insert(ret, Cue:from(cue))
    end
    return ret
end

Cue = {}
Cue.__index = Cue

function Cue:from(obj)
    local instance = setmetatable({}, Cue)
    instance.obj = obj
    return instance
end

function Cue:setTrackingDistance(dist)
    self.obj.TrackingDistance = dist
end

function Cue:address()
    return ToAddr(self.obj, false)
end

function Cue:getCuePart(partId)
    local partObj = self.obj[partId + 1]
    if partObj == nil then
        while #self.obj < (partId + 1) do
            partObj = self.obj:Insert(#self.obj + 1)
            partObj.Part = #self.obj - 1
            Printf(partObj.Part)
        end
    end
    return CuePart:from(partObj)
end

function Cue:setCommand(cmdLine)
    self:getCuePart(0):setCommand(cmdLine)
end

function Cue:setAppearance(appearance)
    self:getCuePart(0):setAppearance(appearance)
end

function Cue:getAppearance()
    return self:getCuePart(0):getAppearance()
end

function Cue:setName(name)
    self:getCuePart(0):setName(name)
end

function Cue:getName()
    return self:getCuePart(0):getName()
end

TRIGGER_TYPE_GO = "Go"
TRIGGER_TYPE_FOLLOW = "Follow"

function Cue:setTriggerType(type, value)
    self.obj.TrigType = type
    if value ~= nil then
        self.obj.TrigTime = value
    end
end

function Cue:setFadeTime(t)
    self:getCuePart(1).obj.CueInFade = t
end

CuePart = {}
CuePart.__index = CuePart

function CuePart:from(obj)
    local instance = setmetatable({}, CuePart)
    instance.obj = obj
    return instance
end

function CuePart:address()
    return ToAddr(self.obj, false)
end

function CuePart:addRecipe()
    local obj = self.obj:Insert(#self.obj + 1)
    return Recipe:from(obj)
end

function CuePart:getOrCreateRecipe(id)
    local obj = self.obj[id]
    if obj == nil then
        local recipe = self:addRecipe()
        while #self.obj < id do
            recipe = self:addRecipe()
        end
        return recipe
    end
    return Recipe:from(obj)
end

function CuePart:setCommand(cmd)
    self.obj.Command = cmd
end

function CuePart:setAppearance(appearance)
    self.obj.Appearance = appearance.obj
end

function CuePart:getAppearance()
    if self.obj.Appearance == nil then
        return nil
    end
    return Appearance:from(self.obj.Appearance)
end

function CuePart:setName(name)
    self.obj.Name = name
end

function CuePart:getName()
    return self.obj.Name
end

Recipe = {}
Recipe.__index = Recipe

function Recipe:from(obj)
    local instance = setmetatable({}, Recipe)
    instance.obj = obj
    return instance
end

function Recipe:address()
    return ToAddr(self.obj, false)
end

function Recipe:setName(name)
    self.obj.Name = name
end

function Recipe:setSelection(group)
    self.obj.Selection = group.obj
end

function Recipe:setValue(preset)
    self.obj.Values = preset.obj
end