class BTStopwatchTrigger extends Triggers;

var PlayerPawn PlayerPawn;
var float PlayerSpawnTime;

var float ReTriggerDelay;
var float TriggerTime;

function PreBeginPlay()
{
   PlayerPawn = PlayerPawn(Owner);
}

function SetPlayerSpawnTime(float SpawnTime)
{
    PlayerSpawnTime = SpawnTime;
}

function Touch(Actor Other)
{
	if (PlayerPawn == Other)
	{
		if (ReTriggerDelay > 0)
		{
			if (Level.TimeSeconds - TriggerTime < ReTriggerDelay)
				return;
			TriggerTime = Level.TimeSeconds;
		}

		ClientProgressMessage(class'Utils'.static.TimeDeltaToString(Level.TimeSeconds - PlayerSpawnTime));
	}
}

function Tick(float DeltaTime)
{
	if (Owner == None)
		Destroy();
}

function ClientProgressMessage(string Message)
{
    PlayerPawn.ClearProgressMessages();
    PlayerPawn.SetProgressTime(2);
    PlayerPawn.SetProgressMessage(Message, 6);
}

defaultproperties
{
    ReTriggerDelay=0.500000
}
