package states;

import objects.AttachedSprite;
import flixel.FlxSprite; // Esta importación ya no es necesaria si solo usas FlxBackdrop para el fondo
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.text.FlxText;
import sys.FileSystem;
import sys.io.File;
import openfl.utils.Assets;

import flixel.addons.display.FlxBackdrop; // Se mantiene, ya que lo estás usando

class CreditsState extends MusicBeatState
{
    private var curSelected:Int = 0; // Índice del elemento seleccionado
    private var creditsData:Array<Array<String>> = []; // Almacena todos los datos de los créditos

    private var grpCreditTexts:FlxTypedGroup<FlxText>; // Grupo para contener solo los textos
    private var grpCreditIcons:FlxTypedGroup<AttachedSprite>; // Grupo para contener solo los iconos

    // Mapas para almacenar la posición Y inicial (relativa al inicio del contenido) de cada sprite
    private var textRelativeYs:Map<FlxText, Float>;
    private var iconRelativeYs:Map<AttachedSprite, Float>;

    private var bg:FlxSprite; // Cambiado a FlxBackdrop
    private var descText:FlxText;
    private var descBox:AttachedSprite;
    private var pibes:FlxSprite; // Imagen principal de retrato
    private var intendedBgColor:FlxColor;

    private var targetScrollY:Float = 0; // La posición Y objetivo para el inicio del contenido scrollable
    private var currentScrollY:Float = 0; // La posición Y actual (interpolada) del inicio del contenido scrollable
    private var entrySpacing:Float = 110; // Espacio vertical entre cada entrada de crédito. ¡AUMENTADO!

    // AJUSTES CLAVE PARA EL POSICIONAMIENTO
    // El borde X derecho donde DEBE TERMINAR el BLOQUE (texto + icono) de los créditos seleccionables.
    private var creditsBlockEndRightX:Float; // Se inicializa en create()

    // Margen entre el texto y el icono.
    private var iconToTextMargin:Float = 25;
    // Ancho fijo para los iconos.
    private var defaultIconWidth:Float = 130; // Se mantiene en 150.

    // Posición X central para la mitad izquierda de la pantalla (ya no se usa directamente para títulos).
    private var portraitXCenter:Float; // Se inicializa en create()
    // El centro visual de la mitad derecha de la pantalla, donde queremos que los TÍTULOS se centren.
    private var rightHalfScreenCenterX:Float; // Se inicializa en create()

    // Límites del área de scroll
    private var scrollWindowTopY:Float; // Se inicializa en create()
    private var scrollWindowHeight:Float; // Se inicializa en create()

    private var creditTextSize:Int = 60; // Tamaño de fuente para los créditos.

