local opponentFolder = 'op'

function onCreatePost()
setProperty('healthBar.visible', false)
----EMPTY BARS
quickSprite(false, 'empty1', 'hpbars/tripulante/'..opponentFolder..'/hpempty', 0, 0, 'hud')
scaleObject('empty1', 1.1, 1.1)
setProperty('empty1.y', downscroll and 0 or screenHeight - getProperty('empty1.height'))

----BARS
quickSprite(false, 'bar1', 'hpbars/tripulante/'..opponentFolder..'/hp1', 0, 0, 'hud')
scaleObject('bar1', 1.1, 1.1)
setProperty('bar1.y', downscroll and 0 or screenHeight - getProperty('bar1.height'))

----FRAMES
quickSprite(false, 'frame1', 'hpbars/tripulante/'..opponentFolder..'/hpframe', 0, 0, 'hud')
scaleObject('frame1', 1.1, 1.1)
setProperty('frame1.y', downscroll and 0 or screenHeight - getProperty('frame1.height'))

end

--I don't give a fuck, he kept insisting with his bullshit about the folders, he wanted his stupid folders, deal with it
function onUpdatePost()
local hp = getProperty('healthBar.percent')
if hp < 25 then
loadGraphic('bar1', 'hpbars/tripulante/'..opponentFolder..'/hp1')
elseif hp > 25 and hp <= 40 then
loadGraphic('bar1', 'hpbars/tripulante/'..opponentFolder..'/hp2')
elseif hp > 40 and hp <= 60 then
loadGraphic('bar1', 'hpbars/tripulante/'..opponentFolder..'/hp3')
elseif hp > 60 and hp <= 80 then
loadGraphic('bar1', 'hpbars/tripulante/'..opponentFolder..'/hp4')
elseif hp > 80 and hp <= 95 then
loadGraphic('bar1', 'hpbars/tripulante/'..opponentFolder..'/hp5')
elseif hp > 95 then
loadGraphic('bar1', 'hpbars/tripulante/'..opponentFolder..'/hp6')
end
setProperty('iconP1.visible',false)
setProperty('iconP1.y', downscroll and 90 or 540)
setProperty('iconP2.y', downscroll and 90 or 500)
setProperty('iconP1.x', 1060)
setProperty('iconP2.x', 90)
if getHealth() < 0 then setHealth(0) end
end

function quickSprite(animated, tag, file, x, y, camera, front)
if animated then makeAnimatedLuaSprite(tag, file, x, y)
else makeLuaSprite(tag, file, x, y) end
setObjectCamera(tag, camera)
addLuaSprite(tag, front or false)
end
