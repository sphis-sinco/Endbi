package;

import flixel.FlxState;
import play.character.CharacterDataManager;
import play.character.CharacterSprite;

class PlayState extends FlxState
{
	public var tempchar:CharacterSprite;

	public var PLAYER:CharacterSprite;
	public var PLAYER_HEALTH:Int = 1;

	public var OPPONENT:CharacterSprite;
	public var OPPONENT_HEALTH:Int = 1;

	override public function new()
	{
		super();

		var backdrop:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		add(backdrop);

		tempchar = new CharacterSprite(CharacterDataManager.getCharacterJson('tempChar'));

		PLAYER = new CharacterSprite(CharacterDataManager.getCharacterJson('tempChar'));
		OPPONENT = new CharacterSprite(CharacterDataManager.getCharacterJson('tempChar'));
	}

	override public function create()
	{
		super.create();

		final charWidthOffset:Int = 6;
		final charHeightOffset:Int = 6;

		PLAYER.setPosition(tempchar.width * charWidthOffset, tempchar.height * charHeightOffset);
		OPPONENT.setPosition(FlxG.width - tempchar.width * charWidthOffset, tempchar.height * charHeightOffset);

		add(PLAYER);
		add(OPPONENT);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
