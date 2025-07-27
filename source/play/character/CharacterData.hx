package play.character;

/**
 * Data structure for character stats and assets.
 */
typedef CharacterData =
{
	/** Folder name for character assets. */
	var ?assetFolder:String;

	/** Asset names for each animation state. */
	var ?assetNames:
		{
			var ?idle:String;
			var ?defence:String;
			var ?death:String;
			var ?atk1:String;
			var ?atk2:String;
			var ?atk3:String;
		};

	/** Attack 1 info. */
	var attack1:CharacterAttackInformation;

	/** Attack 2 info. */
	var attack2:CharacterAttackInformation;

	/** Attack 3 info. */
	var attack3:CharacterAttackInformation;

	/** Max health. */
	var max_health:Null<Int>;

	/** Max energy. */
	var max_energy:Null<Int>;

	/** Character level. */
	var level:Null<Int>;
}

/**
 * Data structure for a character's attack.
 */
typedef CharacterAttackInformation =
{
	/** Unique attack ID. */
	var id:Int;

	/** Name of the attack. */
	var name:String;

	/** Base damage value. */
	var baseDamage:Int;
}
