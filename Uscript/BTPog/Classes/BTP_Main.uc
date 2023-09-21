class BTP_Main expands Mutator;

var BTP_Controller Controllers[1024];
var int ControllersLength;

var BTP_Misc_ServerConfig ServerConfig;
var BTP_Misc_CapEventPublisher CapEventPublisher;
var BTP_CapLogger_File CapLogger_File;
var BTP_CapLogger_ServerConfig CapLogger_ServerConfig;

// Called once by the engine when the map starts.
function PreBeginPlay()
{
	local Object Obj;

	Log("BTPog by Fulcrum (https://github.com/mbovijn/BTPog)");

	Obj = new (none, 'BTPog') class'Object';
	
	ServerConfig = new (Obj, 'Settings') class'BTP_Misc_ServerConfig';
	ServerConfig.SaveConfig();

	CapLogger_ServerConfig = new (Obj, 'BTCapLoggerSettings') class'BTP_CapLogger_ServerConfig';
	CapLogger_ServerConfig.ValidateConfig();
	CapLogger_ServerConfig.SaveConfig();

	CapEventPublisher = Spawn(class'BTP_Misc_CapEventPublisher');
	CapEventPublisher.Init(Self, ServerConfig);

	CapLogger_File = Spawn(class'BTP_CapLogger_File');
	CapLogger_File.Init(CapLogger_ServerConfig);

	Level.Game.BaseMutator.AddMutator(Self);
	Level.Game.RegisterMessageMutator(Self);
}

// Called by the engine whenever a player execute a mutate command.
function Mutate(string MutateString, PlayerPawn Sender)
{
	if (class'BTP_Misc_Utils'.static.GetFirstArgument(MutateString) ~= "btpog")
		ExecuteCommand(Sender, MutateString);

	Super.Mutate(MutateString, Sender);
}

// Called by the engine whenever a player types in chat.
function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if (Sender == Receiver && PlayerPawn(Sender) != None && class'BTP_Misc_Utils'.static.GetFirstArgument(S) ~= "!btpog")
		ExecuteCommand(PlayerPawn(Sender), S);

	return Super.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
}

// Called by the BTP_Misc_CapEventPublisher whenever a pawn caps. 
function PawnCappedEvent(Pawn Pawn)
{
	if (PlayerPawn(Pawn) != None)
		GetController(PlayerPawn(Pawn)).PlayerCappedEvent();
}

// Called by the engine whenever a player spawns.
function ModifyPlayer(Pawn Other)
{
	local BTP_Controller BTP_Controller;

	if (PlayerPawn(Other) != None && Other.bIsPlayer && !Other.PlayerReplicationInfo.bIsSpectator)
	{
		BTP_Controller = GetControllerOrNew(PlayerPawn(Other));
		BTP_Controller.PlayerSpawnedEvent();
	}
	
	Super.ModifyPlayer(Other);
}

function ExecuteCommand(PlayerPawn Sender, string MutateString)
{
	GetController(Sender).ExecuteCommand(class'BTP_Misc_Utils'.static.GetRemainingArguments(MutateString));
}

function BTP_Controller GetControllerOrNew(PlayerPawn Other)
{
	local BTP_Controller BTP_Controller;

	BTP_Controller = GetController(Other);
	if (BTP_Controller == None)
	{
		BTP_Controller = Spawn(class'BTP_Controller', Other);
		BTP_Controller.Init(ServerConfig, CapLogger_File, CapLogger_ServerConfig);

		Controllers[ControllersLength] = BTP_Controller;
		ControllersLength++;
	}

	return BTP_Controller;
}

function BTP_Controller GetController(PlayerPawn Other)
{
	local int i;
	for (i = 0; i < ControllersLength; i++)
		if (Controllers[i] != None && Controllers[i].PlayerPawn.PlayerReplicationInfo.PlayerID == Other.PlayerReplicationInfo.PlayerID)
			return Controllers[i];
	return None;
}
