Midi = {}
Midi.__index = Midi

MidiInput = {}
MidiInput.__index = MidiInput

function Midi:Device(channel)
    local midi = setmetatable({}, Midi)
    midi.channel = channel

    return midi
end

function Midi:note_on(note, velocity)
    Cmd(string.format("SendMidi \"Note\" %d/%d %d", self.channel, note, velocity))
end
function sendMidiCmd(chan, note, velocity)
    return Builder:new():noteOn(chan, noote, velocity)
end

function sendMidi(chan, note, velocity)
    sendMidiCmd(chan, note, velocity):exec()
end

local function midiMapGet(chan, note)
    local pool = Root().ShowData.Remotes.MIDIRemotes
    last_index = 0
    for i, remote in ipairs(pool) do
        last_index = i
        if remote.MidiChannel == chan and remote.MidiIndex == note
        then
            return remote
        end
    end
    return nil
end

local function midiMapGetOrCreate(chan, note)
    local mapping = midiMapGet(chan, note)
    if mapping == nil then
        local pool = Root().ShowData.Remotes.MIDIRemotes
        mapping = pool:Acquire()
    end
    return mapping
end

function MidiInput:set(chan, note, target)
    local midiRemote = midiMapGetOrCreate(chan, note)
    midiRemote.Target = target.obj
    midiRemote.MidiIndex = note
    midiRemote.Key = "Go+"

end
function MidiInput:unset(chan, note)
    local midiRemote = midiMapGet(chan, note)
    if midiRemote ~= nil then
        midiRemote.Target = nil
    end
end