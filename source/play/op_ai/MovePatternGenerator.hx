package play.op_ai;

// Thanks GPT
class MovePatternGenerator
{
	public static var keys = ['a', 'd'];

	public static function generateFilteredPatterns(lengths:Null<Array<Int>> = null):Array<String>
	{
		var result:Array<String> = [];
		var seen:Map<String, Bool> = new Map();

		var lens = lengths;
		lens ??= [10];

		for (length in lens)
		{
			generateCombinations('', length, result, seen);
		}

		return result;
	}

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
		{
			generateCombinations(current + k, maxLength, result, seen);
		}
	}

	public static function main()
	{
		var patterns = generateFilteredPatterns();
		for (p in patterns)
		{
			trace(p);
		}
	}
}
