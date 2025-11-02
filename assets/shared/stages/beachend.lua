function onCreate()
    -- Animated Sprite: sprite1
    makeAnimatedLuaSprite("sprite1", "BeachBolivian/fasfinal/loli", -774, -365)
    addAnimationByPrefix("sprite1", "loli", "idle", 10, true)
    scaleObject("sprite1", 1.5, 1.5)
    addLuaSprite("sprite1")
    -- Animated Sprite: sprite2
    makeAnimatedLuaSprite("sprite2", "BeachBolivian/fasfinal/pasto", -774, -365)
    addAnimationByPrefix("sprite2", "calvicia", "pasto", 10, true)
    scaleObject("sprite2", 1.5, 1.5)
    addLuaSprite("sprite2")
end
