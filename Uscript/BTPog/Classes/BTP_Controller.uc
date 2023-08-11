class BTP_Controller extends Info;

var PlayerPawn PlayerPawn;

var BTP_Suicide_Main BTP_Suicide_Main;
var BTP_Stopwatch_Main BTP_Stopwatch_Main;
var BTP_Stats_Main BTP_Stats_Main;
var BTP_ZeroPing_Main BTP_ZeroPing_Main;
var BTP_CapLogger_Main BTP_CapLogger_Main;

replication
{
	// Replicating these objects such that the 'CustomTick' function on each of them can be called from the client.
    reliable if (Role == ROLE_Authority)
		BTP_ZeroPing_Main, BTP_Stats_Main, BTP_CapLogger_Main;
}

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function Init(BTP_Misc_ServerConfig BTP_Misc_ServerConfig, BTP_CapLogger_File BTP_CapLogger_File, BTP_CapLogger_ServerConfig BTP_CapLogger_ServerConfig)
{
    if (BTP_Misc_ServerConfig.IsBTSuicideEnabled) BTP_Suicide_Main = Spawn(class'BTP_Suicide_Main', Owner);
    if (BTP_Misc_ServerConfig.IsBTStopwatchEnabled) BTP_Stopwatch_Main = Spawn(class'BTP_Stopwatch_Main', Owner);
    if (BTP_Misc_ServerConfig.IsBTStatsEnabled) BTP_Stats_Main = Spawn(class'BTP_Stats_Main', Owner);
    if (BTP_Misc_ServerConfig.IsBTZeroPingDodgeEnabled) BTP_ZeroPing_Main = Spawn(class'BTP_ZeroPing_Main', Owner);
    if (BTP_Misc_ServerConfig.IsBTCapLoggerEnabled)
    {
        BTP_CapLogger_Main = Spawn(class'BTP_CapLogger_Main', Owner);
        BTP_CapLogger_Main.Init(PlayerPawn(Owner), BTP_CapLogger_File, BTP_CapLogger_ServerConfig);
    }
}

function ExecuteCommand(string MutateString)
{
	switch(class'BTP_Misc_Utils'.static.GetArgument(MutateString, 1))
	{
		case "suicide":
            if (BTP_Suicide_Main == None)
                ClientMessage("BTP_Suicide_Main module is disabled on this server");
            else
			    BTP_Suicide_Main.ExecuteCommand(MutateString);
            break;
		case "stopwatch":
        case "sw":
            if (BTP_Stopwatch_Main == None)
                ClientMessage("BTP_Stopwatch_Main module is disabled on this server");
            else
			    BTP_Stopwatch_Main.ExecuteCommand(MutateString);
            break;
		case "stats":
            if (BTP_Stats_Main == None)
                ClientMessage("BTP_Stats_Main module is disabled on this server");
            else
			    BTP_Stats_Main.ExecuteCommand(MutateString);
			break;
        case "zpdodge":
            if (BTP_ZeroPing_Main == None)
                ClientMessage("BTP_ZeroPing_Main module is disabled on this server");
            else
			    BTP_ZeroPing_Main.ExecuteCommand(MutateString);
			break;
		default: ClientMessage("Invalid parameters specified. More info at https://github.com/mbovijn/BTPog");
	}
}

function PlayerSpawnedEvent()
{
    if (BTP_Stopwatch_Main != None) BTP_Stopwatch_Main.PlayerSpawnedEvent();
    if (BTP_CapLogger_Main != None) BTP_CapLogger_Main.PlayerSpawnedEvent();
    if (BTP_ZeroPing_Main != None) BTP_ZeroPing_Main.PlayerSpawnedEvent();
    if (BTP_Stats_Main != None) BTP_Stats_Main.PlayerSpawnedEvent();
}

function PlayerCappedEvent()
{
    if (BTP_Stopwatch_Main != None) BTP_Stopwatch_Main.PlayerCappedEvent();
    if (BTP_CapLogger_Main != None) BTP_CapLogger_Main.PlayerCappedEvent();
}

simulated function Tick(float DeltaTime)
{
    if (Role < ROLE_Authority)
    {
        // Calling the 'Tick' functions here such that I have control over the order in which they're called.
        if (BTP_ZeroPing_Main != None) BTP_ZeroPing_Main.CustomTick(DeltaTime);
        if (BTP_Stats_Main != None) BTP_Stats_Main.CustomTick(DeltaTime);
        if (BTP_CapLogger_Main != None) BTP_CapLogger_Main.CustomTick(DeltaTime);
    }
    else
    {
        // Cleanup
        if (Owner == None)
        {
            if (BTP_Suicide_Main != None) BTP_Suicide_Main.Destroy();
            if (BTP_Stopwatch_Main != None) BTP_Stopwatch_Main.Destroy();
            if (BTP_Stats_Main != None) BTP_Stats_Main.Destroy();
            if (BTP_ZeroPing_Main != None) BTP_ZeroPing_Main.Destroy();
            if (BTP_CapLogger_Main != None) BTP_CapLogger_Main.Destroy();
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
