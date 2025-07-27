package;

import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import play.character.CharacterDataManager;
import play.character.CharacterSprite;
import play.op_ai.MovePatternGenerator;

class PlayState extends FlxState
{
	public static var instance:PlayState = null;

	public var TEMPCHAR:CharacterSprite;

	public var DEFENCE_BUTTON:FlxButton;

	public var ATTACK_SELECT:Bool = false;
	public var ATTACK_SELECT_BUTTON:FlxButton;

	public var ATTACK_BUTTONS:FlxTypedGroup<FlxButton>;

	public var PLAYER:CharacterSprite;

	public var PLAYER_LAST_MOVES:String = '';
	public var PLAYER_ATK_MOVE:String = 'a';
	public var PLAYER_DEF_MOVE:String = 'd';

	public var PLAYER_MAXENERGY:Int = 5;
	public var PLAYER_ENERGY:Int = 5;

	public var PLAYER_MAXHEALTH:Int = 1;
	public var PLAYER_HEALTH:Int = 1;

	public var PLAYER_LEVEL:Int = 1;

	public var PLAYER_TEXT:FlxText;

	public var OPPONENT:CharacterSprite;

	public var OPPONENT_MAXENERGY:Int = 5;
	public var OPPONENT_ENERGY:Int = 5;

	public var OPPONENT_MAXHEALTH:Int = 5;
	public var OPPONENT_HEALTH:Int = 5;

	public var OPPONENT_LEVEL:Int = 1;

	public var OPPONENT_TEXT:FlxText;

	public var PLAYER_CHARACTER_NAME:String;
	public var OPPONENT_CHARACTER_NAME:String;

