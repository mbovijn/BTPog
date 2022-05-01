class BTZeroPingDodge extends Info config (BTPog);

var PlayerPawn PlayerPawn;

var config bool IsActive;
var config bool IsDebugging;

var float PreviousDodgeClickTimer;
var EDodgeDir PreviousDodgeDir;
var EPhysics PreviousPhysics;
var int PreviousHealth;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, ToggleIsDebugging, ToggleIsActive;
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
    ClientMessage("ZPDodge Enabled = "$IsActive);
    SaveConfig();
}

simulated function ToggleIsDebugging()
{
    IsDebugging = !IsDebugging;
    ClientMessage("ZPDodge Debugging Enabled = "$IsDebugging);
    SaveConfig();
}

simulated function Tick(float DeltaTime)
{
    if (Role < ROLE_Authority && IsActive)
    {
        // https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4074
        // Undoes the DodgeClickTimer being set to 0 by a Landed replay event.
        if (PlayerPawn.DodgeDir == DODGE_Done && PlayerPawn.DodgeClickTimer > PreviousDodgeClickTimer)
        {
            if (IsDebugging) ClientMessage("Reduced dodge block (after dodge) by "
                                $class'Utils'.static.TimeDeltaToString(Abs(PreviousDodgeClickTimer), Level.TimeDilation)$" seconds");
            PlayerPawn.DodgeClickTimer = PreviousDodgeClickTimer - DeltaTime;
        }

        // https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4078
        // Undoes the DodgeDir being set to DODGE_None by a Landed replay event, when
        // the client has already initiated a dodge by pressing a movement key.
        if (PlayerPawn.Physics == PHYS_Walking && PreviousPhysics == PHYS_Walking
            && PlayerPawn.DodgeDir == DODGE_None && PreviousDodgeDir != DODGE_None
            && PlayerPawn.DodgeClickTimer == PreviousDodgeClickTimer && PlayerPawn.DodgeClickTimer > 0
            && PreviousHealth > 0)
        {
            if (IsDebugging) ClientMessage("Removed dodge block (after jump) of "
                                $class'Utils'.static.TimeDeltaToString((PlayerPawn.DodgeClickTime - PlayerPawn.DodgeClickTimer), Level.TimeDilation)$" seconds");
            PlayerPawn.DodgeDir = PreviousDodgeDir;
            PlayerPawn.DodgeClickTimer = PlayerPawn.DodgeClickTimer - DeltaTime;
        }

        PreviousDodgeClickTimer = PlayerPawn.DodgeClickTimer;
        PreviousDodgeDir = PlayerPawn.DodgeDir;
        PreviousPhysics = PlayerPawn.Physics;
        PreviousHealth = PlayerPawn.Health;
    }
}

simulated function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
    IsActive=True
    IsDebugging=False
}
