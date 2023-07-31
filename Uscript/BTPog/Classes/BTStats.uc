class BTStats extends Info;

var PlayerPawn PlayerPawn;

var BTStatsClientSettings ClientSettings;
var BTStatsInventory BTStatsInventory;

var EDodgeDir PreviousDodgeDir;
var float PreviousDodgeClickTimer;
var float StoppedDodgingTimestamp;
var float DodgeBlockDuration;
var float DodgeDoubleTapInterval;
var float TimeBetweenTwoDodges;

var EPhysics PreviousPhysics;
var float StartedFallingTimestamp;
var float AirTime;
var float StartedWalkingTimestamp;
var float GroundTime;

var bool PlayerJustSpawned;

var int InputTestTicks;
var int InputTestTicksWithInput;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, ToggleIsActive, ToggleIsDebugging, PlayerSpawnedEventToClient;
}

simulated function PreBeginPlay()
{
	local Object Obj;

	PlayerPawn = PlayerPawn(Owner);

	if (Role < ROLE_Authority)
	{
		Obj = new (none, 'BTPog') class'Object';
		ClientSettings = new (Obj, 'BTStatsSettings') class'BTStatsClientSettings';
		ClientSettings.SaveConfig();
	}
}

function InitBTStatsInventory()
{
	BTStatsInventory = Spawn(class'BTStatsInventory', Owner);
	BTStatsInventory.BTStats = Self;

	PlayerPawn.AddInventory(BTStatsInventory);
}

function ExecuteCommand(string MutateString)
{
	switch(class'Utils'.static.GetArgument(MutateString, 2))
	{
		case "debug":
			ToggleIsDebugging();
			break;
		default:
            ToggleIsActive();
            break;
	}
}

function PlayerSpawnedEvent()
{
	InitBTStatsInventory(); // Because it gets destroyed on death.

	PlayerSpawnedEventToClient();
}

simulated function PlayerSpawnedEventToClient()
{
	PlayerJustSpawned = True;
}

simulated function ToggleIsActive()
{
    ClientSettings.IsActive = !ClientSettings.IsActive;
    ClientSettings.SaveConfig();
}

simulated function ToggleIsDebugging()
{
    ClientSettings.IsDebugging = !ClientSettings.IsDebugging;
    ClientMessage("BTStats Debugging Enabled = "$ClientSettings.IsDebugging);
    ClientSettings.SaveConfig();
}

simulated function CustomTick(float DeltaTime)
{
    local string Messages[7];

	if (Role == ROLE_Authority || (!ClientSettings.IsActive && !ClientSettings.IsDebugging)) return;

	UpdateStats(DeltaTime);

	if (ClientSettings.IsActive)
	{
		Messages[0] = "Dodge Double Tap Interval = "$class'Utils'.static.TimeDeltaToString(DodgeDoubleTapInterval, Level.TimeDilation)$" seconds";
		Messages[1] = "Dodge Block Duration = "$class'Utils'.static.TimeDeltaToString(DodgeBlockDuration, Level.TimeDilation)$" seconds";
		Messages[2] = "Time Between Dodges = "$class'Utils'.static.TimeDeltaToString(TimeBetweenTwoDodges, Level.TimeDilation)$" seconds";
		Messages[3] = "Air Time = "$class'Utils'.static.TimeDeltaToString(AirTime, Level.TimeDilation)$" seconds";
		Messages[4] = "Ground Time = "$class'Utils'.static.TimeDeltaToString(GroundTime, Level.TimeDilation)$" seconds";
		Messages[5] = "Tick Input Hit Rate = "$class'Utils'.static.FloatToString(float(InputTestTicksWithInput)/InputTestTicks, 3)$" ("$InputTestTicksWithInput$"/"$InputTestTicks$")";
		ClientProgressMessage(Messages);
	}

	if (ClientSettings.IsDebugging)
	{
		Log("[BTPog/BTStats] "$PlayerPawn.Health$" - "$GetEnum(enum'EPhysics', PlayerPawn.Physics)$" - "$GetEnum(enum'EDodgeDir', PlayerPawn.DodgeDir)
			$" - "$PlayerPawn.DodgeClickTimer$" - "$DeltaTime$" - "$Level.TimeSeconds);
	}
}

simulated function UpdateStats(float DeltaTime)
{
	if (HasStartedDodging())
	{
		// Using 'PreviousDodgeClickTimer - DeltaTime' here instead of 'PlayerPawn.DodgeClickTimer' since it's possible for the DodgeDir variable to go
		// straight from e.g. DODGE_Forward to DODGE_Done. This can happen when a player dodges against the underside of a slope. For example on the
		// map BT-1545. If DODGE_Done is set the DodgeClickTimer will be equal to 0.
		DodgeDoubleTapInterval = PlayerPawn.DodgeClickTime - (PreviousDodgeClickTimer - DeltaTime);
		TimeBetweenTwoDodges = Level.TimeSeconds - StoppedDodgingTimestamp;
		if (ClientSettings.IsDebugging) LogAndClientMessage("Start of dodge");
	}
	if (HasStoppedDodging())
	{
		StoppedDodgingTimestamp = Level.TimeSeconds;
		if (ClientSettings.IsDebugging) LogAndClientMessage("End of dodge");
	}
	if (IsAfterDodgeBlock())
	{
		DodgeBlockDuration = Level.TimeSeconds - StoppedDodgingTimestamp;
		if (ClientSettings.IsDebugging) LogAndClientMessage("Dodge Block Duration = "$DodgeBlockDuration);
	}

	if (HasStarted(PHYS_Falling))
	{
		StartedFallingTimestamp = Level.TimeSeconds;
	}
	if (HasStopped(PHYS_Falling))
	{
		AirTime = Level.TimeSeconds - StartedFallingTimestamp;
	}
	
	if (HasStarted(PHYS_Walking))
	{
		StartedWalkingTimestamp = Level.TimeSeconds;
	}
	if (HasStopped(PHYS_Walking))
	{
		GroundTime = Level.TimeSeconds - StartedWalkingTimestamp;
	}

	PreviousDodgeDir = PlayerPawn.DodgeDir;
	PreviousPhysics = PlayerPawn.Physics;
	PlayerJustSpawned = False;
	PreviousDodgeClickTimer = PlayerPawn.DodgeClickTimer;
}

simulated function bool HasStarted(EPhysics Physics)
{
	return PreviousPhysics != Physics && PlayerPawn.Physics == Physics;
}

simulated function bool HasStopped(EPhysics Physics)
{
	return PreviousPhysics == Physics && PlayerPawn.Physics != Physics;
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

// Alternative would be to draw using:
// https://github.com/bunnytrack/BTE/blob/master/source/BTE_BTNet1/Classes/BTHUD_BTNet.uc#L1215
// https://github.com/Slipyx/UT99/blob/master/Engine/Mutator.uc#L24
// https://gist.github.com/SeriousBuggie/eb1533b0b7a4d46046f0bd65a5b1909f#draw-text-with-outline-around-it
simulated function ClientProgressMessage(string Messages[7])
{
    local int i;

	PlayerPawn.ClearProgressMessages();
    PlayerPawn.SetProgressTime(0.1);

	for (i = 0; i < ArrayCount(Messages); i++)
    	if (Messages[i] != "") PlayerPawn.SetProgressMessage(Messages[i], ArrayCount(Messages) - i);
}

simulated function LogAndClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
    Log("[BTPog/BTStats] "$Message);
}

simulated function ClientMessage(String Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
