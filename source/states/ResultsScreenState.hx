package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

// --- IMPORTS DE CLASE ---
import backend.ClientPrefs;
import backend.Difficulty;
import backend.Song;
import states.PlayState;
import states.StoryMenuState;
import states.LoadingState;
import flixel.addons.transition.FlxTransitionableState;
import backend.WeekData;
import backend.Paths;
import backend.MusicBeatState;
import states.FreeplayState;
import backend.Highscore;
import backend.CoolUtil;

import shaders.ColorSwap;

private var ASSET_PATH:String = "MenuStuff/Results/";

class ResultsScreenState extends MusicBeatState
{
    // Variables de estadísticas
    var finalScore:Int = 0;
    var totalNotes:Int = 0;
    var maxCombo:Int = 0;
    var sick:Int = 0;
    var good:Int = 0;
    var bad:Int = 0;
    var missed:Int = 0;
    var songName:String = "";
    var difficulty:Int = 0;

    // Variables de Sprites
    var monitor:FlxSprite;
    var bar:FlxSprite;
    var textosD:FlxSprite;
    var bg:FlxBackdrop;
    var title:FlxSprite;
    var scoreTitle:FlxSprite;
    
    var clearedLabel:FlxSprite; 
    var clearPercentageSprites:Array<FlxSprite> = []; // Array para los sprites del porcentaje decimal

    // Variables de posición y animación
    var monitorTargetY:Float = 0;
    var barTargetX:Float = 0;
    var currentPercentage:Float = 0.00; // Valor que se anima para el contador (Float para FlxTween)
    var statCount:Int = 0; // Contador para la secuencia de estadísticas
    var statsToAnimate:Array<Dynamic>; // Array para la lista de stats

    // Constantes de tamaño para números
    private static inline var SCORE_TOTAL_SIZE:Float = 80;
    private static inline var STATS_NUMBERS_SIZE:Float = 50;
    
    // **CONSTANTE** para la separación del porcentaje
    private static inline var CLEARED_SPACING_FACTOR:Float = 2.0; 
    // **CONSTANTE** para el espacio extra después del punto (¡FIX DE ESPACIADO!)
    private static inline var DOT_SPACING_FACTOR:Float = 3; // ⬅️ FIX: Aumentado para mayor separación

    // Declaración de Shaders
    var sickShader:ColorSwap;
    var goodShader:ColorSwap;
    var badShader:ColorSwap;
    var missedShader:ColorSwap;


    public function new(score:Int, notes:Int, combo:Int, s:Int, g:Int, b:Int, m:Int, song:String, diff:Int)
    {
        this.finalScore = score;
        this.totalNotes = notes;
        this.maxCombo = PlayState.maxCombo; // Lectura de la variable estática
        this.sick = s;
        this.good = g;
        this.bad = b;
        this.missed = m;
        
        this.songName = song;
        this.difficulty = diff;
        
        super();
    }