    override function create()
    {
        super.create();

        #if DISCORD_ALLOWED
        DiscordClient.changePresence("In the Menus", null);
        #end

        persistentUpdate = true;

        // Inicializar variables de posicionamiento que dependen de FlxG.width/height
        creditsBlockEndRightX = FlxG.width - 50; // Línea roja a 50px del borde derecho.
        portraitXCenter = FlxG.width * 0.5; // El centro de la pantalla, ya que el retrato va ahí.
        rightHalfScreenCenterX = FlxG.width * 0.75; // Centro de la mitad derecha de la pantalla.
        scrollWindowTopY = 100; // Donde empieza el área de scrollable.
        scrollWindowHeight = FlxG.height - 250; // Altura total del área de scrollable.

        // Fondo
        bg = new FlxBackdrop().loadGraphic(Paths.image("bgCredits"));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.updateHitbox();
        bg.scrollFactor.set();
        bg.velocity.y = -40;
        bg.velocity.x = -40;
        bg.active = true;
        add(bg);
        bg.screenCenter();

        // Grupos para textos e iconos
        grpCreditTexts = new FlxTypedGroup<FlxText>();
        add(grpCreditTexts);

        grpCreditIcons = new FlxTypedGroup<AttachedSprite>();
        add(grpCreditIcons);

        // Inicializar mapas para guardar las Y relativas
        textRelativeYs = new Map<FlxText, Float>();
        iconRelativeYs = new Map<AttachedSprite, Float>();

        // Sprite para la imagen de retrato grande
        pibes = new FlxSprite();
        pibes.alpha = 0;
        pibes.antialiasing = ClientPrefs.data.antialiasing;
        add(pibes);

        // Cargar los datos de los créditos y crear los elementos visuales
        loadCreditsData();
        createCreditEntries();

        // Cuadro y texto de descripción (fuera del área de scroll)
        descBox = new AttachedSprite();
        descBox.makeGraphic(1, 1, FlxColor.BLACK);
        descBox.x = 0;
        descBox.y = FlxG.height - 100;
        descBox.xAdd = -10;
        descBox.yAdd = -10;
        descBox.alphaMult = 0.6;
        descBox.alpha = 0.6;
        add(descBox);

        descText = new FlxText(0, FlxG.height - 90, FlxG.width, "", 32);
        descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
        descText.scrollFactor.set();
        descBox.sprTracker = descText;
        add(descText);
        descText.screenCenter(X);


        // Establecer el primer elemento seleccionable y actualizar la vista
        curSelected = 0;
        for (i in 0...creditsData.length) {
            if (isSelectable(i)) {
                curSelected = i;
                break;
            }
        }

        // Inicializar color de fondo y llamar a changeSelection
        // --- INICIO DE LOS CAMBIOS PARA EL FONDO ---
        if (creditsData.length > 0 && isSelectable(curSelected)) { // Asegurarse de que el elemento seleccionado sea válido y tenga color
            intendedBgColor = CoolUtil.colorFromString(creditsData[curSelected][4]);
            bg.color = intendedBgColor; // Aseguramos que el color inicial se aplique inmediatamente
        } else {
            intendedBgColor = FlxColor.BLACK;
            bg.color = FlxColor.BLACK;
        }
        // --- FIN DE LOS CAMBIOS PARA EL FONDO ---

        changeSelection(0);
    }

