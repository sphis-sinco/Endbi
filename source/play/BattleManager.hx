package play;

import flixel.effects.FlxFlicker;
import play.character.CharacterSprite;
import play.op_ai.MovePatternGenerator;

/**
 * Manages battle logic between player and opponent.
 * Handles attacks, defence, and move pattern prediction.
 */
class BattleManager
{
	/** Player and opponent character references. */
	public var PLAYER:CharacterSprite;

	public var OPPONENT:CharacterSprite;
	public var ATK_MOVE:String;
	public var DEF_MOVE:String;
	public var PLAYER_LAST_MOVES:String;
	public var OPPONENT_NEXT_MOVE:String;

	/**
	 * Constructor for BattleManager.
	 * @param PLAYER Player character
	 * @param OPPONENT Opponent character
	 * @param ATK_MOVE Attack move key
	 * @param DEF_MOVE Defence move key
	 * @param PLAYER_LAST_MOVES Player's move history
	 * @param OPPONENT_NEXT_MOVE Opponent's next move
	 */
	public function new(PLAYER:CharacterSprite, OPPONENT:CharacterSprite, ATK_MOVE:String, DEF_MOVE:String, PLAYER_LAST_MOVES:String, OPPONENT_NEXT_MOVE:String)
	{
		this.PLAYER = PLAYER;
		this.OPPONENT = OPPONENT;
		this.ATK_MOVE = ATK_MOVE;
		this.DEF_MOVE = DEF_MOVE;
		this.PLAYER_LAST_MOVES = PLAYER_LAST_MOVES;
		this.OPPONENT_NEXT_MOVE = OPPONENT_NEXT_MOVE;
	}

	/**
	 * Applies an attack to the opponent, handling flicker and death.
	 * @param attack Attack data
	 * @param defence Whether opponent is defending
	 * @param onDeath Callback if opponent dies
	 */
	public function applyAttackToOpponent(attack:Dynamic, defence:Bool, onDeath:Void->Void)
	{
		final energyDiv = (PLAYER.ENERGY / PLAYER.MAX_ENERGY);
		final prevOH = OPPONENT.HP;
		OPPONENT.HP -= (attack.baseDamage * energyDiv / (defence ? 2 : 1));
		if (prevOH != OPPONENT.HP)
		{
			FlxFlicker.stopFlickering(OPPONENT);
			OPPONENT.playAnimation('defence', 0.25);
			FlxFlicker.flicker(OPPONENT, 1, 0.05, true, true, flicker ->
			{
				if (OPPONENT.HP <= 0)
				{
					OPPONENT.playAnimation('death', 0.8);
					onDeath();
				}
				else
				{
					OPPONENT.playAnimation('idle');
				}
			});
		}
	}

	/**
	 * Applies an attack to the player, handling flicker and death.
	 * @param attack Attack data
	 * @param playerDefend Whether player is defending
	 * @param onDeath Callback if player dies
	 */
	public function applyAttackToPlayer(attack:Dynamic, playerDefend:Bool, onDeath:Void->Void)
	{
		var val = attack.baseDamage;
		final energyDiv = (OPPONENT.ENERGY / OPPONENT.MAX_ENERGY);
		final prevPH = PLAYER.HP;
		PLAYER.playAnimation('defence', 0.25);
		PLAYER.HP -= (val / (playerDefend ? (2 * energyDiv) : (1 * energyDiv)));
		if (prevPH != PLAYER.HP)
		{
			FlxFlicker.stopFlickering(PLAYER);
			FlxFlicker.flicker(PLAYER, 1, 0.05, true, true, flicker ->
			{
				if (PLAYER.HP <= 0)
				{
					PLAYER.playAnimation('death', 0.8);
					onDeath();
				}
				else
				{
					PLAYER.playAnimation('idle');
				}
			});
		}
		OPPONENT.playAnimation('atk${attack.id}', 0.25);
		OPPONENT.ENERGY = Math.max(0, OPPONENT.ENERGY - 1);
		if (PLAYER.HP < 0)
		{
			PLAYER.playAnimation('death', 0.8);
			onDeath();
		}
	}

	/**
	 * Selects the best attack for the opponent based on a scoring system.
	 * @return The best attack
	 */
	public function selectBestOpponentAttack():Dynamic
	{
		var attacks = [OPPONENT.data.attack1, OPPONENT.data.attack2, OPPONENT.data.attack3];
		inline function scoreAttack(attack:Dynamic):Int
		{
			var score = attack.baseDamage;
			if (attack.baseDamage > PLAYER.HP)
				score += 10;
			if (OPPONENT.ENERGY > PLAYER.ENERGY && attack.baseDamage < PLAYER.HP)
				score += 5;
			if (PLAYER.HP > OPPONENT.HP && PLAYER.LEVEL > OPPONENT.LEVEL && PLAYER.ENERGY > OPPONENT.ENERGY)
				score += 3;
			if (OPPONENT.HP < PLAYER.HP && attack.baseDamage < PLAYER.HP)
				score += 2;
			return score;
		}
		var bestAttack = attacks[0];
		var bestScore = scoreAttack(bestAttack);
		for (a in attacks)
		{
			var s = scoreAttack(a);
			if (s > bestScore)
			{
				bestAttack = a;
				bestScore = s;
			}
		}
		return bestAttack;
	}

	/**
	 * Handles energy gain for the player when defending.
	 */
	public function handleDefenceEnergy()
	{
		if (flixel.FlxG.random.bool(flixel.FlxG.random.int(25, 50)))
		{
			PLAYER.ENERGY = Math.min(PLAYER.MAX_ENERGY, PLAYER.ENERGY + 1);
		}
	}

	/**
	 * Checks for move patterns in the player's move history and predicts next move.
	 * @param setONM Whether to set the opponent's next move
	 * @return True if a pattern was found
	 */
	public function checkMovePatterns(?setONM = true):Bool
	{
		final movesList = PLAYER_LAST_MOVES.toString();
		inline function safeSub(len:Int):String
			return movesList.substring(Std.int(Math.max(0, movesList.length - len)), movesList.length);
		final two_movesList = safeSub(2);
		final four_movesList = safeSub(4);
		final six_movesList = safeSub(6);
		final eight_movesList = safeSub(8);
		final patternStrings = MovePatternGenerator.generateFilteredPatterns([4]);
		var usingPattern:Bool = false;
		for (pattern in patternStrings)
		{
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
				if (flixel.FlxG.random.bool(flixel.FlxG.random.float(0, 4) * 25))
					break;
			}
		}
		return usingPattern;
	}
}
