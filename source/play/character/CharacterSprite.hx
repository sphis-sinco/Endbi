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

	var currentAnim:String = "idle";
	var animTimer:Float = 0;
	var animDuration:Float = 0;
	var animPlaying:Bool = false;
	var animQueue:String = null;

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

		playAnimation('idle');
	}

	public function loadAsset(key:String)
	{
		loadGraphic(graphics.get(key));
		scale.set(4, 4);
	}

	/**
	 * Play a character animation (single-frame, swaps sprite, then returns to idle after duration)
	 * @param key Animation key (idle, atk1, atk2, atk3, defence, death)
	 * @param duration Time in seconds to show animation before returning to idle (default: 0.3, death: 0.8)
	 * @param queueAfterIdle If true, will play after current animation ends
	 */
	public function playAnimation(key:String, ?duration:Float, ?queueAfterIdle:Bool = false)
	{
		if (animPlaying && queueAfterIdle)
		{
			animQueue = key;
			return;
		}
		currentAnim = key;
		loadAsset(key);
		animPlaying = true;
		animTimer = 0;
		animDuration = duration != null ? duration : (key == "death" ? 0.8 : 0.3);
	}

	public function stopAnimation()
	{
		animPlaying = false;
		animTimer = 0;
		animDuration = 0;
		animQueue = null;
		playAnimation("idle");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (animPlaying)
		{
			animTimer += elapsed;
			if (animTimer >= animDuration)
			{
				animPlaying = false;
				animTimer = 0;
				if (animQueue != null)
				{
					var next = animQueue;
					animQueue = null;
					playAnimation(next);
				}
				else if (currentAnim != "idle")
				{
					playAnimation("idle");
				}
			}
		}
	}
}
