function onCreate()
    -- Sprite: sprite1
    makeLuaSprite("sprite1", "BeachBolivian/pixel/bg", -826, -485)
    scaleObject("sprite1", 7, 7)
    setProperty("sprite1.antialiasing", false)
    addLuaSprite("sprite1")
    -- Sprite: sprite2
    makeLuaSprite("sprite2", "BeachBolivian/pixel/arbol", -826, -485)
    scaleObject("sprite2", 7, 7)
    setProperty("sprite2.antialiasing", false)
    addLuaSprite("sprite2")
    -- Sprite: sprite3
    makeLuaSprite("sprite3", "BeachBolivian/pixel/filtro", -842, -490)
    scaleObject("sprite3", 7.1, 7.1)
    setProperty("sprite3.alpha", 0.4)
    setProperty("sprite3.antialiasing", false)
    addLuaSprite("sprite3")
end
