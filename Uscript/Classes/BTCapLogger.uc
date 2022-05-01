class BTCapLogger extends BTCapLoggerAbstract;

var PlayerPawn PlayerPawn;
var BTCapLoggerFile BTCapLoggerFile;

var float SpawnTimestamp;
var float CapTime;

var EDodgeDir PreviousDodgeDir;
var float StoppedDodgingTimestamp;

var EPhysics PreviousPhysics;
var float HasLandedTimeStamp;

var int PreviousHealth;

var BTCapLoggerStats DodgeBlockStats;
var BTCapLoggerStats DodgeDoubleTapStats;
var BTCapLoggerStats DodgeAfterLandingStats;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, PlayerSpawnedEvent_ToClient, PlayerCappedEvent_ToClient;
	reliable if (Role < ROLE_Authority)
		ReportInfo_ToServer;
}

function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
}

function Init(BTCapLoggerFile aBTCapLoggerFile)
{
	BTCapLoggerFile = aBTCapLoggerFile;
}

function PlayerSpawnedEvent()
{
	SpawnTimestamp = Level.TimeSeconds;
	PlayerSpawnedEvent_ToClient();
}

simulated function PlayerSpawnedEvent_ToClient()
{
	if (DodgeBlockStats != None) DodgeBlockStats.Destroy();
	if (DodgeDoubleTapStats != None) DodgeDoubleTapStats.Destroy();
	if (DodgeAfterLandingStats != None) DodgeAfterLandingStats.Destroy();

	DodgeBlockStats = Spawn(class'BTCapLoggerStats', Owner);
	DodgeDoubleTapStats = Spawn(class'BTCapLoggerStats', Owner);
	DodgeAfterLandingStats = Spawn(class'BTCapLoggerStats', Owner);
}

function PlayerCappedEvent()
{
	CapTime = Level.TimeSeconds - SpawnTimestamp;
	PlayerCappedEvent_ToClient();
}

simulated function PlayerCappedEvent_ToClient()
{
	ReportInfo_ToServer(
		DodgeBlockStats.Analyze(),
		DodgeDoubleTapStats.Analyze(),
		DodgeAfterLandingStats.Analyze()
	);
}

function ReportInfo_ToServer(
	StatsAnalysis DodgeBlock,
	StatsAnalysis DodgeDoubleTap,
	StatsAnalysis DodgeAfterLanding
)
{
	BTCapLoggerFile.LogCap(
		PlayerPawn,
		CapTime,
		DodgeBlock,
		DodgeDoubleTap,
		DodgeAfterLanding
	);
}

simulated function Tick(float DeltaTime)
{
	if (Role == ROLE_Authority) return;
    
	if (HasStartedDodging())
	{
		if (DodgeDoubleTapStats != None)
			DodgeDoubleTapStats.AddValue(PlayerPawn.DodgeClickTime - PlayerPawn.DodgeClickTimer);

		if (DodgeAfterLandingStats != None)
		{
			if (Level.TimeSeconds - HasLandedTimeStamp < 0.2) // We're only interested in a dodge that occurred within 0.2 seconds after landing.
				DodgeAfterLandingStats.AddValue(Level.TimeSeconds - HasLandedTimeStamp);
		}
	}
	else if (HasStoppedDodging())
	{
		StoppedDodgingTimestamp = Level.TimeSeconds;
	}
	else if (IsAfterDodgeBlock())
	{
		if (DodgeBlockStats != None)
			DodgeBlockStats.AddValue(Level.TimeSeconds - StoppedDodgingTimestamp);
	}

	if (HasStopped(PHYS_Falling))
	{
		HasLandedTimeStamp = Level.TimeSeconds;
	}

	PreviousDodgeDir = PlayerPawn.DodgeDir;
	PreviousPhysics = PlayerPawn.Physics;
	PreviousHealth = PlayerPawn.Health;
}

simulated function bool HasStartedDodging()
{
	return (PreviousDodgeDir == Dodge_Forward || PreviousDodgeDir == Dodge_Back || PreviousDodgeDir == Dodge_Left || PreviousDodgeDir == Dodge_Right)
				&& PlayerPawn.DodgeDir == Dodge_Active;
}

simulated function bool HasStoppedDodging()
{
	return PreviousDodgeDir == DODGE_Active && PlayerPawn.DodgeDir == DODGE_Done;
}

simulated function bool IsAfterDodgeBlock()
{
	return PreviousDodgeDir == DODGE_Done && PlayerPawn.DodgeDir == DODGE_None && PreviousHealth > 0;
}

simulated function bool HasStopped(EPhysics Physics)
{
	return PreviousPhysics == Physics && PlayerPawn.Physics != Physics;
}

function ClientMessage(String Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
