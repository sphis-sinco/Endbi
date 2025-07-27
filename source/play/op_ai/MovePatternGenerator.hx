package play.op_ai;

/**
 * Generates move patterns for opponent AI prediction.
 */
class MovePatternGenerator
{
	/** List of move keys to use for pattern generation. */
	public static var keys = ['a', 'd'];

	/**
	 * Generates filtered move patterns of specified lengths.
	 * @param lengths Array of pattern lengths (default: [2,4,6,8])
	 * @return Array of unique move patterns
	 */
	public static function generateFilteredPatterns(lengths:Null<Array<Int>> = null):Array<String>
	{
		var result:Array<String> = [];
		var seen:Map<String, Bool> = new Map();
		var lens = lengths;
		lens ??= [2, 4, 6, 8];
		for (length in lens)
			generateCombinations('', length, result, seen);
		return result;
	}

	/**
	 * Recursively generates all move combinations of a given length, filtering out redundant prefixes.
	 * @param current Current pattern string
	 * @param maxLength Target pattern length
	 * @param result Array to store results
	 * @param seen Map to track seen patterns
	 */
	public static function generateCombinations(current:String, maxLength:Int, result:Array<String>, seen:Map<String, Bool>)
	{
		if (current.length == maxLength)
		{
			// Check if any smaller even-length prefix already exists
			var skip = false;
			var prefixLength = 2;
			while (prefixLength < maxLength)
			{
				var prefix = current.substr(0, prefixLength);
				if (seen.exists(prefix))
				{
					skip = true;
					break;
				}
				prefixLength += 2;
			}
			if (!skip)
			{
				result.push(current);
				seen.set(current, true);
			}
			return;
		}
		for (k in keys)
			generateCombinations(current + k, maxLength, result, seen);
	}

	/**
	 * Debug: Prints all generated patterns to the console.
	 */
	public static function main()
	{
		var patterns = generateFilteredPatterns();
		for (p in patterns)
			trace(p);
	}
}
