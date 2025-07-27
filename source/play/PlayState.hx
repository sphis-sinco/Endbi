package play;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import play.BattleManager;
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
	public var battleManager:BattleManager;

	override public function new(player:String, op:String = 'jujer')
	{
		super();

		FlxG.camera.flash(0xFF000000, 0.5, true);

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

		battleManager = new BattleManager(PLAYER, OPPONENT, ATK_MOVE, DEF_MOVE, PLAYER_LAST_MOVES, OPPONENT_NEXT_MOVE);
		instance = this;
	}

	public function attackOp(attack:CharacterAttackInformation)
	{
		trace('--------atk--------');
		PLAYER_LAST_MOVES += ATK_MOVE;
		ATTACK_SELECT = false;
		var defence = false;
		var def_reason:String = '';
		final usingPattern:Bool = battleManager.checkMovePatterns();
		if (FlxG.random.float(0, 4) >= 3.5)
			def_reason = 'random chance';
		else if (usingPattern && FlxG.random.float(0, 2) >= 1.5)
			def_reason = 'player has been predicted';
		defence = def_reason != '';
		if (defence)
			trace('Opponent defended: $def_reason');
		battleManager.applyAttackToOpponent(attack, defence, deadEnemy);
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
		trace('OPPONENT DEATH');
		final energyIncrease = 5 * (PLAYER.ENERGY / PLAYER.MAX_ENERGY);

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
		battleManager.handleDefenceHealth();
		battleManager.handleDefenceEnergy();
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
			var bestAttack = battleManager.selectBestOpponentAttack();
			battleManager.applyAttackToPlayer(bestAttack, playerDefend, deadPlayer);
		}
		OPPONENT_NEXT_MOVE = '';
		trace('----op-move-end----');
	}

	public function deadPlayer()
	{
		trace('PLAYER DEATH');
		PLAYER.HP = 0;
		instance = null;
		// TODO: Show death screen, maybe a substate for it?
		FlxG.switchState(() -> new PlayState(PLAYER_CHARACTER_NAME, OPPONENT_CHARACTER_NAME));
	}

	// Removed: now handled by BattleManager
	// Helper function for rounding to 1 decimal place
	inline public static function round1(x:Float):Float
		return Math.fround(x * 10) / 10;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (attackbtn in ATTACK_BUTTONS.members)
		{
			attackbtn.visible = ATTACK_SELECT && !(round1(PLAYER.HP) <= 0) && !(round1(OPPONENT.HP) <= 0);
		}

		ATTACK_SELECT_BUTTON.visible = !ATTACK_SELECT && round1(PLAYER.ENERGY) > 0 && !(round1(PLAYER.HP) <= 0) && !(round1(OPPONENT.HP) <= 0);
		DEFENCE_BUTTON.visible = !ATTACK_SELECT && !(round1(PLAYER.HP) <= 0) && !(round1(OPPONENT.HP) <= 0);

		PLAYER_TEXT.text = 'HP: ' + round1(PLAYER.HP) + '/' + round1(PLAYER.MAX_HP) + '\nENERGY: ' + round1(PLAYER.ENERGY) + '/' + round1(PLAYER.MAX_ENERGY)
			+ '\nLEVEL: ' + PLAYER.LEVEL;
		OPPONENT_TEXT.text = 'HP: ' + round1(OPPONENT.HP) + '/' + round1(OPPONENT.MAX_HP) + '\nENERGY: ' + round1(OPPONENT.ENERGY) + '/'
			+ round1(OPPONENT.MAX_ENERGY) + '\nLEVEL: ' + OPPONENT.LEVEL;
	}
}
