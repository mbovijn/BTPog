class BTP_Suicide_Controller extends Info dependson(BTP_Suicide_Structs);

var PlayerPawn PlayerPawn;
var BTP_Suicide_Main Main;

var BTP_Suicide_MoverTracker MoverTrackers[4];

var bool HasRequestedSuicide;
var bool HasRequestedFire;

function Init(PlayerPawn aPlayerPawn, BTP_Suicide_Main aMain, BTP_Suicide_Structs.MoverTrackerCollection aMoverTrackerCollection)
{
    PlayerPawn = aPlayerPawn;
    Main = aMain;

    InitMoverTrackerCollection(aMoverTrackerCollection);
}

function InitMoverTrackerCollection(BTP_Suicide_Structs.MoverTrackerCollection aMoverTrackerCollection)
{
    local int Index;
    for (Index = 0; Index < ArrayCount(aMoverTrackerCollection.MoverTrackers); Index++)
    {
        if (aMoverTrackerCollection.MoverTrackers[Index].Name != "")
        {
            MoverTrackers[Index] = new class'BTP_Suicide_MoverTracker';
            MoverTrackers[Index].Init(PlayerPawn, GetMoverByName(aMoverTrackerCollection.MoverTrackers[Index].Name));
            MoverTrackers[Index].TimePoint = aMoverTrackerCollection.MoverTrackers[Index].TimePoint;
            MoverTrackers[Index].Alpha = aMoverTrackerCollection.MoverTrackers[Index].Alpha;
        }
    }
}

function BTP_Suicide_Structs.MoverTrackerCollection CreateMoverTrackerCollection()
{
    local BTP_Suicide_Structs.MoverTrackerCollection M;
    local int Index;

    M.Map = class'BTP_Misc_Utils'.static.GetMapName(Level);
    M.Team = PlayerPawn.PlayerReplicationInfo.Team;

    for (Index = 0; Index < ArrayCount(MoverTrackers); Index++)
    {
        if (MoverTrackers[Index] != None)
        {
            M.MoverTrackers[Index].Name = string(MoverTrackers[Index].Mover.Name);
            M.MoverTrackers[Index].TimePoint = MoverTrackers[Index].TimePoint;
            M.MoverTrackers[Index].Alpha = MoverTrackers[Index].Alpha;
        }
    }

    return M;
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

function CreateMoverTracker(int Index, Mover aMover)
{
    if (MoverTrackers[Index] != None)
    {
        MoverTrackers[Index] = None;
    }

    if (aMover == None)
    {
        ClientMessage("No mover found - cleared existing mover if set");
        return;
    }

    MoverTrackers[Index] = new class'BTP_Suicide_MoverTracker';
    MoverTrackers[Index].Init(PlayerPawn, aMover);
    ClientMessage("Selected mover " $ aMover.Name $ " at slot " $ Index);

    Main.ReplicateMoverTrackerCollectionToClient(CreateMoverTrackerCollection());
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
        ClientMessage("Failed - First select a mover at slot " $ Index);
        return;
    }

    MoverTrackers[Index].SetAlpha(float(Argument));
    Main.ReplicateMoverTrackerCollectionToClient(CreateMoverTrackerCollection());
}

function ExecuteSuicideCommand()
{
    if (!HasSelectedAtLeastOneMover())
    {
        ClientMessage("Failed - First select at least one mover with timepoint");
        return;
    }

    HasRequestedSuicide = true;
}

function ExecuteFireCommand()
{
    if (!HasSelectedAtLeastOneMover())
    {
        ClientMessage("Failed - First select at least one mover with timepoint");
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
        ClientMessage("Failed - First select a mover at slot " $ Index);
        return;
    }

    MoverTrackers[Index].SetTimePoint(Argument);
    Main.ReplicateMoverTrackerCollectionToClient(CreateMoverTrackerCollection());
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

function ExecutePrintCommand()
{
    local int Index;
    for (Index = 0; Index < ArrayCount(MoverTrackers); Index++)
        if (MoverTrackers[Index] != None)
            MoverTrackers[Index].Print(Index);
}

function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog/Suicide] "$Message);
}