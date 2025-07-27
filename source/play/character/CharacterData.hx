package play.character;

typedef CharacterData =
{
	var assetFolder:String;
	var assetNames:
		{
			var idle:String;
			var defence:String;
			var death:String;
			var atk1:String;
			var atk2:String;
			var atk3:String;
		};

	var attack1:CharacterAttackInformation;
	var attack2:CharacterAttackInformation;
	var attack3:CharacterAttackInformation;
}

typedef CharacterAttackInformation =
{
	var name:String;
	var baseDamage:Int;
}
