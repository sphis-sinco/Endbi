package;

import flixel.FlxState;
import flixel.text.FlxText;
import play.character.CharacterDataManager;
import play.character.CharacterSprite;

class PlayState extends FlxState
{
	public var TEMPCHAR:CharacterSprite;

	public var PLAYER:CharacterSprite;
	public var PLAYER_HEALTH:Int = 1;

	public var OPPONENT:CharacterSprite;
	public var OPPONENT_HEALTH:Int = 1;

	override public function new()
	{
		super();

		var backdrop:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		add(backdrop);

		TEMPCHAR = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));

		PLAYER = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));
		OPPONENT = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));
	}

	override public function create()
	{
		super.create();

		final charWidthOffset:Int = 6;
		final charHeightOffset:Int = 6;

		PLAYER.setPosition(TEMPCHAR.width * charWidthOffset, TEMPCHAR.height * charHeightOffset);
		OPPONENT.setPosition(FlxG.width - TEMPCHAR.width * charWidthOffset, TEMPCHAR.height * charHeightOffset);

		add(PLAYER);
		add(OPPONENT);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
