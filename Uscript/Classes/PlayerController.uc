class PlayerController extends Info;

var PlayerPawn PlayerPawn;

var BTSuicide BTSuicide;
var BTStopwatch BTStopwatch;
var BTStats BTStats;
var BTZeroPingDodge BTZeroPingDodge;
var BTCapLogger BTCapLogger;

replication
{
	// Replicating these objects such that the 'CustomTick' function on each of them can be called from the client.
    reliable if (Role == ROLE_Authority)
		BTZeroPingDodge, BTStats, BTCapLogger;
}

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function Init(ServerSettings ServerSettings, BTCapLoggerFile BTCapLoggerFile, BTCapLoggerServerSettings BTCapLoggerServerSettings)
{
    if (ServerSettings.IsBTSuicideEnabled) BTSuicide = Spawn(class'BTSuicide', Owner);
    if (ServerSettings.IsBTStopwatchEnabled) BTStopwatch = Spawn(class'BTStopwatch', Owner);
    if (ServerSettings.IsBTStatsEnabled) BTStats = Spawn(class'BTStats', Owner);
    if (ServerSettings.IsBTZeroPingDodgeEnabled) BTZeroPingDodge = Spawn(class'BTZeroPingDodge', Owner);
    if (ServerSettings.IsBTCapLoggerEnabled)
    {
        BTCapLogger = Spawn(class'BTCapLogger', Owner);
        BTCapLogger.Init(BTCapLoggerFile, BTCapLoggerServerSettings);
    }
}

function ExecuteCommand(string MutateString)
{
	switch(class'Utils'.static.GetArgument(MutateString, 1))
	{
		case "suicide":
            if (BTSuicide == None)
                ClientMessage("BTSuicide module is disabled on this server");
            else
			    BTSuicide.ExecuteCommand(MutateString);
            break;
		case "stopwatch":
        case "sw":
            if (BTStopwatch == None)
                ClientMessage("BTStopwatch module is disabled on this server");
            else
			    BTStopwatch.ExecuteCommand(MutateString);
            break;
		case "stats":
            if (BTStats == None)
                ClientMessage("BTStats module is disabled on this server");
            else
			    BTStats.ExecuteCommand(MutateString);
			break;
        case "zpdodge":
            if (BTZeroPingDodge == None)
                ClientMessage("BTZeroPingDodge module is disabled on this server");
            else
			    BTZeroPingDodge.ExecuteCommand(MutateString);
			break;
		default: ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
	}
}

function PlayerSpawnedEvent()
{
    if (BTStopwatch != None) BTStopwatch.PlayerSpawnedEvent();
    if (BTCapLogger != None) BTCapLogger.PlayerSpawnedEvent();
    if (BTZeroPingDodge != None) BTZeroPingDodge.PlayerSpawnedEvent();
    if (BTStats != None) BTStats.PlayerSpawnedEvent();
}

function PlayerCappedEvent()
{
    if (BTStopwatch != None) BTStopwatch.PlayerCappedEvent();
    if (BTCapLogger != None) BTCapLogger.PlayerCappedEvent();
}

simulated function Tick(float DeltaTime)
{
    if (Role < ROLE_Authority)
    {
        // Calling the 'Tick' functions here such that I have control over the order in which they're called.
        if (BTZeroPingDodge != None) BTZeroPingDodge.CustomTick(DeltaTime);
        if (BTStats != None) BTStats.CustomTick(DeltaTime);
        if (BTCapLogger != None) BTCapLogger.CustomTick(DeltaTime);
    }
    else
    {
        // Cleanup
        if (Owner == None)
        {
            if (BTSuicide != None) BTSuicide.Destroy();
            if (BTStopwatch != None) BTStopwatch.Destroy();
            if (BTStats != None) BTStats.Destroy();
            if (BTZeroPingDodge != None) BTZeroPingDodge.Destroy();
            if (BTCapLogger != None) BTCapLogger.Destroy();
            Destroy();
        }
    }
}

function ClientMessage(String Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
