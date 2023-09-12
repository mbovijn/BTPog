class BTP_Suicide_Main extends Info;

var PlayerPawn PlayerPawn;
var BTP_Suicide_MoverTracker MoverTrackers[4];
var bool HasRequestedSuicide;
var bool HasRequestedFire;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function Tick(float DeltaTime)
{
    TickMoverTrackers(DeltaTime);

    if ((HasRequestedSuicide || HasRequestedFire) && CanSuicide(DeltaTime))
    {
        if (HasRequestedSuicide)
        {
            PlayerPawn.KilledBy(None);
            HasRequestedSuicide = false;
        }
        else
        {
            PlayerPawn.Fire();
            HasRequestedFire = false;
        }
    }
}

function TickMoverTrackers(float DeltaTime)
{
    local int Index;
    for (Index = 0; Index < ArrayCount(MoverTrackers); Index++)
        if (MoverTrackers[Index] != None)
            MoverTrackers[Index].CustomTick(DeltaTime);
}

function bool CanSuicide(float DeltaTime)
{
    local int Index;
    for (Index = 0; Index < ArrayCount(MoverTrackers); Index++)
        if (MoverTrackers[Index] != None && !MoverTrackers[Index].CanSuicide(DeltaTime))
            return false;
    return HasSelectedAtLeastOneMover();
}

function bool HasSelectedAtLeastOneMover()
{
    local int Index;
    for (Index = 0; Index < ArrayCount(MoverTrackers); Index++)
        if (MoverTrackers[Index] != None)
            return true;
    return false;
}

function ExecuteCommand(string MutateString)
{
	local string Argument;
    Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);

    if (Argument == "0" || int(Argument) != 0)
    {
        ExecuteIndexCommand(int(Argument), class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
    }
    else if (Argument == "fire")
    {
        ExecuteFireCommand();
    }
    else if (Argument == "suicide")
    {
        ExecuteSuicideCommand();
    }
    else if (Argument == "print")
    {
        ExecutePrintCommand();
    }
    else
    {
        ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
    }
}

function ExecutePrintCommand()
{
    local int Index;
    for (Index = 0; Index < ArrayCount(MoverTrackers); Index++)
        if (MoverTrackers[Index] != None)
            MoverTrackers[Index].Print(Index);
}

function ExecuteIndexCommand(int Index, string MutateString)
{
    local string Argument;
    Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);

    if (Index < 0 || Index >= ArrayCount(MoverTrackers))
    {
        ClientMessage("Please specify an index between 0 and "$(ArrayCount(MoverTrackers) - 1));
        return;
    }

    if (Argument == "select")
    {
        ExecuteSelectCommand(Index, class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
    }
    else if (Argument == "time")
    {
        ExecuteTimeCommand(Index, class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
    }
    else if (Argument == "alpha")
    {
        ExecuteAlphaCommand(Index, class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
    }
    else
    {
        ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
    }
}

function ExecuteAlphaCommand(int Index, string MutateString)
{
    local string Argument;
    Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);

    if (MoverTrackers[Index] == None)
    {
        ClientMessage("First select a mover");
        return;
    }

    MoverTrackers[Index].SetAlpha(float(Argument));
}

function ExecuteSuicideCommand()
{
    if (!HasSelectedAtLeastOneMover())
    {
        ClientMessage("First select a mover and configure a time point");
        return;
    }

    HasRequestedSuicide = true;
}

function ExecuteFireCommand()
{
    if (!HasSelectedAtLeastOneMover())
    {
        ClientMessage("First select a mover and configure a time point");
        return;
    }

    HasRequestedFire = true;
}

function ExecuteTimeCommand(int Index, string MutateString)
{
    local string Argument;
    Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);

    if (MoverTrackers[Index] == None)
    {
        ClientMessage("First select a mover");
        return;
    }

    MoverTrackers[Index].SetTimePoint(Argument);
}

function ExecuteSelectCommand(int Index, string MutateString)
{
    local string Argument;
    Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);

    if (Argument == "")
        CreateMoverTracker(Index, GetTargettedMover());
    else
        CreateMoverTracker(Index, GetMoverByName(Argument));
}

function CreateMoverTracker(int Index, Mover aMover)
{
    if (MoverTrackers[Index] != None)
    {
        MoverTrackers[Index].Destroy();
        MoverTrackers[Index] = None;
    }

    if (aMover == None)
    {
        ClientMessage("No mover found");
        return;
    }

    MoverTrackers[Index] = Spawn(class'BTP_Suicide_MoverTracker', Owner);
    MoverTrackers[Index].Init(PlayerPawn, aMover);
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
