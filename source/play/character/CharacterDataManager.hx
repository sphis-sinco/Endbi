package play.character;

import play.character.CharacterData.CharacterAttackInformation;

class CharacterDataManager
{
	static final defaultAttackInformation:CharacterAttackInformation = {
		baseDamage: 1,
		name: 'Default Attack'
	};

	public static function getCharacterJsonFile(character:String):CharacterData
	{
		var data:CharacterData = {
			assetFolder: null,
			assetNames: {
				idle: null,
				defence: null,
				death: null,
				atk1: null,
				atk2: null,
				atk3: null,
			},
			attack1: null,
			attack2: null,
			attack3: null,

			max_health: null,
			max_energy: null,
			level: null
		};

		if (character == 'jujer')
		{
			data.assetFolder = 'jujer';
		}
		else if (character == 'tempChar')
		{
			data.assetFolder = 'tempChar';
		}
		else
		{
			trace('Unknown character: ${character}');
		}

		data.assetFolder ??= 'tempChar';

		data.assetNames.idle ??= 'idle';
		data.assetNames.defence ??= 'defence';
		data.assetNames.death ??= 'death';
		data.assetNames.atk1 ??= 'atk1';
		data.assetNames.atk2 ??= 'atk2';
		data.assetNames.atk3 ??= 'atk3';

		if (data.assetFolder == 'tempChar')
		{
			data.assetNames = null;
		}

		data.attack1 ??= defaultAttackInformation;
		data.attack2 ??= defaultAttackInformation;
		data.attack3 ??= defaultAttackInformation;

		data.max_health ??= 5;
		data.max_energy ??= 5;
		data.level ??= 1;

		return data;
	}

	public static function getCharacterJson(character:String):CharacterData
	{
		var returnJson:CharacterData = null;

		returnJson = getCharacterJsonFile(character);

		return returnJson;
	}
}
