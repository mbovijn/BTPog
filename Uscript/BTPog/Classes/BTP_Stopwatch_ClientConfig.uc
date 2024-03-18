class BTP_Stopwatch_ClientConfig extends Object perobjectconfig dependson(BTP_Stopwatch_Structs);

var config int PrecisionDecimals;
var config float ReTriggerDelay;
var config bool DisplayTimes;

var config array<BTP_Stopwatch_Structs.StopwatchCollection> StopwatchCollections;

function ValidateConfig()
{
    if (PrecisionDecimals < 0 || PrecisionDecimals > 3)
    {
        Log("[BTPog/Stopwatch] PrecisionDecimals needs to be a value between 0 and 3. Resetting..");
        PrecisionDecimals = 2;
    }

    if (ReTriggerDelay < 0.2 || ReTriggerDelay > 10.0)
    {
        Log("[BTPog/Stopwatch] ReTriggerDelay needs to be a value between 0.2 and 10. Resetting..");
        ReTriggerDelay=1.5;
    }
}

function BTP_Stopwatch_Structs.ClientConfigDto GetClientConfig()
{
    local BTP_Stopwatch_Structs.ClientConfigDto ClientConfigDto;

    ClientConfigDto.PrecisionDecimals = PrecisionDecimals;
    ClientConfigDto.ReTriggerDelay = ReTriggerDelay;
    ClientConfigDto.DisplayTimes = DisplayTimes;
    
    return ClientConfigDto;
}

function BTP_Stopwatch_Structs.StopwatchCollection GetStopwatchCollection(string MapName, byte Team)
{
	local int Index;
    if (FindStopwatchCollection(MapName, Team, Index))
    {
        return StopwatchCollections[Index];
    }
    else
    {
        return class'BTP_Stopwatch_Structs'.static.CreateEmptyStopwatchCollection(MapName, Team);
    }
}

function bool FindStopwatchCollection(string MapName, byte Team, out int Index)
{
	local int F, C;

	MapName = Caps(MapName);
	F = 0;
	C = StopwatchCollections.Length - 1;
    
	while (F <= C)
    {
		Index = F + ((C - F) / 2);
		if ((Caps(StopwatchCollections[Index].Map) $ string(StopwatchCollections[Index].Team)) < (MapName $ string(Team)))
			F = ++Index;
		else if ((Caps(StopwatchCollections[Index].Map) $ string(StopwatchCollections[Index].Team)) > (MapName $ string(Team)))
			C = Index-1;
		else {
            return true;
        }
	}

	return false;
}

function UpdateStopwatchCollection(BTP_Stopwatch_Structs.StopwatchCollection aStopwatchCollection)
{
    local int Index;

	if (!FindStopwatchCollection(aStopwatchCollection.Map, aStopwatchCollection.Team, Index))
		StopwatchCollections.Insert(Index, 1);
    StopwatchCollections[Index] = aStopwatchCollection;

    SaveConfig();
}

function UpdateClientConfig(BTP_Stopwatch_Structs.ClientConfigDto aClientConfigDto)
{
    PrecisionDecimals = aClientConfigDto.PrecisionDecimals;
    ReTriggerDelay = aClientConfigDto.ReTriggerDelay;
    DisplayTimes = aClientConfigDto.DisplayTimes;

    SaveConfig();
}

defaultproperties
{
    PrecisionDecimals=2
    ReTriggerDelay=1.5
    DisplayTimes=True
}
