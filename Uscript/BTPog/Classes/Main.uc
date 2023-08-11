class Main expands Mutator;

var BTP_Controller BTP_Controllers[1024];
var int BTP_ControllersLength;

var BTP_Misc_ServerConfig BTP_Misc_ServerConfig;
var BTP_Misc_CapEventPublisher BTP_Misc_CapEventPublisher;
var BTP_CapLogger_File BTP_CapLogger_File;
var BTP_CapLogger_ServerConfig BTP_CapLogger_ServerConfig;

// Called once by the engine when the map starts.
function PreBeginPlay()
{
	local Object Obj;

	Log("BTPog by Fulcrum (https://github.com/mbovijn/BTPog)");

	Obj = new (none, 'BTPog') class'Object';
	
	BTP_Misc_ServerConfig = new (Obj, 'Settings') class'BTP_Misc_ServerConfig';
	BTP_Misc_ServerConfig.SaveConfig();

	BTP_CapLogger_ServerConfig = new (Obj, 'BTCapLoggerSettings') class'BTP_CapLogger_ServerConfig';
	BTP_CapLogger_ServerConfig.ValidateConfig();
	BTP_CapLogger_ServerConfig.SaveConfig();

	BTP_Misc_CapEventPublisher = Spawn(class'BTP_Misc_CapEventPublisher');
	BTP_Misc_CapEventPublisher.Init(Self, BTP_Misc_ServerConfig);

	BTP_CapLogger_File = Spawn(class'BTP_CapLogger_File');
	BTP_CapLogger_File.Init(BTP_CapLogger_ServerConfig);

	Level.Game.BaseMutator.AddMutator(Self);
	Level.Game.RegisterMessageMutator(Self);
}

// Called by the engine whenever a player execute a mutate command.
function Mutate(string MutateString, PlayerPawn Sender)
{
	if (class'BTP_Misc_Utils'.static.GetArgument(MutateString, 0) ~= "btpog")
		ExecuteCommand(Sender, MutateString);

	Super.Mutate(MutateString, Sender);
}

// Called by the engine whenever a player types in chat.
function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if (Sender == Receiver && PlayerPawn(Sender) != None && class'BTP_Misc_Utils'.static.GetArgument(S, 0) ~= "!btpog")
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
		BTP_Controller = GetBTP_ControllerOrNew(PlayerPawn(Other));
		BTP_Controller.PlayerSpawnedEvent();
	}
	
	Super.ModifyPlayer(Other);
}

function ExecuteCommand(PlayerPawn Sender, string MutateString)
{
	GetController(Sender).ExecuteCommand(MutateString);
}

function BTP_Controller GetBTP_ControllerOrNew(PlayerPawn Other)
{
	local BTP_Controller BTP_Controller;

	BTP_Controller = GetController(Other);
	if (BTP_Controller == None)
	{
		if (BTP_Misc_ServerConfig.IsDebugging) Log("[BTPog] New player registered = "$Other.PlayerReplicationInfo.PlayerName);

		BTP_Controller = Spawn(class'BTP_Controller', Other);
		BTP_Controller.Init(BTP_Misc_ServerConfig, BTP_CapLogger_File, BTP_CapLogger_ServerConfig);

		BTP_Controllers[BTP_ControllersLength] = BTP_Controller;
		BTP_ControllersLength++;
	}

	return BTP_Controller;
}

function BTP_Controller GetController(PlayerPawn Other)
{
	local int i;
	for (i = 0; i < BTP_ControllersLength; i++)
		if (BTP_Controllers[i] != None && BTP_Controllers[i].PlayerPawn.PlayerReplicationInfo.PlayerID == Other.PlayerReplicationInfo.PlayerID)
			return BTP_Controllers[i];
	return None;
}
