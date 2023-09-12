class BTP_CapLogger_Main extends Info dependson(BTP_CapLogger_Structs);

// SERVER & CLIENT VARS
var PlayerPawn PlayerPawn;

var float SpawnTimestamp;
var float CapTime;

// SERVER VARS
var BTP_CapLogger_File CapLogger_File;

var BTP_Misc_PropertyRetriever HardwareIdPropertyRetriever;
var BTP_Misc_PropertyRetriever IdPropertyRetriever;

var int SpawnCount;

var string ZoneCheckpoints;
var byte PreviousZoneNumber;
var int AmountOfZoneCheckpoints;

var BTP_CapLogger_ServerConfig ServerConfig;

// CLIENT VARS
var int TicksPerFPSCalculation; // See BTP_CapLogger_ServerConfig
var float FPSTimePassed; // Time passed in seconds since last FPS calculation
var int FPSTickCounter; // Ticks since last FPS calculation

var EDodgeDir PreviousDodgeDir;
var EPhysics PreviousPhysics; 
var float StoppedDodgingTimestamp;
var float HasLandedTimeStamp;
var float PreviousDodgeClickTimer;
var bool PlayerJustSpawned;
var string UniqueCapId;

var BTP_CapLogger_Stats DodgeBlockStats;
var BTP_CapLogger_Stats DodgeDoubleTapStats;
var BTP_CapLogger_Stats DodgeAfterLandingStats;
var BTP_CapLogger_Stats TimeBetweenDodgesStats;
var BTP_CapLogger_BucketedStats FPSStats;
var BTP_CapLogger_BucketedStats PingStats;
var BTP_CapLogger_MinMaxStats NetspeedStats;

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

function Init(PlayerPawn aPlayerPawn, BTP_CapLogger_File aCapLogger_File, BTP_CapLogger_ServerConfig aCapLogger_ServerConfig)
{
	CapLogger_File = aCapLogger_File;
	PlayerPawn = aPlayerPawn;
	ServerConfig = aCapLogger_ServerConfig;

	HardwareIdPropertyRetriever = Spawn(class'BTP_Misc_PropertyRetriever', PlayerPawn);
	HardwareIdPropertyRetriever.Init(PlayerPawn, "ACEReplicationInfo.hwHash");

	IdPropertyRetriever = Spawn(class'BTP_Misc_PropertyRetriever', PlayerPawn);
	IdPropertyRetriever.Init(PlayerPawn, aCapLogger_ServerConfig.IdPropertyToLog);

	ReplicateConfig_ToClient(aCapLogger_ServerConfig.TicksPerFPSCalculation);
}

function PlayerSpawnedEvent()
{
	SpawnTimestamp = Level.TimeSeconds;
	SpawnCount++;

	AmountOfZoneCheckpoints = 0;
	ZoneCheckpoints = "";
	PreviousZoneNumber = PlayerPawn.FootRegion.ZoneNumber;

	UniqueCapId = class'BTP_Misc_Utils'.static.GenerateUniqueId();
	
	PlayerSpawnedEvent_ToClient("BTPOG_SPAWN_MARKER:" $ UniqueCapId);
}

simulated function PlayerSpawnedEvent_ToClient(String DemoSpawnMarker)
{
	if (DodgeBlockStats != None) DodgeBlockStats.Destroy();
	if (DodgeDoubleTapStats != None) DodgeDoubleTapStats.Destroy();
	if (DodgeAfterLandingStats != None) DodgeAfterLandingStats.Destroy();
	if (TimeBetweenDodgesStats != None) TimeBetweenDodgesStats.Destroy();
	if (FPSStats != None) FPSStats.Destroy();
	if (PingStats != None) PingStats.Destroy();
	if (NetspeedStats != None) NetspeedStats.Destroy();

	DodgeBlockStats = Spawn(class'BTP_CapLogger_Stats', Owner);
	DodgeDoubleTapStats = Spawn(class'BTP_CapLogger_Stats', Owner);
	DodgeAfterLandingStats = Spawn(class'BTP_CapLogger_Stats', Owner);
	TimeBetweenDodgesStats = Spawn(class'BTP_CapLogger_Stats', Owner);
	FPSStats = Spawn(class'BTP_CapLogger_BucketedStats', Owner);
	PingStats = Spawn(class'BTP_CapLogger_BucketedStats', Owner);
	NetspeedStats = Spawn(class'BTP_CapLogger_MinMaxStats', Owner);

	SpawnTimestamp = Level.TimeSeconds;
	PlayerJustSpawned = True;
}

function PlayerCappedEvent()
{
	CapTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;
	PlayerCappedEvent_ToClient("BTPOG_CAP_MARKER:" $ UniqueCapId);
}

simulated function PlayerCappedEvent_ToClient(String DemoCapMarker)
{
	CapTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;

	ReportInfo_ToServer(
		DodgeBlockStats.Analyze(),
		DodgeDoubleTapStats.Analyze(),
		DodgeAfterLandingStats.Analyze(),
		TimeBetweenDodgesStats.Analyze(),
		FPSStats.Analyze(),
		PingStats.Analyze(),
		NetspeedStats.Analyze(),
		CapTime, // ClientCapTime
		Level.EngineVersion$GetEngineRevision(), // e.g. 469c - May  4 2022 Preview,
		GetRenderer()
	);
}

