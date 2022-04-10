class BTZeroPingDodge extends Actor config (BTPog);

var PlayerPawn PlayerPawn;

var config bool IsActive;
var config bool IsDebugging;

var float PreviousDodgeClickTimer;

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
        if (PlayerPawn.DodgeDir == DODGE_Done && PlayerPawn.DodgeClickTimer > PreviousDodgeClickTimer)
        {
            if (IsDebugging) PlayerPawn.ClientMessage("ZPDodge reduced the dodge block duration by "$class'Utils'.static.TimeDeltaToString(Abs(PreviousDodgeClickTimer), Level.TimeDilation)$" seconds");
            PlayerPawn.DodgeClickTimer = PreviousDodgeClickTimer - DeltaTime;
        }
        PreviousDodgeClickTimer = PlayerPawn.DodgeClickTimer;
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
