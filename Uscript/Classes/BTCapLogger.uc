class BTCapLogger extends BTCapLoggerAbstract;

var PlayerPawn PlayerPawn;
var BTCapLoggerFile BTCapLoggerFile;

var float SpawnTimestamp;
var float CapTime;

var EDodgeDir PreviousDodgeDir;
var float StoppedDodgingTimestamp;

var EPhysics PreviousPhysics; 
var float HasLandedTimeStamp;

var float PreviousDodgeClickTimer;

var bool PlayerJustSpawned;

var BTCapLoggerStats DodgeBlockStats;
var BTCapLoggerStats DodgeDoubleTapStats;
var BTCapLoggerStats DodgeAfterLandingStats;
var BTCapLoggerStats TimeBetweenDodgesStats;
var BTCapLoggerBucketedStats FPSStats;
var BTCapLoggerBucketedStats PingStats;

var int TicksPerFPSCalculation; // See BTCapLoggerSettings
var float FPSTimePassed; // Time passed in seconds since last FPS calculation
var int FPSTickCounter; // Ticks since last FPS calculation

var int SpawnCount;

var PropertyRetriever HardwareIdPropertyRetriever;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, PlayerSpawnedEvent_ToClient, PlayerCappedEvent_ToClient, ReplicateConfig_ToClient;
	reliable if (Role < ROLE_Authority)
		ReportInfo_ToServer;
}

simulated function ReplicateConfig_ToClient(float aTicksPerFPSCalculation)
{
	TicksPerFPSCalculation = aTicksPerFPSCalculation;
}

function Init(PlayerPawn aPlayerPawn, BTCapLoggerFile aBTCapLoggerFile, BTCapLoggerServerSettings aBTCapLoggerSettings)
{
	BTCapLoggerFile = aBTCapLoggerFile;
	PlayerPawn = aPlayerPawn;

	HardwareIdPropertyRetriever = Spawn(class'PropertyRetriever', PlayerPawn);
	HardwareIdPropertyRetriever.Init(PlayerPawn, "ACEReplicationInfo.hwHash");

	ReplicateConfig_ToClient(aBTCapLoggerSettings.TicksPerFPSCalculation);
}

function PlayerSpawnedEvent()
{
	SpawnTimestamp = Level.TimeSeconds;
	SpawnCount++;
	
	PlayerSpawnedEvent_ToClient();
}

simulated function PlayerSpawnedEvent_ToClient()
{
	if (DodgeBlockStats != None) DodgeBlockStats.Destroy();
	if (DodgeDoubleTapStats != None) DodgeDoubleTapStats.Destroy();
	if (DodgeAfterLandingStats != None) DodgeAfterLandingStats.Destroy();
	if (TimeBetweenDodgesStats != None) TimeBetweenDodgesStats.Destroy();
	if (FPSStats != None) FPSStats.Destroy();
	if (PingStats != None) PingStats.Destroy();

	DodgeBlockStats = Spawn(class'BTCapLoggerStats', Owner);
	DodgeDoubleTapStats = Spawn(class'BTCapLoggerStats', Owner);
	DodgeAfterLandingStats = Spawn(class'BTCapLoggerStats', Owner);
	TimeBetweenDodgesStats = Spawn(class'BTCapLoggerStats', Owner);
	FPSStats = Spawn(class'BTCapLoggerBucketedStats', Owner);
	PingStats = Spawn(class'BTCapLoggerBucketedStats', Owner);

	SpawnTimestamp = Level.TimeSeconds;
	PlayerJustSpawned = True;
}

function PlayerCappedEvent()
{
	CapTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;
	PlayerCappedEvent_ToClient();
}

simulated function PlayerCappedEvent_ToClient()
{
	CapTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;

	ReportInfo_ToServer(
		DodgeBlockStats.Analyze(),
		DodgeDoubleTapStats.Analyze(),
		DodgeAfterLandingStats.Analyze(),
		TimeBetweenDodgesStats.Analyze(),
		FPSStats.Analyze(),
		PingStats.Analyze(),
		CapTime, // ClientCapTime
		Level.EngineVersion$GetEngineRevision(), // e.g. 469c - May  4 2022 Preview,
		GetRenderer()
	);
}

function ReportInfo_ToServer(
	StatsAnalysis DodgeBlock,
	StatsAnalysis DodgeDoubleTap,
	StatsAnalysis DodgeAfterLanding,
	StatsAnalysis TimeBetweenDodges,
	StatsAnalysis FPS,
	StatsAnalysis Ping,
	float ClientCapTime,
	String ClientEngineVersion,
	String Renderer
)
{
	BTCapLoggerFile.LogCap(
		PlayerPawn,
		CapTime,
		DodgeBlock,
		DodgeDoubleTap,
		DodgeAfterLanding,
		TimeBetweenDodges,
		FPS,
		Ping,
		ClientCapTime - CapTime,
		ClientEngineVersion,
		SpawnCount,
		Renderer,
		HardwareIdPropertyRetriever.GetProperty()
		// TODO - pass in other property if defined, otherwise empty
	);
}

