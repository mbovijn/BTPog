class BTP_Stopwatch_Main extends Info dependson(BTP_Stopwatch_Structs);

// CLIENT VARIABLES
var BTP_Stopwatch_ClientConfig ClientConfig;

// SERVER VARIABLES
var BTP_Stopwatch_Structs.ClientConfigDto ClientConfigDto;

var BTP_Stopwatch_Controller RedController;
var BTP_Stopwatch_Controller BlueController;

var float SpawnTimestamp;

replication
{
	reliable if (Role < ROLE_Authority)
		ReplicateConfigToServer, ReplicateStopwatchCollectionToServer;
	reliable if (Role == ROLE_Authority)
		ReplicateConfigToClient, ReplicateStopwatchCollectionToClient;
}

// TODO - consider moving stopwatches to the client - on a server with a low tickrate times are inconsistent

function ReplicateConfigToServer(BTP_Stopwatch_Structs.ClientConfigDto aClientConfigDto)
{
	ClientConfigDto = aClientConfigDto;
}

function ReplicateStopwatchCollectionToServer(BTP_Stopwatch_Structs.StopwatchCollection aStopwatchCollection)
{
	if (aStopwatchCollection.Team == 0)
	{
		RedController = Spawn(class'BTP_Stopwatch_Controller', Owner);
		RedController.Init(PlayerPawn(Owner), Self, SpawnTimestamp, aStopwatchCollection);
	}
	else if (aStopwatchCollection.Team == 1)
	{
		BlueController = Spawn(class'BTP_Stopwatch_Controller', Owner);
		BlueController.Init(PlayerPawn(Owner), Self, SpawnTimestamp, aStopwatchCollection);
	}
	else
	{
		Log("[BTPog/Stopwatch] Received StopwatchCollection with invalid team " $ aStopwatchCollection.Team $ "from the client");
	}
}

simulated function ReplicateConfigToClient(BTP_Stopwatch_Structs.ClientConfigDto aClientConfigDto)
{
	ClientConfig.UpdateClientConfig(aClientConfigDto);
}

simulated function ReplicateStopwatchCollectionToClient(BTP_Stopwatch_Structs.StopwatchCollection aStopwatchCollection)
{
	ClientConfig.UpdateStopwatchCollection(aStopwatchCollection);
}

simulated function PostNetBeginPlay()
{
    local Object Obj;
    if (Role < ROLE_Authority)
    {
        Obj = new (none, 'BTPog_Stopwatch') class'Object';
	    ClientConfig = new (Obj, 'Stopwatch_ClientConfig') class'BTP_Stopwatch_ClientConfig';

	    ClientConfig.ValidateConfig();
		ClientConfig.SaveConfig();

		ReplicateConfigToTheServer();
    }
}

simulated function ReplicateConfigToTheServer()
{
	local string MapName;
	MapName = class'BTP_Misc_Utils'.static.GetMapName(Level);

	ReplicateConfigToServer(ClientConfig.GetClientConfig());
	ReplicateStopwatchCollectionToServer(ClientConfig.GetStopwatchCollection(MapName, 0)); // RED side
	ReplicateStopwatchCollectionToServer(ClientConfig.GetStopwatchCollection(MapName, 1)); // BLUE side
}

function BTP_Stopwatch_Controller GetController()
{
	switch (PlayerPawn(Owner).PlayerReplicationInfo.Team)
	{
		case 0: return RedController;
		case 1: return BlueController;
		default: return None;
	}
}

function PlayerCappedEvent()
{
	local BTP_Stopwatch_Controller Controller;
	Controller = GetController();

	if (Controller != None) Controller.PlayerCappedEvent();
}

function PlayerSpawnedEvent()
{
	local BTP_Stopwatch_Controller Controller;
	Controller = GetController();
	if (Controller != None) Controller.PlayerSpawnedEvent();

	SpawnTimestamp = Level.TimeSeconds;
}

function ExecuteCommand(String MutateString)
{
	local BTP_Stopwatch_Controller Controller;
	Controller = GetController();

	if (Controller == None)
	{
		ClientMessage("Please try again once initialization has finished");
		return;
	}

	if (!ExecuteCommandInternal(Controller, MutateString))
	{
		ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
	}
}

function bool ExecuteCommandInternal(BTP_Stopwatch_Controller Controller, string MutateString)
{
	local string Argument, RemainingArguments;
	Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);
	RemainingArguments = class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString);

	if (Argument == "" || Argument == "0" || int(Argument) != 0)
	{
		return ExecuteCreateCommand(RemainingArguments, int(Argument));
	}
	else if (Argument == "create")
	{
		Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(RemainingArguments);
		
		if (Argument == "" || Argument == "0" || int(Argument) != 0)
		{
			RemainingArguments = class'BTP_Misc_Utils'.static.GetRemainingArguments(RemainingArguments);
			return ExecuteCreateCommand(RemainingArguments, int(Argument));
		}

		return False;
	}
	else if (Argument == "delete" || Argument == "del")
	{
		return ExecuteDeleteCommand(RemainingArguments);
	}
	else if (Argument == "reset")
	{
		Controller.Reset();
		return True;
	}
	else if (Argument == "precision")
	{
		return ExecutePrecisionCommand(RemainingArguments);
	}
	else if (Argument == "print")
	{
		Controller.Print();
		return True;
	}
	else if (Argument == "toggle")
	{
		return ExecuteToggleCommand();
	}
	else if (Argument == "retriggerdelay")
	{
		return ExecuteRetriggerDelayCommand(RemainingArguments);
	}

	return False;
}

function bool ExecuteCreateCommand(string MutateString, int Index)
{
	local string Argument;
	Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);

	if (Argument == "")
	{
		GetController().CreateAtPlayerPosition(Index);
		return True;
	}
	else
	{
		GetController().CreateAt(Index, class'BTP_Misc_Utils'.static.ToVector(Argument));
		return True;
	}
}

function bool ExecuteDeleteCommand(string MutateString)
{
	local string Argument;
	Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);

	if (Argument == "all")
	{
		GetController().DeleteAll();
		return True;
	}
	else if (Argument == "0" || int(Argument) != 0)
	{
		GetController().Delete(int(Argument));
		return True;
	}
	
	return False;
}

function bool ExecutePrecisionCommand(string MutateString)
{
	local string Argument;
	Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);
	if (!(Argument == "0" || (int(Argument) > 0 && int(Argument) <= 3))) return False;

	ClientConfigDto.PrecisionDecimals = int(Argument);
	ReplicateConfigToClient(ClientConfigDto);
	
	ClientMessage("Configured stopwatch precision to " $ ClientConfigDto.PrecisionDecimals $ " decimals");
	return True;
}

function bool ExecuteToggleCommand()
{
	ClientConfigDto.DisplayTimes = !ClientConfigDto.DisplayTimes;
	ReplicateConfigToClient(ClientConfigDto);
	
	ClientMessage("Toggled the display of stopwatch times");
	return True;
}

function bool ExecuteRetriggerDelayCommand(string MutateString)
{
	local string Argument;
	Argument = class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString);
	if (!(float(Argument) > 0.2 && float(Argument) <= 10.0)) return False;

	ClientConfigDto.ReTriggerDelay = float(Argument);
	ReplicateConfigToClient(ClientConfigDto);
	
	ClientMessage("Configured retrigger delay to " $ ClientConfigDto.PrecisionDecimals $ " seconds");
	return True;
}

function ClientMessage(string Message)
{
    PlayerPawn(Owner).ClientMessage("[BTPog/Stopwatch] " $ Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
