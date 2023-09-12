class BTP_Stopwatch_Trigger extends Triggers;

var PlayerPawn PlayerPawn;
var BTP_Stopwatch_Main Stopwatch_Main;

var int Id;

var float SpawnTimestamp;
var float TempBestTime;
var float BestTime;

var float TriggerTime;

function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
}

function Init(int aId, float aSpawnTimestamp, BTP_Stopwatch_Main aMain)
{
	Id = aId;
	SpawnTimestamp = aSpawnTimestamp;
	Stopwatch_Main = aMain;

	SetVisuals();
}

function SetVisuals()
{
	Mesh			= LodMesh'Botpack.UTRingex';
	// Skin			= Texture'CPFlag';
	Style			= STY_Normal;
	DrawScale		= 1.0;
	bMeshEnviromap	= false;

	// LoopAnim('Explo');
}

function SetSpawnTimestamp(float aSpawnTimestamp)
{
    SpawnTimestamp = aSpawnTimestamp;
	TempBestTime = 0;
}

function ResetBestTime()
{
	BestTime = 0;
}

function SetNewBestTime()
{
	BestTime = TempBestTime;
}

function Print()
{
	PlayerPawn.ClientMessage("[BTPog/Stopwatch] Index = " $ Id $ ", BestTime = " $ class'BTP_Misc_Utils'.static.FloatToString(BestTime, Stopwatch_Main.ClientConfigDto.PrecisionDecimals)
								$ "Location = (" $ class'BTP_Misc_Utils'.static.ToStringWithoutDecimals(Location) $ ")");
}

function Touch(Actor Other)
{
	local float NewTime;

	if (PlayerPawn == Other)
	{
		if (Stopwatch_Main.ClientConfigDto.ReTriggerDelay > 0)
		{
			if (Level.TimeSeconds - TriggerTime < Stopwatch_Main.ClientConfigDto.ReTriggerDelay)
				return;
			TriggerTime = Level.TimeSeconds;
		}

		NewTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;
		if (Stopwatch_Main.ClientConfigDto.DisplayTimes) PrintTime(NewTime);
		
		if (NewTime < TempBestTime || TempBestTime == 0)
			TempBestTime = NewTime;
	}
}

function PrintTime(float NewTime)
{
	local int TruncatedNewTime, TruncatedBestTime;
	
	TruncatedNewTime = int(NewTime * (10**Stopwatch_Main.ClientConfigDto.PrecisionDecimals));
	TruncatedBestTime = int(BestTime * (10**Stopwatch_Main.ClientConfigDto.PrecisionDecimals));

	ClientProgressMessage(
		class'BTP_Misc_Utils'.static.FloatToString(NewTime, Stopwatch_Main.ClientConfigDto.PrecisionDecimals),
		class'BTP_Misc_Utils'.static.FloatToDeltaString((TruncatedNewTime - TruncatedBestTime) / (10**Stopwatch_Main.ClientConfigDto.PrecisionDecimals), Stopwatch_Main.ClientConfigDto.PrecisionDecimals),
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
		Message = Message $ " (" $ StopwatchDelta $ ")";
		PlayerPawn.SetProgressColor(Color, 6);
	}

    PlayerPawn.SetProgressMessage(Message, 6);
	PlayerPawn.ClientMessage("[BTPog/Stopwatch] " $ Id $ ": " $ Message);
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
	CollisionRadius=60
	CollisionHeight=30

	AmbientGlow=64
	bHidden=false
	bStatic=false
	bNoDelete=false
	bUnlit=false
	bMovable=true
	bCollideActors=true
	bCollideWhenPlacing=false
	bMeshEnviromap=true
	LightBrightness=255
	LightHue=191
	LightSaturation=64
	LightEffect=LE_Shock
	LightRadius=0
	LightType=LT_Steady
	DrawType=DT_Mesh
	Style=STY_Translucent
	DrawScale=1
	
	bOnlyOwnerSee=True
}
