class PlayerController extends Actor;

var PlayerPawn PlayerPawn;

var BTSuicide BTSuicide;
var BTStopwatch BTStopwatch;
var BTStats BTStats;
var BTZeroPingDodge BTZeroPingDodge;
var BTCapLogger BTCapLogger;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function Init(Settings Settings, BTCapLoggerFile BTCapLoggerFile)
{
    if (Settings.IsBTSuicideEnabled) BTSuicide = Spawn(class'BTSuicide', Owner);
    if (Settings.IsBTStopwatchEnabled) BTStopwatch = Spawn(class'BTStopwatch', Owner);
    if (Settings.IsBTStatsEnabled) BTStats = Spawn(class'BTStats', Owner);
    if (Settings.IsBTZeroPingDodgeEnabled) BTZeroPingDodge = Spawn(class'BTZeroPingDodge', Owner);
    if (Settings.IsBTCapLoggerEnabled)
    {
        BTCapLogger = Spawn(class'BTCapLogger', Owner);
        BTCapLogger.Init(BTCapLoggerFile);
    }
}

function ExecuteCommand(string MutateString)
{
	switch(class'Utils'.static.GetArgument(MutateString, 1))
	{
		case "suicide":
            if (BTSuicide == None)
            {
                ClientMessage("BTSuicide module is disabled on this server");
                break;
            }
			BTSuicide.ExecuteCommand(MutateString);
			break;
		case "stopwatch":
            if (BTStopwatch == None)
            {
                ClientMessage("BTStopwatch module is disabled on this server");
                break;
            }
			BTStopwatch.ExecuteCommand(MutateString);
			break;
		case "stats":
            if (BTStats == None)
            {
                ClientMessage("BTStats module is disabled on this server");
                break;
            }
			BTStats.ExecuteCommand(MutateString);
			break;
        case "zpdodge":
            if (BTZeroPingDodge == None)
            {
                ClientMessage("BTZeroPingDodge module is disabled on this server");
                break;
            }
			BTZeroPingDodge.ExecuteCommand(MutateString);
			break;
		default: ClientMessage("More info at https://github.com/mbovijn/BTPog");
	}
}

function PlayerSpawnedEvent()
{
    if (BTStopwatch != None) BTStopwatch.PlayerSpawnedEvent();
    if (BTCapLogger != None) BTCapLogger.PlayerSpawnedEvent();
}

function PlayerCappedEvent()
{
    if (BTCapLogger != None) BTCapLogger.PlayerCappedEvent();
}

function Tick(float DeltaTime)
{
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

function ClientMessage(String Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}