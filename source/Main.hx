package;

import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.save.bind('Endbi', 'Sinco');

		#if sys
		trace(Sys.args());
		final haxeVer:Int = Sys.command('haxe', ['--version']);
		trace(haxeVer);
		trace(Sys.cpuTime());
		// trace(Sys.environment());
		trace(Sys.getCwd());
		trace(Sys.programPath());
		trace(Sys.systemName());
		trace(Sys.time());

		if (haxeVer != 0)
			trace('Non-haxer detected, posting nudes on twitter.com...');
		#end

		addChild(new FlxGame(0, 0, play.PlayState));
	}
}
