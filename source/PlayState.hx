package;

import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import play.character.CharacterData;
import play.character.CharacterDataManager;
import play.character.CharacterSprite;
import play.op_ai.MovePatternGenerator;

class PlayState extends FlxState
{
	public static var instance:PlayState = null;

	public var ATK_MOVE:String = 'a';
	public var DEF_MOVE:String = 'd';

	public var TEMPCHAR:CharacterSprite;

	public var DEFENCE_BUTTON:FlxButton;

	public var ATTACK_SELECT:Bool = false;
	public var ATTACK_SELECT_BUTTON:FlxButton;

	public var ATTACK_BUTTONS:FlxTypedGroup<FlxButton>;

	public var PLAYER:CharacterSprite;

	public var PLAYER_LAST_MOVES:String = '';

	public var PLAYER_TEXT:FlxText;

	public var OPPONENT:CharacterSprite;

	public var OPPONENT_NEXT_MOVE:String = '';

	public var OPPONENT_TEXT:FlxText;

	public var PLAYER_CHARACTER_NAME:String;
	public var OPPONENT_CHARACTER_NAME:String;

	override public function new(player:String, op:String = 'jujer')
	{
		super();

		MovePatternGenerator.keys = [ATK_MOVE, DEF_MOVE];

		var backdrop:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		add(backdrop);

		PLAYER_TEXT = new FlxText();
		OPPONENT_TEXT = new FlxText();

		TEMPCHAR = new CharacterSprite(CharacterDataManager.getCharacterJson('TEMPCHAR'));

		if (PLAYER == null || player != PLAYER_CHARACTER_NAME)
			PLAYER = new CharacterSprite(CharacterDataManager.getCharacterJson(player));

		if (instance != null)
		{
			PLAYER.LEVEL = instance.PLAYER.LEVEL;
			PLAYER.ENERGY = instance.PLAYER.ENERGY;
			PLAYER.HP = instance.PLAYER.HP;
			PLAYER.MAX_ENERGY = instance.PLAYER.MAX_ENERGY;
			PLAYER.MAX_HP = instance.PLAYER.MAX_HP;

			instance = null;
		}

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

		PLAYER.setPosition(PLAYER.width * charWidthOffset, TEMPCHAR.height * charHeightOffset);
		OPPONENT.setPosition(FlxG.width - OPPONENT.width * charWidthOffset, TEMPCHAR.height * charHeightOffset);

		OPPONENT.flipX = true;

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
			attackOp(PLAYER.data.attack1);
		}));
		ATTACK_BUTTONS.add(new FlxButton(0, 32, PLAYER.data.attack2.name, () ->
		{
			attackOp(PLAYER.data.attack2);
		}));
		ATTACK_BUTTONS.add(new FlxButton(0, 64, PLAYER.data.attack3.name, () ->
		{
			attackOp(PLAYER.data.attack3);
		}));

		for (attackbtn in ATTACK_BUTTONS.members)
		{
			attackbtn.y += (FlxG.height - ATTACK_BUTTONS.members.length * 48);
		}

		add(ATTACK_SELECT_BUTTON);
		add(DEFENCE_BUTTON);

		instance = this;
	}

	public function attackOp(attack:CharacterAttackInformation)
	{
		trace('--------atk--------');
		PLAYER_LAST_MOVES += ATK_MOVE;

		ATTACK_SELECT = false;

		var defence = false;
		var def_reason:String = '';

		final usingPattern:Bool = checkMovePatterns();

		if (FlxG.random.float(0, 4) >= 3.5)
			def_reason = 'random chance';
		else if (usingPattern && FlxG.random.float(0, 2) >= 1.5)
			def_reason = 'player has been predicted';

		defence = def_reason != '';
		if (defence)
			trace('Opponent defended: $def_reason');

		final energyDiv = (PLAYER.ENERGY / PLAYER.MAX_ENERGY);
		final prevOH = OPPONENT.HP;
		OPPONENT.HP -= Std.int(attack.baseDamage * energyDiv / ((defence) ? 2 : 1));
		{
			if (prevOH != OPPONENT.HP)
			{
				// sfx goes here
				FlxFlicker.stopFlickering(OPPONENT);
				OPPONENT.playAnimation('defence', 0.25);
				FlxFlicker.flicker(OPPONENT, 1, 0.05, true, true, flicker ->
				{
					if (OPPONENT.HP <= 0)
					{
						OPPONENT.playAnimation('death', 0.8);
						deadEnemy();
					}
					else
					{
						OPPONENT.playAnimation('idle');
					}
				});
			}
		}

		PLAYER.playAnimation('atk${attack.id}', 0.25);
		PLAYER.ENERGY -= 1;

		if (OPPONENT.HP < 0)
		{
			OPPONENT.playAnimation('death', 0.8);
			deadEnemy();
		}
		if (PLAYER.ENERGY < 0)
		{
			PLAYER.ENERGY = 0;
		}

		if (FlxG.random.bool(FlxG.random.int(0, 100)) || defence)
		{
			opMove();
		}
	}

	public function deadEnemy()
	{
		final energyIncrease = 5 * Std.int(PLAYER.ENERGY / PLAYER.MAX_ENERGY);

		PLAYER.LEVEL++;
		PLAYER.HP += energyIncrease;
		PLAYER.MAX_ENERGY += energyIncrease;

		if (PLAYER.LEVEL > 20 || energyIncrease == 0)
		{
			PLAYER.LEVEL--;
			PLAYER.HP -= energyIncrease;
			PLAYER.MAX_ENERGY -= energyIncrease;
		}

		FlxG.switchState(() -> new PlayState(PLAYER_CHARACTER_NAME, OPPONENT_CHARACTER_NAME));
	}

	public function defence()
	{
		trace('--------def--------');
		PLAYER_LAST_MOVES += DEF_MOVE;

		PLAYER.playAnimation('defence', 0.25);
		if (FlxG.random.bool(FlxG.random.int(25, 50)))
		{
			PLAYER.ENERGY++;
			if (PLAYER.ENERGY > PLAYER.MAX_ENERGY)
				PLAYER.ENERGY--;
			else
				trace('Increased energy');
		}
		else
			trace('Did nothing');

		if (FlxG.random.bool(FlxG.random.int(0, 100)))
		{
			opMove(true);
		}
	}

	public function opMove(playerDefend:Bool = false)
	{
		trace('------op-move------');
		var attack = false;

		attack = FlxG.random.bool(FlxG.random.int(0, 100)) ? true : attack;
		attack = OPPONENT.LEVEL > PLAYER.LEVEL ? true : attack;
		attack = OPPONENT.ENERGY > PLAYER.ENERGY ? true : attack;
		attack = PLAYER.HP == 1 ? true : attack;
		attack = OPPONENT_NEXT_MOVE == ATK_MOVE ? true : attack;
		attack = OPPONENT.ENERGY == 0 ? false : attack;
		attack = OPPONENT_NEXT_MOVE == DEF_MOVE ? false : attack;

		trace('Opponent attacking: $attack');

		if (attack)
		{
			// Gather all attacks
			var attacks = [OPPONENT.data.attack1, OPPONENT.data.attack2, OPPONENT.data.attack3];

			// Score each attack based on situation
			function scoreAttack(attack:CharacterAttackInformation):Int
			{
				var score = attack.baseDamage;

				if (attack.baseDamage > PLAYER.HP)
					score += 10; // Can KO player
				if (OPPONENT.ENERGY > PLAYER.ENERGY && attack.baseDamage < PLAYER.HP)
					score += 5; // Flex
				if (PLAYER.HP > OPPONENT.HP && PLAYER.LEVEL > OPPONENT.LEVEL && PLAYER.ENERGY > OPPONENT.ENERGY)
					score += 3; // Fear
				if (OPPONENT.HP < PLAYER.HP && attack.baseDamage < PLAYER.HP)
					score += 2; // Overconfident

				return score;
			}

			// Pick the attack with the highest score
			var bestAttack = attacks[0];
			var bestScore = scoreAttack(bestAttack);
			for (a in attacks)
			{
				var s = scoreAttack(a);
				trace('attack "${a.name}", score: $s');

				if (s > bestScore)
				{
					bestAttack = a;
					bestScore = s;
				}
			}
			var val = bestAttack.baseDamage;

			final energyDiv = (OPPONENT.ENERGY / OPPONENT.MAX_ENERGY);
			final prevPH = PLAYER.HP;
			PLAYER.playAnimation('defence', 0.25);
			PLAYER.HP -= Std.int(val / ((playerDefend) ? (2 * energyDiv) : (1 * energyDiv)));
			{
				if (prevPH != PLAYER.HP)
				{
					// sfx goes here
					FlxFlicker.stopFlickering(PLAYER);
					FlxFlicker.flicker(PLAYER, 1, 0.05, true, true, flicker ->
					{
						if (PLAYER.HP <= 0)
						{
							PLAYER.playAnimation('death', 0.8);
							deadPlayer();
						}
						else
						{
							PLAYER.playAnimation('idle');
						}
					});
				}
			}

			OPPONENT.playAnimation('atk${bestAttack.id}', 0.25);
			OPPONENT.ENERGY -= 1;

			if (PLAYER.HP < 0)
			{
				PLAYER.playAnimation('death', 0.8);
				deadPlayer();
			}
			if (OPPONENT.ENERGY < 0)
			{
				OPPONENT.ENERGY = 0;
			}
		}

		OPPONENT_NEXT_MOVE = '';
		trace('----op-move-end----');
	}

	public function deadPlayer()
	{
		PLAYER.HP = 0;
		instance = null;
		// TODO: Show death screen, maybe a substate for it?
		FlxG.switchState(() -> new PlayState(PLAYER_CHARACTER_NAME, OPPONENT_CHARACTER_NAME));
	}

	public function checkMovePatterns(?setONM = true):Bool
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

		final patternStrings = MovePatternGenerator.generateFilteredPatterns([4]);

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
				if (setONM)
				{
					if (pattern.endsWith(ATK_MOVE))
						OPPONENT_NEXT_MOVE = ATK_MOVE;
					if (pattern.endsWith(DEF_MOVE))
						OPPONENT_NEXT_MOVE = DEF_MOVE;
				}

				if (FlxG.random.bool(FlxG.random.float(0, 4) * 25)) // player may deviate
				{
					trace('Decided usage pattern: "$pattern"');

					break;
				}
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
			attackbtn.visible = ATTACK_SELECT && !(PLAYER.HP < 1) && !(OPPONENT.HP < 1);
		}

		ATTACK_SELECT_BUTTON.visible = !ATTACK_SELECT && PLAYER.ENERGY > 0 && !(PLAYER.HP < 1) && !(OPPONENT.HP < 1);
		DEFENCE_BUTTON.visible = !ATTACK_SELECT && !(PLAYER.HP < 1) && !(OPPONENT.HP < 1);

		PLAYER_TEXT.text = 'HP: ${PLAYER.HP}/${PLAYER.MAX_HP}' + '\nENERGY: ${PLAYER.ENERGY}/${PLAYER.MAX_ENERGY}' + '\nLEVEL: ${PLAYER.LEVEL}';
		OPPONENT_TEXT.text = 'HP: ${OPPONENT.HP}/${OPPONENT.MAX_HP}' + '\nENERGY: ${OPPONENT.ENERGY}/${OPPONENT.MAX_ENERGY}' + '\nLEVEL: ${OPPONENT.LEVEL}';
	}
}
