class BTP_Stopwatch_Trigger extends Triggers;

var PlayerPawn PlayerPawn;
var int ID;
var int PrecisionDecimals;

var float SpawnTimestamp;
var float TempBestTime;
var float BestTime;

var float ReTriggerDelay;
var float TriggerTime;

simulated function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
}

simulated function Init(int aIndex, float aSpawnTimestamp, int aPrecisionDecimals)
{
	ID = aIndex;
	SpawnTimestamp = aSpawnTimestamp;
	PrecisionDecimals = aPrecisionDecimals;
}

simulated function SetSpawnTimestamp(float aSpawnTimestamp)
{
    SpawnTimestamp = aSpawnTimestamp;
	TempBestTime = 0;
}

simulated function ResetBestTime()
{
	BestTime = 0;
}

simulated function SetNewBestTime()
{
	BestTime = TempBestTime;
}

simulated function Print()
{
	PlayerPawn.ClientMessage("[BTPog] Index = "$ID$", Location = ("$class'BTP_Misc_Utils'.static.ToStringWithoutDecimals(Location)
								$"), BestTime = "$class'BTP_Misc_Utils'.static.FloatToString(BestTime, PrecisionDecimals));
}

simulated function Touch(Actor Other)
{
	local float NewTime;

	if (PlayerPawn == Other)
	{
		if (ReTriggerDelay > 0)
		{
			if (Level.TimeSeconds - TriggerTime < ReTriggerDelay)
				return;
			TriggerTime = Level.TimeSeconds;
		}

		NewTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;
		PrintTime(NewTime);
		
		if (NewTime < TempBestTime || TempBestTime == 0)
			TempBestTime = NewTime;
	}
}

simulated function PrintTime(float NewTime)
{
	local int TruncatedNewTime, TruncatedBestTime;
	
	TruncatedNewTime = int(NewTime * (10**PrecisionDecimals));
	TruncatedBestTime = int(BestTime * (10**PrecisionDecimals));

	ClientProgressMessage(
		class'BTP_Misc_Utils'.static.FloatToString(NewTime, PrecisionDecimals),
		class'BTP_Misc_Utils'.static.FloatToDeltaString((TruncatedNewTime - TruncatedBestTime) / (10**PrecisionDecimals), PrecisionDecimals),
		DetermineTextColor(TruncatedNewTime, TruncatedBestTime)
	);
}

simulated function ClientProgressMessage(string StopwatchTime, string StopwatchDelta, Color Color)
{
	local string Message;

	PlayerPawn.ClearProgressMessages();
    PlayerPawn.SetProgressTime(2);

	Message = StopwatchTime;
	if (BestTime > 0)
	{
		Message = Message$" ("$StopwatchDelta$")";
		PlayerPawn.SetProgressColor(Color, 6);
	}

    PlayerPawn.SetProgressMessage(Message, 6);
	PlayerPawn.ClientMessage("[BTPog] Stopwatch "$ID$": "$Message);
}

simulated function Color DetermineTextColor(int TruncatedNewTime, int TruncatedBestTime)
{
	if (TruncatedNewTime <= TruncatedBestTime || TruncatedBestTime == 0)
		return Green();
	else
		return Red();
}

simulated function Color Green()
{
	local Color ColorGreen;
	ColorGreen.R = 0;
	ColorGreen.G = 255;
	ColorGreen.B = 0;
	return ColorGreen;
}

simulated function Color Red()
{
	local Color ColorRed;
	ColorRed.R = 255;
	ColorRed.G = 0;
	ColorRed.B = 0;
	return ColorRed;
}

simulated function Tick(float DeltaTime)
{
	if (Owner == None)
		Destroy();
}

defaultproperties
{
    ReTriggerDelay=2.0
	CollisionRadius=60
	CollisionHeight=30
}
