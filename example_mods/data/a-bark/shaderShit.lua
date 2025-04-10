function onCreatePost()
setPropertyFromClass('ClientPrefs', 'shaders', true)

	makeLuaSprite('uh')
	setSpriteShader('uh', 'uh')
	
	makeLuaSprite('tvShad')
	setSpriteShader('tvShad', 'TvEffect')
	setShaderFloat('tvShad', 'vignetteIntensity',0.025)
	setShaderFloat('tvShad', 'chromIntensity',0.004)
	setShaderFloat('tvShad', 'tvIntensity',0.001)
	setShaderFloat('tvShad', 'tvFrequency',0.1)
	setShaderFloat('tvShad', 'tvDistorcion',0.2)
	setShaderBool('tvShad', 'lineTv',false)
	setShaderFloat('tvShad', 'lineFrequency',0.4)
	setShaderFloat('tvShad', 'lineSize',0.025)
	setShaderFloat('tvShad', 'lineOffset',0.005)
	setShaderFloat('tvShad', 'lineSpace',0.7)
	setShaderFloat('tvShad', 'multiply',1)
	setShaderBool('tvShad', 'vignetteFollowAlpha',false)
	
	addHaxeLibrary('ColorSwap', 'shaders')

	runHaxeCode([[
	var colorShad = new ColorSwap();
	colorShad.hue = 0/360;
	colorShad.saturation = -25/100;
	colorShad.brightness = 0/100;
	setVar('colorShad', colorShad);
	var uh = game.getLuaObject("uh").shader;
	var tv = game.getLuaObject("tvShad").shader;
	var cl = colorShad.shader;
	//game.camGame._filters = [new ShaderFilter(uh)]; //, new ShaderFilter(cl)];
	//game.camHUD._filters = [new ShaderFilter(uh)]; //, new ShaderFilter(cl)];
	//game.camOther._filters = [new ShaderFilter(tv)];
	FlxG.game._filters = [new ShaderFilter(uh)];
	return;
	]])
end
function onDestroy()
runHaxeCode([[
	game.camGame._filters = [];
	game.camHUD._filters = [];
	game.camOther._filters = [];
	FlxG.game._filters = [];
	return;
]])
end