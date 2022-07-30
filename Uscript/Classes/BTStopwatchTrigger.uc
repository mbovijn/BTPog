class BTStopwatchTrigger extends Triggers;

var PlayerPawn PlayerPawn;
var int ID;
var int PrecisionDecimals;

var float PlayerSpawnTime;
var float BestTime;

var float ReTriggerDelay;
var float TriggerTime;

function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
}

function SetPlayerSpawnTime(float SpawnTime)
{
    PlayerSpawnTime = SpawnTime;
}

function ResetBestTime()
{
	BestTime = 0;
}

function Touch(Actor Other)
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

		NewTime = (Level.TimeSeconds - PlayerSpawnTime) / Level.TimeDilation;
		PrintTime(NewTime);

		if (NewTime < BestTime || BestTime == 0)
			BestTime = NewTime;
	}
}

function PrintTime(float NewTime)
{
	local int TruncatedNewTime, TruncatedBestTime;
	
	TruncatedNewTime = int(NewTime * (10**PrecisionDecimals));
	TruncatedBestTime = int(BestTime * (10**PrecisionDecimals));

	ClientProgressMessage(
		class'Utils'.static.FloatToString(NewTime, PrecisionDecimals),
		class'Utils'.static.FloatToDeltaString((TruncatedNewTime - TruncatedBestTime) / (10**PrecisionDecimals), PrecisionDecimals),
		DetermineTextColor(TruncatedNewTime, TruncatedBestTime)
	);
}

function ClientProgressMessage(string StopwatchTime, string StopwatchDelta, Color Color)
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

function Color DetermineTextColor(int TruncatedNewTime, int TruncatedBestTime)
{
	if (TruncatedNewTime <= TruncatedBestTime || TruncatedBestTime == 0)
		return Green();
	else
		return Red();
}

function Color Green()
{
	local Color ColorGreen;
	ColorGreen.R = 0;
	ColorGreen.G = 255;
	ColorGreen.B = 0;
	return ColorGreen;
}

function Color Red()
{
	local Color ColorRed;
	ColorRed.R = 255;
	ColorRed.G = 0;
	ColorRed.B = 0;
	return ColorRed;
}

function Tick(float DeltaTime)
{
	if (Owner == None)
		Destroy();
}

defaultproperties
{
    ReTriggerDelay=0.500000
}
