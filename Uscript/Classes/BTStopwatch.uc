class BTStopwatch extends Actor;

var PlayerPawn PlayerPawn;
var BTStopwatchTrigger StopwatchTrigger;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);
}

function PlayerSpawnedEvent()
{
	if (StopwatchTrigger != None) StopwatchTrigger.SetPlayerSpawnTime(Level.TimeSeconds);
}

function ExecuteCommand(string MutateString)
{
	switch (class'Utils'.static.GetArgument(MutateString, 2))
	{
		case "":
			Set(Owner.Location);
			break;
		default: Set(ToVector(class'Utils'.static.GetArgument(MutateString, 2)));
	}
}

function Set(Vector Location)
{
	if (StopwatchTrigger != None) StopwatchTrigger.Destroy();
    StopwatchTrigger = Spawn(class'BTStopwatchTrigger', Owner, , RemoveDecimals(Location));
    ClientMessage("Stopwatch set at location "$ToString(Location)$"");
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
