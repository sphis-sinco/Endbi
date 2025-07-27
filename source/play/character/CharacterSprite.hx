package play.character;

import flixel.graphics.FlxGraphic;

/**
 * Represents a character sprite with animation and stats.
 */
class CharacterSprite extends FlxSprite
{
	/** Map of animation keys to asset paths. */
	public var graphics:Map<String, String> = [];

	/** Character data reference. */
	public var data:CharacterData = null;

	public var HP:Float = 0;
	public var MAX_HP:Float = 0;
	public var ENERGY:Float = 0;
	public var MAX_ENERGY:Float = 0;
	public var LEVEL:Int = 0;

	var currentAnim:String = 'idle';
	var animTimer:Float = 0;
	var animDuration:Float = 0;
	var animPlaying:Bool = false;
	var animQueue:String = null;

	/**
	 * Constructor for CharacterSprite.
	 * @param data CharacterData object
	 */
	override public function new(data:CharacterData)
	{
		super(0, 0);
		this.data = data;
		reload();
	}

	/**
	 * Reloads character stats and asset paths from data.
	 */
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
		graphics.set('idle', '${prefix}${data.assetFolder}/${data.assetNames?.idle ?? 'idle'}${suffix}');
		graphics.set('defence', '${prefix}${data.assetFolder}/${data.assetNames?.defence ?? 'defence'}${suffix}');
		graphics.set('death', '${prefix}${data.assetFolder}/${data.assetNames?.death ?? 'death'}${suffix}');
		graphics.set('atk1', '${prefix}${data.assetFolder}/${data.assetNames?.atk1 ?? 'atk1'}${suffix}');
		graphics.set('atk2', '${prefix}${data.assetFolder}/${data.assetNames?.atk2 ?? 'atk2'}${suffix}');
		graphics.set('atk3', '${prefix}${data.assetFolder}/${data.assetNames?.atk3 ?? 'atk3'}${suffix}');
		playAnimation('idle');
	}

	/**
	 * Loads a sprite asset by key and sets scale.
	 * @param key Animation key
	 */
	public function loadAsset(key:String)
	{
		var path = graphics.get(key);
		if (path == null)
		{
			trace('Warning: Graphic path for key "$key" not found in graphics map.');
			return;
		}
		loadGraphic(path);
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
		animDuration = duration != null ? duration : (key == 'death' ? 0.8 : 0.3);
	}

	/**
	 * Stops the current animation and returns to idle.
	 */
	public function stopAnimation()
	{
		animPlaying = false;
		animTimer = 0;
		animDuration = 0;
		animQueue = null;
		playAnimation('idle');
	}

	/**
	 * Updates animation timers and handles animation transitions.
	 * @param elapsed Time since last update
	 */
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
				else if (currentAnim != 'idle')
				{
					playAnimation('idle');
				}
			}
		}
	}
}
