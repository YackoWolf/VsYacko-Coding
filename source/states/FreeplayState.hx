package states;

import substates.IntroSubState;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.CoolUtil;

import objects.HealthIcon;
import objects.MusicPlayer;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.addons.display.FlxBackdrop; 
import flixel.graphics.frames.FlxAtlasFrames;

import openfl.utils.Assets;

import haxe.Json;

import flixel.animation.FlxAnimation;

// Añade/Asegúrate de tener estos:
import flixel.FlxSprite;// Si no lo tienes para el grupo de estrellas
import Std; // Para la conversión de tipos (Std.int)
import sys.io.File; // Para getContent()
import sys.FileSystem; // <<<< ¡ESTE ES EL FIX PARA .exists()!

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	public static var hasSeenIntro:Bool = false; 
    var characterNotify:FlxSprite;

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var arrowMonitor:FlxSprite; // <--- ¡Asegúrate de que esto esté aquí!
    var originalArrowX:Float;   // <--- ¡Añade esto! (Para guardar la posición)
	var disco:FlxSprite = new FlxSprite();
	var bar:FlxSprite = new FlxSprite();
	var titulo:FlxSprite;
	var cover:FlxSprite;
	var monitor:FlxSprite;
	var puntuacion:FlxSprite;
	var cleared:FlxSprite;
	var bg:FlxSprite;
	var bg2:FlxSprite;
	var intendedColor:Int;

	var highscoreDigitsGroup:FlxTypedGroup<FlxSprite>;
	var clearedDigitsGroup:FlxTypedGroup<FlxSprite>;

	private var dificultad:FlxSprite;
	private var dificultadAtlasFrames:FlxAtlasFrames;

	private var rangoIcon:FlxSprite;
	private var rankAtlasFrames:FlxAtlasFrames;

	private var scoreAtlasFrames:FlxAtlasFrames;
	private var starsGroup:FlxTypedGroup<FlxSprite>;
	var fueginGroup:FlxTypedGroup<FlxSprite>;
	private var starsAtlasFrames:FlxAtlasFrames;
	private var currentSongData:Dynamic; 
	var currentStarMetadata:Dynamic = null;
	public static var songMetadataCache:Map<String, Dynamic> = new Map<String, Dynamic>();

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	var creditsText:FlxText;

	override function create()
	{
		super.create();

		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxBackdrop().loadGraphic(Paths.image("MenuStuff/freeplay/freeplay/BG/bg"));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.scrollFactor.set();
		bg.velocity.y = -40;
		bg.velocity.x = -40;
		bg.scale.x = 1.8;
		bg.scale.y = 1.8;
		bg.active = true;
		add(bg);
		bg.screenCenter();

		bg2 = new FlxSprite();
		bg2.antialiasing = ClientPrefs.data.antialiasing;
		bg2.updateHitbox();
		bg2.alpha = 0.9;
		add(bg2);
		bg2.x = 0;
		bg2.y = 0;

		bar.frames = Paths.getSparrowAtlas('MenuStuff/freeplay/freeplay/glitch');
		bar.animation.addByPrefix('idle', 'glitch', 6, true);
		bar.x =0;
		bar.y =0;
		add(bar);
		bar.animation.play("idle");
		bar.updateHitbox();

		disco.frames = Paths.getSparrowAtlas('MenuStuff/freeplay/freeplay/disk');
		disco.animation.addByPrefix('idle', 'disk', 30, true);
		disco.x =-300;
		disco.y =335;
		disco.scale.x = 1.2;
		disco.scale.y = 1.2;
		add(disco);
		disco.animation.play("idle");
		disco.updateHitbox();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(20, 320, songs[i].songName, true);
			songText.targetY = i;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		cover = new FlxSprite();
		cover.antialiasing = ClientPrefs.data.antialiasing;
		cover.scale.x = 0.64; // Reduce el ancho a la mitad
		cover.scale.y = 0.64; // Reduce el alto a la mitad
		cover.x=520;
		cover.y= 40;
		add(cover);

		monitor = new FlxSprite().loadGraphic(Paths.image("MenuStuff/freeplay/freeplay/monitor"));
		monitor.antialiasing = ClientPrefs.data.antialiasing;
		add(monitor);
		monitor.screenCenter();

		arrowMonitor = new FlxSprite().loadGraphic(Paths.image("MenuStuff/freeplay/freeplay/arrow"));
		arrowMonitor.scale.set(0.23, 0.23);
		arrowMonitor.x = 340;
    	arrowMonitor.y = 250;
		arrowMonitor.angle = 90;
		add(arrowMonitor);
		originalArrowX = arrowMonitor.x;

		cleared = new FlxSprite().loadGraphic(Paths.image("MenuStuff/freeplay/freeplay/cleared"));
		cleared.antialiasing = ClientPrefs.data.antialiasing;
		cleared.screenCenter();
		add(cleared);
		
		puntuacion = new FlxSprite().loadGraphic(Paths.image("MenuStuff/freeplay/freeplay/highscore"));
		puntuacion.antialiasing = ClientPrefs.data.antialiasing;
		puntuacion.screenCenter();
		add(puntuacion);

		highscoreDigitsGroup = new FlxTypedGroup<FlxSprite>();
		add(highscoreDigitsGroup);
		
		clearedDigitsGroup = new FlxTypedGroup<FlxSprite>();
		add(clearedDigitsGroup);

		fueginGroup = new FlxTypedGroup<FlxSprite>(); // Inicializa el grupo
		add(fueginGroup);

		var fireAtlasFrames:FlxAtlasFrames = Paths.getSparrowAtlas('MenuStuff/freeplay/freeplay/fuego'); // Asegúrate de que el atlas esté ahí

		// Cargar el Atlas de Estrellas (Ruta corregida)
		starsAtlasFrames = Paths.getSparrowAtlas('MenuStuff/freeplay/freeplay/stars');

		// Inicializar el grupo de estrellas
		starsGroup = new FlxTypedGroup<FlxSprite>();
		add(starsGroup);

		// POSICIÓN INICIAL DE LA PRIMERA ESTRELLA
		var startX:Float = -570; 
		var startY:Float = -270; 

		// FACTORES DE ESPACIADO Y DIAGONAL
		var spacingX:Float = 40; 
		var spacingY:Float = 5.5; 

		// Crear las 8 estrellas
		for (i in 0...8) 
		{
			var star:FlxSprite = new FlxSprite(0, 0);
			star.frames = starsAtlasFrames;
			star.antialiasing = ClientPrefs.data.antialiasing;
			star.scale.set(0.13, 0.13); // Ajusta el tamaño aquí
			
			// Posicionamiento Diagonal
			star.x = startX + (i * spacingX); 
			star.y = startY + (i * spacingY); 
			
			starsGroup.add(star);

			var fire:FlxSprite = new FlxSprite(0, 0);
			fire.frames = fireAtlasFrames;
			fire.scale.set(0.13, 0.13);
        
			// Cargar animación del atlas 'fuego.xml'
			// Asumiendo que el prefijo del frame es 'fire' (fire0000, fire0001, etc.)
			fire.animation.addByPrefix('fire', 'fire', 24, true); 
			fire.animation.play('fire');
			
			// CRÍTICO: Posicionar el fuego exactamente detrás de la estrella
			// Ajusta el offset si el centro de fuego no está en el centro de la estrella.
			fire.x = star.x + 340; // Ajuste manual (ej: 5px a la izquierda)
			fire.y = star.y - 140; // Ajuste manual (ej: 10px arriba)
			
			fire.visible = false; // Inicia invisible
			fire.antialiasing = ClientPrefs.data.antialiasing;
			fueginGroup.add(fire);
		}

		scoreAtlasFrames = Paths.getSparrowAtlas('MenuStuff/freeplay/freeplay/scoren');
		rankAtlasFrames = Paths.getSparrowAtlas('MenuStuff/freeplay/freeplay/rankings');

		WeekData.setDirectoryFromWeek();

		//scoreText = new FlxText(FlxG.width * 0.7, 500, 400, "", 105);
		//scoreText.setFormat(Paths.font("Barlow-ExtraBoldItalic.ttf"), 40, FlxColor.WHITE, RIGHT);
		//scoreText.alignment = CENTER;

		//scoreBG = new FlxSprite(scoreText.x - 200, 0).makeGraphic(1, 66, 0xFF000000);
		//scoreBG.alpha = 0;
		//add(scoreBG);

		rangoIcon = new FlxSprite(800, 500);
		rangoIcon.frames = rankAtlasFrames;
		rangoIcon.antialiasing = ClientPrefs.data.antialiasing;
		rangoIcon.visible = false;
		add(rangoIcon);

		diffText = new FlxText(FlxG.width / 2 - 800, 410, 550, "", 80);
		diffText.setFormat(Paths.font("NiseSegaSonic.ttf"), 70, FlxColor.WHITE, RIGHT);
		diffText.alignment = CENTER;
		//add(diffText);

		// [NUEVO] Cargar el atlas de dificultad UNA SOLA VEZ (Ruta corregida)
		dificultadAtlasFrames = Paths.getSparrowAtlas('MenuStuff/freeplay/freeplay/dificultad'); 

		// [NUEVO] Inicializar el sprite de Dificultad (SIN "Icon")
		dificultad = new FlxSprite(290, 190); // <-- Usa la nueva variable
		dificultad.frames = dificultadAtlasFrames;
		dificultad.antialiasing = ClientPrefs.data.antialiasing;
		dificultad.scale.set(0.5, 0.5); // Ajusta la escala si es muy grande
		add(dificultad);

		//add(scoreText);


		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		disco.color = songs[curSelected].color;
		intendedColor = disco.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		updateDifficultyText();

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		creditsText = new FlxText(200, 400, FlxG.width, "", 30);
		add(creditsText);

		var leText:String = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);

		titulo = new FlxSprite().loadGraphic(Paths.image("MenuStuff/freeplay/freeplay/titulo"));
		titulo.antialiasing = ClientPrefs.data.antialiasing;
		add(titulo);
		titulo.screenCenter();
		
		player = new MusicPlayer(this);
		add(player);

		// -----------------------------------------------------------------
		// 🔥 CREACIÓN Y CARGA COMPLETA DEL SPRITE (¡Invisible por defecto!)
		// -----------------------------------------------------------------
		var charFrames:FlxAtlasFrames = Paths.getSparrowAtlas('MenuStuff/M4X/m4x'); 
		
		// Si la carga falla, characterNotify será NULL y el resto del código lo ignorará.
		
		characterNotify = new FlxSprite(0, 0); // Posición (0, 0)
		characterNotify.frames = charFrames;
		characterNotify.antialiasing = ClientPrefs.data.antialiasing;
		
		// Definimos la animación para que ya esté "cacheada" y lista
		characterNotify.animation.addByPrefix('faltaRango', 'm4x faltaRango', 5, true); 
		
		// 🔥 CRÍTICO: Ponemos la animación a correr. Aunque es invisible, fuerza
		// que la textura y los frames estén en caché.
		characterNotify.animation.play('faltaRango'); 
		
		// Lo hacemos invisible.
		characterNotify.visible = false; 
		add(characterNotify);

		// -----------------------------------------------------------------
		// 🔥 LÓGICA DE APERTURA DEL DIÁLOGO (Si no se ha visto)
		// -----------------------------------------------------------------
		if (!hasSeenIntro)
		{
			openSubState(new IntroSubState());
			hasSeenIntro = true;
			trace('IntroSubState: Intento de abrir el diálogo inicial.');
		} else {
			trace('IntroSubState: El diálogo ya se vio. No se abrirá.');
		}
			
		changeSelection();
		updateStars();
		updateTexts();
	}

	// [Modificar o añadir en FreeplayState.hx]
	private function updateStars():Void
	{
		var numStarsToFill:Int = 0;
		var difficultyName:String = Difficulty.list[curDifficulty].toLowerCase();

		// (Opcional, pero recomendado: quita la línea trace para ver el nuevo valor)
		// trace("Dificultad actual: " + difficultyName); 
		
		// 1. LECTURA DESDE currentStarMetadata (EL RESTO SE QUEDA IGUAL)
		if (currentStarMetadata != null && Reflect.hasField(currentStarMetadata, "difficultyStars")) 
		{
			trace("PASO 1: currentStarMetadata NO es NULL.");

			if (Reflect.hasField(currentStarMetadata, "difficultyStars")) 
			{
				trace("PASO 2: Se encontró el campo 'difficultyStars' en el JSON.");
				
				var starsMap:Dynamic = Reflect.field(currentStarMetadata, "difficultyStars");
				
				if (starsMap != null && Reflect.hasField(starsMap, difficultyName))
				{
					trace("PASO 3: Se encontró el valor para la dificultad: " + difficultyName);

					var starCount:Dynamic = Reflect.field(starsMap, difficultyName);
					
					if (starCount != null)
					{
						var starCountInt:Int = Std.int(starCount);
						
						// 🛑 CRÍTICO: Acotar el valor leído a un MÁXIMO de 8.
						numStarsToFill = Std.int(Math.min(Math.max(starCountInt, 0), 8)); 
						trace("✅ ÉXITO: Estrellas leídas del JSON: " + numStarsToFill); 
					}
				} else {
					trace("❌ ERROR: El campo 'difficultyStars' NO tiene un valor para la dificultad '" + difficultyName + "'.");
				}
			} else {
				trace("❌ ERROR: El JSON NO tiene el campo 'difficultyStars'.");
			}
		} else {
			trace("❌ ERROR: La variable 'currentStarMetadata' es NULL. El JSON no se cargó.");
		}

		// 2. LÓGICA DE RESPALDO (Esta parte solo se ejecuta si numStarsToFill es 0)
		if (numStarsToFill == 0 && curDifficulty >= 0) 
		{
			trace("ENTRANDO EN LÓGICA DE RESPALDO (JSON Falló).");
			// Mapeo por defecto (Máximo 8)
			switch(curDifficulty)
			{
				case 0: numStarsToFill = 2; // Easy
				case 1: numStarsToFill = 5; // Normal <--- ESTO ES LO QUE ESTÁS VIENDO AHORA
				case 2: numStarsToFill = 8; // Hard
				default: numStarsToFill = 0;
			}
			trace("⚠️ RESULTADO DEL RESPALDO: " + numStarsToFill + " estrellas.");
		}
		
		// 3. LÓGICA DE DIBUJO DE SPRITES (SIN CAMBIOS)
		var filledFrame:String = 'starFull0000'; 
		var emptyFrame:String = 'starWhite0000';

		if (starsGroup.members.length != fueginGroup.members.length)
        return;
		
		for (i in 0...8)
		{
			if (starsGroup.members.length <= i) break; 
			
			var star:FlxSprite = starsGroup.members[i];
			var fire:FlxSprite = fueginGroup.members[i];
			
			var frameToUse:String = (i < numStarsToFill) ? filledFrame : emptyFrame;

			star.animation.addByPrefix(frameToUse, frameToUse, 0, false);
			star.animation.play(frameToUse);

			if (i < numStarsToFill)
			{
				fire.visible = true;
				if (fire.animation.name != 'fire')
					fire.animation.play('fire'); // Asegura que la animación se esté reproduciendo
			}
			else
			{
				fire.visible = false;
			}
		}
		trace("--- FIN DEBUG ESTRELLAS ---");
	}
	public function updateDifficultyText()
	{
		// Creamos un mapeo directo de índice (curDifficulty) a nombre de frame.
		// Asumiendo: 0 = Easy, 1 = Normal, 2 = Hard
		var difficultyFrames:Array<String> = ['easy0000', 'normal0000', 'hard0000'];
		
		// Usamos el índice de dificultad (0, 1, 2) para obtener el nombre de frame.
		var frameName:String = difficultyFrames[curDifficulty]; 
		
		if (frameName != null) 
		{
			dificultad.visible = true; 
			
			// 1. Añadimos y reproducimos el frame estático
			dificultad.animation.addByPrefix(frameName, frameName, 0, false); 
			dificultad.animation.play(frameName);
		}
		else 
		{
			// Si hay una dificultad custom no mapeada aquí, simplemente lo ocultamos.
			dificultad.visible = false;
		}
	}

	// [Añadir en cualquier parte vacía de la clase FreeplayState]

	private function getRankIcon(accuracy:Float):String
	{
		var rating:String = '';
		
		// Si la precisión es 0, no hay ranking (esto cubre el score borrado o no jugado)
		if (accuracy <= 0) {
			return '';
		}
		
		// Logica de Ranking (Basado en porcentaje: 1.0 = 100%)
		if (accuracy >= 0.90) {
			rating = 'AD'; 
		} else if (accuracy >= 0.75) {
			rating = 'A'; 
		} else if (accuracy >= 0.60) {
			rating = 'B'; 
		} else if (accuracy >= 0.30) {
			rating = 'C'; 
		} else {
			rating = ''; // Menos de C
		}
		
		// Los nombres de frame en tu XML son (A0000, B0000, C0000, AD0000)
		if (rating != '') {
			return rating + '0000'; 
		}
		return '';
	}

	// [Reemplazar la función renderDigits completa en FreeplayState.hx]

	private function renderDigits(value:String, group:FlxTypedGroup<FlxSprite>, startX:Float, startY:Float, digitSpacing:Float)
	{
		group.clear();
		var currentX:Float = startX;
		var currentY:Float = startY;
		
		// Diccionario de mapeo de caracteres a nombres de frame en el XML
		var frameMap:Map<String, String> = [
			'0' => 'scoren 00000',
			'1' => 'scoren 10000',
			'2' => 'scoren 20000',
			'3' => 'scoren 30000',
			'4' => 'scoren 40000',
			'5' => 'scoren 50000',
			'6' => 'scoren 60000',
			'7' => 'scoren 70000',
			'8' => 'scoren 80000',
			'9' => 'scoren 90000',
			'%' => 'scoren %0000',
			'.' => 'scoren .0000'
		];

		var yOffsetPerDigit:Float = 5;

		for (i in 0...value.length)
		{
			var char:String = value.charAt(i);
			var frameName:String = frameMap.get(char);
			
			if (frameName == null) continue; 

			var digitSprite:FlxSprite = group.recycle(); 

			if (digitSprite == null) {
				digitSprite = new FlxSprite();
				group.add(digitSprite); 
			}
			
			// CORRECCIÓN CLAVE DE RENDIMIENTO: Usa la referencia cacheada
			digitSprite.frames = scoreAtlasFrames; 
			
			// Crea una animación estática con el nombre del frame
			digitSprite.animation.addByPrefix(frameName, frameName, 0, false); 
			digitSprite.animation.play(frameName);

			// 1. APLICAR ESCALA (¡CORRECCIÓN DE TAMAÑO!)
        	var scaleFactor:Float = 0.3; // <-- AJUSTA ESTE VALOR (0.5 = 50% del tamaño original)
        	digitSprite.scale.set(scaleFactor, scaleFactor);

			// Posicionar el dígito
			digitSprite.x = currentX;
			digitSprite.y = currentY;
			digitSprite.antialiasing = ClientPrefs.data.antialiasing;
			
			digitSprite.visible = true;
			digitSprite.active = true;

			var baseSpacing:Float = 40; 
        	var spacingMultiplier:Float = 2.5;
			
			var newSpacing:Float = baseSpacing * scaleFactor * spacingMultiplier;
        	currentX += newSpacing; // Mover al siguiente dígito
			currentY += yOffsetPerDigit;
		}
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;

	var stopMusicPlay:Bool = false;
	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!player.playingMusic)
		{
			//scoreText.text = Language.getPhrase('SCORE', 'SCORE: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
			positionHighscore();
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
					loadStarMetadataAndDraw();
					updateStars();
					updateDifficultyText();
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
					loadStarMetadataAndDraw();
					updateStars();
					updateDifficultyText();
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
					loadStarMetadataAndDraw();
					updateStars(); 
					updateDifficultyText();
				}
			}

			if (controls.UI_LEFT_P)
			{
				changeDiff(-1);
				//_updateSongLastDifficulty();
				loadStarMetadataAndDraw(); 
				updateDifficultyText();
			}
			else if (controls.UI_RIGHT_P)
			{
				changeDiff(1);
				//_updateSongLastDifficulty();
				loadStarMetadataAndDraw(); 
				updateDifficultyText();
			}
		}

		if (controls.BACK)
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
			else 
			{
				persistentUpdate = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(FlxG.keys.justPressed.SPACE)
		{
			if(instPlaying != curSelected && !player.playingMusic)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound();
					try
					{
						var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
						if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							vocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(vocals);
							vocals.persist = vocals.looped = true;
							vocals.volume = 0.8;
							vocals.play();
							vocals.pause();
						}
						else vocals = FlxDestroyUtil.destroy(vocals);
					}
					catch(e:Dynamic)
					{
						vocals = FlxDestroyUtil.destroy(vocals);
					}
					
					opponentVocals = new FlxSound();
					try
					{
						//trace('please work...');
						var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							opponentVocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(opponentVocals);
							opponentVocals.persist = opponentVocals.looped = true;
							opponentVocals.volume = 0.8;
							opponentVocals.play();
							opponentVocals.pause();
							//trace('yaaay!!');
						}
						else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
					catch(e:Dynamic)
					{
						//trace('FUUUCK');
						opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				FlxG.sound.music.pause();
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
				player.pauseOrResume(true);
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(!player.playing);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic)
		{
			if (subState != null) {
                // Si hay un subestado abierto (la intro), ignoramos el ACCEPT.
                trace("ACCEPT IGNORADO: SubState (Intro) abierto.");
                super.update(elapsed);
                return;
			}
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			try
			{
				Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch(e:haxe.Exception)
			{
				trace('ERROR! ${e.message}');

				var errorStr:String = e.message;
				if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
				else errorStr += '\n\n' + e.stack;

				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			stopMusicPlay = true;

			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else if(controls.RESET && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}

	private function loadStarMetadataAndDraw():Void
	{
		// Asegúrate de que songName exista en este scope (lo más seguro es definirlo)
		var songName:String = songs[curSelected].songName; 

		// 1. 🔥 COMPROBAR CACHÉ
		if (songMetadataCache.exists(songName))
		{
			currentStarMetadata = songMetadataCache.get(songName);
		}
		else // 2. Si no está en caché, leer del disco (solo la primera vez)
		{
			var metadataPath:String = Paths.getPath('assets/songs/' + songName + '/metadata.json', TEXT);
			
			if (sys.FileSystem.exists(metadataPath))
			{
				var rawJson:String = sys.io.File.getContent(metadataPath);
				currentStarMetadata = haxe.Json.parse(rawJson);
				
				// 3. GUARDAR EN CACHÉ antes de continuar
				songMetadataCache.set(songName, currentStarMetadata);
			}
			else
			{
				currentStarMetadata = null; // No metadata found
			}
		}
		
		var metadataFileName:String = 'metadata.json'; 
		var metadataPath:String = Paths.getPath('data/' + songName + '/' + metadataFileName, TEXT);

		// Reiniciar los datos antes de intentar cargar
		currentStarMetadata = null; 

		if (sys.FileSystem.exists(metadataPath)) 
		{
			try {
				var jsonText:String = sys.io.File.getContent(metadataPath);
				currentStarMetadata = haxe.Json.parse(jsonText);
			} catch (e:Dynamic) {
				// Manejo de errores
			}
		} 
		
		// Una vez que currentStarMetadata está cargado, dibujamos las estrellas
		updateStars(); 
	}
	
	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function grabCreditsList(folder:String):Array<String>
	{
		var credits:Array<String> = [];
		var creditsFile:Array<String> = CoolUtil.coolTextFile(Paths.getPath('data/credits-persong.txt'));
	  
		if (creditsFile.length > 0)
			{
				for (credit in creditsFile)
				{
				credits.push(credit.trim());
				}
			}
	  
		return credits;
	}
	  
	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty, false);

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;

		// -----------------------------------------------------------------
		// LÓGICA DE VISIBILIDAD DE M4X (SIN REPRODUCCIÓN DE ANIMACIÓN)
		// -----------------------------------------------------------------
		var songName:String = songs[curSelected].songName;
		var currentDiff:Int = curDifficulty;
		
		var scoreValue:Int = Highscore.getScore(songName, currentDiff); 
		var hasRank:Bool = scoreValue > 0;
		
		if (characterNotify != null) 
		{
			// 🔥 Si no tiene rango, hacemos el sprite VISIBLE.
			characterNotify.visible = !hasRank;
			
			// El trace es solo para confirmar, puedes quitarlo
			// if (characterNotify.visible) {
			//     trace('M4X: HACIENDO VISIBLE. Ya estaba cargado.');
			// }
		}
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
			FlxTween.cancelTweensOf(disco);
			FlxTween.color(disco, 1, disco.color, intendedColor);
		}

		for (num => item in grpSongs.members)
		{
			var icon:HealthIcon = iconArray[num];
			item.alpha = 0.6;
			icon.alpha = 0.6;
			if (item.targetY == curSelected)
			{
				item.alpha = 1;
				icon.alpha = 1;
			}
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;
			
		cover.loadGraphic(Paths.image('MenuStuff/freeplay/freeplay/art/${Paths.formatToSongPath(songs[curSelected].songName)}'));
		bg2.loadGraphic(Paths.image('MenuStuff/freeplay/freeplay/BG/${Paths.formatToSongPath(songs[curSelected].songName)}'));

		var creditsString:String = grabCreditsList(Mods.currentModDirectory)[curSelected];
		creditsText.text = Language.getPhrase("Credit_text", "BY: {1}", [creditsString]);
		creditsText.setFormat(Paths.font("Yacko-Regular.ttf"), 40, FlxColor.WHITE);
		creditsText.x = 850;
		creditsText.y = 30;

		// 🔥 CORRECCIÓN: SOLO ejecutar la animación si hay un cambio real (pulsación de tecla)
    	if (change != 0 && arrowMonitor != null)
		{
			// Cancelar cualquier animación previa
			FlxTween.cancelTweensOf(arrowMonitor); 

			// 1. Mover ligeramente a la izquierda (usando la posición original como base)
			FlxTween.tween(arrowMonitor, {x: originalArrowX - 20}, 0.2, { 
				ease: FlxEase.sineOut,
				onComplete: function(t:FlxTween) {
					// 2. Regresar a la posición ORIGINAL
					FlxTween.tween(arrowMonitor, {x: originalArrowX}, 0.3, { 
						ease: FlxEase.sineIn 
					});
				}
			});
		}

		changeDiff();
		_updateSongLastDifficulty();

	}

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

	// [Modificar completamente la función positionHighscore() - Línea 74]

	private function positionHighscore()
	{
		// 1. Obtener los valores (Usamos los valores INTENDED para el Rank Icon,
		//    ya que es un cambio discreto (A, S, etc.), y los valores LERPED
		//    para los dígitos numéricos, que queremos que transicionen suavemente).
		
		var intendedHighscore:Int = intendedScore; // Valor final
		var intendedRatingFloat:Float = intendedRating; // Valor final
		var rankName:String = getRankIcon(intendedRatingFloat);

		// Valores en transición para los dígitos
		var lerpedHighscore:Int = lerpScore; 
		var lerpedRating:Float = lerpRating; 
		
		// 2. ACTUALIZAR Y POSICIONAR EL SPRITE DE RANKING
		if (rankName != '')
		{
			// Si hay un ranking (score > 0), mostrar y actualizar el frame
			rangoIcon.visible = true;
			
			// [LÍNEAS CORREGIDAS PARA EL ERROR String should be Int]
			// Usamos addByPrefix porque estás usando el nombre del frame.
			rangoIcon.animation.addByPrefix(rankName, rankName, 0, false); 
			rangoIcon.animation.play(rankName);
			
			// POSICIONAMIENTO DEL RANKING:
			rangoIcon.x = -70; // Ejemplo de posición (a la derecha de la etiqueta Highscore)
			rangoIcon.y = 190; // Ejemplo de posición (arriba del Highscore)
			rangoIcon.scale.set(0.8, 0.9); // Ajusta la escala si es muy grande
		} else {
			// Si no hay ranking (score borrado, 0%), ocultar el icono
			rangoIcon.visible = false;
		}
		
		// 2. Formatear Highscore (a cadena)
		// *** USAMOS lerpedHighscore PARA LA TRANSICIÓN ***
		var scoreString:String = Std.string(lerpedHighscore); 
		
		// 3. Formatear Cleared/Precisión (92.78%)
		var accuracyString:String;
		// *** USAMOS lerpedHighscore PARA COMPROBAR SI HAY PUNTUACIÓN ***
		if (lerpedHighscore <= 0) { 
			accuracyString = "0.00%"; // Mostrar 0.00% si no hay highscore
		} else {
			// Redondeamos y formateamos a 2 decimales para la precisión
			// *** USAMOS lerpedRating PARA LA TRANSICIÓN ***
			accuracyString = FlxMath.roundDecimal(lerpedRating * 100, 2) + "%";
		}

		// 4. Renderizar Dígitos del Highscore
		var scoreStartX:Float = -50; 
		var scoreStartY:Float = 120; 
		var digitSpacing:Float = 50;
		
		renderDigits(scoreString, highscoreDigitsGroup, scoreStartX, scoreStartY, digitSpacing);

		// 5. Renderizar Dígitos de Cleared
		var clearedStartX:Float = 200;
		var clearedStartY:Float = 210; // Posición debajo del label Cleared
		
		renderDigits(accuracyString, clearedDigitsGroup, clearedStartX, clearedStartY, digitSpacing);
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		// 1. CRÍTICO: Mantiene la animación de selección (necesario para el lerp del índice)
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));

		// 2. Mantiene el bucle de "limpieza"
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}