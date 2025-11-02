package options;

import states.MainMenuState;
import backend.StageData;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Note Colors',
		'Controls',
		'Adjust Delay and Combo',
		'Graphics',
		'Visuals',
		'Gameplay'
		#if TRANSLATIONS_ALLOWED , 'Language' #end
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	var bg:FlxSprite;
	var pensamiento:FlxSprite = new FlxSprite();
	var titulo:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label)
		{
			case 'Note Colors':
				openSubState(new options.NotesColorSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals':
				openSubState(new options.VisualsSettingsSubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Language':
				openSubState(new options.LanguageSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		//var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		//bg.antialiasing = ClientPrefs.data.antialiasing;
		//bg.color = 0xFFea71fd;
		//bg.updateHitbox();

		//bg.screenCenter();
		//add(bg);

		bg = new FlxBackdrop().loadGraphic(Paths.image("bgCredits"));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xff0004ff;
		bg.updateHitbox();
		bg.scrollFactor.set();
		bg.velocity.y = -40;
		bg.velocity.x = -40;
		bg.scale.x = 1.8;
		bg.scale.y = 1.8;
		bg.active = true;
		add(bg);
		bg.screenCenter();

		titulo = new FlxSprite().loadGraphic(Paths.image("MenuStuff/Options/tittle"));
		titulo.antialiasing = ClientPrefs.data.antialiasing;
		add(titulo);
		titulo.screenCenter();

		pensamiento.frames = Paths.getSparrowAtlas('MenuStuff/Options/yacko');
		pensamiento.animation.addByPrefix('piensa', 'yacko', 2, true);
		pensamiento.x =0;
		pensamiento.y =0;
		//pensamiento.scale.x = 1.2;
		//pensamiento.scale.y = 1.2;
		add(pensamiento);
		pensamiento.animation.play("piensa");
		pensamiento.updateHitbox();


		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (num => option in options)
		{
			// 1. CREACIÓN BÁSICA: Se mantiene en (0, 0)
			var optionText:Alphabet = new Alphabet(0, 0, Language.getPhrase('options_$option', option), true);
			
			// 2. RECUPERAR POSICIÓN Y: Usamos screenCenter() para obtener la Y central correcta.
			// ¡Esto es lo que arregla el scroll Y!
			optionText.screenCenter(); 
			
			// 3. SE MANTIENE EL OFFSET Y: Se aplica la lógica de desplazamiento vertical del menú.
			optionText.y += (92 * (num - (options.length / 2))) + 45;
			
			// 4. FORZAR POSICIÓN X: Sobrescribimos la posición X para alinear a la izquierda (100px).
			optionText.x = 100;

			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			//item.x = FlxG.width - item.width - RIGHT_MARGIN;
			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				// 5. Posicionamiento de Selectores: Usamos item.x (que es 100) como ancla.
				selectorLeft.x = item.x - 60; 
				selectorLeft.y = item.y;
				
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}