    private function loadCreditsData()
    {
        // Tus datos por defecto
        var defaultList:Array<Array<String>> = [ // Name - Icon name - Description - Link - BG Color
            ["VSYACKO TEAM"],
            ["Yacko",              "yacko",        "Director y Artista",              "https://www.youtube.com/@YackoWolf",   "00FFCA"],
            ["ElConoIluminado",  "cono",           "Animador 3D",                     "https://www.youtube.com/@ElConoQueilumina",   "FF7400"],
            ["vale11super",        "vale",         "Artista, animador y creador de chromas", "https://www.youtube.com/@valemespor_10pm12",   "FF0013"],
            ["francrafteador",     "franchesco",   "Animador de cinematicas",         "",   "16C725"],
            ["KyleFaz87",          "kyle",         "Coder y animador",                "https://www.youtube.com/@kylefaz1987", "FF9600"],
            ["Lo_Pro_123",         "pro",          "Guionista del lore",              "", "FF7400"],
            ["TiagoMYSF",          "tiago",        "Charter y artista",               "https://www.youtube.com/@TiagoMYSF", "16C725"],
            ["noob_38",            "noob",         "Animador de cinematicas",         "https://www.youtube.com/@noob_38/featured",   "FFFFFF"],
            ["Alterx00",           "alterx",       "Compositor de A BARK",            "https://www.youtube.com/@Alterx00",   "00FFE1"],
            ["Patrick_569",        "patrick",      "Compositor y creador de chromas", "https://www.youtube.com/@patrick_569", "FFFFFF"],
            ["Dacker",             "dacker",       "Artista de escenarios",           "https://www.youtube.com/@DackerDavsant",   "16C725"],
            ["Dark",               "dark",         "Musico del menu y pausa",         "https://www.youtube.com/@DarkCenterTema", "FF0013"],
            ["Hi_i_am_Darki",      "darki",        "Artista y animador",              "https://thedarklegendsproductions.carrd.co/", "FF0013"],
            ["kevinia",            "kevinia",      "Coder",                           "", "16C725"],
            ["hexgamer4720A",      "hex",          "Coder",                           "", "FF0013"],
            ["Dyscarn",            "dyscarn",      "Coder",                           "https://www.youtube.com/@Dyscarn", "F0F700"],
            ["Lexod",              "lexod",        "Compositor",                      "https://www.youtube.com/@LexodMinus",   "444444"],
            ["NoctiX",             "noctix",       "Compositor",                      "https://www.youtube.com/@NoctiX-i4h",   "7100DD"],
            ["Presionad0",         "presionado",   "Artista conceptual",              "https://www.youtube.com/@presionad0",   "16C725"],
            ["TomDash",            "tom",          "Charter",                         "https://www.youtube.com/@TomDashUTAU", "0075FF"],
            ["UpGr4d3 N3XuZ",      "upgrade",      "Artista y animador",              "https://www.youtube.com/@NeXuZ_01", "FFFFFF"],
            ["The orange eyes",    "eyes",         "Artista",                         "", "4FFF00"],
            ["GlitchedMultiversal","glitch",       "Animador",                        "", "FFFFFF"],
            [""],
            ["PSYCH ENGINE TEAM"],
            ["Shadow Mario",       "shadowmario",  "Main Programmer and Head of Psych Engine", "https://ko-fi.com/shadowmario",    "444444"],
            ["Riveren",            "riveren",      "Main Artist/Animator of Psych Engine",    "https://x.com/riverennn",          "14967B"],
            [""],
            ["FORMER ENGINE MEMBERS"],
            ["bb-panzu",           "bb",           "Ex-Programmer of Psych Engine",           "https://x.com/bbsub3",             "3E813A"],
            [""],
            ["ENGINE CONTRIBUTORS"],
            ["crowplexus",         "crowplexus",   "Linux Support, HScript Iris, Input System v3, and Other PRs",  "https://twitter.com/IamMorwen",   "CFCFCF"],
            ["Kamizeta",           "kamizeta",     "Creator of Pessy, Psych Engine's mascot.",  "https://www.instagram.com/cewweey/",  "D21C11"],
            ["MaxNeton",           "maxneton",     "Loading Screen Easter Egg Artist/Animator.", "https://bsky.app/profile/maxneton.bsky.social","3C2E4E"],
            ["Keoiki",             "keoiki",       "Note Splash Animations and Latin Alphabet", "https://x.com/Keoiki_",           "D2D2D2"],
            ["SqirraRNG",          "sqirra",       "Crash Handler and Base code for\nChart Editor's Waveform", "https://x.com/gedehari",           "E1843A"],
            ["EliteMasterEric",    "mastereric",   "Runtime Shaders support and Other PRs",    "https://x.com/EliteMasterEric",   "FFBD40"],
            ["MAJigsaw77",         "majigsaw",     ".MP4 Video Loader Library (hxvlc)",       "https://x.com/MAJigsaw77",         "5F5F5F"],
            ["iFlicky",            "flicky",       "Composer of Psync and Tea Time\nAnd some sound effects",  "https://x.com/flicky_i",          "9E29CF"],
            ["KadeDev",            "kade",         "Fixed some issues on Chart Editor and Other PRs",   "https://x.com/kade0912",          "64A250"],
            ["superpowers04",      "superpowers04","LUA JIT Fork",                           "https://x.com/superpowers04",      "B957ED"],
            ["CheemsAndFriends",   "cheems",       "Creator of FlxAnimate",                   "https://x.com/CheemsnFriendos",   "E1E1E1"],
            [""],
            ["FUNKIN' CREW"],
            ["ninjamuffin99",      "ninjamuffin99","Programmer of Friday Night Funkin'",        "https://x.com/ninja_muffin99",    "CF2D2D"],
            ["PhantomArcade",      "phantomarcade","Animator of Friday Night Funkin'",          "https://x.com/PhantomArcade3K",   "FADC45"],
            ["evilsk8r",           "evilsk8r",     "Artist of Friday Night Funkin'",           "https://x.com/evilsk8r",          "5ABD4B"],
            ["kawaisprite",        "kawaisprite",  "Composer of Friday Night Funkin'",          "https://x.com/kawaisprite",       "378FC7"],
            [""],
            ["PSYCH ENGINE DISCORD"],
            ["Join the Psych Ward!", "discord", "", "https://discord.gg/2ka77eMXDv", "5165F6"]
        ];

        for (item in defaultList)
            creditsData.push(item);

        #if MODS_ALLOWED
        for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
        #end
    }

