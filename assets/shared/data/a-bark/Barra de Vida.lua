function onCreatePost()
	makeLuaSprite('Health', 'hpbars/a-bark/hpframe')
	setObjectCamera('Health', 'hud')
	scaleObject('Health', 1, 1)
	setObjectOrder('Health', getObjectOrder('healthBar') + 5)
	setProperty('healthBar.visible', true)
	setObjectOrder('Health', getObjectOrder('healthBar', 'uiGroup')+1, 'uiGroup')
end

function onUpdatePost(elapsed)
	setProperty('Health.x', getProperty('healthBar.x') - 143)
	setProperty('Health.y', getProperty('healthBar.y') - 91)
	setProperty("iconP1.x", 895)
    setProperty("iconP1.y", 580)
    setProperty("iconP2.x", 213)
    setProperty("iconP2.y", 580)
end