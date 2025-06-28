require("00_library")

function main()

    local gels = Gel:getAllFromBook(12)

    local pickerLayout = Layout:getOrCreate(3, "Picker")
    local sequence = Sequence.getOrCreate(600, "Picker test")
    local cue = sequence.getOrCreateCue(1)
    pickerLayout:assign(cue, 0, 0, 200, 200)

end

return main

