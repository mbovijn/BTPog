class BTP_Misc_Utils extends Object;

static function string GetRemainingArguments(string FullString)
{
	if (InStr(FullString, " ") == -1)
	{
		return "";
	}
	else
	{
		return Right(FullString, Len(FullString) - InStr(FullString, " ") - 1);
	}
}

static function string GetFirstArgument(string FullString)
{
	return GetArgument(FullString, 0);
}

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

static function string TimeDeltaToString(float TimeDelta, float TimeDilation)
{
	return FloatToString(TimeDelta / TimeDilation, 3);
}

static function string FloatToString(float Number, int Decimals)
{
	if (Decimals == 0)
		return Left(Number, InStr(Number, "."));
	else
		return Left(Number, InStr(Number, ".") + 1 + Decimals);
}

static function string FloatToDeltaString(float Number, int Decimals)
{
	if (Number >= 0)
		return "+"$FloatToString(Number, Decimals);
	else
		return FloatToString(Number, Decimals);
}

static function string ToStringWithoutDecimals(Vector Vector)
{
	return int(Vector.X)$","$int(Vector.Y)$","$int(Vector.Z);
}

static function Vector ToVector(String VectorString)
{
	local Vector NewVector;
	NewVector.X = int(class'BTP_Misc_Utils'.static.GetStringPart(VectorString, 0, ","));
	NewVector.Y = int(class'BTP_Misc_Utils'.static.GetStringPart(VectorString, 1, ","));
	NewVector.Z = int(class'BTP_Misc_Utils'.static.GetStringPart(VectorString, 2, ","));
	return NewVector;
}

static function Vector RemoveDecimalsFromVector(Vector OldVector)
{
	local Vector NewVector;
	NewVector.X = int(OldVector.X);
	NewVector.Y = int(OldVector.Y);
	NewVector.Z = int(OldVector.Z);
	return NewVector;
}

static function String GenerateUniqueId()
{
	const KeyChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	const IdLength = 24;

	local string Id;
	local int Index;

	for (Index = 0; Index < IdLength; Index++)
	{
		Id = Id $ mid(KeyChars, rand(len(KeyChars)), 1);
	}

	return Id;
}

static function string GetMapName(LevelInfo LevelInfo)
{
    return Left(string(LevelInfo), InStr(string(LevelInfo), "."));
}