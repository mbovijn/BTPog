class BTStats extends Info config (BTPog);

var PlayerPawn PlayerPawn;

var config bool IsActive;
var config bool IsDebugging;

var EDodgeDir PreviousDodgeDir;
var float StoppedDodgingTimestamp;
var float DodgeBlockDuration;
var float DodgeDoubleTapInterval;

var EPhysics PreviousPhysics;
var float StartedFallingTimestamp;
var float AirTime;
var float StartedWalkingTimestamp;
var float GroundTime;

var int PreviousHealth;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, ToggleIsActive, ToggleIsDebugging;
}

function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
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

simulated function ToggleIsActive()
{
    IsActive = !IsActive;
    SaveConfig();
}

simulated function ToggleIsDebugging()
{
    IsDebugging = !IsDebugging;
    ClientMessage("BTStats Debugging Enabled = "$IsDebugging);
    SaveConfig();
}

simulated function Tick(float DeltaTime)
{
    local string Messages[7];

	if (Role < ROLE_Authority && IsActive)
    {
		UpdateStats(DeltaTime);

		Messages[0] = "Dodge Double Tap Interval = "$class'Utils'.static.TimeDeltaToString(DodgeDoubleTapInterval, Level.TimeDilation)$" seconds";
		Messages[1] = "Dodge Block Duration = "$class'Utils'.static.TimeDeltaToString(DodgeBlockDuration, Level.TimeDilation)$" seconds";
		Messages[2] = "Air Time = "$class'Utils'.static.TimeDeltaToString(AirTime, Level.TimeDilation)$" seconds";
		Messages[3] = "Ground Time = "$class'Utils'.static.TimeDeltaToString(GroundTime, Level.TimeDilation)$" seconds";
		ClientProgressMessage(Messages);

		if (IsDebugging)
		{
			Log("[BTPog/BTStats] "$GetEnum(enum'EPhysics', PlayerPawn.Physics)$" - "$GetEnum(enum'EDodgeDir', PlayerPawn.DodgeDir)
				$" - "$PlayerPawn.DodgeClickTimer$" - "$DeltaTime$" - "$Level.TimeSeconds);
		}
    }
}

simulated function UpdateStats(float DeltaTime)
{
	if (HasStartedDodging())
	{
		DodgeDoubleTapInterval = PlayerPawn.DodgeClickTime - PlayerPawn.DodgeClickTimer;
	}
	else if (HasStoppedDodging())
	{
		StoppedDodgingTimestamp = Level.TimeSeconds;
	}
	else if (IsAfterDodgeBlock())
	{
		DodgeBlockDuration = Level.TimeSeconds - StoppedDodgingTimestamp;
		if (IsDebugging) Log("[BTPog/BTStats] Dodge Block Duration = "$DodgeBlockDuration);
	}

	if (HasStarted(PHYS_Falling))
	{
		StartedFallingTimestamp = Level.TimeSeconds;
	}
	else if (HasStopped(PHYS_Falling))
	{
		AirTime = Level.TimeSeconds - StartedFallingTimestamp;
	}
	
	if (HasStarted(PHYS_Walking))
	{
		StartedWalkingTimestamp = Level.TimeSeconds;
	}
	else if (HasStopped(PHYS_Walking))
	{
		GroundTime = Level.TimeSeconds - StartedWalkingTimestamp;
	}

	PreviousDodgeDir = PlayerPawn.DodgeDir;
	PreviousPhysics = PlayerPawn.Physics;
	PreviousHealth = PlayerPawn.Health;
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

simulated function ClientMessage(String Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	IsActive=False
	IsDebugging=False
}
