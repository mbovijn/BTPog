// TODO: test with flagbase which has event set
class CapEventPublisher extends Actor;

var Main Subscriber;

function PreBeginPlay()
{
    Subscriber = Main(Owner);

    SetupFlagBaseSubscriptions();
}

function SetupFlagBaseSubscriptions()
{
    local name Events[16];

    SetEventIfNotExistsOnAllFlagBases();
    GetUniqueEventsFromAllFlagBases(Events);

    SpawnCapEventPublisherHelpers(Events);
}

function SetEventIfNotExistsOnAllFlagBases()
{
    local FlagBase FlagBase;
    foreach AllActors(class'FlagBase', FlagBase)
    {
        Log("FlagBase Event = "$FlagBase.Event); // TODO: only log if isDebuggingEnabled
        if (FlagBase.Event == '') FlagBase.Event = 'BTPog';
    }
}

function GetUniqueEventsFromAllFlagBases(out name Events[16]) {
    local FlagBase FlagBase;
    foreach AllActors(class'FlagBase', FlagBase)
        AddEventIfNotThereYet(FlagBase.Event, Events);
}

function AddEventIfNotThereYet(name Event, out name Events[16])
{
    local int i;
    for (i = 0; i < ArrayCount(Events); i++)
        if (Events[i] == Event) return;
    for (i = 0; i < ArrayCount(Events); i++)
        if (Events[i] == '') break;
    Events[i] = Event;
}

function SpawnCapEventPublisherHelpers(name Events[16]) {
    local int i;
    for (i = 0; i < ArrayCount(Events); i++)
    {
        if (Events[i] != '')
        {
            Log("Spawning CapEventPublisherHelper with Event = "$Events[i]); // TODO: only log if isDebuggingEnabled
            Spawn(class'CapEventPublisherHelper', Self, Events[i]);
        }
    }
}

function PlayerCappedEvent(Pawn Player)
{
    Subscriber.PlayerCappedEvent(Player);
}
