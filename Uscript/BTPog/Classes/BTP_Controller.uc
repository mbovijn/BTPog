class BTP_Controller extends Info;

var PlayerPawn PlayerPawn;

var BTP_Suicide_Main Suicide_Main;
var BTP_Stopwatch_Main Stopwatch_Main;
var BTP_Stats_Main Stats_Main;
var BTP_ZeroPing_Main ZeroPing_Main;
var BTP_CapLogger_Main CapLogger_Main;

replication
{
	// Replicating these objects such that the 'CustomTick' function on each of them can be called from the client.
    reliable if (Role == ROLE_Authority)
		ZeroPing_Main, Stats_Main, CapLogger_Main;
}

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function Init(BTP_Misc_ServerConfig ServerConfig, BTP_CapLogger_File CapLogger_File, BTP_CapLogger_ServerConfig CapLogger_ServerConfig)
{
    if (ServerConfig.IsBTSuicideEnabled) Suicide_Main = Spawn(class'BTP_Suicide_Main', Owner);
    if (ServerConfig.IsBTStopwatchEnabled) Stopwatch_Main = Spawn(class'BTP_Stopwatch_Main', Owner);
    if (ServerConfig.IsBTStatsEnabled) Stats_Main = Spawn(class'BTP_Stats_Main', Owner);
    if (ServerConfig.IsBTZeroPingDodgeEnabled) ZeroPing_Main = Spawn(class'BTP_ZeroPing_Main', Owner);
    if (ServerConfig.IsBTCapLoggerEnabled)
    {
        CapLogger_Main = Spawn(class'BTP_CapLogger_Main', Owner);
        CapLogger_Main.Init(PlayerPawn(Owner), CapLogger_File, CapLogger_ServerConfig);
    }
}

function ExecuteCommand(string MutateString)
{
    switch(class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString))
	{
		case "suicide":
            if (Suicide_Main == None)
                ClientMessage("BTP_Suicide_Main module is disabled on this server");
            else
			    Suicide_Main.ExecuteCommand(class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
            break;
		case "stopwatch":
        case "sw":
            if (Stopwatch_Main == None)
                ClientMessage("BTP_Stopwatch_Main module is disabled on this server");
            else
			    Stopwatch_Main.ExecuteCommand(class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
            break;
		case "stats":
            if (Stats_Main == None)
                ClientMessage("BTP_Stats_Main module is disabled on this server");
            else
			    Stats_Main.ExecuteCommand(class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
			break;
        case "zpdodge":
            if (ZeroPing_Main == None)
                ClientMessage("BTP_ZeroPing_Main module is disabled on this server");
            else
			    ZeroPing_Main.ExecuteCommand(class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
			break;
		default: ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
	}
}

function PlayerSpawnedEvent()
{
    if (Stopwatch_Main != None) Stopwatch_Main.PlayerSpawnedEvent();
    if (CapLogger_Main != None) CapLogger_Main.PlayerSpawnedEvent();
    if (ZeroPing_Main != None) ZeroPing_Main.PlayerSpawnedEvent();
    if (Stats_Main != None) Stats_Main.PlayerSpawnedEvent();
}

function PlayerCappedEvent()
{
    if (Stopwatch_Main != None) Stopwatch_Main.PlayerCappedEvent();
    if (CapLogger_Main != None) CapLogger_Main.PlayerCappedEvent();
}

simulated function Tick(float DeltaTime)
{
    if (Role < ROLE_Authority)
    {
        // Calling the 'Tick' functions here such that I have control over the order in which they're called.
        if (ZeroPing_Main != None) ZeroPing_Main.CustomTick(DeltaTime);
        if (Stats_Main != None) Stats_Main.CustomTick(DeltaTime);
        if (CapLogger_Main != None) CapLogger_Main.CustomTick(DeltaTime);
    }
    else
    {
        // Cleanup
        if (Owner == None)
        {
            if (Suicide_Main != None) Suicide_Main.Destroy();
            if (Stopwatch_Main != None) Stopwatch_Main.Destroy();
            if (Stats_Main != None) Stats_Main.Destroy();
            if (ZeroPing_Main != None) ZeroPing_Main.Destroy();
            if (CapLogger_Main != None) CapLogger_Main.Destroy();
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
