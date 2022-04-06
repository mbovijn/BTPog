class CapEventPublisherHelper extends Actor;

var CapEventPublisher CapEventPublisher;

function PreBeginPlay()
{
    CapEventPublisher = CapEventPublisher(Owner);
}

// This function will be called by the FlagBase when a player caps.
function Trigger(Actor Other, Pawn EventInstigator)
{
    CapEventPublisher.PlayerCappedEvent(EventInstigator);
}
