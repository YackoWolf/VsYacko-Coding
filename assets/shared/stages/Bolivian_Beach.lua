local currentSprites 

function onCreate()
luaDebugMode = false
addCharacterToList('noxfaker', 'dad')
addCharacterToList('noxfang', 'dad')
addCharacterToList('nax', 'dad')
addCharacterToList('noxend', 'dad')
addCharacterToList('bfpixel', 'boyfriend')
addCharacterToList('bfire', 'boyfriend')
addCharacterToList('bf-dead', 'boyfriend')
precacheImage("BeachBolivian/fog")
precacheImage("BeachBolivian/playa")
precacheImage("BeachBolivian/palmeras")
precacheImage("BeachBolivian/fasfinal/loli")
precacheImage("BeachBolivian/fasfinal/pasto")
precacheImage("BeachBolivian/fas2/fog")
precacheImage("BeachBolivian/fas2/palmsombra")
precacheImage("BeachBolivian/fas2/fuegin")
precacheImage("BeachBolivian/fas2/playa")
precacheImage("BeachBolivian/fas2/roca")
precacheImage("BeachBolivian/fas2/palmera")
precacheImage("BeachBolivian/fas2/filtro")
precacheImage("BeachBolivian/pixel/bg")
precacheImage("BeachBolivian/pixel/arbol")
precacheImage("BeachBolivian/pixel/filtro")
beach()
end

function beach()
    makeLuaSprite("fog", "BeachBolivian/fog", -1174, -710)
    scaleObject("fog", 3.25, 2.7)
    addLuaSprite("fog")

    makeLuaSprite("beach", "BeachBolivian/playa", -1167, -727)
    scaleObject("beach", 3.25, 2.7)
    addLuaSprite("beach")

    makeLuaSprite("palms", "BeachBolivian/palmeras", -921, -648)
    scaleObject("palms", 2.6, 2.5)
    addLuaSprite("palms", true)
    currentSprites = {'fog', 'beach', 'palms'}
end
function onStartCountdown()
triggerEvent('Change Character', '1', 'noxfaker')
end
function beachfire()
for i = 1, #currentSprites do removeLuaSprite(currentSprites[i]) end
    makeAnimatedLuaSprite("fogAnim", "BeachBolivian/fas2/fog", -1169, -715)
    addAnimationByPrefix("fogAnim", "lucesita", "fog", 9, true)
    scaleObject("fogAnim", 3.25, 2.7)
    addLuaSprite("fogAnim")

    makeLuaSprite("palmerin", "BeachBolivian/fas2/palmsombra", -1167, -707)
    scaleObject("palmerin", 3.25, 2.7)
    addLuaSprite("palmerin")

    makeAnimatedLuaSprite("fuegin", "BeachBolivian/fas2/fuegin", -1169, -740)
    addAnimationByPrefix("fuegin", "fuegin", "fuegin", 10, true)
    scaleObject("fuegin", 3.25, 2.7)
    addLuaSprite("fuegin")

    makeLuaSprite("beach2", "BeachBolivian/fas2/playa", -1167, -722)
    scaleObject("beach2", 3.25, 2.7)
    addLuaSprite("beach2")

    makeAnimatedLuaSprite("rocks", "BeachBolivian/fas2/roca", -1169, -695)
    addAnimationByPrefix("rocks", "roca", "roca", 10, true)
    scaleObject("rocks", 3.25, 2.7)
    addLuaSprite("rocks")

    makeAnimatedLuaSprite("prime", "BeachBolivian/fas2/palmera", -924, -635)
    addAnimationByPrefix("prime", "palmerafiu", "palmera", 10, true)
    scaleObject("prime", 2.6, 2.5)
    addLuaSprite("prime", true)

    makeLuaSprite("filter", "BeachBolivian/fas2/filtro", -1244, -720)
    scaleObject("filter", 3.35, 2.75)
    setProperty("filter.alpha", 0.3)
    addLuaSprite("filter", true)
    local x = {'fogAnim', 'palmerin', 'fuegin', 'beach2', 'rocks', 'prime', 'filter'}
    for i = 1, #x do
    table.insert(currentSprites, x[i])
    end

getstageData('beachfire')
triggerEvent('Change Character', '1', 'noxfang')
getstageData('beachfire')
end

