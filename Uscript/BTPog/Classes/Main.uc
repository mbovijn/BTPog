class Main expands Mutator;

var PlayerController PlayerControllers[1024];
var int PlayerControllersLength;

var ServerSettings ServerSettings;
var CapEventPublisher CapEventPublisher;
var BTCapLoggerFile BTCapLoggerFile;
var BTCapLoggerServerSettings BTCapLoggerServerSettings;

// Called once by the engine when the map starts.
function PreBeginPlay()
{
	local Object Obj;

	Log("BTPog by Fulcrum (https://github.com/mbovijn/BTPog)");

	Obj = new (none, 'BTPog') class'Object';
	
	ServerSettings = new (Obj, 'Settings') class'ServerSettings';
	ServerSettings.SaveConfig();

	BTCapLoggerServerSettings = new (Obj, 'BTCapLoggerSettings') class'BTCapLoggerServerSettings';
	BTCapLoggerServerSettings.ValidateConfig();
	BTCapLoggerServerSettings.SaveConfig();

	CapEventPublisher = Spawn(class'CapEventPublisher');
	CapEventPublisher.Init(Self, ServerSettings);

	BTCapLoggerFile = Spawn(class'BTCapLoggerFile');
	BTCapLoggerFile.Init(BTCapLoggerServerSettings);

	Level.Game.BaseMutator.AddMutator(Self);
	Level.Game.RegisterMessageMutator(Self);
}

// Called by the engine whenever a player execute a mutate command.
function Mutate(string MutateString, PlayerPawn Sender)
{
	if (class'Utils'.static.GetArgument(MutateString, 0) ~= "btpog")
		ExecuteCommand(Sender, MutateString);

	Super.Mutate(MutateString, Sender);
}

// Called by the engine whenever a player types in chat.
function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if (Sender == Receiver && PlayerPawn(Sender) != None && class'Utils'.static.GetArgument(S, 0) ~= "!btpog")
		ExecuteCommand(PlayerPawn(Sender), S);

	return Super.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
}

// Called by the CapEventPublisher whenever a pawn caps. 
function PawnCappedEvent(Pawn Pawn)
{
	if (PlayerPawn(Pawn) != None)
		GetPlayerController(PlayerPawn(Pawn)).PlayerCappedEvent();
}

// Called by the engine whenever a player spawns.
function ModifyPlayer(Pawn Other)
{
	local PlayerController PlayerController;

	if (PlayerPawn(Other) != None && Other.bIsPlayer && !Other.PlayerReplicationInfo.bIsSpectator)
	{
		PlayerController = GetPlayerControllerOrNew(PlayerPawn(Other));
		PlayerController.PlayerSpawnedEvent();
	}
	
	Super.ModifyPlayer(Other);
}

function ExecuteCommand(PlayerPawn Sender, string MutateString)
{
	GetPlayerController(Sender).ExecuteCommand(MutateString);
}

function PlayerController GetPlayerControllerOrNew(PlayerPawn Other)
{
	local PlayerController PlayerController;

	PlayerController = GetPlayerController(Other);
	if (PlayerController == None)
	{
		if (ServerSettings.IsDebugging) Log("[BTPog] New player registered = "$Other.PlayerReplicationInfo.PlayerName);

		PlayerController = Spawn(class'PlayerController', Other);
		PlayerController.Init(ServerSettings, BTCapLoggerFile, BTCapLoggerServerSettings);

		PlayerControllers[PlayerControllersLength] = PlayerController;
		PlayerControllersLength++;
	}

	return PlayerController;
}

function PlayerController GetPlayerController(PlayerPawn Other)
{
	local int i;
	for (i = 0; i < PlayerControllersLength; i++)
		if (PlayerControllers[i] != None && PlayerControllers[i].PlayerPawn.PlayerReplicationInfo.PlayerID == Other.PlayerReplicationInfo.PlayerID)
			return PlayerControllers[i];
	return None;
}
