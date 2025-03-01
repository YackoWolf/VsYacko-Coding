package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

import flixel.addons.display.FlxBackdrop;
import flixel.animation.FlxAnimation;

class GalleryState extends FlxState
{
    private var imagenes:Array<FlxSprite>;
    private var indiceActual:Int = 0;
    private var textoEncabezado:FlxText;

    var sonicSpines:FlxSprite;
    var sonicSpines2:FlxSprite;
    var bg:FlxSprite;

    override public function create()
    {
        super.create();

        bg = new FlxBackdrop().loadGraphic(Paths.image("MenuStuff/Gallery/bg"));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.scrollFactor.set();
		bg.velocity.y = -40;
		bg.velocity.x = -40;
		bg.active = true;
		add(bg);
        bg.screenCenter();

        sonicSpines = new FlxBackdrop().loadGraphic(Paths.image("MenuStuff/Gallery/spines"));
		sonicSpines.antialiasing = ClientPrefs.data.antialiasing;
		sonicSpines.updateHitbox();
		sonicSpines.scrollFactor.set();
		sonicSpines.velocity.y = 0;
		sonicSpines.velocity.x = -40;
		sonicSpines.active = true;
		add(sonicSpines);
		sonicSpines.screenCenter();

        sonicSpines2 = new FlxBackdrop().loadGraphic(Paths.image("MenuStuff/Gallery/spines"));
		sonicSpines2.antialiasing = ClientPrefs.data.antialiasing;
        sonicSpines2.angle = 180;
		sonicSpines2.updateHitbox();
		sonicSpines2.scrollFactor.set();
		sonicSpines2.velocity.y = 0;
		sonicSpines2.velocity.x = 40;
		sonicSpines2.active = true;
		add(sonicSpines2);
		sonicSpines2.screenCenter();

        // Muestra el cursor explícitamente
        FlxG.mouse.visible = true; // Corrección aquí

        textoEncabezado = new FlxText(0, 100, FlxG.width, "");
        textoEncabezado.setFormat(Paths.font("NiseSegaSonic.ttf"), 32, FlxColor.WHITE, CENTER);
        add(textoEncabezado);

        // Carga las imágenes
        imagenes = [];
        for (i in 0...18) // Itera de 0 a 7 (18 iteraciones)
        {
            var nombreImagen:String = 'galeria/gal' + i; // Construye el nombre correcto
            var rutaImagen:String = Paths.image(nombreImagen).key;
            if (FlxG.bitmap.checkCache(rutaImagen))
            {
                var imagen:FlxSprite = new FlxSprite().loadGraphic(rutaImagen);
                imagen.screenCenter();
                imagen.scale.set(0.5, 0.5);
                imagen.visible = false;
                add(imagen);
                imagenes.push(imagen);
            }
        }

        // Muestra la primera imagen
        if (imagenes.length > 0)
        {
            imagenes[0].visible = true;
        }

        // Botones de navegación (el resto del código permanece igual)
        var botonAnterior:FlxButton = new FlxButton(20, FlxG.height - 80, "Anterior", onAnterior);
        var botonSiguiente:FlxButton = new FlxButton(FlxG.width - 120, FlxG.height - 80, "Siguiente", onSiguiente);
        var botonSalir:FlxButton = new FlxButton(FlxG.width / 2 - 50, FlxG.height - 80, "Salir", onSalir);
        add(botonAnterior);
        add(botonSiguiente);
        add(botonSalir);

        actualizarTextoEncabezado();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
        {
            onAnterior(); // Llama a la función onAnterior()
        }

        if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
        {
            onSiguiente(); // Llama a la función onSiguiente()
        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new MainMenuState());
        }
    
        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new MainMenuState());
        }

        actualizarTextoEncabezado();
    }

    private function onAnterior():Void
    {
        imagenes[indiceActual].visible = false;
        indiceActual--;
        if (indiceActual < 0)
        {
            indiceActual = imagenes.length - 1;
        }
        imagenes[indiceActual].visible = true;

        actualizarTextoEncabezado();
    }

    private function onSiguiente():Void
    {
        imagenes[indiceActual].visible = false;
        indiceActual++;
        if (indiceActual >= imagenes.length)
        {
            indiceActual = 0;
        }
        imagenes[indiceActual].visible = true;

        actualizarTextoEncabezado();
    }

    private function actualizarTextoEncabezado():Void
    {
        switch (indiceActual)
        {
            case 0:
                textoEncabezado.text = "Concepto del inicio xd";
            case 1:
                textoEncabezado.text = "ULTRA viejo logo del mod";
            case 2:
                textoEncabezado.text = "Si herobrine estuviera en el mod";
            case 3:
                textoEncabezado.text = "Conceptos del yacko sprite";
            case 4:
                textoEncabezado.text = "Primera fase descartada de noxfang";
            case 5:
                textoEncabezado.text = "Fase faker descartada";
            case 6:
                textoEncabezado.text = "Concepto del storyMode";
            case 7:
                textoEncabezado.text = "Concepto del sus xd";
            case 8:
                textoEncabezado.text = "Viejo story Mode xd";
            case 9:
                textoEncabezado.text = "El anterior logo del mod";
            case 10:
                textoEncabezado.text = "Viejo inicio";
            case 11:
                textoEncabezado.text = "Concepto del freeplay";
            case 12:
                textoEncabezado.text = "Anterior Concepto del freeplay";
            case 13:
                textoEncabezado.text = "Concepto del menu de pausa";
            case 14:
                textoEncabezado.text = "JEFE FINAL VERDADERO";
            case 15:
                textoEncabezado.text = "Gracias ChatGPT";
            case 16:
                textoEncabezado.text = "PERO QUE XDDDD";
            case 17:
                textoEncabezado.text = "MEME MUERTO XD";
            default:
                textoEncabezado.text = "";
        }
    }

    private function onSalir():Void
    {
        FlxG.switchState(new MainMenuState());
    }
}