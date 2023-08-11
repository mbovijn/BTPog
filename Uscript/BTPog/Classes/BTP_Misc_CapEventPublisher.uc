class BTP_Misc_CapEventPublisher extends Info;

var Main Subscriber;
var BTP_Misc_ServerConfig BTP_Misc_ServerConfig;

function Init(Main aSubscriber, BTP_Misc_ServerConfig aBTP_Misc_ServerConfig)
{
    BTP_Misc_ServerConfig = aBTP_Misc_ServerConfig;
    Subscriber = aSubscriber;

    SetupFlagBaseSubscriptions();
}

function SetupFlagBaseSubscriptions()
{
    local name Events[16];

    SetEventIfNotExistsOnAllFlagBases();
    GetUniqueEventsFromAllFlagBases(Events);

    SpawnBTP_Misc_CapEventPublisherHelpers(Events);
}

function SetEventIfNotExistsOnAllFlagBases()
{
    local FlagBase FlagBase;
    foreach AllActors(class'FlagBase', FlagBase)
    {
        if (BTP_Misc_ServerConfig.IsDebugging) Log("FlagBase Event = "$FlagBase.Event);
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

function SpawnBTP_Misc_CapEventPublisherHelpers(name Events[16]) {
    local int i;
    for (i = 0; i < ArrayCount(Events); i++)
    {
        if (Events[i] != '')
        {
            if (BTP_Misc_ServerConfig.IsDebugging) Log("Spawning BTP_Misc_CapEventPublisherHelper with Event = "$Events[i]);
            Spawn(class'BTP_Misc_CapEventPublisherHelper', Self, Events[i]);
        }
    }
}

function PawnCappedEvent(Pawn aPawn)
{
    Subscriber.PawnCappedEvent(aPawn);
}
