class BTStopwatch extends Info;

var PlayerPawn PlayerPawn;
var BTStopwatchTrigger Triggers[32];
var BTStopwatchClientSettings ClientSettings;

var float SpawnTimestamp;
var float BestCapTime; // Storing this server-side to be consistent with the actual cap times.

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, PlayerSpawnedEvent_ToClient, PlayerCappedEvent_ToClient, ExecuteCommand_ToClient;
	reliable if (Role < ROLE_Authority)
		ResetBestCapTime_ToServer;
}

simulated function PreBeginPlay()
{
    local Object Obj;

    PlayerPawn = PlayerPawn(Owner);

    if (Role < ROLE_Authority)
    {
        Obj = new (none, 'BTPog') class'Object';
	    ClientSettings = new (Obj, 'BTStopwatchSettings') class'BTStopwatchClientSettings';

	    ClientSettings.ValidateConfig();
		ClientSettings.SaveConfig();
    }
}

function PlayerCappedEvent()
{
	local float NewCapTime;
	NewCapTime = (Level.TimeSeconds - SpawnTimestamp) / Level.TimeDilation;
	
	if (NewCapTime < BestCapTime || BestCapTime == 0)
	{
		PlayerCappedEvent_ToClient();
		BestCapTime = NewCapTime;
	}
}

simulated function PlayerCappedEvent_ToClient()
{
	local int Index;
	for (Index = 0; Index < ArrayCount(Triggers); Index++)
		if (Triggers[Index] != None)
			Triggers[Index].SetNewBestTime();
}

function PlayerSpawnedEvent()
{
	SpawnTimestamp = Level.TimeSeconds;
	PlayerSpawnedEvent_ToClient();
}

simulated function PlayerSpawnedEvent_ToClient()
{
	local int Index;
	
	for (Index = 0; Index < ArrayCount(Triggers); Index++)
		if (Triggers[Index] != None)
			Triggers[Index].SetSpawnTimestamp(Level.TimeSeconds);
	
	SpawnTimestamp = Level.TimeSeconds;
}

function ResetBestCapTime_ToServer()
{
	BestCapTime = 0;
}

function ExecuteCommand(string MutateString)
{
	ExecuteCommand_ToClient(MutateString);
}

simulated function ExecuteCommand_ToClient(string MutateString)
{
	local string Argument;
	Argument = class'Utils'.static.GetArgument(MutateString, 2);

	if (Argument == "" || Argument == "0" || int(Argument) != 0)
	{
		ExecuteCreateCommand(MutateString, int(Argument));
	}
	else if (Argument == "delete")
	{
		ExecuteDeleteCommand(MutateString);
	}
	else if (Argument == "reset")
	{
		ExecuteResetCommand();
	}
	else if (Argument == "precision")
	{
		ExecutePrecisionCommand(MutateString);
	}
	else
	{
		ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
	}
}

simulated function ExecuteResetCommand()
{
	local int Index;

	for (Index = 0; Index < ArrayCount(Triggers); Index++)
			if (Triggers[Index] != None)
				Triggers[Index].ResetBestTime();
	
	ResetBestCapTime_ToServer();

	ClientMessage("Best times have been reset");
}

simulated function ExecuteDeleteCommand(string MutateString)
{
	local string Argument;
	Argument = class'Utils'.static.GetArgument(MutateString, 3);

	if (Argument == "all")
	{
		DeleteAll();
	}
	else if (Argument == "0" || int(Argument) != 0)
	{
		Delete(int(Argument));
	}
	else
	{
		ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
	}
}

simulated function Delete(int Index)
{
	if (!IsValidIndex(Index))
		return;
	
	DeleteInternal(Index);
	ResetBestCapTimeIfNoTriggers();
}

simulated function DeleteAll()
{
	local int Index;
	for (Index = 0; Index < ArrayCount(Triggers); Index++)
			if (Triggers[Index] != None) DeleteInternal(Index);
	ResetBestCapTime_ToServer();
}

simulated function bool IsValidIndex(int Index)
{
	if (Index < 0 || Index >= ArrayCount(Triggers))
	{
		ClientMessage("Please select a stopwatch index between 0 and "$(ArrayCount(Triggers) - 1));
		return false;
	}
	return true;
}

simulated function ResetBestCapTimeIfNoTriggers()
{
	local int i;
	for (i = 0; i < ArrayCount(Triggers); i++)
			if (Triggers[i] != None) return;
	ResetBestCapTime_ToServer();
}

simulated function ExecuteCreateCommand(string MutateString, int Index)
{
	if (!IsValidIndex(Index))
		return;

	if (class'Utils'.static.GetArgument(MutateString, 3) == "")
		Create(Owner.Location, Index);
	else
		Create(ToVector(class'Utils'.static.GetArgument(MutateString, 3)), Index);
}

simulated function ExecutePrecisionCommand(string MutateString)
{
	local int Index;
	local string Argument;
	
	Argument = class'Utils'.static.GetArgument(MutateString, 3);
	if (!(Argument == "0" || (int(Argument) > 0 && int(Argument) <= 3)))
	{
		ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
		return;
	}

	ClientSettings.PrecisionDecimals = int(Argument);
	ClientSettings.SaveConfig();

	for (Index = 0; Index < ArrayCount(Triggers); Index++)
		if (Triggers[Index] != None)
			Triggers[Index].PrecisionDecimals = ClientSettings.PrecisionDecimals;
	
	ClientMessage("Configured the stopwatch precision to "$ClientSettings.PrecisionDecimals$" decimals");
}

simulated function DeleteInternal(int Index)
{
	if (Triggers[Index] == None)
	{
		ClientMessage("No stopwatch found at index "$Index);
		return;
	}

	Triggers[Index].Destroy();
	Triggers[Index] = None;
	ClientMessage("Deleted stopwatch at index "$Index);
}

simulated function Create(Vector Location, int Index)
{
	if (Triggers[Index] != None) Triggers[Index].Destroy();

    Triggers[Index] = Spawn(class'BTStopwatchTrigger', Owner, , RemoveDecimals(Location));
	Triggers[Index].Init(Index, SpawnTimestamp, ClientSettings.PrecisionDecimals);

    ClientMessage("Created stopwatch "$Index$" at location "$ToStringWithoutDecimals(Location));
}

simulated function Vector ToVector(String VectorString)
{
	local Vector NewVector;
	NewVector.X = int(class'Utils'.static.GetStringPart(VectorString, 0, ","));
	NewVector.Y = int(class'Utils'.static.GetStringPart(VectorString, 1, ","));
	NewVector.Z = int(class'Utils'.static.GetStringPart(VectorString, 2, ","));
	return NewVector;
}

simulated function Vector RemoveDecimals(Vector OldVector)
{
	local Vector NewVector;
	NewVector.X = int(OldVector.X);
	NewVector.Y = int(OldVector.Y);
	NewVector.Z = int(OldVector.Z);
	return NewVector;
}

simulated function string ToStringWithoutDecimals(Vector Vector)
{
	return int(Vector.X)$","$int(Vector.Y)$","$int(Vector.Z);
}

simulated function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
