require("00_library")

local appearanceOffset = 100
local selectedAppearanceOffset = 120

function main()
    local gels = Gel:getAllFromBook(12)
    local tag = Tag:byNameOrCreate("ColorPicker")
    local groups = tag:getGroups()

    Cmd('ClearAll')
    Cmd('Blind On')

    Printf("Generating %d Presets for %d groups", #gels, #groups)
    Builder:new():delete("Appearance 1 Thru"):ifTag(tag:getName()):exec()

    for n, gel in pairs(gels) do
        for _, group in pairs(groups) do
            local cmd = Builder:new()
            cmd                                   :obj(group):at(gel):noUndo():next():
            store(string.format("Preset 4.%d", n)):merge():noUndo():noConfirm():debug():exec()
            Cmd('ClearAll')
        end
        local preset = Color:byId(n)
        tag:assign(preset)

        preset:setName(gel:getName())
        preset:setNote(gel:address())

        local appearance = Appearance:getOrCreate(appearanceOffset + n, string.format("%s Unselected", gel:getName()))
        appearance:setBgColor(gel:getRGB())
        appearance:setFgColor(gel:getRGB())

        tag:assign(appearance)

        local selectedAppearance = Appearance:getOrCreate(selectedAppearanceOffset + n, string.format("%s Selected", gel:getName()))
        selectedAppearance:setFgColor(0, 0, 0)
        selectedAppearance:setBgColor(gel:getRGB())

        tag:assign(selectedAppearance)

    end

end

return main