    override public function create():Void
    {
        // NOTA: Se ha quitado FlxG.sound.music.stop() de aquí. 
        // El motor debería detener la canción. Si el bug de 'freakyMenu' al inicio persiste, 
        // revisa si el estado anterior está llamando a playMusic() al cambiar de estado.

        // --- 1. FONDO FLXBACKDROP ---
        bg = new FlxBackdrop(Paths.image(ASSET_PATH + "bg"), FlxAxes.XY);
        bg.scrollFactor.set(0.5, 0.5);
        bg.velocity.set(50, 50);
        add(bg);
        
        // --- 2. Inicialización de Sprites y Z-Order ---
        bar = new FlxSprite(0, 0);
        bar.loadGraphic(Paths.image(ASSET_PATH + "bar"));
        bar.screenCenter(Y);
        bar.x = -bar.width;
        barTargetX = (FlxG.width / 2) - (bar.width / 2);
        add(bar);

        // TITTLE (Detrás del monitor)
        title = new FlxSprite(0, 0);
        title.loadGraphic(Paths.image(ASSET_PATH + "tittle"));
        title.screenCenter(X);
        title.y = -title.height;
        add(title);

        // MONITOR (Delante del tittle)
        monitor = new FlxSprite(0, 0);
        monitor.loadGraphic(Paths.image(ASSET_PATH + "monitor"));
        monitor.screenCenter(X);
        monitor.y = FlxG.height;
        monitorTargetY = (FlxG.height / 2) - (monitor.height / 2);
        add(monitor);

        // TEXTOS DE ESTADÍSTICAS
        textosD = new FlxSprite(0, 0);
        textosD.frames = Paths.getSparrowAtlas(ASSET_PATH + 'textosD');
        textosD.animation.addByPrefix('aparece', 'textosD aparece', 24, false);
        textosD.animation.addByPrefix('idle', 'textosD idle', 24, true);
        textosD.centerOffsets();
        textosD.screenCenter();
        textosD.alpha = 0;
        add(textosD);
        
        // SCORE T (Palabra SCORE: Centrado ABSOLUTO)
        scoreTitle = new FlxSprite(0, 0);
        scoreTitle.loadGraphic(Paths.image(ASSET_PATH + "scoreT"));
        scoreTitle.screenCenter(); // Centrado X y Y
        add(scoreTitle);
        
        // --- 2.5. Inicialización de Shaders ---
        sickShader = new ColorSwap();
        sickShader.hue = -178 / 360;
        sickShader.brightness = 0.0;
        
        goodShader = new ColorSwap();
        goodShader.hue = 15 / 360;
        goodShader.brightness = 0.23;
        
        badShader = new ColorSwap();
        badShader.hue = -67 / 360;
        badShader.brightness = 0.48;
        
        missedShader = new ColorSwap();
        missedShader.hue = -68 / 360;
        missedShader.brightness = 0.0;
        // ---------------------------------------------
        
        // --- 3. Inicio de Animación ---
        
        FlxTween.tween(bar, {x: barTargetX}, 0.7, {
            ease: flixel.tweens.FlxEase.quadOut,
            onComplete: function(twn:FlxTween) {
                startMonitorTween();
            }
        });

        super.create();
    }
    
    function startMonitorTween():Void
    {
        FlxTween.tween(monitor, {y: monitorTargetY}, 0.8, {
            ease: flixel.tweens.FlxEase.quadOut,
            onComplete: function(twn:FlxTween) {
                startTitleTween();
            }
        });
    }

    function startTitleTween():Void
    {
        var titleTargetY:Float = 0;
        
        FlxTween.tween(title, {y: titleTargetY}, 0.5, {
            ease: flixel.tweens.FlxEase.quadOut,
            onComplete: function(twn:FlxTween) {
                startTextosDAnimation();
            }
        });
    }
    
