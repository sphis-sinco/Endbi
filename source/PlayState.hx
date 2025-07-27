package;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import play.character.CharacterDataManager;
import play.character.CharacterSprite;

class PlayState extends FlxState
{
	public var TEMPCHAR:CharacterSprite;

	public var ATTACK_SELECT:Bool = false;
	public var ATTACK_SELECT_BUTTON:FlxButton;

	public var ATTACK_BUTTONS:FlxTypedGroup<FlxButton>;

	public var PLAYER:CharacterSprite;

	public var PLAYER_LAST_MOVES:String = '';
	public var PLAYER_ATK_MOVE:String = 'a';
	public var PLAYER_DEF_MOVE:String = 'd';

	public var PLAYER_MAXENERGY:Int = 1;
	public var PLAYER_ENERGY:Int = 1;

	public var PLAYER_MAXHEALTH:Int = 1;
	public var PLAYER_HEALTH:Int = 1;

	public var PLAYER_LEVEL:Int = 1;

	public var PLAYER_TEXT:FlxText;

	public var OPPONENT:CharacterSprite;

	public var OPPONENT_MAXENERGY:Int = 1;
	public var OPPONENT_ENERGY:Int = 1;

	public var OPPONENT_MAXHEALTH:Int = 5;
	public var OPPONENT_HEALTH:Int = 5;

	public var OPPONENT_LEVEL:Int = 1;

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

		ATTACK_BUTTONS = new FlxTypedGroup<FlxButton>();

		ATTACK_SELECT_BUTTON = new FlxButton(0, FlxG.height - 3 * 48, 'Attack', () ->
		{
			ATTACK_SELECT = true;
		});
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

		add(ATTACK_BUTTONS);

		ATTACK_BUTTONS.add(new FlxButton(0, 0, PLAYER.data.attack1.name, () ->
		{
			attackOp(Std.int(PLAYER.data.attack1.baseDamage * (PLAYER_ENERGY / PLAYER_MAXENERGY)));
		}));
		ATTACK_BUTTONS.add(new FlxButton(0, 32, PLAYER.data.attack2.name, () ->
		{
			attackOp(Std.int(PLAYER.data.attack2.baseDamage * (PLAYER_ENERGY / PLAYER_MAXENERGY)));
		}));
		ATTACK_BUTTONS.add(new FlxButton(0, 64, PLAYER.data.attack3.name, () ->
		{
			attackOp(Std.int(PLAYER.data.attack3.baseDamage * (PLAYER_ENERGY / PLAYER_MAXENERGY)));
		}));

		for (attackbtn in ATTACK_BUTTONS.members)
		{
			attackbtn.y += (FlxG.height - ATTACK_BUTTONS.members.length * 48);
		}

		add(ATTACK_SELECT_BUTTON);
	}

	public function attackOp(val:Int)
	{
		ATTACK_SELECT = false;

		var defence = false;
		var def_reason:String = '';

		final spammingAttack:Bool = PLAYER_LAST_MOVES.split(PLAYER_DEF_MOVE)[0].length >= 4;
		if (spammingAttack)
			def_reason = 'player has been predicted';
		else if (FlxG.random.int(0, 4) >= 3)
			def_reason = 'random chance';

		defence = def_reason != '';
		if (defence)
			trace('Opponent defended: $def_reason');

		final energyDiv = (PLAYER_ENERGY / PLAYER_MAXENERGY);
		OPPONENT_HEALTH -= Std.int(val / ((defence) ? (2 * energyDiv) : (1 * energyDiv)));
		PLAYER_ENERGY -= 1;

		PLAYER_LAST_MOVES += PLAYER_ATK_MOVE;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (attackbtn in ATTACK_BUTTONS.members)
		{
			attackbtn.visible = ATTACK_SELECT;
		}

		ATTACK_SELECT_BUTTON.visible = !ATTACK_SELECT;

		PLAYER_TEXT.text = 'HP: ${PLAYER_HEALTH}/${PLAYER_MAXHEALTH}' + '\nENERGY: ${PLAYER_ENERGY}/${PLAYER_MAXENERGY}' + '\nLEVEL: ${PLAYER_LEVEL}';
		OPPONENT_TEXT.text = 'HP: ${OPPONENT_HEALTH}/${OPPONENT_MAXHEALTH}' + '\nENERGY: ${OPPONENT_ENERGY}/${OPPONENT_MAXENERGY}'
			+ '\nLEVEL: ${OPPONENT_LEVEL}';
	}
}
