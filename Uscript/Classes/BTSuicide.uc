class BTSuicide extends Info;

var PlayerPawn PlayerPawn;
var BTSuicideMoverTracker MoverTracker;
var bool HasRequestedSuicide;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function Tick(float DeltaTime)
{
    if (MoverTracker == None)
        return;

    MoverTracker.CustomTick(DeltaTime);

    if (HasRequestedSuicide && MoverTracker.CanSuicide(DeltaTime))
    {
        PlayerPawn.KilledBy(None);
        HasRequestedSuicide = false;
    }
}

function ExecuteCommand(string MutateString)
{
	local string Argument;
    Argument = class'Utils'.static.GetArgument(MutateString, 2);

    if (Argument == "suicide")
    {
        ExecuteSuicideCommand();
    }
    else if (Argument == "select")
    {
        ExecuteSelectCommand(MutateString);
    }
    else if (Argument == "time")
    {
        ExecuteTimeCommand(MutateString);
    }
    else
    {
        ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
    }
}

function ExecuteSuicideCommand()
{
    if (MoverTracker == None)
    {
        ClientMessage("First select a mover and configure a time point");
        return;
    }

    HasRequestedSuicide = true;
}

function ExecuteTimeCommand(string MutateString)
{
    local string Argument;
    Argument = class'Utils'.static.GetArgument(MutateString, 3);

    if (MoverTracker == None)
    {
        ClientMessage("First select a mover");
        return;
    }

    MoverTracker.SetTimePoint(Argument);
}

function ExecuteSelectCommand(string MutateString)
{
    local string Argument;
    Argument = class'Utils'.static.GetArgument(MutateString, 3);

    if (MoverTracker != None)
    {
        MoverTracker.Destroy();
        MoverTracker = None;
    }

    if (Argument == "")
        CreateMoverTracker(GetTargettedMover());
    else
        CreateMoverTracker(GetMoverByName(Argument));
}

function CreateMoverTracker(Mover aMover)
{
    if (aMover == None)
    {
        ClientMessage("No mover found");
        return;
    }

    MoverTracker = Spawn(class'BTSuicideMoverTracker', Owner);
    MoverTracker.Init(PlayerPawn, aMover);
    ClientMessage("Selected mover with name "$aMover.Name);
}

function Mover GetMoverByName(String Name)
{
    local Mover Mover;
	foreach AllActors(Class'Mover', Mover)
		if (string(Mover.Name) == Name) return Mover;
    return None;
}

// Taken from https://github.com/bunnytrack/TriggerMover
function Mover GetTargettedMover()
{
	local Actor HitActor;
	local vector X, Y, Z, HitLocation, HitNormal, EndTrace, StartTrace;
	local Mover HitMover;

	GetAxes(PlayerPawn.ViewRotation, X, Y, Z);

	StartTrace = PlayerPawn.Location + PlayerPawn.EyeHeight * vect(0, 0, 1);
	EndTrace = StartTrace + X * 10000;

	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
	HitMover = Mover(HitActor);

	return HitMover;
}

function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}