	override public function new(player:String, op:String)
	{
		super();

		MovePatternGenerator.keys = [PLAYER_ATK_MOVE, PLAYER_DEF_MOVE];

		var backdrop:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		add(backdrop);

		PLAYER_TEXT = new FlxText();
		OPPONENT_TEXT = new FlxText();

		if (instance != null)
		{
			this.PLAYER_LEVEL = instance.PLAYER_LEVEL;
			this.PLAYER_ENERGY = instance.PLAYER_ENERGY;
			this.PLAYER_HEALTH = instance.PLAYER_HEALTH;
			this.PLAYER_MAXENERGY = instance.PLAYER_MAXENERGY;
			this.PLAYER_MAXHEALTH = instance.PLAYER_MAXHEALTH;

			instance = null;
		}

		TEMPCHAR = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));

		if (PLAYER == null || player != PLAYER_CHARACTER_NAME)
			PLAYER = new CharacterSprite(CharacterDataManager.getCharacterJson(player));
		if (OPPONENT == null || op != OPPONENT_CHARACTER_NAME)
			OPPONENT = new CharacterSprite(CharacterDataManager.getCharacterJson(op));

		ATTACK_BUTTONS = new FlxTypedGroup<FlxButton>();

		ATTACK_SELECT_BUTTON = new FlxButton(0, FlxG.height - 3 * 48, 'Attack', () ->
		{
			ATTACK_SELECT = true;
		});

		DEFENCE_BUTTON = new FlxButton(0, FlxG.height - 3 * 48 + 32, 'Defence', defence);

		PLAYER_CHARACTER_NAME = player;
		OPPONENT_CHARACTER_NAME = op;
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
		add(DEFENCE_BUTTON);

		instance = this;
	}

	public function attackOp(val:Int)
	{
		trace('--------atk--------');
		PLAYER_LAST_MOVES += PLAYER_ATK_MOVE;

		ATTACK_SELECT = false;

		var defence = false;
		var def_reason:String = '';

		final usingPattern:Bool = checkMovePatterns();

		if (usingPattern)
			def_reason = 'player has been predicted';
		else if (FlxG.random.int(0, 4) >= 3)
			def_reason = 'random chance';

		defence = def_reason != '';
		if (defence)
			trace('Opponent defended: $def_reason');

		final energyDiv = (PLAYER_ENERGY / PLAYER_MAXENERGY);
		final prevOH = OPPONENT_HEALTH;
		OPPONENT_HEALTH -= Std.int(val / ((defence) ? (2 * energyDiv) : (1 * energyDiv)));
		{
			if (prevOH != OPPONENT_HEALTH)
			{
				// sfx goes here
				FlxFlicker.stopFlickering(OPPONENT);
				FlxFlicker.flicker(OPPONENT, 1, 0.05);
			}
		}
		PLAYER_ENERGY -= 1;

		if (OPPONENT_HEALTH < 0)
		{
			final energyIncrease = 5 * Std.int(PLAYER_ENERGY / PLAYER_MAXENERGY);

			PLAYER_LEVEL++;
			PLAYER_MAXENERGY += energyIncrease;

			if (PLAYER_LEVEL > 20 || energyIncrease == 0)
			{
				PLAYER_LEVEL--;
				PLAYER_MAXENERGY -= energyIncrease;
			}

			FlxG.switchState(() -> new PlayState(PLAYER_CHARACTER_NAME, OPPONENT_CHARACTER_NAME));
		}
		if (PLAYER_ENERGY < 0)
		{
			PLAYER_ENERGY = 0;
		}

		if (FlxG.random.bool(FlxG.random.int(0, 100)) || defence)
		{
			opponentAttack();
		}
	}

	public function defence()
	{
		trace('--------def--------');
		PLAYER_LAST_MOVES += PLAYER_DEF_MOVE;

		if (FlxG.random.bool(FlxG.random.int(25, 50)))
		{
			PLAYER_ENERGY++;

			if (PLAYER_ENERGY > PLAYER_MAXENERGY)
				PLAYER_ENERGY--;
			else
				trace('Increased energy');
		}
		else
			trace('Did nothing');

		if (FlxG.random.bool(FlxG.random.int(0, 100)) || checkMovePatterns())
		{
			opponentAttack();
		}
	}

	public function opponentAttack() {}

	public function checkMovePatterns():Bool
	{
		trace('------movepat------');
		final movesList = PLAYER_LAST_MOVES.toString();
		trace('movesList: $movesList');

		final two_movesList = movesList.substring(movesList.length - 2, movesList.length);
		trace('two_movesList: $two_movesList');

		final four_movesList = movesList.substring(movesList.length - 4, movesList.length);
		trace('four_movesList: $four_movesList');

		final six_movesList = movesList.substring(movesList.length - 6, movesList.length);
		trace('six_movesList: $six_movesList');

		final eight_movesList = movesList.substring(movesList.length - 8, movesList.length);
		trace('eight_movesList: $eight_movesList');

		final patternStrings = MovePatternGenerator.generateFilteredPatterns();

		var usingPattern:Bool = false;

		for (pattern in patternStrings)
		{
			trace('Checking for pattern "$pattern"');

			switch (pattern.length)
			{
				case 2:
					usingPattern = two_movesList == pattern;
				case 4:
					usingPattern = four_movesList == pattern;
				case 6:
					usingPattern = six_movesList == pattern;
				case 8:
					usingPattern = eight_movesList == pattern;
				default:
					trace('Unimplemented size: ${pattern.length}');
			}
			if (usingPattern)
			{
				trace('Using pattern: "$pattern"');
				break;
			}
		}
		trace('----movepat-end----');

		return usingPattern;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (attackbtn in ATTACK_BUTTONS.members)
		{
			attackbtn.visible = ATTACK_SELECT;
		}

		ATTACK_SELECT_BUTTON.visible = !ATTACK_SELECT && PLAYER_ENERGY > 0;
		DEFENCE_BUTTON.visible = !ATTACK_SELECT;

		PLAYER_TEXT.text = 'HP: ${PLAYER_HEALTH}/${PLAYER_MAXHEALTH}' + '\nENERGY: ${PLAYER_ENERGY}/${PLAYER_MAXENERGY}' + '\nLEVEL: ${PLAYER_LEVEL}';
		OPPONENT_TEXT.text = 'HP: ${OPPONENT_HEALTH}/${OPPONENT_MAXHEALTH}' + '\nENERGY: ${OPPONENT_ENERGY}/${OPPONENT_MAXENERGY}'
			+ '\nLEVEL: ${OPPONENT_LEVEL}';
	}
}
