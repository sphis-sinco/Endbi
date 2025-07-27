package play.character;

typedef CharacterData =
{
	var assetFolder:String;

	var attack1:CharacterAttackInformation;
	var attack2:CharacterAttackInformation;
	var attack3:CharacterAttackInformation;
}

typedef CharacterAttackInformation =
{
	var name:String;
	var baseDamage:Int;
}