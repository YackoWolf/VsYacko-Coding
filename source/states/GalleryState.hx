package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class GalleryState extends FlxState
{
    private var imagenes:Array<FlxSprite>;
    private var indiceActual:Int = 0;

    override public function create()
    {
        super.create();

        // Muestra el cursor explícitamente
        FlxG.mouse.visible = true; // Corrección aquí

        // Carga las imágenes
        imagenes = [];
        for (i in 0...2) // Itera de 0 a 1 (2 iteraciones)
        {
            var nombreImagen:String = 'galeria/gal' + i; // Construye el nombre correcto
            var rutaImagen:String = Paths.image(nombreImagen).key;
            if (FlxG.bitmap.checkCache(rutaImagen))
            {
                var imagen:FlxSprite = new FlxSprite().loadGraphic(rutaImagen);
                imagen.screenCenter();
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
    }

    private function onSalir():Void
    {
        FlxG.switchState(new MainMenuState());
    }
}