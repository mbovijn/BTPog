class BTP_Stopwatch_Controller extends Info dependson(BTP_Stopwatch_Structs);

var PlayerPawn PlayerPawn;
var BTP_Stopwatch_Main Main;

var BTP_Stopwatch_Trigger Triggers[14];
var float SpawnTimestamp;
var float BestCapTime;

function Init(PlayerPawn aPlayerPawn, BTP_Stopwatch_Main aMain, BTP_Stopwatch_Structs.StopwatchCollection aStopwatchCollection)
{
    PlayerPawn = aPlayerPawn;
    Main = aMain;

    // TODO - init triggers
}

function PlayerCappedEvent()
{
    local int Index;
	local float NewCapTime;

	NewCapTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;
	
	if (NewCapTime < BestCapTime || BestCapTime == 0)
	{
		for (Index = 0; Index < ArrayCount(Triggers); Index++)
			if (Triggers[Index] != None)
				Triggers[Index].SetNewBestTime();
		
		BestCapTime = NewCapTime;

        if (HasTriggers())
        {
            // TODO - save config on the client, but only if some triggers are configured
        }
	}
}

function PlayerSpawnedEvent()
{
    local int Index;

	for (Index = 0; Index < ArrayCount(Triggers); Index++)
		if (Triggers[Index] != None)
			Triggers[Index].SetSpawnTimestamp(Level.TimeSeconds);
	
	SpawnTimestamp = Level.TimeSeconds;
}

function Print()
{
    local int Index;

	for (Index = 0; Index < ArrayCount(Triggers); Index++)
        if (Triggers[Index] != None)
            Triggers[Index].Print();
}

function CreateAtPlayerPosition(int Index)
{
    CreateAt(Index, PlayerPawn.Location);
}

function CreateAt(int Index, Vector Location)
{
    if (!IsValidIndex(Index)) return;

    if (Triggers[Index] != None)
	{
		ClientMessage("Delete the stopwatch at this index before creating a new one");
		return;
	}

    Triggers[Index] = Spawn(class'BTP_Stopwatch_Trigger', PlayerPawn, , class'BTP_Misc_Utils'.static.RemoveDecimalsFromVector(Location));
	Triggers[Index].Init(Index, SpawnTimestamp, Main);

    ClientMessage("Created stopwatch " $ Index $ " at location " $ class'BTP_Misc_Utils'.static.ToStringWithoutDecimals(Location));
    
    // TODO - save config on the client
}

function Delete(int Index)
{
    if (!IsValidIndex(Index)) return;

    if (Triggers[Index] == None)
	{
		ClientMessage("Could not delete stopwatch since none was found at index " $ Index);
		return;
	}

    Triggers[Index].Destroy();
	Triggers[Index] = None;

    if (!HasTriggers())
    {
        BestCapTime = 0;
    }

	ClientMessage("Deleted stopwatch at index " $ Index);

    // TODO - save config on the client
}

function DeleteAll()
{
    local int Index;

	for (Index = 0; Index < ArrayCount(Triggers); Index++)
    {
        if (Triggers[Index] != None)
        {
            Triggers[Index].Destroy();
            Triggers[Index] = None;
        }
    }

	BestCapTime = 0;

    ClientMessage("Deleted all stopwatches");

    // TODO - save config on the client
}

function Reset()
{
    local int Index;

    for (Index = 0; Index < ArrayCount(Triggers); Index++)
        if (Triggers[Index] != None)
            Triggers[Index].ResetBestTime();
	
	BestCapTime = 0;

	ClientMessage("Best times have been reset");

    // TODO - save config on the client
}

function bool IsValidIndex(int Index)
{
	if (Index < 0 || Index >= ArrayCount(Triggers))
	{
		ClientMessage("Invalid index specified (0.." $ (ArrayCount(Triggers) - 1) $ ")");
		return False;
	}

	return True;
}

function bool HasTriggers()
{
    local int Index;

    for (Index = 0; Index < ArrayCount(Triggers); Index++)
        if (Triggers[Index] != None) return True;
    
    return False;
}

function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog/Stopwatch] " $ Message);
}
