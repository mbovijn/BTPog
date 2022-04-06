class Controller extends Actor;

var PlayerPawn PlayerPawn;

var BTSuicide BTSuicide;
var BTStopwatch BTStopwatch;
var BTStats BTStats;
var BTGhost BTGhost;
var BTZeroPingDodge BTZeroPingDodge;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);

    BTSuicide = Spawn(class'BTSuicide', Owner);
    BTStopwatch = Spawn(class'BTStopwatch', Owner);
    BTStats = Spawn(class'BTStats', Owner);
    BTGhost = Spawn(class'BTGhost', Owner);
    BTZeroPingDodge = Spawn(class'BTZeroPingDodge', Owner);
}

function ExecuteCommand(string MutateString)
{
	switch(class'Utils'.static.GetArgument(MutateString, 1))
	{
		case "suicide":
			BTSuicide.ExecuteCommand(MutateString);
			break;
		case "stopwatch":
			BTStopwatch.ExecuteCommand(MutateString);
			break;
		case "stats":
			BTStats.ExecuteCommand(MutateString);
			break;
        case "zpdodge":
			BTZeroPingDodge.ExecuteCommand(MutateString);
			break;
		default: DisplayHelp();
	}
}

function PlayerSpawnedEvent()
{
    BTGhost.PlayerSpawnedEvent();
}

function PlayerCappedEvent()
{
    BTGhost.PlayerCappedEvent();
}

function Tick(float DeltaTime)
{
    if (Owner == None)
    {
        BTSuicide.Destroy();
        BTStopwatch.Destroy();
        BTStats.Destroy();
        BTGhost.Destroy();
        BTZeroPingDodge.Destroy();
        Destroy();
    }
}

function DisplayHelp()
{
    PlayerPawn.ClientMessage("[BTPog] Description at https://github.com/mbovijn/BTPog");
}