    private function createCreditEntries()
    {
        var currentRelativeY:Float = 50;

        for (i => creditEntry in creditsData)
        {
            var isEntrySelectable:Bool = isSelectable(i);

            // Crear el texto.
            var text:FlxText = new FlxText(0, currentRelativeY, 0, creditEntry[0], creditTextSize);
            // IMPORTANTE: Asegúrate de que el font "sonic-mania-improved-v2.otf" existe en Paths.font
            text.setFormat(Paths.font("sonic-mania-improved-v2.otf"), creditTextSize, FlxColor.WHITE);
            text.antialiasing = ClientPrefs.data.antialiasing;
            grpCreditTexts.add(text);
            textRelativeYs.set(text, currentRelativeY);

            // Posicionamiento de títulos (no seleccionables) - CENTRADO A LA DERECHA
            if (!isEntrySelectable) {
                text.alignment = CENTER;
                text.x = rightHalfScreenCenterX - (text.width / 2); // Centrado en la mitad derecha
                text.borderColor = FlxColor.BLACK;
                text.borderSize = 2;
                text.borderStyle = FlxTextBorderStyle.OUTLINE;
            }

            // Crear y posicionar el ícono SOLO SI es seleccionable
            if (isEntrySelectable && creditEntry.length > 1 && creditEntry[1] != null && creditEntry[1].length > 0)
            {
                var iconPath:String = 'credits/' + creditEntry[1];
                var finalIconPath:String = 'credits/missing_icon';

                if (Paths.fileExists('images/$iconPath.png', IMAGE)) {
                    finalIconPath = iconPath;
                } else if (Paths.fileExists('images/$iconPath-pixel.png', IMAGE)) {
                    finalIconPath = iconPath + '-pixel';
                }

                var icon:AttachedSprite = new AttachedSprite(finalIconPath);
                if (finalIconPath.endsWith('-pixel')) icon.antialiasing = false;

                // Redimensionar el icono
                icon.setGraphicSize(Std.int(defaultIconWidth), Std.int(defaultIconWidth));
                icon.updateHitbox();

                icon.x = 0; // Se recalculará en update
                icon.y = currentRelativeY;
                icon.antialiasing = ClientPrefs.data.antialiasing;
                grpCreditIcons.add(icon);
                iconRelativeYs.set(icon, currentRelativeY);
            }

            currentRelativeY += entrySpacing;
        }
    }

    private var holdTime:Float = 0;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
        {
            FlxG.sound.music.volume += 0.5 * elapsed;
        }

        if (creditsData.length > 0)
        {
            var shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;

            if (controls.UI_UP_P)
            {
                changeSelection(-shiftMult);
                holdTime = 0;
            }
            if (controls.UI_DOWN_P)
            {
                changeSelection(shiftMult);
                holdTime = 0;
            }

            if(controls.UI_DOWN || controls.UI_UP)
            {
                var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
                holdTime += elapsed;
                var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

                if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                {
                    changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
                }
            }
        }

