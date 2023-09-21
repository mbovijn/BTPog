class BTP_Misc_CapEventPublisher extends Info;

var BTP_Main Subscriber;
var BTP_Misc_ServerConfig ServerConfig;

function Init(BTP_Main aSubscriber, BTP_Misc_ServerConfig aServerConfig)
{
    ServerConfig = aServerConfig;
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
        if (ServerConfig.IsDebugging) Log("FlagBase Event = "$FlagBase.Event);
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
            if (ServerConfig.IsDebugging) Log("Spawning BTP_Misc_CapEventPublisherHelper with Event = "$Events[i]);
            Spawn(class'BTP_Misc_CapEventPublisherHelper', Self, Events[i]);
        }
    }
}

function PawnCappedEvent(Pawn aPawn)
{
    Subscriber.PawnCappedEvent(aPawn);
}