function pixelbeach()
for i = 1, #currentSprites do removeLuaSprite(currentSprites[i]) end
    makeLuaSprite("pixelbg", "BeachBolivian/pixel/bg", -826, -485)
    scaleObject("pixelbg", 7, 7)
    setProperty("pixelbg.antialiasing", false)
    addLuaSprite("pixelbg")

    makeLuaSprite("pixeltree", "BeachBolivian/pixel/arbol", -826, -485)
    scaleObject("pixeltree", 7, 7)
    setProperty("pixeltree.antialiasing", false)
    addLuaSprite("pixeltree", true)

    makeLuaSprite("pixelfilter", "BeachBolivian/pixel/filtro", -842, -490)
    scaleObject("pixelfilter", 7.1, 7.1)
    setProperty("pixelfilter.alpha", 0.4)
    setProperty("pixelfilter.antialiasing", false)
    addLuaSprite("pixelfilter", true)
    local x = {'pixelbg', 'pixeltree', 'pixelfilter'}
    for i = 1, #x do
    table.insert(currentSprites, x[i])
    end
getstageData('pixelbeach')
triggerEvent('Change Character', '1', 'nax')
triggerEvent('Change Character', '0', 'bfpixel')
setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'bf-pixel-dead')
setPropertyFromClass('substates.GameOverSubstate','deathSoundName', 'fnf_loss_sfx-pixel')
setPropertyFromClass('substates.GameOverSubstate','loopSoundName', 'gameOver-pixel')
setPropertyFromClass('substates.GameOverSubstate','endSoundName', 'gameOverEnd-pixel')
getstageData('pixelbeach')
end

function beachend()
for i = 1, #currentSprites do removeLuaSprite(currentSprites[i]) end
    makeAnimatedLuaSprite("loli", "BeachBolivian/fasfinal/loli", -774, -365)
    addAnimationByPrefix("loli", "loli", "idle", 7, true)
    scaleObject("loli", 1.5, 1.5)
    addLuaSprite("loli")

    makeAnimatedLuaSprite("grass", "BeachBolivian/fasfinal/pasto", -774, -365)
    addAnimationByPrefix("grass", "calvicia", "pasto", 7, true)
    scaleObject("grass", 1.5, 1.5)
    addLuaSprite("grass")
    local x = {'loli', 'grass'}
    for i = 1, #x do
    table.insert(currentSprites, x[i])
    end
getstageData('beachend')
triggerEvent('Change Character', '1', 'noxend')
triggerEvent('Change Character', '0', 'bfire')
setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'bf-keepfire-dead')
setPropertyFromClass('substates.GameOverSubstate','deathSoundName', 'fnf_loss_sfx')
setPropertyFromClass('substates.GameOverSubstate','loopSoundName', 'gameOver')
setPropertyFromClass('substates.GameOverSubstate','endSoundName', 'gameOverEnd')
getstageData('beachend')
end

--1:01, fuego = 61000 ms == step 618
--1:51, pixel = 111000 ms == step 1110
--2:50, final = 170000 ms == step 1708
function onStepHit()
if curStep == 537 then
cameraFlash('other', 'FFFFFF', 0.5)
beachfire()
end
if curStep == 974 then
cameraFlash('other', 'FFFFFF', 0.5)
pixelbeach()
end
if curStep == 1509 then
cameraFlash('other', 'FFFFFF', 0.5)
beachend()
end
end

local stageData = {
    defaultZoom = 0.9,

    boyfriend = {770, 100},
    girlfriend = {400, 130},
    opponent = {100, 100},
    hide_girlfriend = false,

    camera_boyfriend = {0, 0},
    camera_opponent = {0, 0},
    camera_girlfriend = {0, 0},
    camera_speed = 1
}
local stageFile
function getstageData(stage)
    if currentModDirectory ~= '' then
        stageFile = currentModDirectory..'/stages/'..stage
    else
        stageFile = 'stages/'..stage
    end
	
    local json = stringSplit(getTextFromFile(stageFile..'.json'), '{')
	table.remove(json, 1)
	json = stringSplit(table.concat(json), '}')
	table.remove(json, 2)
	json = stringSplit(table.concat(json), '\n')
	json = table.concat(json, '')
	json = json:gsub('directory', stageFile)
	json = json:gsub(' ', '')
	json = json:gsub(':', '!_!')
	json = json:gsub(',"', '/_/')
	json = json:gsub('"', '')
	json = json:gsub('!_!', '("')
	json = json:gsub('/_/', '")')
	json = json:gsub('%[', '')
	json = json:gsub('%]', '')
	json = json:gsub('hide_girlfriend', 'hideGF')
	json = json:gsub('camera_boyfriend', 'camBF')
	json = json:gsub('camera_girlfriend', 'camGF')
	json = json:gsub('camera_opponent', 'camDAD')
	
    for dZ in string.gmatch(json, "defaultZoom%(%s*['\"](.-)['\"]") do
        stageData.defaultZoom = tonumber(dZ)
    end
    for bfp in string.gmatch(json, "boyfriend%(%s*['\"](.-)['\"]") do
	    local pos = stringSplit(bfp, ',')
        stageData.boyfriend[1] = pos[1]
        stageData.boyfriend[2] = pos[2]
    end
    for gfp in string.gmatch(json, "girlfriend%(%s*['\"](.-)['\"]") do
	    local pos = stringSplit(gfp, ',')
        stageData.girlfriend[1] = pos[1]
        stageData.girlfriend[2] = pos[2]
    end
    for ddp in string.gmatch(json, "opponent%(%s*['\"](.-)['\"]") do
	    local pos = stringSplit(ddp, ',')
        stageData.opponent[1] = pos[1]
        stageData.opponent[2] = pos[2]
    end
    for hgf in string.gmatch(json, "hideGF%(%s*['\"](.-)['\"]") do
        stageData.hide_girlfriend = hgf
    end
    for cbf in string.gmatch(json, "camBF%(%s*['\"](.-)['\"]") do
	    local pos = stringSplit(cbf, ',')
        stageData.camera_boyfriend[1] = pos[1]
        stageData.camera_boyfriend[2] = pos[2]
    end
    for cgf in string.gmatch(json, "camGF%(%s*['\"](.-)['\"]") do
	    local pos = stringSplit(cgf, ',')
        stageData.camera_girlfriend[1] = pos[1]
        stageData.camera_girlfriend[2] = pos[2]
    end
    for cdd in string.gmatch(json, "camDAD%(%s*['\"](.-)['\"]") do
	    local pos = stringSplit(cdd, ',')
        stageData.camera_opponent[1] = pos[1]
        stageData.camera_opponent[2] = pos[2]
    end
    for cs in string.gmatch(json, "camera_speed%(%s*['\"](.-)['\"]") do
        stageData.camera_speed = tonumber(cs)
    end
    configPositions()
