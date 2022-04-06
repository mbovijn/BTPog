class BTStopwatch extends Mutator;

var PlayerPawn PlayerPawn;
var BTStopwatchTrigger Stopwatch;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
	Level.Game.BaseMutator.AddMutator(self);
}

// Called by the engine whenever a player spawns.
function ModifyPlayer(Pawn Other)
{
	if (PlayerPawn.PlayerReplicationInfo.PlayerID == Other.PlayerReplicationInfo.PlayerID)
		SetPlayerSpawnTime(Level.TimeSeconds);

	Super.ModifyPlayer(Other);
}

function SetPlayerSpawnTime(float SpawnTime)
{
	if (Stopwatch != None)
	{
		PlayerPawn.ClientMessage("DEBUG - Setting player spawn time"); // To figure out the bug
		Stopwatch.SetPlayerSpawnTime(SpawnTime);
	}
}

function ExecuteCommand(string MutateString)
{
	switch(class'Utils'.static.GetArgument(MutateString, 2))
	{
		case "set":
			switch (class'Utils'.static.GetArgument(MutateString, 3))
			{
				case "":
					Set(Owner.Location);
					break;
				default: Set(ToVector(class'Utils'.static.GetArgument(MutateString, 3)));
			}
			break;
		case "clear":
			Clear();
			break;
		default:
	}
}

function Set(Vector Location)
{
	if (Stopwatch != None) Stopwatch.Destroy();
    Stopwatch = Spawn(class'BTStopwatchTrigger', Owner, , RemoveDecimals(Location));
    ClientMessage("Set stopwatch at location ("$ToString(Location)$")");
}

function Clear()
{
    if (Stopwatch != None)
	{
		Stopwatch.Destroy();
		Stopwatch = None;
		ClientMessage("Cleared stopwatch.");
	}
}

function Vector ToVector(String VectorString)
{
	local Vector NewVector;
	NewVector.X = int(class'Utils'.static.GetStringPart(VectorString, 0, ","));
	NewVector.Y = int(class'Utils'.static.GetStringPart(VectorString, 1, ","));
	NewVector.Z = int(class'Utils'.static.GetStringPart(VectorString, 2, ","));
	return NewVector;
}

function Vector RemoveDecimals(Vector OldVector)
{
	local Vector NewVector;
	NewVector.X = int(OldVector.X);
	NewVector.Y = int(OldVector.Y);
	NewVector.Z = int(OldVector.Z);
	return NewVector;
}

function string ToString(Vector Vector)
{
	return int(Vector.X)$","$int(Vector.Y)$","$int(Vector.Z);
}

function ClientMessage(string Message)
{
    PlayerPawn.ClientMessage("[BTPog] "$Message);
}
