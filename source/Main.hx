package;

import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.save.bind('Endbi', 'Sinco');
		addChild(new FlxGame(0, 0, PlayState));
	}
}