    function startTextosDAnimation():Void
    {
        textosD.alpha = 1;
        textosD.animation.play('aparece', true);
        
        // Cuando el sprite de "textosD" termina su animación de aparición:
        textosD.animation.callback = function(name:String, frame:Int, index:Int) {
            if (name == 'aparece' && frame == textosD.animation.curAnim.numFrames - 1) {
                textosD.animation.play('idle', true);
                
                // LLAMAR A LAS FUNCIONES AL MISMO TIEMPO
                new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                    displayClearedDecimalPercentage(); 
                    animateStatsSequence(); 
                    displayScorenScore(); 
                });
            }
        }
    }
    
    // ----------------------------------------------------------------------
    // <<-- FUNCIÓN: PORCENTAJE DE PRECISIÓN DECIMAL (CLEARED) -->>
    // ----------------------------------------------------------------------
    function displayClearedDecimalPercentage():Void
    {
        // 1. CÁLCULO DE PRECISIÓN PONDERADA 
        var finalAccuracyFloat:Float = 0; 

        // Fórmula estándar de precisión
        var hitPonderado:Float = (sick * 1.0) + (good * 0.6) + (bad * 0.1); 
        var totalCountedNotes:Int = sick + good + bad + missed;
        var maxPonderado:Float = totalCountedNotes * 1.0; 

        if (maxPonderado > 0)
        {
            finalAccuracyFloat = (hitPonderado / maxPonderado) * 100;
        }
        
        // Limitar el valor final a 100.00%
        finalAccuracyFloat = FlxMath.bound(finalAccuracyFloat, 0, 100); 
        
        // Convertir a Int para animación: multiplicamos por 100 para animar los dos decimales
        var finalValueInt:Int = Std.int(finalAccuracyFloat * 100); 

        this.currentPercentage = 0.00; // Valor inicial para el Tween
        
        // 2. POSICIONAMIENTO
        // 🎯 POSICIÓN FIJA (X, Y) - VALORES AJUSTADOS
        var CLEARED_POS_X:Float = 820; 
        var CLEARED_POS_Y:Float = 300; 

        var clearedTargetX:Float = CLEARED_POS_X;
        var clearedTargetY:Float = CLEARED_POS_Y;
        
        // 3. ANIMACIÓN DEL CONTADOR (TWEEN)
        FlxTween.tween(this, {currentPercentage: finalAccuracyFloat}, 1.0, {
            ease: flixel.tweens.FlxEase.quadOut,
            onUpdate: function(twn:FlxTween) {
                var valueToDisplay:Int = Std.int(currentPercentage * 100);
                
                // 1. ELIMINAR los sprites anteriores
                for (sprite in clearPercentageSprites) remove(sprite, true);
                clearPercentageSprites = [];

                // 2. CREAR y añadir los nuevos sprites
                // El último parámetro 'center' está en 'false' para alineación izquierda.
                addScorenDecimalNumber(valueToDisplay, clearedTargetX, clearedTargetY, SCORE_TOTAL_SIZE, 4, CLEARED_SPACING_FACTOR, null, clearPercentageSprites, 2, false, true);
            },
            onComplete: function(twn:FlxTween) {
                // Asegura que el valor final sea el exacto
                var valueToDisplay:Int = finalValueInt;
                
                for (sprite in clearPercentageSprites) remove(sprite, true);
                clearPercentageSprites = [];
                
                // El valor final se renderiza una última vez para asegurar la precisión
                addScorenDecimalNumber(valueToDisplay, clearedTargetX, clearedTargetY, SCORE_TOTAL_SIZE, 4, CLEARED_SPACING_FACTOR, null, clearPercentageSprites, 2, false, true);
            }
        });
    }
    
    // --- FUNCIÓN DE SECUENCIA (Para las estadísticas laterales) ---
    function animateStatsSequence():Void
    {
        // Define las estadísticas y su orden de aparición:
        statsToAnimate = [
            // {label: "nombre", value: variable, xOffset, yOffset: posición en la lista (0, 1, 2...), minLength, shader}
            {label: "totalNotes", value: totalNotes, xOffset: -80, yOffset: 0, minLength: 5, shader: null}, // 1. Total Notes
            {label: "maxCombo", value: maxCombo, xOffset: -80, yOffset: 1, minLength: 5, shader: null}, // 2. Max Combo
            {label: "sick", value: sick, xOffset: -200, yOffset: 2, minLength: 5, shader: sickShader}, // 3. Sick
            {label: "good", value: good, xOffset: -170, yOffset: 3, minLength: 5, shader: goodShader}, // 4. Good
            {label: "bad", value: bad, xOffset: -200, yOffset: 4, minLength: 5, shader: badShader}, // 5. Bad
            {label: "missed", value: missed, xOffset: -170, yOffset: 5, minLength: 5, shader: missedShader} // 6. Missed
        ];
        
        statCount = 0; // Reinicia el contador de la secuencia
        animateNextStat(); // Inicia la secuencia
    }

    // --- FUNCIÓN DE ANIMACIÓN RECURSIVA ---
    function animateNextStat():Void
    {
        if (statsToAnimate == null || statCount >= statsToAnimate.length) return; // Detener la recursión

        var currentStat = statsToAnimate[statCount];
        
        // Objeto temporal que contiene el valor actual
        var animData = {value: 0.0}; 
        var finalValue:Int = currentStat.value;
        
        // Posiciones calculadas
        var startY = textosD.y + 100;
        var startXBase = textosD.x + 380;
        var size = STATS_NUMBERS_SIZE;
        var spacing = 52;
        startY += 75; // Ajuste inicial
        
        var statY = startY + (spacing * currentStat.yOffset);
        var statX = startXBase + currentStat.xOffset;
        
        var currentTextSprites:Array<FlxSprite> = [];
        
        // Inicia el Tween para el conteo de 0 al valor final
        FlxTween.tween(animData, {value: finalValue}, 0.5, { 
            ease: flixel.tweens.FlxEase.quadOut,
            onUpdate: function(twn:FlxTween) 
            {
                // Accede al valor directamente desde el objeto animData
                var valueToDisplay:Int = Std.int(animData.value);
                
                // 1. ELIMINAR LOS SPRITES ANTERIORES
                for (sprite in currentTextSprites) remove(sprite, true);
                currentTextSprites = [];

                // 2. CREAR Y AÑADIR LOS NUEVOS SPRITES CON EL VALOR ACTUAL (Usando la función con sprites)
                addScorenNumber(valueToDisplay, statX, statY, size, currentStat.minLength, 2.5, currentStat.shader, currentTextSprites);
            },
            onComplete: function(twn:FlxTween) {
                // 3. PASAR AL SIGUIENTE
                statCount++;
                // Pequeño retraso entre cada estadística
                new FlxTimer().start(0.2, function(tmr:FlxTimer) { 
                    animateNextStat();
                });
            }
        });
    }

    // <-- FUNCIÓN: CONTAJE Y ANIMACIÓN DEL SCORE TOTAL (Usando sprites) -->
    function displayScorenScore():Void
    {
        // **POSICIÓN PARA SCORE TOTAL**
        var startX = 50;
        var startY = FlxG.height - 115;
        var scoreSpacingFactor = 3;
        var finalScoreValue = finalScore;
        
        // Objeto temporal que contiene el score actual
        var scoreAnimData = {value: 0.0}; 
        var currentScoreSprites:Array<FlxSprite> = []; // Array para los sprites del score

        FlxTween.tween(scoreAnimData, {value: finalScoreValue}, 1.0, { 
            ease: flixel.tweens.FlxEase.quadOut,
            onUpdate: function(twn:FlxTween) {
                // Accede al valor directamente desde el objeto scoreAnimData
                var valueToDisplay:Int = Std.int(scoreAnimData.value);

                // 1. ELIMINAR los sprites anteriores
                for (sprite in currentScoreSprites) remove(sprite, true);
                currentScoreSprites = [];

                // 2. CREAR y añadir los nuevos sprites
                addScorenNumber(valueToDisplay, startX, startY, SCORE_TOTAL_SIZE, 8, scoreSpacingFactor, null, currentScoreSprites);
            },
            onComplete: function(twn:FlxTween) {
                // Asegura que el valor final sea el correcto
                for (sprite in currentScoreSprites) remove(sprite, true);
                currentScoreSprites = [];
                addScorenNumber(finalScoreValue, startX, startY, SCORE_TOTAL_SIZE, 8, scoreSpacingFactor, null, currentScoreSprites);

                // 🔊 LÓGICA DE MÚSICA CORREGIDA CON FALLBACK:
                // ⚠️ FIX DEL ERROR: La variable debe ser Dynamic, no String.
                var resultsMusic:Dynamic = Paths.music('plantilla'); 
                
                if (resultsMusic != null) {
                    // Si el objeto de sonido no es nulo (se encontró la música), lo reproducimos.
                    FlxG.sound.music.stop(); 
                    FlxG.sound.playMusic(resultsMusic);
                } else {
                    // Si el objeto es nulo (SOUND NOT FOUND), usamos freakyMenu como fallback.
                    FlxG.sound.music.stop();
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                }
            }
        });
    }
    
    // ----------------------------------------------------------------------
    // <-- FUNCIÓN: AÑADIR NÚMEROS (Función original que llama a la base) -->
    // ----------------------------------------------------------------------
    function addScorenNumber(number:Int, x:Float, y:Float, size:Float, minLength:Int = 0, spacingFactor:Float = 2.5, colorSwap:ColorSwap = null, ?spriteArray:Array<FlxSprite>):Void
    {
        // minLength: 0, decimalPlaces: 0, addPercent: false
        addScorenDecimalNumber(number, x, y, size, minLength, spacingFactor, colorSwap, spriteArray, 0, false, false);
    }
    
    // ----------------------------------------------------------------------
    // <-- FUNCIÓN BASE FINAL (AJUSTE DE ESPACIADO DESPUÉS DEL PUNTO) -->
    // ----------------------------------------------------------------------
    function addScorenDecimalNumber(number:Int, x:Float, y:Float, size:Float, minLength:Int = 0, spacingFactor:Float = 2.5, colorSwap:ColorSwap = null, ?spriteArray:Array<FlxSprite>, decimalPlaces:Int = 0, center:Bool = false, addPercent:Bool = false):Void
    {
        var numString:String = Std.string(number);
        
        // 1. RELLENA CON CEROS INICIALES si es necesario
        while (numString.length < minLength)
        {
            numString = "0" + numString;
        }
        
        // 2. INSERTAR PUNTO DECIMAL ('.')
        if (decimalPlaces > 0)
        {
            var len:Int = numString.length;
            var pointIndex:Int = len - decimalPlaces;
            
            // Rellenar con ceros si el número es muy pequeño (ej: 50 -> 0.50)
            while (pointIndex < 0) {
                numString = "0" + numString;
                len++;
                pointIndex++;
            }
            // Insertar el caracter '.' que tiene su propio frame en el atlas 'scoren'
            numString = numString.substr(0, pointIndex) + "." + numString.substr(pointIndex);
        }
        
        // 3. AÑADIR SÍMBOLO DE PORCENTAJE ('%')
        if (addPercent)
        {
            // Insertar el caracter '%' que tiene su propio frame en el atlas 'scoren'
            numString += "%";
        }

        // 4. CALCULAR POSICIÓN INICIAL (si se requiere centrado)
        var totalWidth:Float = 0;
        var scale:Float = size / 167; // 167 es el tamaño base de tu fuente
        var digitWidth:Float = 45 * scale; // Ancho asumido del dígito 
        
        var dotWidth:Float = 33 * scale * 0.8; // Ancho base del sprite del punto
        var percentWidth:Float = 145 * scale; // Ancho base del sprite del porcentaje

        // Calcula el ancho total para el centrado
        for (i in 0...numString.length)
        {
            var char:String = numString.charAt(i);
            if (char == '.') {
                // 💥 FIX 2a: Usar digitWidth como base para el ancho del punto con factor de espaciado
                totalWidth += digitWidth * DOT_SPACING_FACTOR; 
            } else if (char == '%') {
                totalWidth += percentWidth * spacingFactor * 0.5; // Ajuste para el símbolo de %
            } else {
                totalWidth += digitWidth * spacingFactor;
            }
        }
        
        var curX:Float = x;
        
        if (center) {
             curX -= totalWidth / 2;
             curX += (digitWidth * spacingFactor) / 2; 
        }


        // 5. CREAR SPRITES
        for (i in 0...numString.length)
        {
            var char:String = numString.charAt(i);
            var frameName:String = 'scoren ' + char + '0000';
            var widthToAdvance:Float = digitWidth * spacingFactor;

            var digitSprite:FlxSprite = new FlxSprite(curX, y);
            digitSprite.frames = Paths.getSparrowAtlas(ASSET_PATH + 'scoren');
            
            // Lógica para caracteres especiales (Punto y Porcentaje)
            if (char == '.') {
                // 💥 FIX 2b: Aplicar la misma fórmula de avance que la usada en totalWidth
                widthToAdvance = digitWidth * DOT_SPACING_FACTOR; 
            } else if (char == '%') {
                widthToAdvance = percentWidth * spacingFactor * 0.5;
            }
            
            // Cargar y reproducir la animación
            digitSprite.animation.addByNames('char', [frameName], 0, false);
            digitSprite.animation.play('char');
            
            // Aplica el tamaño (size)
            digitSprite.setGraphicSize(0, size);
            digitSprite.updateHitbox();
            
            // APLICACIÓN DEL SHADER
            if (colorSwap != null) {
                digitSprite.shader = colorSwap.shader;
            }
            
            add(digitSprite);
            
            // Guardar la referencia al sprite en el array (para el conteo)
            if (spriteArray != null)
            {
                spriteArray.push(digitSprite);
            }
            
            // Avanzar posición
            curX += widthToAdvance;
        }
    }

    override public function update(elapsed:Float):Void
    {
        if (controls.ACCEPT)
        {
            // ⚠️ FIX PRINCIPAL: Detener la música de Results ANTES de CUALQUIER transición.
            if (FlxG.sound.music != null) FlxG.sound.music.stop(); 
            
            if (PlayState.isStoryMode)
            {
                // Lógica de transición de Story Mode (WBDA)
                if (PlayState.storyPlaylist.length <= 0)
                {
                    // FIN DE SEMANA -> Volver al menú de la historia
                    Mods.loadTopMod();
                    // ❌ ELIMINADA: FlxG.sound.playMusic(Paths.music('freakyMenu')); 
                    // (Debe ser iniciada por StoryMenuState.hx/create())
                    #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

                    // Lógica de guardado de semana
                    if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
                        StoryMenuState.weekCompleted.set(WeekData.weeksList[PlayState.storyWeek], true);
                        
                        Highscore.saveWeekScore(WeekData.getWeekFileName(), PlayState.campaignScore, PlayState.storyDifficulty);

                        FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
                        FlxG.save.flush();
                    }
                    
                    PlayState.changedDifficulty = false;
                    MusicBeatState.switchState(new StoryMenuState());
                }
                else
                {
                    // SIGUIENTE CANCIÓN -> Cargar la próxima canción
                    var difficulty:String = Difficulty.getFilePath();

                    FlxTransitionableState.skipNextTransIn = true;
                    FlxTransitionableState.skipNextTransOut = true;
                    
                    Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
                    // FlxG.sound.music.stop() ya se llamó al inicio de update()

                    // ❌ ELIMINADA: FlxG.sound.playMusic(Paths.music('freakyMenu')); 
                    // (Esta línea no iba aquí, interfería con la carga de la siguiente canción)

                    LoadingState.prepareToSong();
                    LoadingState.loadAndSwitchState(new PlayState(), false, false);
                }
            }
            else
            {
                // LÓGICA DE FREEPLAY -> Volver al menú Freeplay
                Mods.loadTopMod();
                #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
                
                // FlxG.sound.music.stop() ya se llamó al inicio de update()
                
                PlayState.changedDifficulty = false;
                MusicBeatState.switchState(new FreeplayState());
                // ⚠️ ¡NOTA! La música debe iniciarse ahora en FreeplayState.hx/create()
            }
        }
        
        super.update(elapsed);
    }
}