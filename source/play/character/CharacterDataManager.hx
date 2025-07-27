package play.character;

import play.character.CharacterData.CharacterAttackInformation;

class CharacterDataManager
{
	static final defaultAttackInformation:CharacterAttackInformation = {
		baseDamage: 1,
		name: 'Default Attack'
	};

	public static function getCharacterJsonFile(character:String)
	{
		switch (character)
		{
			default:
				return null;
		}

		return null;
	}

	public static function getCharacterJson(character:String):CharacterData
	{
		var returnJson:CharacterData = null;

		returnJson = getCharacterJsonFile(character);

		returnJson.assetFolder ??= 'tempChar';

		returnJson.assetNames.idle ??= 'idle';
		returnJson.assetNames.defence ??= 'defence';
		returnJson.assetNames.death ??= 'death';
		returnJson.assetNames.atk1 ??= 'atk1';
		returnJson.assetNames.atk2 ??= 'atk2';
		returnJson.assetNames.atk3 ??= 'atk3';

		if (returnJson.assetFolder == 'tempChar')
		{
			returnJson.assetNames = null;
		}

		returnJson.attack1 ??= defaultAttackInformation;
		returnJson.attack2 ??= defaultAttackInformation;
		returnJson.attack3 ??= defaultAttackInformation;

		return returnJson;
	}
}
