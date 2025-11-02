function onEvent(name, value1, value2)
    if name == "playVideo" then
        -- Cargar y reproducir el video
        startVideo(value1, false)
        setProperty("inCutscene", false)

        setObjectCamera("videoCutscene", "hud")
        setObjectOrder("videoCutscene", 1)
    end
end