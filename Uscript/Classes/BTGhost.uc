class BTGhost extends Actor;

var PlayerPawn PlayerPawn;

var BTGhostRecorder Recorder;
var BTGhostPlayer Player;

var float SpawnTime;

function PreBeginPlay()
{
    PlayerPawn = PlayerPawn(Owner);

    Recorder = Spawn(class'BTGhostRecorder', Owner);
    Player = Spawn(class'BTGhostPlayer', Owner);
}

function PlayerSpawnedEvent()
{
    Recorder.PlayerSpawnedEvent();
    Player.PlayerSpawnedEvent();
}

function PlayerCappedEvent()
{
    Recorder.PlayerCappedEvent();
    Player.PlayerSpawnedEvent();
}

function Tick(float DeltaTime)
{
    if (Owner == None)
    {
		Recorder.Destroy();
        Player.Destroy();
        Destroy();
    }
}
