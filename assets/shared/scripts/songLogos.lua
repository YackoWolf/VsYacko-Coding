local coolY = 0
function onCreate()
local fileExists = checkFileExists(currentModDirectory..'/images/logos/'..songPath..'.xml')
local file = fileExists and 'logos/'..songPath or 'logoBumpin'
local anim = fileExists and 'idle' or 'logo bumpin'

quickSprite(true, 'songLogo', file, 0, 0, 'other', true)
addAnimationByPrefix('songLogo', 'idle', anim, 8, true)
screenCenter('songLogo')
coolY = getProperty('songLogo.y')
setProperty('songLogo.y', -screenHeight)
end

function onSongStart()
doTweenY('songLogo', 'songLogo', coolY, 1, 'expoOut')
runTimer('quit', 2)
end

function onTimerCompleted(t)
if t == 'quit' then
doTweenY('quitLogo', 'songLogo', screenHeight, 1, 'backIn')
end
end

function onTweenCompleted(t)
if t == 'quitLogo' then
removeLuaSprite('songLogo')
end
end

function quickSprite(animated, tag, file, x, y, camera, front)
if animated then
makeAnimatedLuaSprite(tag, file, x, y)
else
makeLuaSprite(tag, file, x, y)
end
setObjectCamera(tag, camera)
front = front or false
addLuaSprite(tag, front)
end
