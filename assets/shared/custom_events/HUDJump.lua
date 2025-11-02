local bounceHeight = 8    -- altura
local gravity = 1         -- fuerza
local bounceSpeed = 0.1   -- velocidad vertical
local bounceActive = true
local bounceY = 0         -- posición base

function onBeatHit()
    if bounceActive then
        bounceSpeed = -bounceHeight
    end
end

function onUpdate(elapsed)
    if bounceActive then
        bounceSpeed = bounceSpeed + gravity * elapsed * 60
        bounceY = bounceY + bounceSpeed * elapsed * 60
        if bounceY > 0 then
            bounceY = 0
            bounceSpeed = bounceSpeed * -0.45 -- rebote amortiguado
        end
        setProperty('camHUD.y', bounceY)
    end
end