simulated function CustomTick(float DeltaTime)
{
	if (Role == ROLE_Authority) return;

	MeasureFPS(DeltaTime);

	if (PlayerPawn.PlayerReplicationInfo != None && PlayerPawn.PlayerReplicationInfo.Ping > 0 && PingStats != None)
		PingStats.AddValue(PlayerPawn.PlayerReplicationInfo.Ping, PlayerPawn.PlayerReplicationInfo.Ping);
    
	if (HasStartedDodging())
	{
		// Using 'PreviousDodgeClickTimer - DeltaTime' here instead of 'PlayerPawn.DodgeClickTimer' since it's possible for the DodgeDir variable to go
		// straight from e.g. DODGE_Forward to DODGE_Done. This can happen when a player dodges against the underside of a slope. For example on the
		// map BT-1545. If DODGE_Done is set the DodgeClickTimer will be equal to 0.
		if (DodgeDoubleTapStats != None && (PlayerPawn.DodgeClickTime - (PreviousDodgeClickTimer - DeltaTime)) > 0)
			DodgeDoubleTapStats.AddValue(PlayerPawn.DodgeClickTime - (PreviousDodgeClickTimer - DeltaTime) / Level.TimeDilation);

		if (DodgeAfterLandingStats != None)
		{
			if (HasLandedTimeStamp > 0 && Level.TimeSeconds - HasLandedTimeStamp < 0.2) // We're only interested in a dodge that occurred within 0.2 seconds after landing.
				DodgeAfterLandingStats.AddValue((Level.TimeSeconds - HasLandedTimeStamp) / Level.TimeDilation);
		}

		if (TimeBetweenDodgesStats != None)
		{
			if (StoppedDodgingTimestamp > 0 && Level.TimeSeconds - StoppedDodgingTimestamp < 0.6) // We're only interested in dodges chained in quick succession.
				TimeBetweenDodgesStats.AddValue((Level.TimeSeconds - StoppedDodgingTimestamp) / Level.TimeDilation);
		}
	}
	if (HasStoppedDodging())
	{
		StoppedDodgingTimestamp = Level.TimeSeconds;
	}
	if (IsAfterDodgeBlock())
	{
		if (DodgeBlockStats != None)
			DodgeBlockStats.AddValue((Level.TimeSeconds - StoppedDodgingTimestamp) / Level.TimeDilation);
	}

	if (HasStopped(PHYS_Falling))
	{
		HasLandedTimeStamp = Level.TimeSeconds;
	}

	PreviousDodgeDir = PlayerPawn.DodgeDir;
	PreviousPhysics = PlayerPawn.Physics;
	PlayerJustSpawned = False;
	PreviousDodgeClickTimer = PlayerPawn.DodgeClickTimer;
}

simulated function MeasureFPS(float DeltaTime)
{
	FPSTimePassed += DeltaTime/Level.TimeDilation;
	FPSTickCounter++;

	if (FPSTickCounter >= TicksPerFPSCalculation)
	{
		if (FPSStats != None)
			FPSStats.AddValue(int(FPSTickCounter/FPSTimePassed), FPSTickCounter/FPSTimePassed);
		
		FPSTickCounter = 0;
		FPSTimePassed = 0;
	}
}

simulated function bool HasStartedDodging()
{
	return (PreviousDodgeDir == DODGE_Forward || PreviousDodgeDir == DODGE_Back || PreviousDodgeDir == DODGE_Left || PreviousDodgeDir == DODGE_Right)
				&& (PlayerPawn.DodgeDir == DODGE_Active || PlayerPawn.DodgeDir == DODGE_Done);
}

simulated function bool HasStoppedDodging()
{
	return (PreviousDodgeDir == DODGE_Forward || PreviousDodgeDir == DODGE_Back || PreviousDodgeDir == DODGE_Left || PreviousDodgeDir == DODGE_Right || PreviousDodgeDir == DODGE_Active)
				&& PlayerPawn.DodgeDir == DODGE_Done;
}

simulated function bool IsAfterDodgeBlock()
{
	return PreviousDodgeDir == DODGE_Done && PlayerPawn.DodgeDir == DODGE_None && !PlayerJustSpawned && PreviousPhysics != PHYS_None;
}

simulated function bool HasStopped(EPhysics Physics)
{
	return PreviousPhysics == Physics && PlayerPawn.Physics != Physics;
}

simulated function string GetEngineRevision()
{
    local ENetRole R;
    local string Result;

    R = Level.Role;
    Level.Role = ROLE_Authority;

    if (int(Level.EngineVersion) >= 469)
        Result = Level.GetPropertyText("EngineRevision");

    Level.Role = R;
    return Result;
}

simulated function string GetRenderer()
{
	local string Renderer;
	local int i;

	// e.g. Class'OpenGLDrv.OpenGLRenderDevice'
	Renderer = PlayerPawn.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice Class");

	i = InStr(Renderer, "'");
	if (i != -1)
	{
		Renderer = Mid(Renderer, i+1);
		i = InStr(Renderer, ".");
		if (i != -1)
			Renderer = Left(Renderer, i);
	}
	else
	{
		Log("[BTPog/BTCapLogger] Could not retrieve renderer: "$Renderer);
		Renderer = "Unknown";
	}
	
	return Renderer;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
