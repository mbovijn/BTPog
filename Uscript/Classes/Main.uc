class Main expands Mutator;

var Controller Controllers[1024];
var int ControllersLength;

// Called once by the engine when the map starts.
function PreBeginPlay()
{
	Log("BTPog by Fulcrum (https://github.com/mbovijn/BTPog)");

	Spawn(class'CapEventPublisher', Self);

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
	if (class'Utils'.static.GetArgument(S, 0) ~= "!btpog")
		ExecuteCommand(PlayerPawn(Sender), S);

	return Super.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
}

// Called by the CapEventPublisher whenever a player caps.
function PlayerCappedEvent(Pawn Pawn)
{
	GetController(Pawn).PlayerCappedEvent();
}

// Called by the engine whenever a player spawns.
function ModifyPlayer(Pawn Other)
{
	local Controller Controller;

	if (PlayerPawn(Other) != None && Other.bIsPlayer && !Other.PlayerReplicationInfo.bIsSpectator)
	{
		Controller = GetControllerOrNew(Other);
		Controller.PlayerSpawnedEvent();
	}
	
	Super.ModifyPlayer(Other);
}

function ExecuteCommand(PlayerPawn Sender, string MutateString)
{
	GetController(Sender).ExecuteCommand(MutateString);
}

function Controller GetControllerOrNew(Pawn Other)
{
	local Controller Controller;

	Controller = GetController(Other);
	if (Controller == None)
	{
		Controller = Spawn(class'Controller', Other);
		Controllers[ControllersLength] = Controller;
		ControllersLength++;
	}

	return Controller;
}

function Controller GetController(Pawn Other)
{
	local int i;
	for (i = 0; i < ControllersLength; i++)
		if (Controllers[i] != None && Controllers[i].PlayerPawn.PlayerReplicationInfo.PlayerID == Other.PlayerReplicationInfo.PlayerID)
			return Controllers[i];
	return None;
}