        if (controls.ACCEPT)
        {
            if (curSelected != -1 && creditsData.length > curSelected && creditsData[curSelected].length > 3) {
                var link = creditsData[curSelected][3];
                if (link != null && link.length > 4) {
                    CoolUtil.browserLoad(link);
                }
            }
        }

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
            return;
        }

        currentScrollY = FlxMath.lerp(currentScrollY, targetScrollY, 0.2);

        var currentTextDataIndex = 0;

        for (textItem in grpCreditTexts.members) {
            if (textRelativeYs.exists(textItem)) {
                textItem.y = textRelativeYs.get(textItem) + currentScrollY;

                // Si es un título, mantén su alineación y posición (centrada a la derecha).
                if (!isSelectable(currentTextDataIndex)) {
                     textItem.alignment = CENTER;
                     textItem.x = rightHalfScreenCenterX - (textItem.width / 2); // Centrado en la mitad derecha
                } else {
                    // Si es seleccionable, maneja la alineación del texto y la posición del icono
                    var iconSprite:AttachedSprite = null;
                    for (iconMember in grpCreditIcons.members) {
                        if (iconRelativeYs.exists(iconMember) && iconRelativeYs.get(iconMember) == textRelativeYs.get(textItem)) {
                            iconSprite = iconMember;
                            break;
                        }
                    }

                    var actualIconWidth = (iconSprite != null && iconSprite.alpha > 0) ? iconSprite.width : 0;
                    var iconExpectedX = creditsBlockEndRightX - actualIconWidth;
                    var textExpectedRightX = (actualIconWidth > 0) ? (iconExpectedX - iconToTextMargin) : creditsBlockEndRightX;
                    var minTextContentX = 50;
                    var availableTextWidth = textExpectedRightX - minTextContentX;

                    if (textItem.width > availableTextWidth && availableTextWidth > 0) {
                        textItem.width = availableTextWidth;
                        textItem.x = minTextContentX;
                        textItem.alignment = LEFT;
                    } else if (availableTextWidth <= 0) {
                        textItem.width = 0;
                        textItem.x = textExpectedRightX;
                        textItem.alignment = RIGHT;
                    }
                    else {
                        textItem.x = textExpectedRightX - textItem.width;
                        textItem.alignment = RIGHT;
                    }
                }
            }
            currentTextDataIndex++;
        }

        // --- Posicionamiento de Íconos ---
        for (iconItem in grpCreditIcons.members) {
            if (iconRelativeYs.exists(iconItem)) {
                var correspondingText:FlxText = null;
                for (textMember in grpCreditTexts.members) {
                    if (textRelativeYs.exists(textMember) && textRelativeYs.get(textMember) == iconRelativeYs.get(iconItem)) {
                        correspondingText = textMember;
                        break;
                    }
                }

                if (correspondingText != null) {
                    // ORIGINAL (o lo que intentamos antes):
                    // var estimatedTextBaselineY = correspondingText.y + correspondingText.size * 0.8;
                    // iconItem.y = estimatedTextBaselineY - (iconItem.height / 2);

                    // NUEVA LÓGICA: Centrar verticalmente el icono con el texto, pero asegurando que no se salga de la línea.
                    // Opción 1: Centrar el icono con la altura completa del texto (línea original).
                    // Esto es bueno si el icono es del mismo tamaño o ligeramente más grande que el texto.
                    iconItem.y = correspondingText.y + (correspondingText.height / 2) - (iconItem.height / 2);

                    // Opción 2 (más robusta para iconos muy grandes):
                    // Si el icono es significativamente más alto que el texto, podemos querer que el centro del icono
                    // se alinee con el centro del texto, pero limitando su desplazamiento hacia abajo.
                    // O podemos intentar alinear la parte superior o inferior del icono con puntos clave del texto.

                    // Probemos una solución que intente mantener el centro del icono cerca del centro del texto,
                    // pero que también evite que el icono descienda demasiado si es muy alto.
                    // Esto podría ser un valor constante o una relación.
                    // Por ejemplo, alinear la parte superior del icono con la parte superior del texto:
                    // iconItem.y = correspondingText.y;

                    // O alinear el centro del icono con la parte superior del texto:
                    // iconItem.y = correspondingText.y - (iconItem.height / 2);

                    // O alinear el centro del icono con una "línea media" del texto que no sea necesariamente la línea base
                    // y que esté un poco más arriba para compensar los iconos grandes.
                    // Vamos a intentar una mezcla: el centro del icono se alinea con el centro del texto,
                    // pero si el icono es mucho más grande, ajustamos un poco hacia arriba.

                    var textCenterY = correspondingText.y + (correspondingText.height / 2);
                    var iconCenterY = iconItem.y + (iconItem.height / 2);

                    // Si la altura del icono es mucho mayor que la altura del texto, ajustamos:
                    if (iconItem.height > correspondingText.height * 0.5) { // Si el icono es 1.5 veces más alto que el texto
                        iconItem.y = correspondingText.y - ((iconItem.height - correspondingText.height) / 2);
                    } else {
                        // Si el icono no es excesivamente grande, lo centramos con el texto
                        iconItem.y = correspondingText.y + (correspondingText.height / 2) - (iconItem.height / 2);
                    }


                    iconItem.x = correspondingText.x + correspondingText.width + iconToTextMargin;
                }
            }
        }
    }

    private var selectionTween:FlxTween = null;
    private var portraitTween:FlxTween = null;
    private var descTween:FlxTween = null;

    private function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        if (creditsData.length == 0) return;

        var originalSelected = curSelected;
        var newPotentialSelected = curSelected;
        var attempts = 0;
        var maxAttempts = creditsData.length * 2;

        do {
            newPotentialSelected = FlxMath.wrap(newPotentialSelected + change, 0, creditsData.length - 1);
            attempts++;

            if (attempts > maxAttempts) {
                newPotentialSelected = originalSelected;
                FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
                break;
            }
        } while (!isSelectable(newPotentialSelected));

        curSelected = newPotentialSelected;

        // --- INICIO DE LOS CAMBIOS PARA EL FONDO (MISMO CÓDIGO QUE ANTES) ---
        if (curSelected != -1 && creditsData.length > curSelected && creditsData[curSelected].length > 4) {
            intendedBgColor = CoolUtil.colorFromString(creditsData[curSelected][4]);
            FlxTween.color(bg, 0.2, bg.color, intendedBgColor); // Suaviza la transición del color de fondo
        } else {
            // Si por alguna razón no hay color, o la entrada no tiene el campo de color.
            intendedBgColor = FlxColor.BLACK;
            FlxTween.color(bg, 0.2, bg.color, intendedBgColor);
        }
        // --- FIN DE LOS CAMBIOS PARA EL FONDO ---


        // Actualizar el alpha y color de los textos
        var currentTextDataIndex = 0;
        for (textItem in grpCreditTexts.members) {
            var isThisTextSelected = (currentTextDataIndex == curSelected);

            if (isThisTextSelected) {
                textItem.alpha = 1;
                textItem.color = FlxColor.fromRGB(112, 153, 255); // Amarillo
                textItem.borderColor = FlxColor.TRANSPARENT;
                textItem.borderSize = 0;
            } else if (isSelectable(currentTextDataIndex)) {
                textItem.alpha = 0.6;
                textItem.color = FlxColor.WHITE;
                textItem.borderColor = FlxColor.TRANSPARENT;
                textItem.borderSize = 0;
            } else {
                textItem.alpha = 1;
                textItem.color = FlxColor.WHITE;
                textItem.borderColor = FlxColor.BLACK;
                textItem.borderSize = 2;
                textItem.borderStyle = FlxTextBorderStyle.OUTLINE;
            }
            currentTextDataIndex++;
        }

        // Actualizar el alpha de los iconos
        var iconIndexInGroup = 0;
        for (i => creditEntry in creditsData) {
            if (isSelectable(i)) {
                if (iconIndexInGroup < grpCreditIcons.members.length) {
                    var iconItem = grpCreditIcons.members[iconIndexInGroup];
                    if (i == curSelected) {
                        iconItem.alpha = 1;
                    } else {
                        iconItem.alpha = 0.6;
                    }
                }
                iconIndexInGroup++;
            }
        }

        // --- Ajustar el scroll vertical ---
        var selectedTextRelativeY:Float = -1;
        if (curSelected >= 0 && curSelected < creditsData.length) {
            selectedTextRelativeY = curSelected * entrySpacing;
        }

        if (selectedTextRelativeY != -1) {
            targetScrollY = scrollWindowTopY - selectedTextRelativeY;

            var totalContentHeight = creditsData.length * entrySpacing;
            if (totalContentHeight < scrollWindowHeight) {
                targetScrollY = (scrollWindowHeight - totalContentHeight) / 2 + scrollWindowTopY;
            } else {
                targetScrollY = Math.min(targetScrollY, scrollWindowTopY);
                var minScrollY = (scrollWindowTopY + scrollWindowHeight) - totalContentHeight;
                targetScrollY = Math.max(targetScrollY, minScrollY);
            }
        }

        // Lógica para la imagen de retrato (CENTRADA EN PANTALLA)
        var imageName:String = creditsData[curSelected].length > 1 ? creditsData[curSelected][1] : "";
        if (imageName.length > 0)
        {
            var imagePath:String = 'portraits/' + imageName;

            if (Paths.fileExists('images/$imagePath.png', IMAGE))
            {
                pibes.loadGraphic(Paths.image(imagePath));
                if (pibes.width != FlxG.width || pibes.height != FlxG.height) {
                    var scaleFactorX = FlxG.width / pibes.width;
                    var scaleFactorY = FlxG.height / pibes.height;
                    var finalScale = Math.min(scaleFactorX, scaleFactorY);

                    pibes.setGraphicSize(Std.int(pibes.width * finalScale), Std.int(pibes.height * finalScale));
                    pibes.updateHitbox();
                }
                pibes.screenCenter();
                pibes.alpha = 1;
                pibes.antialiasing = ClientPrefs.data.antialiasing;
            }
            else if (Paths.fileExists('images/$imagePath-pixel.png', IMAGE))
            {
                pibes.loadGraphic(Paths.image('$imagePath-pixel'));
                if (pibes.width != FlxG.width || pibes.height != FlxG.height) {
                    var scaleFactorX = FlxG.width / pibes.width;
                    var scaleFactorY = FlxG.height / pibes.height;
                    var finalScale = Math.min(scaleFactorX, scaleFactorY);

                    pibes.setGraphicSize(Std.int(pibes.width * finalScale), Std.int(pibes.height * finalScale));
                    pibes.updateHitbox();
                }
                pibes.screenCenter();
                pibes.alpha = 1;
                pibes.antialiasing = false;
            }
            else
            {
                pibes.alpha = 0;
            }
        }
        else
        {
            pibes.alpha = 0;
        }

        // Lógica de la descripción
        if (curSelected != -1 && creditsData.length > curSelected && creditsData[curSelected].length > 2) {
            descText.text = creditsData[curSelected][2];
            if (descText.text.trim().length > 0) {
                descText.visible = descBox.visible = true;
                descText.screenCenter(X);
                descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
                descBox.screenCenter(X);
                descBox.y = descText.y - 10;

                if(descTween != null) descTween.cancel();
                descTween = FlxTween.tween(descText, {y : FlxG.height - 90}, 0.25, {ease: FlxEase.sineOut});
                descBox.updateHitbox();
            } else {
                descText.visible = descBox.visible = false;
            }
        } else {
            descText.visible = descBox.visible = false;
        }
    }

    private function isSelectable(index:Int):Bool {
        if (index < 0 || index >= creditsData.length) return false;
        // Una entrada es seleccionable si tiene al menos 4 elementos (Name, Icon, Desc, Link)
        // Y ahora, para el color, también necesitamos que tenga el 5to elemento (BG Color).
        // Así que la condición real debería ser que tenga al menos 5 elementos.
        return creditsData[index].length >= 5; // Cambiado de 4 a 5
    }

    #if MODS_ALLOWED
    private function pushModCreditsToList(folder:String)
    {
        var creditsFile:String = Paths.mods(folder + '/data/credits.txt');

        #if TRANSLATIONS_ALLOWED
        var translatedCredits:String = Paths.mods(folder + '/data/credits-${ClientPrefs.data.language}.txt');
        #end

        if (#if TRANSLATIONS_ALLOWED (FileSystem.exists(translatedCredits) && (creditsFile = translatedCredits) == translatedCredits) || #end FileSystem.exists(creditsFile))
        {
            var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
            for(i in firstarray)
            {
                var arr:Array<String> = i.replace('\\n', '\n').split("::");
                if(arr.length >= 5) { // Nombre, Icono, Desc, Link, Color
                    if (arr.length < 6 || arr[5] == null || arr[5] == "") {
                         arr.push(folder);
                    }
                    creditsData.push(arr);
                } else if (arr.length > 0 && arr[0].trim().length > 0) {
                    creditsData.push([arr[0]]);
                }
            }
            creditsData.push(['']);
        }
    }
    #end
}