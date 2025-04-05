function onCreate()
    -- Animated Sprite: sprite6
    makeAnimatedLuaSprite("sprite6", "BeachBolivian/fas2/fog", -1169, -715)
    addAnimationByPrefix("sprite6", "lucesita", "fog", 8, true)
    scaleObject("sprite6", 3.25, 2.7)
    addLuaSprite("sprite6")
    -- Sprite: palmerin
    makeLuaSprite("palmerin", "BeachBolivian/fas2/palmsombra", -1167, -707)
    scaleObject("palmerin", 3.25, 2.7)
    addLuaSprite("palmerin")
    -- Animated Sprite: sprite2
    makeAnimatedLuaSprite("sprite2", "BeachBolivian/fas2/fuegin", -1169, -740)
    addAnimationByPrefix("sprite2", "fuegin", "fuegin", 8, true)
    scaleObject("sprite2", 3.25, 2.7)
    addLuaSprite("sprite2")
    -- Sprite: sprite1
    makeLuaSprite("sprite1", "BeachBolivian/fas2/playa", -1167, -722)
    scaleObject("sprite1", 3.25, 2.7)
    addLuaSprite("sprite1")
    -- Animated Sprite: sprite4
    makeAnimatedLuaSprite("sprite4", "BeachBolivian/fas2/roca", -1169, -695)
    addAnimationByPrefix("sprite4", "roca", "roca", 6, true)
    scaleObject("sprite4", 3.25, 2.7)
    addLuaSprite("sprite4")
    -- Animated Sprite: prime
    makeAnimatedLuaSprite("prime", "BeachBolivian/fas2/palmera", -924, -635)
    addAnimationByPrefix("prime", "palmerafiu", "palmera", 8, true)
    scaleObject("prime", 2.6, 2.5)
    addLuaSprite("prime")
    -- Sprite: sprite5
    makeLuaSprite("sprite5", "BeachBolivian/fas2/filtro", -1244, -720)
    scaleObject("sprite5", 3.35, 2.75)
    setProperty("sprite5.alpha", 0.3)
    addLuaSprite("sprite5")
end
