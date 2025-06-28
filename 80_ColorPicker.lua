require("00_library")

ColorPicker = {}
ColorPicker.__index = ColorPicker

local pickers = { "Prim", "Sec", "Spare A", "Spare B", "Spare C", "Flash", "Color FXA", "Color FXB" }
local sequenceStart = 1000
local pickerSize = 200
local pickerGridSpacing = 10
local macroOffset = 1000
local configMacroOffset = 1400
local groupsOffset = 500
local presetStart = 1
local presetSelectStart = 20
local presetFadeStart = 40

local log = Logger:new("ColorPicker")

function ColorPicker:pickerCreate(yOffset, seq, selectedAppearances)
    cues = {}
    macros = {}

    local numberOfPresets = #self.colorPresets

    --lpColorClearCmd = LaunchPadCmd:new()

    for n, color in pairs(self.colorPresets) do
        local individualOffset = macroOffset + yOffset * numberOfPresets + n
        local cue = seq:getOrCreateCue(n)

        log:debug("creating picker with yOffset %d Cue %d color named '%s'", yOffset, n, color:getName())

        table.insert(cues, cue)
        cue:setName(color:getName())
        cue:setAppearance(self.appearances[n])

        local pickerMacro = Macro:getOrCreate(individualOffset, string.format("%s %s", seq:getName(), color:getName()))
        self.tag:assign(pickerMacro)

        local selectLine = pickerMacro:setLineOrCreate(1, Builder:new():gotoObj():sequence(seq):cue(n):noUndo():str())
        local jumpLine = pickerMacro:setLineOrCreate(2, Builder:new():
        gotoObj()                                              :sequence(seq):cue(n):noUndo():next():
        copy(self.colorPresets[n])                             :at(string.format("Preset 4.%d", yOffset + presetFadeStart)):noConfirm():noOops():next():
        copy(self.colorPresets[n])                             :at(string.format("Preset 4.%d", yOffset + presetSelectStart)):noConfirm():noOops():next():
        str())
        jumpLine:disable()
        pickerMacro:setAppearance(self.appearances[n])
        table.insert(macros, pickerMacro)

        self           .goSwitch:addLine(Builder:new():
        set(jumpLine)                           :property("Enabled", true):next():
        set(selectLine)                         :property("Enabled", false):next():str())

        self.goFade:addLine(Builder:new():
        set(jumpLine)              :property("Enabled", false):next():
        set(selectLine)            :property("Enabled", true):next():str())

        local pickerMacroLayoutElem = self.pickerLayout:assign(pickerMacro, n * (pickerSize + pickerGridSpacing), -1 * (pickerSize + pickerGridSpacing) * yOffset, pickerSize, pickerSize)
        pickerMacroLayoutElem:hideDecorations()
        pickerMacroLayoutElem:setTextVisibility(false)
        --lpColorClearCmd:setLedRGB(n, 10 - yOffset, r, g, b, 170)

    end



    --lpColorClearCmd:exec()

    for n, color in pairs(self.colorPresets) do
        local cueCommand = Builder:new()
        cueCommand:assign(self.appearances):at(macros[1]):thru(macros[#macros].obj.No):noConfirm():noUndo():next()
        cueCommand:assign(selectedAppearances[n]):at(macros[n]):noConfirm():noUndo():next()
        cueCommand:copy(color):at(string.format("Preset 4.%d", yOffset + presetFadeStart)):noUndo():noConfirm():next()
        --[[lpColorClearCmd:copyToCmd(cueCommand)
        local r, g, b = self.gels[n]:getRGB()
        LaunchPadCmd:from(cueCommand):setLedRGB(n, 9 - yOffset, r, g, b)
]]
        cues[n]:setCommand(cueCommand:str())
    end

    if Color:byId(yOffset + presetFadeStart) == nil then
        Builder:new():copy(self.colorPresets[1]):at(string.format("Preset 4.%d", yOffset + presetFadeStart)):noUndo():noConfirm():exec()
    end

    if Color:byId(yOffset + presetSelectStart) == nil then
        Builder:new():copy(self.colorPresets[1]):at(string.format("Preset 4.%d", yOffset + presetSelectStart)):noUndo():noConfirm():exec()
    end

    local elem = self.pickerLayout:assign(Color:byId(yOffset + presetSelectStart), -2 * (pickerSize + pickerGridSpacing), -1 * (pickerSize + pickerGridSpacing) * yOffset, pickerSize, pickerSize)
    elem:setTextVisibility(false)
    elem:hideDecorations()

end

function ColorPicker:createGroupAssignSelector(configLayout, groups, valuesSequence)
    local unselected = Appearance:byName("unselected")
    local selected = Appearance:byName("selected")
    local transparent = Appearance:byId(14)
    local macroStart = macroOffset + 200

    local fadeSeq = valuesSequence:getCue(2)
    local copySeq = valuesSequence:getCue(3)

    for n, picker in pairs(pickers) do
        local elem = configLayout:label(n * (pickerSize + pickerGridSpacing), 0, pickerSize, pickerSize)
        elem:setText(picker)
    end

    for i, group in pairs(groups) do

        local elem = configLayout:label(-pickerSize * 2, -i * (pickerSize + pickerGridSpacing), pickerSize * 2, pickerSize)
        elem:setText(CleanupText(group:getName()))

        local firstMacro = macroStart + i * #pickers + 1
        local lastMacro = macroStart + i * #pickers + #pickers
        for n, _ in pairs(pickers) do
            local macroId = macroStart + i * #pickers + n
            local selectMacro = Macro:getOrCreate(macroId, "")
            local macroElem = configLayout:assign(selectMacro, n * (pickerSize + pickerGridSpacing), -i * (pickerSize + pickerGridSpacing), pickerSize, pickerSize)
            macroElem:hideDecorations()
            macroElem:setTextVisibility(false)
            selectMacro:setAppearance(unselected)
            local cmd = Builder:new()
            cmd:assign(unselected):at(string.format("Macro %d Thru %d", firstMacro, lastMacro)):noUndo():next()
            cmd:assign(selected):at(selectMacro):noUndo():noConfirm()
            selectMacro:setLineOrCreate(1, cmd:str())

            cmd = Builder:new()
            cmd:assign(Color:byId(presetFadeStart + n)):at(valuesSequence):cue(2):part(1, i):noUndo()
            selectMacro:setLineOrCreate(2, cmd:str())

            local assignGroupCmd = Builder:new()
            assignGroupCmd:assign(Color:byId(presetSelectStart + n)):at(valuesSequence):cue(1):part(1, i):noUndo()

            copySeq:getCuePart(i)

            cmd = Builder:new()
            cmd:set(valuesSequence):cue(3):part(i):property("Command", assignGroupCmd:str())
            selectMacro:setLineOrCreate(3, cmd:str())
        end
    end

end

function ColorPicker:createValuesSequence(valuesSequence, groups)

    local valuesCue = valuesSequence:getOrCreateCue(1, "ValuesCue")
    valuesCue:setTriggerType(TRIGGER_TYPE_FOLLOW, 0.1)
    local cuePart = valuesCue:getCuePart(1)
    for n, group in pairs(groups) do
        local recipe = cuePart:getOrCreateRecipe(n)
        recipe:setName(group:getName())
        recipe:setSelection(group)
        recipe:setValue(Color:byId(presetSelectStart + 1))
    end

    local fadeCue = valuesSequence:getOrCreateCue(2, "FadeCue")
    fadeCue:setFadeTime(0.5)
    cuePart = fadeCue:getCuePart(1)
    for n, group in pairs(groups) do
        local recipe = cuePart:getOrCreateRecipe(n)
        recipe:setName(group:getName())
        recipe:setSelection(group)
        recipe:setValue(Color:byId(presetFadeStart + 1))
    end

    local copyCue = valuesSequence:getOrCreateCue(3, "CopyCue")
    copyCue:setTriggerType(TRIGGER_TYPE_FOLLOW, 0.1)
    local cmd = Builder:new()
    cmd:copy(Color:byId(presetFadeStart + 1)):thru(presetFadeStart + #pickers):at(Color:byId(presetSelectStart + 1)):noConfirm():noUndo()
    copyCue:setCommand(cmd:str())
    return
end

function ColorPicker:createMatrixSelector(valuesSequence, groups)
    local tricks = MATricks:findWithTag("ColorPicker")

    local macros = {}
    local resetCmd = Builder:new()

    for n, trick in pairs(tricks) do
        local macro = Macro:create(configMacroOffset + n, trick:getName())
        self.tag:assign(macro)

        macro:setAppearance(Appearance:byName(string.format("%s Unselected", trick:getName())))
        local layoutItem = self.pickerLayout:assign(macro, n * (pickerGridSpacing + pickerSize), 0.2 * pickerSize, pickerSize, pickerSize)
        layoutItem:hideDecorations()
        layoutItem:setTextVisibility(false)
        local appearance = Appearance:byName(string.format("%s Unselected", trick:getName()))
        resetCmd:assign(appearance):at(macro):noUndo():next()

        table.insert(macros, macro)
    end

    local fadeCue = valuesSequence:getCue(2)

    for n, trick in pairs(tricks) do
        macros[n]:setLineOrCreate(1, resetCmd:str())
        macros[n]:setLineOrCreate(2, Builder:new():assign(Appearance:byName(string.format("%s Selected", trick:getName()))):at(macros[n]):noUndo():str())
        local setCmd = Builder:new()
        for i, group in pairs(groups) do
            setCmd:assign(trick):at(valuesSequence):cue(2):part(1, i):noUndo():next()
        end
        macros[n]:setLineOrCreate(3, setCmd:str())
    end
end

function ColorPicker:new()
    local clrPicker = setmetatable({}, ColorPicker)

    self.tag = Tag:byNameOrCreate("ColorPicker")
    self.gels = Gel:getAllFromBook(12)
    self.colorPresets = Color:byRange(1, #self.gels)
    self.appearances = Appearance:byRange(101, 101 + #self.gels)
    self.appearanceActive = Appearance:byName("active")
    self.appearanceInactive = Appearance:byName("inactive")

    return clrPicker
end
function ColorPicker:build()

    local additionalPresetsTag = Tag:byNameOrCreate("ColorPickerAdd")

    local selectedAppearances = Appearance:byRange(121, 121 + #self.gels)
    local groups = self.tag:getGroups()

    Builder:new():delete("Layout 1.1 Thru"):noConfirm():exec()
    Builder:new():delete("Layout 2.1 Thru"):noConfirm():exec()
    Builder:new():delete("Macro 1 Thru"):ifTag(self.tag:getName()):noConfirm():exec()

    self.goFadeCommand = Builder:new()
    self.goSwitchCommand = Builder:new()

    self.goFade = Macro:acquire("Fade")
    self.tag:assign(self.goFade)
    self.goFade:setAppearance(self.appearanceActive)

    self.goSwitch = Macro:acquire("Direct")
    self.tag:assign(self.goSwitch)
    self.goSwitch:setAppearance(self.appearanceInactive)

    local additionalPresets = Color:findWithTag(additionalPresetsTag:getName())
    log:info("Creating additional %d presets", #additionalPresets)
    for n, preset in pairs(additionalPresets) do
        local addAppearance = Appearance:byName(string.format("%s Unselected", preset:getNote()))
        local addAppearanceSelected = Appearance:byName(string.format("%s Selected", preset:getNote()))
        table.insert(self.appearances, addAppearance)
        table.insert(selectedAppearances, addAppearanceSelected)
        table.insert(self.colorPresets, preset)
    end

    self.pickerLayout = Layout:getOrCreate(1, "ColorPicker")
    self.tag:assign(self.pickerLayout)
    local configLayout = Layout:getOrCreate(2, "ColorPicker Config")
    self.tag:assign(configLayout)

    local valuesSequence = Sequence:getOrCreate(sequenceStart - 1, "Color Values")
    self.tag:assign(valuesSequence)

    for n, picker in pairs(pickers) do
        local pickerSequence = Sequence:create(sequenceStart + n, picker)
        self.tag:assign(pickerSequence)
        pickerSequence:setPreferCueAppearance(true)
        local layoutElem = self.pickerLayout:assign(pickerSequence, -pickerSize, -n * (pickerSize + pickerGridSpacing), pickerSize * 2, pickerSize)
        layoutElem:hideDecorations()

        self:pickerCreate(n, pickerSequence, selectedAppearances)
    end
    self:createValuesSequence(valuesSequence, groups)
    self:createGroupAssignSelector(configLayout, groups, valuesSequence)
    self:createMatrixSelector(valuesSequence, groups)

    self.pickerLayout:assign(self.goFade, (pickerSize + pickerGridSpacing) * 8, pickerSize * 0.2, pickerSize * 1.5, pickerSize)
    self.pickerLayout:assign(self.goSwitch, (pickerSize + pickerGridSpacing) * 9.5, pickerSize * 0.2, pickerSize * 1.5, pickerSize)
    self.goFade:addLine(self.goFadeCommand:assign(self.appearanceActive):at(self.goFade):noUndo():next():assign(self.appearanceInactive):at(self.goSwitch):str())
    self.goSwitch:addLine(self.goSwitchCommand:assign(self.appearanceActive):at(self.goSwitch):noUndo():next():assign(self.appearanceInactive):at(self.goFade):str())

    Builder:new():go(valuesSequence):noUndo():exec()
end

function main()
    ColorPicker:new():build()
end

return main

