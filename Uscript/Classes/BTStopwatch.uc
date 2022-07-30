class BTStopwatch extends Info;

var PlayerPawn PlayerPawn;
var BTStopwatchTrigger Triggers[32];

var int PrecisionDecimals;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerPawn, PlayerSpawnedEvent_ToClient, ExecuteCommand_ToClient;
}

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function PlayerSpawnedEvent()
{
	PlayerSpawnedEvent_ToClient();
}

simulated function PlayerSpawnedEvent_ToClient()
{
	local int Index;
	for (Index = 0; Index < ArrayCount(Triggers); Index++)
		if (Triggers[Index] != None)
			Triggers[Index].SetPlayerSpawnTime(Level.TimeSeconds);
}

function ExecuteCommand(string MutateString)
{
	ExecuteCommand_ToClient(MutateString);
}

simulated function ExecuteCommand_ToClient(string MutateString)
{
	local string Argument;
	Argument = class'Utils'.static.GetArgument(MutateString, 2);

	if (Argument == "all")
	{
		ExecuteAllTriggersCommand(MutateString);
	}
	else if (Argument == "" || Argument == "0" || int(Argument) != 0)
	{ 
		ExecuteSingleTriggerCommand(MutateString, int(Argument));
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

simulated function ExecuteAllTriggersCommand(string MutateString)
{
	local int Index;
	for (Index = 0; Index < ArrayCount(Triggers); Index++)
	{
		if (Triggers[Index] != None)
		{
			switch (class'Utils'.static.GetArgument(MutateString, 3))
			{
				case "delete": Delete(Index); break;
				case "reset": Reset(Index); break;
				default: ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog"); return;
			}
		}
	}
}

simulated function ExecuteSingleTriggerCommand(string MutateString, int Index)
{
	if (Index < 0 || Index >= ArrayCount(Triggers))
	{
		ClientMessage("Only a stopwatch slot between 0 and "$(ArrayCount(Triggers) - 1)$" can be selected");
		return;
	}

	switch (class'Utils'.static.GetArgument(MutateString, 3))
	{
		case "delete": Delete(Index); break;
		case "reset": Reset(Index); break;
		case "": Create(Owner.Location, Index); break;
		default: Create(ToVector(class'Utils'.static.GetArgument(MutateString, 3)), Index);
	}
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
	PrecisionDecimals = int(Argument);

	for (Index = 0; Index < ArrayCount(Triggers); Index++)
		if (Triggers[Index] != None)
			Triggers[Index].PrecisionDecimals = PrecisionDecimals;
}

simulated function Delete(int Index)
{
	if (Triggers[Index] == None)
	{
		ClientMessage("Could not delete stopwatch since no stopwatch was found at slot "$Index);
		return;
	}

	Triggers[Index].Destroy();
	Triggers[Index] = None;
	ClientMessage("Deleted stopwatch at slot "$Index);
}

simulated function Reset(int Index)
{
	if (Triggers[Index] == None)
	{
		ClientMessage("Could not reset stopwatch since no stopwatch was found at slot "$Index);
		return;
	}

	Triggers[Index].ResetBestTime();
	ClientMessage("Reset stopwatch at slot "$Index);
}

simulated function Create(Vector Location, int Index)
{
	if (Triggers[Index] != None) Triggers[Index].Destroy();

    Triggers[Index] = Spawn(class'BTStopwatchTrigger', Owner, , RemoveDecimals(Location));
	Triggers[Index].ID = Index;
	Triggers[Index].PrecisionDecimals = PrecisionDecimals;

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
	PrecisionDecimals=2
}
