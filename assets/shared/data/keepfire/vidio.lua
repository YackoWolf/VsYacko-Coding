local allowCountdown = false

function onStartCountdown()
	-- Block the first countdown and start a timer of 0.001 seconds to play the video
	if not allowCountdown and not seenCutscene then
		setProperty('inCutscene', true);
		startVideo('keepfire')
       allowCountdown = true
	return Function_Stop;
	end
	return Function_Continue;
end