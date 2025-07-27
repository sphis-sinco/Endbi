package play.character;

import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;

class CharacterSprite extends FlxSprite
{
	public var graphics:Map<String, FlxGraphic> = [];

	public var data:CharacterData = null;

	override public function new(data:CharacterData)
	{
		super(0, 0);
		this.data = data;

		reload();
	}

	public function reload()
	{
		graphics = [];

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
	}
}
