package;

import flixel.FlxState;
import flixel.text.FlxText;
import play.character.CharacterDataManager;
import play.character.CharacterSprite;

class PlayState extends FlxState
{
	public var TEMPCHAR:CharacterSprite;

	public var PLAYER:CharacterSprite;
	public var PLAYER_MAXHEALTH:Int = 1;
	public var PLAYER_HEALTH:Int = 1;
	public var PLAYER_TEXT:FlxText;

	public var OPPONENT:CharacterSprite;
	public var OPPONENT_MAXHEALTH:Int = 1;
	public var OPPONENT_HEALTH:Int = 1;
	public var OPPONENT_TEXT:FlxText;

	override public function new()
	{
		super();

		var backdrop:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		add(backdrop);

		TEMPCHAR = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));

		PLAYER = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));
		OPPONENT = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));

		PLAYER_TEXT = new FlxText();
		OPPONENT_TEXT = new FlxText();
	}

	override public function create()
	{
		super.create();

		final charWidthOffset = 6;
		final charHeightOffset = 6;

		PLAYER.setPosition(TEMPCHAR.width * charWidthOffset, TEMPCHAR.height * charHeightOffset);
		OPPONENT.setPosition(FlxG.width - TEMPCHAR.width * charWidthOffset, TEMPCHAR.height * charHeightOffset);

		add(PLAYER);
		add(OPPONENT);

		final referenceDividor = 4;

		PLAYER_TEXT.setPosition(0, FlxG.height - (56 * referenceDividor));
		OPPONENT_TEXT.setPosition(FlxG.width - (81 * referenceDividor), FlxG.height - (56 * referenceDividor));

		PLAYER_TEXT.size = 16;
		OPPONENT_TEXT.size = 16;

		PLAYER_TEXT.color = 0x000000;
		OPPONENT_TEXT.color = 0x000000;

		add(PLAYER_TEXT);
		add(OPPONENT_TEXT);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		PLAYER_TEXT.text = 'HP: ${PLAYER_HEALTH}/${PLAYER_MAXHEALTH}';
		OPPONENT_TEXT.text = 'HP: ${OPPONENT_HEALTH}/${OPPONENT_MAXHEALTH}';
	}
}