end

function nilCheck(value, original)
	if value == '' or value == nil then
		return getProperty(original)
	else
		return value
	end
end

function setCharsPos(char, thing)
	setCharacterX(char, thing[1] + getProperty(char .. '.positionArray[0]'))
	setCharacterY(char, thing[2] + getProperty(char .. '.positionArray[1]'))
	setProperty(char .. '.x', thing[1] + getProperty(char .. '.positionArray[0]'))
	setProperty(char .. '.y', thing[2] + getProperty(char .. '.positionArray[1]'))
end

function configPositions()
	setProperty('camGame.zoom', stageData.defaultZoom)
	setProperty('defaultCamZoom', stageData.defaultZoom)

	setCharsPos('boyfriend', stageData.boyfriend)
	setCharsPos('gf', stageData.girlfriend)
	setCharsPos('dad', stageData.opponent)
	
	setProperty('gf.visible', not stageData.hide_girlfriend)

	setProperty('boyfriendCameraOffset[0]', nilCheck(stageData.camera_boyfriend[1], 'boyfriendCameraOffset[0]'))
	setProperty('boyfriendCameraOffset[1]', nilCheck(stageData.camera_boyfriend[2], 'boyfriendCameraOffset[1]'))
	setProperty('girlfriendCameraOffset[0]', nilCheck(stageData.camera_girlfriend[1], 'girlfriendCameraOffset[0]'))
	setProperty('girlfriendCameraOffset[1]', nilCheck(stageData.camera_girlfriend[2], 'girlfriendCameraOffset[1]'))
	setProperty('opponentCameraOffset[0]', nilCheck(stageData.camera_opponent[1], 'opponentCameraOffset[0]'))
	setProperty('opponentCameraOffset[1]', nilCheck(stageData.camera_opponent[2], 'opponentCameraOffset[1]'))
	
	setProperty('cameraSpeed', nilCheck(stageData.camera_speed, 'cameraSpeed'))
	goToChar(mustHitSection and 'bf' or 'dad')
end


function goToChar(v)
if v == 'dad' then
offsetName = 'opponent'
offsetX = 150
offsetY = -100
elseif v == 'gf' then
offsetName = 'girlfriend'
offsetX = 0
offsetY = 0
else
v = 'boyfriend'
offsetName = 'boyfriend'
offsetX = -100
offsetY = -100
end
setProperty('camFollowPos.x', getProperty(v..'.cameraPosition[0]') + getProperty(offsetName..'CameraOffset[0]') + (getMidpointX(v)+offsetX))
setProperty('camFollow.x', getProperty(v..'.cameraPosition[0]') + getProperty(offsetName..'CameraOffset[0]') + (getMidpointX(v)+offsetX))
setProperty('camFollowPos.y', getProperty(v..'.cameraPosition[1]') + getProperty(offsetName..'CameraOffset[1]') + (getMidpointY(v)+offsetY))
setProperty('camFollow.y', getProperty(v..'.cameraPosition[1]') + getProperty(offsetName..'CameraOffset[1]') + (getMidpointY(v)+offsetY))
end