function ReportInfo_ToServer(
	BTP_CapLogger_Structs.StatsAnalysis DodgeBlock,
	BTP_CapLogger_Structs.StatsAnalysis DodgeDoubleTap,
	BTP_CapLogger_Structs.StatsAnalysis DodgeAfterLanding,
	BTP_CapLogger_Structs.StatsAnalysis TimeBetweenDodges,
	BTP_CapLogger_Structs.StatsAnalysis FPS,
	BTP_CapLogger_Structs.StatsAnalysis Ping,
	BTP_CapLogger_Structs.StatsMinMaxAnalysis Netspeed,
	float ClientCapTime,
	String ClientEngineVersion,
	String Renderer
)
{
	local BTP_CapLogger_Structs.LogData LogData;
	LogData.UniqueId = UniqueCapId;
	LogData.CapTime = CapTime;
	LogData.DodgeBlock = DodgeBlock;
	LogData.DodgeDoubleTap = DodgeDoubleTap;
	LogData.DodgeAfterLanding = DodgeAfterLanding;
	LogData.TimeBetweenDodges = TimeBetweenDodges;
	LogData.FPS = FPS;
	LogData.Ping = Ping;
	LogData.Netspeed = Netspeed;
	LogData.ClientCapTimeDelta = ClientCapTime - CapTime;
	LogData.ClientEngineVersion = ClientEngineVersion;
	LogData.SpawnCount = SpawnCount;
	LogData.Renderer = Renderer;
	LogData.HardwareID = HardwareIdPropertyRetriever.GetProperty();
	LogData.CustomID = IdPropertyRetriever.GetProperty();
	LogData.ZoneCheckpoints = ZoneCheckpoints;

	CapLogger_File.LogCap(PlayerPawn, LogData);
}

// The CustomTick function only gets called on the client. So, to execute something on each tick on the server,
// we use the standard Tick function. That's OK since we don't care about the order of execution of this Tick
// function between different modules.
function Tick(float DeltaTime)
{
	if (Role < ROLE_Authority) return;

	if (PreviousZoneNumber != PlayerPawn.FootRegion.ZoneNumber)
	{
		AddZoneCheckpoint(PlayerPawn.FootRegion.ZoneNumber);
	}

	PreviousZoneNumber = PlayerPawn.FootRegion.ZoneNumber;
}

function AddZoneCheckpoint(byte NewZoneNumber)
{
	local String Time;

	if (AmountOfZoneCheckpoints >= ServerConfig.MaxZoneCheckpoints)
	{
		if (ServerConfig.IsDebugging)
		{
			Log("[BTPog/CapLogger] Could not track anymore zone checkpoints for player "
				$ PlayerPawn.PlayerReplicationInfo.PlayerName $ " since the limit of "
				$ ServerConfig.MaxZoneCheckpoints $ " was reached");
		}
		return;
	}

	Time = class'BTP_Misc_Utils'.static.TimeDeltaToString(Level.TimeSeconds - SpawnTimestamp, Level.TimeDilation);
	ZoneCheckpoints = ZoneCheckpoints $ NewZoneNumber $ "-" $ Time $ ";";
	
	AmountOfZoneCheckpoints++;
}

simulated function CustomTick(float DeltaTime)
{
	if (Role == ROLE_Authority) return;

	MeasureFPS(DeltaTime);

	if (PlayerPawn.PlayerReplicationInfo != None && PlayerPawn.PlayerReplicationInfo.Ping > 0 && PingStats != None)
		PingStats.AddValue(PlayerPawn.PlayerReplicationInfo.Ping, PlayerPawn.PlayerReplicationInfo.Ping);
	
	if (PlayerPawn.Player != None && PlayerPawn.Player.CurrentNetSpeed > 0 && NetspeedStats != None)
		NetspeedStats.AddValue(PlayerPawn.Player.CurrentNetSpeed);
    
	if (HasStartedDodging())
	{
		// Using 'PreviousDodgeClickTimer - DeltaTime' here instead of 'PlayerPawn.DodgeClickTimer' since it's possible for the DodgeDir variable to go
		// straight from e.g. DODGE_Forward to DODGE_Done. This can happen when a player dodges against the underside of a slope. For example on the
		// map BT-1545. If DODGE_Done is set the DodgeClickTimer will be equal to 0.
		if (DodgeDoubleTapStats != None && (PlayerPawn.DodgeClickTime - (PreviousDodgeClickTimer - DeltaTime)) > 0)
			DodgeDoubleTapStats.AddValue((PlayerPawn.DodgeClickTime - (PreviousDodgeClickTimer - DeltaTime)) / Level.TimeDilation);

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
		Log("[BTPog/CapLogger] Could not retrieve renderer: "$Renderer);
		Renderer = "Unknown";
	}
	
	return Renderer;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
