require("00_library")

local pickerSize = 200
local pickerMargin = 20

local function createSequencePicker(layout, sequences, appActive, appInactive, tag)
    for y, seq in pairs(sequences) do
        local macros = {}
        seq:setPreferCueAppearance(true)
        seq:setAppearance(Appearance:byName("Transparent"))

        local seqElem = layout:assign(seq, -2 * (pickerSize + pickerMargin), y * (pickerSize + pickerMargin), pickerSize * 2, pickerSize)
        seqElem:setVisibilityBar(true)

        local cmdReset = Builder:new()

        for x, cue in pairs(seq:children()) do
            if x > 2 then
                local cueAppearance = cue:getAppearance() or appInactive
                local macro = Macro:acquire()
                macro:setName(cue:getName())
                table.insert(macros, macro)

                local cmd = Builder:new():gotoObj():sequence(seq):cue(x - 2):noUndo():next()
                macro:setLineOrCreate(1, cmd:str())
                macro:setAppearance(cueAppearance)

                tag:assign(macro)

                cmdReset:assign(cueAppearance):at(macro):noUndo():noConfirm():next()

                layoutElem = layout:assign(macro, (x - 3) * (pickerSize + pickerMargin), y * (pickerSize + pickerMargin), pickerSize, pickerSize)
                layoutElem:setText(CleanupText(cue:getName()))

            end
        end

        for _, macro in pairs(macros) do
            macro:setLineOrCreate(2, cmdReset:str())
            macro:setLineOrCreate(3, Builder:new():assign(appActive):at(macro):str())
        end

    end

end

function createSequencePickerByTagName(tagName, appActive, appInactive, tag)
    local layout = Layout:getOrCreateByName(tagName)
    tag:assign(layout)
    local sequences = Sequence:findWithTag(tagName)
    if #sequences == 0 then
        return
    end
    createSequencePicker(layout, sequences, appActive, appInactive, tag)
end

function main()

    local tag = Tag:byNameOrCreate("SequencePicker")
    --Builder:new():delete("Layout 1 Thru"):ifTag("SequencePicker"):noConfirm():debug():exec()
    local layouts = tag:getLayouts()
    for n, layout in pairs(layouts) do
        layout:clear()
    end
    Builder:new():delete("Macro 1 Thru"):ifTag("SequencePicker"):noConfirm():debug():exec()

    local appActive = Appearance:byName("active")
    local appInactive = Appearance:byName("inactive")

    createSequencePickerByTagName("SequencePicker", appActive, appInactive, tag)

    local seqPickerTags = Tag:byTagName("SequencePicker")

    for _, seqPicker in pairs(seqPickerTags) do
        createSequencePickerByTagName(seqPicker:getName(), appActive, appInactive, tag)
    end

end

return main