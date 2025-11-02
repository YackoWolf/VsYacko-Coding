local opponentFolder = 'op'
local playerFolder = 'bf'

function onCreatePost()
setProperty('healthBar.visible', false)
----EMPTY BARS
quickSprite(false, 'empty1', 'hpbars/a-bark/'..opponentFolder..'/hpempty', 0, 0, 'hud')
scaleObject('empty1', 0.8, 0.8)
setProperty('empty1.y', downscroll and 0 or screenHeight - getProperty('empty1.height'))

quickSprite(false, 'empty2', 'hpbars/a-bark/'..playerFolder..'/hpempty', 0, 0, 'hud')
scaleObject('empty2', 0.8, 0.8)
setProperty('empty2.y', downscroll and 0 or screenHeight - getProperty('empty2.height'))
setProperty('empty2.x', screenWidth - getProperty('empty2.width'))
----BARS
quickSprite(false, 'bar1', 'hpbars/a-bark/'..opponentFolder..'/hp1', 0, 0, 'hud')
scaleObject('bar1', 0.8, 0.8)
setProperty('bar1.y', downscroll and 0 or screenHeight - getProperty('bar1.height'))

quickSprite(false, 'bar2', 'hpbars/a-bark/'..playerFolder..'/hp1', 0, 0, 'hud')
scaleObject('bar2', 0.8, 0.8)
setProperty('bar2.y', downscroll and 0 or screenHeight - getProperty('bar2.height'))
setProperty('bar2.x', screenWidth - getProperty('bar2.width'))
----FRAMES
quickSprite(false, 'frame1', 'hpbars/a-bark/'..opponentFolder..'/hpframe', 0, 0, 'hud')
scaleObject('frame1', 0.8, 0.8)
setProperty('frame1.y', downscroll and 0 or screenHeight - getProperty('frame1.height'))

quickSprite(false, 'frame2', 'hpbars/a-bark/'..playerFolder..'/hpframe', 0, 0, 'hud')
scaleObject('frame2', 0.8, 0.8)
setProperty('frame2.y', downscroll and 0 or screenHeight - getProperty('bar2.height'))
setProperty('frame2.x', screenWidth - getProperty('bar2.width'))
end

--I don't give a fuck, he kept insisting with his bullshit about the folders, he wanted his stupid folders, deal with it
function onUpdatePost()
local hp = getProperty('healthBar.percent')
if hp <= 25 then
loadGraphic('bar1', 'hpbars/a-bark/'..opponentFolder..'/hp4')
loadGraphic('bar2', 'hpbars/a-bark/'..playerFolder..'/hp1')
elseif hp > 25 and hp <= 50 then
loadGraphic('bar1', 'hpbars/a-bark/'..opponentFolder..'/hp3')
loadGraphic('bar2', 'hpbars/a-bark/'..playerFolder..'/hp2')
elseif hp > 50 and hp <= 75 then
loadGraphic('bar1', 'hpbars/a-bark/'..opponentFolder..'/hp2')
loadGraphic('bar2', 'hpbars/a-bark/'..playerFolder..'/hp3')
elseif hp > 75 then
loadGraphic('bar1', 'hpbars/a-bark/'..opponentFolder..'/hp1')
loadGraphic('bar2', 'hpbars/a-bark/'..playerFolder..'/hp4')
end
setProperty('iconP1.y', downscroll and 90 or 540)
setProperty('iconP2.y', downscroll and 90 or 540)
setProperty('iconP1.x', 1060)
setProperty('iconP2.x', 60)
if getHealth() < 0 then setHealth(0) end
end

function quickSprite(animated, tag, file, x, y, camera, front)
if animated then makeAnimatedLuaSprite(tag, file, x, y)
else makeLuaSprite(tag, file, x, y) end
setObjectCamera(tag, camera)
addLuaSprite(tag, front or false)
end
