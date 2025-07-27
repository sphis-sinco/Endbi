package;

import openfl.display.Sprite;

/**
 * Main entry point for the Endbi game.
 * Initializes save system and launches the main play state.
 */
class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.save.bind('Endbi', 'Sinco');
		addChild(new FlxGame(0, 0, play.PlayState));
	}
}
