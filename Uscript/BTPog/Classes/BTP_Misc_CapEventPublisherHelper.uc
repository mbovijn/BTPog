class BTP_Misc_CapEventPublisherHelper extends Info;

var BTP_Misc_CapEventPublisher CapEventPublisher;

function PreBeginPlay()
{
    CapEventPublisher = BTP_Misc_CapEventPublisher(Owner);
}

// This function will be called by the FlagBase when a player caps.
function Trigger(Actor Other, Pawn EventInstigator)
{
    CapEventPublisher.PawnCappedEvent(EventInstigator);
}
