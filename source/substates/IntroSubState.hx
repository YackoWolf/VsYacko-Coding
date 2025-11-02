package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer; 
import flixel.tweens.FlxTween;
import flixel.graphics.frames.FlxAtlasFrames;

class IntroSubState extends MusicBeatSubstate
{
    var character:FlxSprite;
    var backgroundBox:FlxSprite;
    var enterPrompt:FlxSprite;
    
    // Rutas de las imágenes
    var dialogueData:Array<Dynamic> = [
        { image: 'MenuStuff/M4X/d1', charAnim: 'm4x nTalk', charIdle: 'm4x nIdle', duration: 1.0 },
        { image: 'MenuStuff/M4X/d2', charAnim: 'm4x eTalk', charIdle: 'm4x eIdle', duration: 3.0 },
        { image: 'MenuStuff/M4X/d3', charAnim: 'm4x idle', charIdle: 'm4x idle', duration: 0.0 }
    ];
    var currentStep:Int = 0;

    public function new()
    {
        super();
        
        // 1. Fondo semi-transparente
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xAA000000); 
        add(bg);

        // 2. SPRITE DE DIÁLOGO (Imagen central d1, d2, d3)
        backgroundBox = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
        backgroundBox.screenCenter(); 
        add(backgroundBox);
        
        // 3. SPRITE ANIMADO M4X
        var charFrames:FlxAtlasFrames = Paths.getSparrowAtlas('MenuStuff/M4X/m4x'); 
        character = new FlxSprite(0, 0); 
        character.frames = charFrames;
        character.antialiasing = ClientPrefs.data.antialiasing;
        
        // Animaciones
        character.animation.addByPrefix('m4x nTalk', 'm4x nTalk', 30, true);
        character.animation.addByPrefix('m4x nIdle', 'm4x nIdle', 5, false);
        character.animation.addByPrefix('m4x eTalk', 'm4x eTalk', 30, true);
        character.animation.addByPrefix('m4x eIdle', 'm4x eIdle', 5, false);
        character.animation.addByPrefix('m4x idle', 'm4x idle', 5, true);
        //character.animation.addByPrefix('faltaRango', 'm4x faltaRango', 5, true); // Añadida por si acaso
        
        add(character);
        
        // 4. SPRITE DE ENTER (El prompt)
        enterPrompt = new FlxSprite(FlxG.width / 2, -100); 
        enterPrompt.loadGraphic(Paths.image('MenuStuff/M4X/enter')); 
        enterPrompt.screenCenter(X); 
        enterPrompt.y = FlxG.height * 0.1; 
        enterPrompt.antialiasing = ClientPrefs.data.antialiasing;
        enterPrompt.visible = false; 
        add(enterPrompt);
        
        // Iniciar la secuencia al crear el subestado
        advanceDialogue();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (controls.ACCEPT && enterPrompt.visible) 
        {
            FlxTween.cancelTweensOf(enterPrompt);
            advanceDialogue();
        }
    }
    
    function advanceDialogue()
    {
        enterPrompt.visible = false;
        
        if (currentStep >= dialogueData.length)
        {
            close();
            return;
        }

        var current = dialogueData[currentStep];

        backgroundBox.loadGraphic(Paths.image(current.image)); 
        backgroundBox.screenCenter(); 

        character.animation.play(current.charAnim);

        if (current.duration > 0)
        {
            // Usamos .start() para evitar errores del compilador
            new FlxTimer().start(current.duration, function(t:FlxTimer) {
                if (character != null && character.active) 
                { 
                    character.animation.play(current.charIdle);
                    showEnterPrompt(); 
                }
            }, 1); 
        }
        else
        {
            character.animation.play(current.charIdle);
            showEnterPrompt();
        }
        
        currentStep++;
    }
    
    function showEnterPrompt()
    {
        enterPrompt.visible = true;
        // Animación de rebote
        FlxTween.tween(enterPrompt, {y: enterPrompt.y + 10}, 0.5, {ease: flixel.tweens.FlxEase.sineInOut, type: FlxTween.PINGPONG});
    }
}