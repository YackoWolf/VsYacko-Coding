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
import backend.CoolUtil; // Importado

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
	
	var clearedText:FlxText; // Texto del porcentaje CLEARED

	// Variables de posición y animación
	var monitorTargetY:Float = 0;
	var barTargetX:Float = 0;
	var currentPercentage:Float = 0.00; // Valor que se anima para el contador

	// Constantes de tamaño para números
	private static inline var SCORE_TOTAL_SIZE:Float = 80;
	private static inline var STATS_NUMBERS_SIZE:Float = 50;

	public function new(score:Int, notes:Int, combo:Int, s:Int, g:Int, b:Int, m:Int, song:String, diff:Int)
	{
		this.finalScore = score;
		this.totalNotes = notes;
		this.maxCombo = combo;
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
				
				// LLAMAR A LA FUNCIÓN DEL CONTADOR DE PORCENTAJE
				displayClearedPercentage();
			}
		}
	}
	
	// <-- FUNCIÓN: CONTAJE Y ANIMACIÓN DEL PORCENTAJE -->
	function displayClearedPercentage():Void
	{
		// 1. CÁLCULO DE PRECISIÓN
		var accuracy:Float = 0;
		
		if (totalNotes > 0)
		{
			// Cálculo estándar: (Notas No-Miss) / (Total de Notas) * 100
			var notesHit:Int = sick + good + bad;
			// CORRECCIÓN FINAL: CoolUtil.truncateVal -> CoolUtil.floorDecimal
			accuracy = CoolUtil.floorDecimal(((notesHit / totalNotes) * 100), 2);
		}
		
		this.currentPercentage = 0.00;
		
		// 2. CREACIÓN DEL OBJETO DE TEXTO
		clearedText = new FlxText(0, 0, FlxG.width, "", 100);
		// CORRECCIÓN FINAL: Eliminar el grosor del borde (4) para corregir el error de EmbeddedFont
		clearedText.setFormat(Paths.font("Score-Regular.ttf"), 100, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, true);
		clearedText.y = monitor.y + 50; 
		clearedText.screenCenter(X);
		clearedText.alpha = 0;
		add(clearedText);
		
		// 3. ANIMACIÓN DE APARICIÓN (ALPHA)
		FlxTween.tween(clearedText, {alpha: 1}, 0.3);
		
		// 4. ANIMACIÓN DEL CONTADOR (TWEEN)
		FlxTween.tween(this, {currentPercentage: accuracy}, 1.0, {
			ease: flixel.tweens.FlxEase.quadOut,
			onUpdate: function(twn:FlxTween) {
				// CORRECCIÓN FINAL: CoolUtil.truncateVal -> CoolUtil.floorDecimal
				clearedText.text = "CLEARED: " + CoolUtil.floorDecimal(currentPercentage, 2) + "%";
			},
			onComplete: function(twn:FlxTween) {
				// CORRECCIÓN FINAL: CoolUtil.truncateVal -> CoolUtil.floorDecimal
				clearedText.text = "CLEARED: " + CoolUtil.floorDecimal(accuracy, 2) + "%"; // Asegura el valor final
				
				// Ahora, inicia la aparición de los números de score (Sick, Good, Bad, etc.)
				new FlxTimer().start(0.5, function(tmr:FlxTimer) {
					displayScorenNumbers();
					displayScorenScore();
				});
			}
		});
	}
	// <-- FIN DE FUNCIÓN NUEVA -->
	
	function displayScorenScore():Void
	{
		// **POSICIÓN PARA SCORE TOTAL**
		var startX = 50;
		var startY = FlxG.height - 115;
		
		var scoreSpacingFactor = 3;

		addScorenNumber(finalScore, startX, startY, SCORE_TOTAL_SIZE, 8, scoreSpacingFactor);
	}
	
	function displayScorenNumbers():Void
	{
		var startY = textosD.y + 100;
		var startXBase = textosD.x + 380;
		
		var spacing = 52;
		
		startY += 75;
		
		var size = STATS_NUMBERS_SIZE;

		// Definición de las posiciones X para cada par de líneas
		var xOffset1 = -80;
		var xOffset2 = -200;
		var xOffset3 = -170;
		
		// Mínimo de 5 dígitos (00020) para todas las estadísticas.
		var minLengthStats = 5;

		// =========================================================
		//  CONFIGURACIÓN DE SHADERS INDIVIDUALES
		// =========================================================
		
		// 🎨 Sick: Tono -178 (convertido a -0.494)
		var sickShader = new ColorSwap();
		sickShader.hue = -178 / 360;
		sickShader.brightness = 0.0;
		
		// 🎨 Good: Tono +15 (0.042), Luminosidad +23 (0.23)
		var goodShader = new ColorSwap();
		goodShader.hue = 15 / 360;
		goodShader.brightness = 0.23;
		
		// 🎨 Bad: Tono -67 (-0.186), Luminosidad +48 (0.48)
		var badShader = new ColorSwap();
		badShader.hue = -67 / 360;
		badShader.brightness = 0.48;
		
		// 🎨 Missed (Shit): Tono -68 (-0.189)
		var missedShader = new ColorSwap();
		missedShader.hue = -68 / 360;
		missedShader.brightness = 0.0;


		// Fila 1 (Total Notes): NO aplica shader (null por defecto)
		addScorenNumber(totalNotes, startXBase + xOffset1, startY + (spacing * 0), size, minLengthStats);
		// Fila 2 (Max Combo): NO aplica shader
		addScorenNumber(maxCombo, startXBase + xOffset1, startY + (spacing * 1), size, minLengthStats);

		// Fila 3 (Sick): APLICA SHADER sickShader
		addScorenNumber(sick, startXBase + xOffset2, startY + (spacing * 2), size, minLengthStats, 2.5, sickShader);
		// Fila 4 (Good): APLICA SHADER goodShader
		addScorenNumber(good, startXBase + xOffset3, startY + (spacing * 3), size, minLengthStats, 2.5, goodShader);
		
		// Fila 5 (Bad): APLICA SHADER badShader
		addScorenNumber(bad, startXBase + xOffset2, startY + (spacing * 4), size, minLengthStats, 2.5, badShader);
		// Fila 6 (Missed): APLICA SHADER missedShader
		addScorenNumber(missed, startXBase + xOffset3, startY + (spacing * 5), size, minLengthStats, 2.5, missedShader);
	}
	
	function addScorenNumber(number:Int, x:Float, y:Float, size:Float, minLength:Int = 0, spacingFactor:Float = 2.5, colorSwap:ColorSwap = null):Void
	{
		var numString:String = Std.string(number);
		
		// Rellena con ceros iniciales si es necesario
		while (numString.length < minLength)
		{
			numString = "0" + numString;
		}

		var curX:Float = x;
		var scale:Float = size / 167; // 167 es el tamaño original de la fuente sprite
		var digitWidth:Float = 45 * scale;

		for (i in 0...numString.length)
		{
			var digit:String = numString.charAt(i);
			if (digit == "-") continue;
			
			var frameName:String = 'scoren ' + digit + '0000';

			var digitSprite:FlxSprite = new FlxSprite(curX, y);
			digitSprite.frames = Paths.getSparrowAtlas(ASSET_PATH + 'scoren');
			digitSprite.animation.addByNames('digit', [frameName], 0, false);
			digitSprite.animation.play('digit');
			
			// Aplica el tamaño (size)
			digitSprite.setGraphicSize(0, size);
			digitSprite.updateHitbox();
			
			// APLICACIÓN DEL SHADER
			if (colorSwap != null) {
				digitSprite.shader = colorSwap.shader;
			}
			
			add(digitSprite);
			
			// Usar el factor de separación único (spacingFactor)
			curX += digitWidth * spacingFactor;
		}
	}

	override public function update(elapsed:Float):Void
	{
		if (controls.ACCEPT)
		{
			if (PlayState.isStoryMode)
			{
				// Lógica de transición de Story Mode (WBDA)
				if (PlayState.storyPlaylist.length <= 0)
				{
					// FIN DE SEMANA -> Volver al menú de la historia
					Mods.loadTopMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
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
					FlxG.sound.music.stop();

					LoadingState.prepareToSong();
					LoadingState.loadAndSwitchState(new PlayState(), false, false);
				}
			}
			else
			{
				// LÓGICA DE FREEPLAY -> Volver al menú Freeplay
				Mods.loadTopMod();
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

				PlayState.changedDifficulty = false;
				MusicBeatState.switchState(new FreeplayState());
			}
		}
		
		super.update(elapsed);
	}
}