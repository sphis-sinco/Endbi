package play;

import flixel.effects.FlxFlicker;
import play.character.CharacterSprite;
import play.op_ai.MovePatternGenerator;

class BattleManager
{
	public var PLAYER:CharacterSprite;
	public var OPPONENT:CharacterSprite;
	public var ATK_MOVE:String;
	public var DEF_MOVE:String;
	public var PLAYER_LAST_MOVES:String;
	public var OPPONENT_NEXT_MOVE:String;

	public function new(PLAYER:CharacterSprite, OPPONENT:CharacterSprite, ATK_MOVE:String, DEF_MOVE:String, PLAYER_LAST_MOVES:String, OPPONENT_NEXT_MOVE:String)
	{
		this.PLAYER = PLAYER;
		this.OPPONENT = OPPONENT;
		this.ATK_MOVE = ATK_MOVE;
		this.DEF_MOVE = DEF_MOVE;
		this.PLAYER_LAST_MOVES = PLAYER_LAST_MOVES;
		this.OPPONENT_NEXT_MOVE = OPPONENT_NEXT_MOVE;
	}

	public function applyAttackToOpponent(attack:Dynamic, defence:Bool, onDeath:Void->Void)
	{
		final energyDiv = (PLAYER.ENERGY / PLAYER.MAX_ENERGY);
		final prevOH = OPPONENT.HP;
		OPPONENT.HP -= (attack.baseDamage * energyDiv / ((defence) ? 2 : 1));
		if (prevOH != OPPONENT.HP)
		{
			FlxFlicker.stopFlickering(OPPONENT);
			OPPONENT.playAnimation('defence', 0.25);
			FlxFlicker.flicker(OPPONENT, 1, 0.05, true, true, flicker ->
			{
				if (PlayState.round1(OPPONENT.HP) <= 0)
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

	public function applyAttackToPlayer(attack:Dynamic, playerDefend:Bool, onDeath:Void->Void)
	{
		var val = attack.baseDamage;
		final energyDiv = (OPPONENT.ENERGY / OPPONENT.MAX_ENERGY);
		final prevPH = PLAYER.HP;
		PLAYER.playAnimation('defence', 0.25);
		PLAYER.HP -= (val / ((playerDefend) ? (2 * energyDiv) : (1 * energyDiv)));
		if (prevPH != PLAYER.HP)
		{
			FlxFlicker.stopFlickering(PLAYER);
			FlxFlicker.flicker(PLAYER, 1, 0.05, true, true, flicker ->
			{
				if (PlayState.round1(PLAYER.HP) <= 0)
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
		OPPONENT.ENERGY -= 1;
		if (PLAYER.HP < 0)
		{
			PLAYER.playAnimation('death', 0.8);
			onDeath();
		}
		if (OPPONENT.ENERGY < 0)
		{
			OPPONENT.ENERGY = 0;
		}
	}

	public function selectBestOpponentAttack():Dynamic
	{
		var attacks = [OPPONENT.data.attack1, OPPONENT.data.attack2, OPPONENT.data.attack3];
		function scoreAttack(attack:Dynamic):Int
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

	public function handleDefenceEnergy()
	{
		if (FlxG.random.bool(FlxG.random.int(25, 50)))
		{
			PLAYER.ENERGY++;
			if (PLAYER.ENERGY > PLAYER.MAX_ENERGY)
				PLAYER.ENERGY--;
		}
	}

	public function handleDefenceHealth()
	{
		if (FlxG.random.bool(FlxG.random.int(25, 50)))
		{
			PLAYER.HP++;
			if (PLAYER.HP > PLAYER.MAX_HP)
				PLAYER.HP--;
		}
	}

	public function checkMovePatterns(?setONM = true):Bool
	{
		final movesList = PLAYER_LAST_MOVES.toString();
		final two_movesList = movesList.substring(movesList.length - 2, movesList.length);
		final four_movesList = movesList.substring(movesList.length - 4, movesList.length);
		final six_movesList = movesList.substring(movesList.length - 6, movesList.length);
		final eight_movesList = movesList.substring(movesList.length - 8, movesList.length);
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
				if (FlxG.random.bool(FlxG.random.float(0, 4) * 25))
				{
					break;
				}
			}
		}
		return usingPattern;
	}
}
