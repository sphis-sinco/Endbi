package play.character;

import flixel.graphics.FlxGraphic;

class CharacterSprite extends FlxSprite
{
	public var graphics:Map<String, FlxGraphic> = [];

	public var data:CharacterData = null;

	public var HP:Int = 0;
	public var MAX_HP:Int = 0;

	public var ENERGY:Int = 0;
	public var MAX_ENERGY:Int = 0;

	public var LEVEL:Int = 0;

	override public function new(data:CharacterData)
	{
		super(0, 0);
		this.data = data;

		reload();
	}

	public function reload()
	{
		graphics = [];

		MAX_HP = data.max_health;
		HP = MAX_HP;

		MAX_ENERGY = data.max_energy;
		ENERGY = MAX_ENERGY;

		LEVEL = data.level;

		final prefix:String = 'assets/images/characters/';
		final suffix:String = '.png';

		graphics.set('idle', FlxGraphic.fromAssetKey('${prefix}${data.assetFolder}/${data.assetNames?.idle ?? 'idle'}${suffix}'));
		graphics.set('defence', FlxGraphic.fromAssetKey('${prefix}${data.assetFolder}/${data.assetNames?.defence ?? 'defence'}${suffix}'));
		graphics.set('death', FlxGraphic.fromAssetKey('${prefix}${data.assetFolder}/${data.assetNames?.death ?? 'death'}${suffix}'));

		graphics.set('atk1', FlxGraphic.fromAssetKey('${prefix}${data.assetFolder}/${data.assetNames?.atk1 ?? 'atk1'}${suffix}'));
		graphics.set('atk2', FlxGraphic.fromAssetKey('${prefix}${data.assetFolder}/${data.assetNames?.atk2 ?? 'atk2'}${suffix}'));
		graphics.set('atk3', FlxGraphic.fromAssetKey('${prefix}${data.assetFolder}/${data.assetNames?.atk3 ?? 'atk3'}${suffix}'));

		loadAsset('idle');
	}

	public function loadAsset(key:String)
	{
		loadGraphic(graphics.get(key));

		scale.set(4, 4);
	}
}
