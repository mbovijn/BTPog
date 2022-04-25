class CapEventPublisher extends Info;

var Main Subscriber;
var Settings Settings;

function Init(Main aSubscriber, Settings aSettings)
{
    Settings = aSettings;
    Subscriber = aSubscriber;

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
        if (Settings.IsDebugging) Log("FlagBase Event = "$FlagBase.Event);
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
            if (Settings.IsDebugging) Log("Spawning CapEventPublisherHelper with Event = "$Events[i]);
            Spawn(class'CapEventPublisherHelper', Self, Events[i]);
        }
    }
}

function PawnCappedEvent(Pawn aPawn)
{
    Subscriber.PawnCappedEvent(aPawn);
}
