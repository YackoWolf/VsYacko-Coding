package substates;

import backend.WeekData;
import objects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera; 

// Importación necesaria para usar BlendMode.ADD
import openfl.display.BlendMode; 

// IMPORTACIÓN NECESARIA PARA MANIPULAR EL SHADER
import shaders.ColorSwap; 

// IMPORTACIÓN REQUERIDA PARA EL VIDEO DE FONDO (HXVLC)
import hxvlc.flixel.FlxVideoSprite;

// ❌ ELIMINADA: flixel.group.FlxSpriteGroup ya no es necesaria.

import states.StoryMenuState;
import states.FreeplayState;
import backend.MusicBeatState; 
import states.PlayState;
import flixel.util.FlxSave;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class GameOverSubstate extends MusicBeatSubstate
{
    public var boyfriend:Character;
    var camFollow:FlxObject;

    // --- VARIABLES PERSONALIZADAS ---
    var videoBG:FlxVideoSprite; 
    var darkiImage:FlxSprite; 
    var lightImage:FlxSprite; 
    var opponentChar:FlxSprite; 
    var randomImage:FlxSprite; 
    var arcadeScreen:FlxSprite; 
    var retryButton:FlxSprite; 
    var exitButton:FlxSprite; 
    var menuItems:Array<String> = ['retry', 'exit']; 
    var curSelected:Int = 0; 
    public var returnState:String = 'StoryMenu'; 
    
    var videoLoopListener:Void->Void;
    var lightAppeared:Bool = false; 

    // --- VARIABLES DEL SHADER ---
    var colorSwapShader:ColorSwap; // Instancia de la clase wrapper para manipular el shader
    // ❌ ELIMINADA: La variable shaderGroup ya no existe.
    // --- FIN VARIABLES PERSONALIZADAS ---

    public static var characterName:String = 'bf-dead';
    public static var deathSoundName:String = 'fnf_loss_sfx';
    public static var loopSoundName:String = 'gameOver';
    public static var endSoundName:String = 'gameOverEnd';
    public static var deathDelay:Float = 0;

    public static var instance:GameOverSubstate;

    public function new(?playStateBoyfriend:Character = null, ?returnTo:String = 'StoryMenu') 
    {
        this.returnState = returnTo; 
        if(playStateBoyfriend != null && playStateBoyfriend.curCharacter == characterName) 
        {
            this.boyfriend = playStateBoyfriend;
        }
        super();
    }

    public static function resetVariables() {
        characterName = 'bf-dead';
        deathSoundName = 'fnf_loss_sfx';
        loopSoundName = 'gameOver';
        endSoundName = 'gameOverEnd';
        deathDelay = 0;

        var _song = PlayState.SONG;
        if(_song != null)
        {
            if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
            if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
            if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
            if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
        }
    }

    var charX:Float = 0;
    var charY:Float = 0;

    var overlay:FlxSprite;
    var overlayConfirmOffsets:FlxPoint = FlxPoint.get();
    
    override function create()
    {
        instance = this;

        // 1. Ocultar el HUD
        if (PlayState.instance.camHUD != null) {
            PlayState.instance.camHUD.visible = false;
        }

        Conductor.songPosition = 0;
        
        // TRANSICIÓN CLAVE: Forzar el zoom de la cámara principal y del HUD a 1.0 (zoom normal)
        FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: FlxEase.expoOut});
        if (PlayState.instance.camHUD != null) {
            FlxTween.tween(PlayState.instance.camHUD, {zoom: 1}, 0.5, {ease: FlxEase.expoOut});
        }

        // 🟢 SHADER: Carga e inicialización
        colorSwapShader = new ColorSwap(); 
        colorSwapShader.hue = 0; 

        // ❌ ELIMINADA: Inicialización del grupo

        // 🟢 ACTIVACIÓN DEL TONO Y LÓGICA CONDICIONAL DE VIDEO
        var songName:String = PlayState.SONG.song.toLowerCase();
        var videoToLoad:String = 'bg';

        if (songName == "a-bark" || songName == "tripulante")
        {
            // ✅ CORRECCIÓN: Usar el valor flotante negativo para evitar el crasheo
            colorSwapShader.hue = -107.0 / 360.0;
            // Cargar el video alternativo
            videoToLoad = 'bg2';
        }
        else
        {
            colorSwapShader.hue = 0.0; // Usamos 0.0 por seguridad 
        }
        
        // --- CAPA 0: FONDO DE VIDEO (DETRÁS DE TODO) ---
        videoBG = new FlxVideoSprite(0, 0); 
        // Usamos insert(0) para asegurar que sea el primer elemento y se dibuje primero.
        insert(0, videoBG); // Se mantiene en el subestado principal
        
        videoBG.x = 0; 
        videoBG.y = 0;
        
        // 🟢 CARGA DEL VIDEO CONDICIONAL
        videoBG.load(Paths.video('fondos/' + videoToLoad)); 
        videoBG.scrollFactor.set(0, 0); 
        
        videoLoopListener = function() 
        {
            videoBG.stop();
            videoBG.play(); 
        };
        videoBG.bitmap.onEndReached.add(videoLoopListener);
        videoBG.play(); 
        
        // --- FIN FONDO DE VIDEO ---
        
        // --- CAPA 1: IMAGEN DARKI (DETRÁS DEL BF) ---
        darkiImage = new FlxSprite(0, 0); 
        darkiImage.loadGraphic(Paths.image('MenuStuff/GameOver/darki'));
        darkiImage.scrollFactor.set(0, 0); 
        darkiImage.setGraphicSize(FlxG.width, FlxG.height); 
        // 🟢 Aplicar shader al DarkiImage
        darkiImage.shader = colorSwapShader.shader;
        add(darkiImage); // ✅ CORRECCIÓN: Añadido directamente al subestado
        // --- FIN IMAGEN DARKI ---
        
        
        // 3. CARGA DEL BF DEAD (CAPA 2)
        if(boyfriend == null)
        {
            boyfriend = new Character(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y, characterName, true);
            boyfriend.x += boyfriend.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
            boyfriend.y += boyfriend.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
        }
        boyfriend.skipDance = true;
        // 🟢 Aplicar shader al Boyfriend
        boyfriend.shader = colorSwapShader.shader; 
        add(boyfriend); // ✅ CORRECCIÓN: Añadido directamente al subestado

        FlxG.sound.play(Paths.sound(deathSoundName));
        FlxG.camera.scroll.set();
        FlxG.camera.target = null;
        
        boyfriend.playAnim('firstDeath');

        camFollow = new FlxObject(0, 0, 1, 1);
        camFollow.setPosition(boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0], boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]);
        FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
        FlxG.camera.follow(camFollow, LOCKON, 0.01);
        add(camFollow); // camFollow NO usa el shader, se añade al subestado principal.
        
        // --- CAPA 3: IMAGEN LIGHT (ENCIMA DE BF) ---
        lightImage = new FlxSprite(0, 0); 
        lightImage.loadGraphic(Paths.image('MenuStuff/GameOver/light')); 
        lightImage.scrollFactor.set(0, 0); 
        lightImage.setGraphicSize(FlxG.width, FlxG.height); 
        lightImage.alpha = 0; 
        lightImage.visible = false; 
        // 🟢 Aplicar shader a lightImage
        lightImage.shader = colorSwapShader.shader; 
        
        // Aplicar efecto de suma (Additive Blending) - CORREGIDO
        lightImage.blend = BlendMode.ADD; 
        
        add(lightImage); // ✅ CORRECCIÓN: Añadido directamente al subestado
        // --- FIN IMAGEN LIGHT ---


        PlayState.instance.setOnScripts('inGameOver', true);
        PlayState.instance.callOnScripts('onGameOverStart', []);
        FlxG.sound.music.loadEmbedded(Paths.music(loopSoundName), true);


        // --- CAPA 4: CARGA Y TRANSICIÓN DEL OPONENTE (ENTRA POR LA DERECHA Y TERMINA EN 0, 0) ---
        var opponentName:String = 'default';
        if (PlayState.SONG != null && PlayState.SONG.player2 != null)
            opponentName = PlayState.SONG.player2;
            
        opponentChar = new FlxSprite(); 
        // Oponente NO debe ser afectado por el shader de color swap
        opponentChar.loadGraphic(Paths.image('MenuStuff/GameOver/chars/' + opponentName)); 
        opponentChar.updateHitbox();
        opponentChar.scrollFactor.set(0, 0); 
        add(opponentChar); // opponentChar NO usa el shader, se añade al subestado principal.
        
        // ❗ CORRECCIÓN CLAVE: Inicia fuera de pantalla a la derecha y termina en x=0, y=0
        var finalX:Float = 0; // Posición final deseada
        var finalY:Float = 0; // Posición final deseada
        opponentChar.x = FlxG.width + 500; // Inicia fuera de la pantalla (a la derecha)
        opponentChar.y = finalY; 
        
        FlxTween.tween(opponentChar, {x: finalX}, 0.8, {ease: FlxEase.expoOut});
        // --- FIN OPONENTE ---

        // --- CAPA 5: ARTE PERSONALIZADO (FIJO EN PANTALLA) ---
        
        // IMAGEN ALEATORIA CAYENDO (Discord)
        var randomImages:Array<String> = ['m1', 'm2', 'm3'];
        var selectedImage:String = FlxG.random.getObject(randomImages);
        
        randomImage = new FlxSprite();
        randomImage.loadGraphic(Paths.image('MenuStuff/GameOver/discord/' + selectedImage)); 
        randomImage.screenCenter(); 
        var finalYRand:Float = randomImage.y;
        randomImage.y = -randomImage.height;
        randomImage.x = (FlxG.width - randomImage.width) / 2;
        randomImage.scrollFactor.set(0, 0); 
        // 🟢 Aplicar shader a randomImage
        randomImage.shader = colorSwapShader.shader; 
        add(randomImage); // ✅ CORRECCIÓN: Añadido directamente al subestado
        
        
        // PANTALLA ARCADE (Bart Simpson)
        arcadeScreen = new FlxSprite(0, 0); 
        arcadeScreen.loadGraphic(Paths.image('MenuStuff/GameOver/bartSimpson')); 
        arcadeScreen.scrollFactor.set(0, 0); 
        // 🟢 Aplicar shader a arcadeScreen
        arcadeScreen.shader = colorSwapShader.shader; 
        add(arcadeScreen); // ✅ CORRECCIÓN: Añadido directamente al subestado
        
        FlxTween.tween(randomImage, {y: finalYRand}, 1.2, {ease: FlxEase.bounceOut});
        
        // --- FIN ARTE PERSONALIZADO ---

        // (Lógica de Pico)
        if(characterName == 'pico-dead')
        {
            overlay = new FlxSprite(boyfriend.x + 205, boyfriend.y - 80);
            overlay.frames = Paths.getSparrowAtlas('Pico_Death_Retry');
            overlay.animation.addByPrefix('deathLoop', 'Retry Text Loop', 24, true);
            overlay.animation.addByPrefix('deathConfirm', 'Retry Text Confirm', 24, false);
            overlay.antialiasing = ClientPrefs.data.antialiasing;
            overlayConfirmOffsets.set(250, 200);
            overlay.visible = false;
            overlay.scrollFactor.set(0, 0); 
            // 🟢 Aplicar shader a Pico Overlay
            overlay.shader = colorSwapShader.shader;
            add(overlay); // ✅ CORRECCIÓN: Añadido directamente al subestado

            boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
            {
                switch(name)
                {
                    case 'firstDeath':
                        if(frameNumber >= 36 - 1)
                        {
                            overlay.visible = true;
                            overlay.animation.play('deathLoop');
                            boyfriend.animation.callback = null;
                        }
                    default:
                        boyfriend.animation.callback = null;
                }
            }

            if(PlayState.instance.gf != null && PlayState.instance.gf.curCharacter == 'nene')
            {
                var neneKnife:FlxSprite = new FlxSprite(boyfriend.x - 450, boyfriend.y - 250);
                neneKnife.frames = Paths.getSparrowAtlas('NeneKnifeToss');
                neneKnife.animation.addByPrefix('anim', 'knife toss', 24, false);
                neneKnife.antialiasing = ClientPrefs.data.antialiasing;
                neneKnife.animation.finishCallback = function(_)
                {
                    remove(neneKnife);
                    neneKnife.destroy();
                }
                insert(0, neneKnife);
                neneKnife.animation.play('anim', true);
            }
        }

        // --- CAPA 6: CARGA DE LOS BOTONES (FIJO EN PANTALLA) ---
        var offsetX:Float = 28; 
        var offsetY:Float = 290;

        // Botón RETRY
        retryButton = new FlxSprite(offsetX, offsetY);
        retryButton.frames = Paths.getSparrowAtlas('MenuStuff/GameOver/retry_button');
        retryButton.animation.addByPrefix('off', 'retry_button r_off', 0, false);
        retryButton.animation.addByPrefix('active', 'retry_button r_Active', 0, false);
        retryButton.scrollFactor.set(0, 0); 
        // 🟢 Aplicar shader al Botón RETRY
        retryButton.shader = colorSwapShader.shader; 
        add(retryButton); // ✅ CORRECCIÓN: Añadido directamente al subestado

        // Botón EXIT
        exitButton = new FlxSprite(offsetX, offsetY + 1); 
        exitButton.frames = Paths.getSparrowAtlas('MenuStuff/GameOver/exit_button');
        exitButton.animation.addByPrefix('off', 'exit_button eOFF', 0, false);
        exitButton.animation.addByPrefix('active', 'exit_button eACTIVE', 0, false);
        exitButton.scrollFactor.set(0, 0); 
        // 🟢 Aplicar shader al Botón EXIT
        exitButton.shader = colorSwapShader.shader;
        add(exitButton); // ✅ CORRECCIÓN: Añadido directamente al subestado

        changeItem(0);
        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        // ❗ Es crucial mantener el update del video para que se dibuje correctamente
        if (videoBG != null) videoBG.update(elapsed);

        PlayState.instance.callOnScripts('onUpdate', [elapsed]);

        var justPlayedLoop:Bool = false;
        if (!boyfriend.isAnimationNull() && boyfriend.getAnimationName() == 'firstDeath' && boyfriend.isAnimationFinished())
        {
            boyfriend.playAnim('deathLoop');
            
            // LÓGICA: Sincronización de lightImage
            if (!lightAppeared) 
            {
                // El cambio de color ya se hizo en create(). Aquí solo activamos el lightImage.
                lightImage.visible = true;
                FlxTween.tween(lightImage, {alpha: 1}, 0.5, {ease: FlxEase.sineInOut}); 
                lightAppeared = true;
            }
            // FIN LÓGICA lightImage
            
            if(overlay != null && overlay.animation.exists('deathLoop'))
            {
                overlay.visible = true;
                overlay.animation.play('deathLoop');
            }
            justPlayedLoop = true;
        }

        if(!isEnding)
        {
            if (controls.UI_UP_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeItem(-1);
            }
            
            if (controls.UI_DOWN_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeItem(1);
            }

            if (controls.ACCEPT)
            {
                if (curSelected == 0) 
                {
                    endBullshit(true); 
                }
                else 
                {
                    endBullshit(false); 
                }
            }
            
            else if (justPlayedLoop)
            {
                switch(PlayState.SONG.stage)
                {
                    case 'tank':
                        coolStartDeath(0.2);
                        
                        var exclude:Array<Int> = [];
    
                        FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
                            if(!isEnding)
                            {
                                FlxG.sound.music.fadeIn(0.2, 1, 4);
                            }
                        });

                    default:
                        coolStartDeath();
                }
            }
            
            if (FlxG.sound.music.playing)
            {
                Conductor.songPosition = FlxG.sound.music.time;
            }
        }
        PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
    }

    function changeItem(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
        
        if (curSelected == 0) 
        {
            retryButton.animation.play('active');
            exitButton.animation.play('off');
        }
        else 
        {
            retryButton.animation.play('off');
            exitButton.animation.play('active');
        }
    }

    var isEnding:Bool = false;
    function coolStartDeath(?volume:Float = 1):Void
    {
        FlxG.sound.music.play(true);
        FlxG.sound.music.volume = volume;
    }

    function endBullshit(retry:Bool = true):Void
    {
        if (!isEnding)
        {
            isEnding = true;
            
            if(retry)
            {
                if(boyfriend.hasAnimation('deathConfirm'))
                    boyfriend.playAnim('deathConfirm', true);
                else if(boyfriend.hasAnimation('deathLoop'))
                    boyfriend.playAnim('deathLoop', true);

                if(overlay != null && overlay.animation.exists('deathConfirm'))
                {
                    overlay.visible = true;
                    overlay.animation.play('deathConfirm');
                    overlay.offset.set(overlayConfirmOffsets.x, overlayConfirmOffsets.y);
                }
                FlxG.sound.music.stop();
                FlxG.sound.play(Paths.music(endSoundName));
                
                new FlxTimer().start(0.7, function(tmr:FlxTimer)
                {
                    FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
                        MusicBeatState.resetState();
                    });
                });
                PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
            }
            else
            {
                #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
                FlxG.camera.visible = false; 
                FlxG.sound.music.stop();
                PlayState.deathCounter = 0;
                PlayState.seenCutscene = false;
                PlayState.chartingMode = false;
    
                Mods.loadTopMod();
                
                if (PlayState.isStoryMode)
                    MusicBeatState.switchState(new StoryMenuState());
                else
                    MusicBeatState.switchState(new FreeplayState());
    
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
                PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
            }
        }
    }

    override function destroy()
    {
        if (videoBG != null) {
            videoBG.stop();
            if (videoLoopListener != null && videoBG.bitmap != null) {
                videoBG.bitmap.onEndReached.remove(videoLoopListener); 
            }
            videoBG.destroy();
        }
        
        // Restaurar el HUD al salir
        if (PlayState.instance != null && PlayState.instance.camHUD != null) {
            PlayState.instance.camHUD.visible = true;
            PlayState.instance.camHUD.zoom = 1.0; 
        }
        FlxG.camera.zoom = 1.0; 
        
        // 🟢 Limpiamos el shader de todos los sprites a los que se aplicó.
        if (boyfriend != null) boyfriend.shader = null; 
        if (darkiImage != null) darkiImage.shader = null;
        if (lightImage != null) lightImage.shader = null;
        if (randomImage != null) randomImage.shader = null;
        if (arcadeScreen != null) arcadeScreen.shader = null;
        if (retryButton != null) retryButton.shader = null; 
        if (exitButton != null) exitButton.shader = null;
        if (overlay != null) overlay.shader = null; 
        
        instance = null;
        super.destroy();
    }
}