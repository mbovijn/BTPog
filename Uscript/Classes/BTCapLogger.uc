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
var BTCapLoggerBucketedStats FPSStats;

var int TicksPerFPSCalculation; // See BTCapLoggerSettings
var float FPSTimePassed; // Time passed in seconds since last FPS calculation
var int FPSTickCounter; // Ticks since last FPS calculation

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, PlayerSpawnedEvent_ToClient, PlayerCappedEvent_ToClient, ReplicateConfig_ToClient;
	reliable if (Role < ROLE_Authority)
		ReportInfo_ToServer;
}

function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
}

simulated function ReplicateConfig_ToClient(float aTicksPerFPSCalculation)
{
	TicksPerFPSCalculation = aTicksPerFPSCalculation;
}

function Init(BTCapLoggerFile aBTCapLoggerFile, BTCapLoggerSettings aBTCapLoggerSettings)
{
	BTCapLoggerFile = aBTCapLoggerFile;
	ReplicateConfig_ToClient(aBTCapLoggerSettings.TicksPerFPSCalculation);
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
	if (FPSStats != None) FPSStats.Destroy();

	DodgeBlockStats = Spawn(class'BTCapLoggerStats', Owner);
	DodgeDoubleTapStats = Spawn(class'BTCapLoggerStats', Owner);
	DodgeAfterLandingStats = Spawn(class'BTCapLoggerStats', Owner);
	FPSStats = Spawn(class'BTCapLoggerBucketedStats', Owner);
}

function PlayerCappedEvent()
{
	CapTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;
	PlayerCappedEvent_ToClient();
}

simulated function PlayerCappedEvent_ToClient()
{
	ReportInfo_ToServer(
		DodgeBlockStats.Analyze(),
		DodgeDoubleTapStats.Analyze(),
		DodgeAfterLandingStats.Analyze(),
		FPSStats.Analyze()
	);
}

function ReportInfo_ToServer(
	StatsAnalysis DodgeBlock,
	StatsAnalysis DodgeDoubleTap,
	StatsAnalysis DodgeAfterLanding,
	StatsAnalysis FPS
)
{
	BTCapLoggerFile.LogCap(
		PlayerPawn,
		CapTime,
		DodgeBlock,
		DodgeDoubleTap,
		DodgeAfterLanding,
		FPS
	);
}
simulated function Tick(float DeltaTime)
{
	if (Role == ROLE_Authority) return;

	MeasureFPS(DeltaTime);
    
	if (HasStartedDodging())
	{
		if (DodgeDoubleTapStats != None)
			DodgeDoubleTapStats.AddValue((PlayerPawn.DodgeClickTime - PlayerPawn.DodgeClickTimer) / Level.TimeDilation);

		if (DodgeAfterLandingStats != None)
		{
			if (Level.TimeSeconds - HasLandedTimeStamp < 0.2) // We're only interested in a dodge that occurred within 0.2 seconds after landing.
				DodgeAfterLandingStats.AddValue((Level.TimeSeconds - HasLandedTimeStamp) / Level.TimeDilation);
		}
	}
	else if (HasStoppedDodging())
	{
		StoppedDodgingTimestamp = Level.TimeSeconds;
	}
	else if (IsAfterDodgeBlock())
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
	PreviousHealth = PlayerPawn.Health;
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

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
