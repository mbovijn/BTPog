class BTZeroPingDodge extends Actor config (BTPog);

var PlayerPawn PlayerPawn;
var config bool IsActive;

var float PreviousDodgeClickTimer;

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
	// TODO provide a message with feedback to the user
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
    if (Role < ROLE_Authority && IsActive)
    {
        if (PlayerPawn.DodgeDir == DODGE_Done && PlayerPawn.DodgeClickTimer > PreviousDodgeClickTimer)
        {
            PlayerPawn.ClientMessage("I got you bro");
            PlayerPawn.DodgeClickTimer = PreviousDodgeClickTimer - DeltaTime;
            // TODO: add logging if debugging is enabled (in order to check when this occurs) (does it also occur at e.g. 50ms ping? Need a real server bruh)
        }

        PreviousDodgeClickTimer = PlayerPawn.DodgeClickTimer;
    }
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
    IsActive=True
}
