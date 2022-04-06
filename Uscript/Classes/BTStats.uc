class BTStats extends Actor config (BTPog);

var PlayerPawn PlayerPawn;
var config bool IsActive;

var EDodgeDir PreviousDodgeDir;
var float EndOfDodgeTimestamp;
var float DodgeBlockDuration;
var float DodgeDoubleTapDelta;

var EPhysics PreviousPhysics;
var float StartedFallingTimestamp;
var float AirTime;
var float StartedWalkingTimestamp;
var float GroundTime;

// temp
var bool shouldLog;
var float counter;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, Set;
}

function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
}

function ExecuteCommand(string MutateString)
{
	switch(class'Utils'.static.GetArgument(MutateString, 2))
	{
		case "on":
			Set(True);
			break;
		case "off":
			Set(False);
			break;
        default:
	}
}

simulated function Set(bool Active)
{
    IsActive = Active;
    SaveConfig();
}

simulated function Tick(float DeltaTime)
{
    local string Messages[7];

	if (Role < ROLE_Authority && IsActive)
    {
		if (IsStartOfDodge())
		{
			DodgeDoubleTapDelta = PlayerPawn.DodgeClickTime - PlayerPawn.DodgeClickTimer;
		}
		else if (IsEndOfDodge())
		{
			EndOfDodgeTimestamp = Level.TimeSeconds;
			shouldLog = True;
			counter=0;
		}
		else if (IsAfterDodgeBlock())
		{
			DodgeBlockDuration = Level.TimeSeconds - EndOfDodgeTimestamp;
			shouldLog = False;
		}

		if (HasStartedFalling())
		{
			StartedFallingTimestamp = Level.TimeSeconds;
		}
		else if (HasFinishedFalling())
		{
			AirTime = Level.TimeSeconds - StartedFallingTimestamp;
		}
		
		if (HasStartedWalking())
		{
			StartedWalkingTimestamp = Level.TimeSeconds;
		}
		else if (HasFinishedWalking())
		{
			GroundTime = Level.TimeSeconds - StartedWalkingTimestamp;
		}

		PreviousDodgeDir = PlayerPawn.DodgeDir;
		PreviousPhysics = PlayerPawn.Physics;

		if (shouldLog)
		{
			Log(GetEnum(Enum'EDodgeDir', PlayerPawn.DodgeDir)$" - "$PlayerPawn.DodgeClickTimer$" - "$DeltaTime$" - "$counter);
			counter += DeltaTime;
		}

		// These times haven't been adjusted for time dilation due to BT hardcore mode.
		Messages[0] = "Dodge Double Tap Delta = "$class'Utils'.static.FloatToString(DodgeDoubleTapDelta)$" seconds";
		Messages[1] = "Dodge Block Duration = "$class'Utils'.static.FloatToString(DodgeBlockDuration)$" seconds";
		Messages[2] = "Air Time = "$class'Utils'.static.FloatToString(AirTime)$" seconds";
		Messages[3] = "Ground Time = "$class'Utils'.static.FloatToString(GroundTime)$" seconds";
		ClientProgressMessage(Messages);
    }
}

// TODO: can we remove the fact that dodge block time depends on ping?
// If we're during a dodge, and during a particular tick we notice that DodgeClickTimer == 0, or DodgeClickTimer == DeltaTime, then
// reset the DodgeClickTimer to 'PreviousDodgeClickTimer + DeltaTime'

// TODO: testen op een echte server met wat meer ping bruh

// TODO: cap time depends on ping, can we register the cap time on the client instead?
// TODO: is this extra time static? or does it increase with the cap duration?

// TODO more abstract functions for reuse

simulated function bool HasStartedFalling()
{
	return PreviousPhysics != PHYS_Falling && PlayerPawn.Physics == PHYS_Falling;
}

simulated function bool HasFinishedFalling()
{
	return PreviousPhysics == PHYS_Falling && PlayerPawn.Physics != PHYS_Falling;
}

simulated function bool HasStartedWalking()
{
	return PreviousPhysics != PHYS_Walking && PlayerPawn.Physics == PHYS_Walking;
}

simulated function bool HasFinishedWalking()
{
	return PreviousPhysics == PHYS_Walking && PlayerPawn.Physics != PHYS_Walking;
}

simulated function bool IsStartOfDodge()
{
	return (PreviousDodgeDir == Dodge_Forward || PreviousDodgeDir == Dodge_Back || PreviousDodgeDir == Dodge_Left || PreviousDodgeDir == Dodge_Right)
				&& PlayerPawn.DodgeDir == Dodge_Active;
}

simulated function bool IsEndOfDodge()
{
	return PreviousDodgeDir == DODGE_Active && PlayerPawn.DodgeDir == DODGE_Done;
}

simulated function bool IsAfterDodgeBlock()
{
	return PreviousDodgeDir == DODGE_Done && PlayerPawn.DodgeDir == DODGE_None;
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

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
