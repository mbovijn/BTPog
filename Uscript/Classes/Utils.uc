class Utils extends Object;

static function string GetArgument(string FullString, int ArgumentNumber)
{
	return GetStringPart(FullString, ArgumentNumber, " ");
}

static function string GetStringPart(string FullString, int PartNumber, string Delimiter)
{
	if (PartNumber == 0)
	{
		if (InStr(FullString, Delimiter) == -1)
		{
			return FullString;
		}
		else
		{
			return Left(FullString, InStr(FullString, Delimiter));
		}
	}
	if (InStr(FullString, Delimiter) == -1) return "";
	return GetStringPart(Mid(FullString, InStr(FullString, Delimiter) + 1), PartNumber - 1, Delimiter);
}

static function string TimeDeltaToString(float TimeDelta)
{
	// Multiplier to account for time dilation on hardcore mode.
	return FloatToString(0.90909090909 * TimeDelta);
}

static function string FloatToString(float Number)
{
	return Left(Number, InStr(Number, ".") + 4);
}
