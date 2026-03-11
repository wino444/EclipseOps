-- =============================================
-- 🎹 Piano Core Engine
-- wino444/repo/main/piano_core.lua
-- =============================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Connector = workspace:WaitForChild("GlobalPianoConnector")

-- ===== Sound System =====
local LocalSounds = {
    "233836579","233844049","233845680",
    "233852841","233854135","233856105"
}

local SoundFolder = Instance.new("Folder")
SoundFolder.Name = "AutoPianoSounds"
SoundFolder.Parent = Player.PlayerGui

local ExistingSounds = {}

local function PlayNoteSound(noteNum)
    local v55 = (noteNum - 1) % 12 + 1
    local v57 = math.ceil(noteNum / 12)
    local v59 = math.ceil(v55 / 2)
    local v60 = (v57 - 1) * 16 + 8 * (1 - v55 % 2)
    if not LocalSounds[v59] then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. LocalSounds[v59]
    sound.TimePosition = v60 + (v57 - 0.9) / 15
    sound.Parent = SoundFolder
    sound:Play()
    table.insert(ExistingSounds, 1, sound)
    if #ExistingSounds >= 10 then
        if ExistingSounds[10] then
            ExistingSounds[10]:Stop()
            ExistingSounds[10]:Destroy()
        end
        ExistingSounds[10] = nil
    end
    delay(4, function() sound:Stop() sound:Destroy() end)
end

local KEY_MAP = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"

local function LetterToNote(char)
    return string.find(KEY_MAP, char, 1, true)
end

local function PlayNote(noteNum)
    if noteNum < 1 or noteNum > 61 then return end
    PlayNoteSound(noteNum)
    Connector:FireServer("play", noteNum)
end

local function PlayLetter(char)
    local note = LetterToNote(char)
    if note then PlayNote(note) end
end

-- ===== Parser: t(0.3)t(0.3)o(0.6) =====
local function ParseNotes(noteStr)
    local notes = {}
    for key, delay in noteStr:gmatch("(.)%(([%d%.]+)%)") do
        table.insert(notes, { key = key, delay = tonumber(delay) })
    end
    if #notes == 0 then
        for key in noteStr:gmatch("%S+") do
            table.insert(notes, { key = key, delay = 0.3 })
        end
    end
    return notes
end

local function CalcTotalTime(noteStr)
    local total = 0
    for delay in noteStr:gmatch("%(([%d%.]+)%)") do
        total = total + tonumber(delay)
    end
    return total
end

local function PlaySong(noteStr)
    local notes = ParseNotes(noteStr)
    local isPlaying = true
    coroutine.wrap(function()
        for _, noteData in ipairs(notes) do
            if not isPlaying then break end
            PlayLetter(noteData.key)
            wait(noteData.delay)
        end
        print("🎵 เล่นเสร็จ!")
    end)()
    return function() isPlaying = false end
end

-- ===== Public API =====
getgenv().PianoEngine = {
    PlayNote      = PlayNote,
    PlayLetter    = PlayLetter,
    ParseNotes    = ParseNotes,
    CalcTotalTime = CalcTotalTime,
    PlaySong      = PlaySong,
}

print("✅ Piano Core โหลดสำเร็จ!")
