class BTZeroPingDodge extends Info;

var PlayerPawn PlayerPawn;

var BTZeroPingDodgeClientSettings ClientSettings;

var float PreviousDodgeClickTimer;
var EDodgeDir PreviousDodgeDir;
var EPhysics PreviousPhysics;
var EPhysics PhysicsOfFirstDodgeDone;
var EPhysics PhysicsOfSecondDodgeDone;
var int PreviousHealth;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, ToggleIsDebugging, ToggleIsActive;
}

simulated function PreBeginPlay()
{
    local Object Obj;

    PlayerPawn = PlayerPawn(Owner);

    if (Role < ROLE_Authority)
    {
        Obj = new (none, 'BTPog') class'Object';
	    ClientSettings = new (Obj, 'BTZeroPingDodgeSettings') class'BTZeroPingDodgeClientSettings';
	    ClientSettings.SaveConfig();
    }
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
    ClientSettings.IsActive = !ClientSettings.IsActive;
    ClientMessage("ZPDodge Enabled = "$ClientSettings.IsActive);
    ClientSettings.SaveConfig();
}

simulated function ToggleIsDebugging()
{
    ClientSettings.IsDebugging = !ClientSettings.IsDebugging;
    ClientMessage("ZPDodge Debugging Enabled = "$ClientSettings.IsDebugging);
    ClientSettings.SaveConfig();
}

simulated function CustomTick(float DeltaTime)
{
    if (Role == ROLE_Authority || !ClientSettings.IsActive) return;
    
    // https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4074 (Called by ClientUpdatePosition)
    // Undoes the DodgeClickTimer being set to 0 by a Landed replay event.
    if (PlayerPawn.DodgeDir == DODGE_Done && PreviousDodgeDir == DODGE_Done
        && PlayerPawn.DodgeClickTimer > PreviousDodgeClickTimer)
    {
        if (ClientSettings.IsDebugging) LogAndClientMessage("Reduced dodge block by "
                            $class'Utils'.static.TimeDeltaToString(Abs(PreviousDodgeClickTimer), Level.TimeDilation)$" seconds");
        PlayerPawn.DodgeClickTimer = PreviousDodgeClickTimer - DeltaTime;
    }

    // https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4078 (Called by ClientUpdatePosition)
    // Undoes the DodgeDir being set to DODGE_None by a Landed replay event. This is problematic when
    // the player already pressed a movement key with the intent to dodge, as it means that the dodge
    // would get cancelled. e.g. DODGE_Forward -> DODGE_None
    if (PlayerPawn.Physics == PHYS_Walking && PreviousPhysics == PHYS_Walking
        && PlayerPawn.DodgeDir == DODGE_None && PreviousDodgeDir != DODGE_None
        && PlayerPawn.DodgeClickTimer == PreviousDodgeClickTimer && PlayerPawn.DodgeClickTimer > 0
        && PreviousHealth > 0)
    {
        if (ClientSettings.IsDebugging) LogAndClientMessage("Prevented dodge from being cancelled after landing a jump");
        PlayerPawn.DodgeDir = PreviousDodgeDir;
        PlayerPawn.DodgeClickTimer = PlayerPawn.DodgeClickTimer - DeltaTime;
    }

    // https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4078 (Called by ClientUpdatePosition)
    // Undoes the DodgeDir being set to DODGE_None by a Landed replay event. This is problematic when
    // the player is in the 'dodge block' state since it means that the player will be able to dodge
    // again before the standard 0.35 sec dodge block duration. i.e. DODGE_Done -> DODGE_None
    if (PlayerPawn.DodgeDir == DODGE_None && PreviousDodgeDir == DODGE_Done
        && PreviousPhysics != PHYS_None
        && PlayerPawn.DodgeClickTimer < PlayerPawn.DodgeClickTime
        && PlayerPawn.DodgeClickTimer == PreviousDodgeClickTimer // We need this such that the slope-dodge-block-reset trick still works.
        && PreviousHealth > 0)
    {
        if (ClientSettings.IsDebugging) LogAndClientMessage("Prevented unlegit dodge block reduction of "
                                            $class'Utils'.static.TimeDeltaToString(0.35 + PlayerPawn.DodgeClickTimer, Level.TimeDilation)$" seconds");
        PlayerPawn.DodgeDir = DODGE_Done;
        PlayerPawn.DodgeClickTimer = PlayerPawn.DodgeClickTimer - DeltaTime;
    }

    PreviousDodgeClickTimer = PlayerPawn.DodgeClickTimer;
    PreviousDodgeDir = PlayerPawn.DodgeDir;
    PreviousPhysics = PlayerPawn.Physics;
    PreviousHealth = PlayerPawn.Health;
}

simulated function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

simulated function LogAndClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
    Log("[BTPog/BTZeroPingDodge] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
