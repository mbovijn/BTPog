class BTP_Suicide_Structs extends Object;

struct MoverTracker {
    var string Name;
    var float TimePoint;
    var float Alpha;
};

struct MoverTrackerCollection {
    var string Map;
    var byte Team;
    var MoverTracker MoverTrackers[4];
};

static function MoverTrackerCollection CreateEmptyMoverTrackerCollection(string Map, byte Team)
{
    local MoverTrackerCollection M;
    M.Map = Map;
    M.Team = Team;
    return M;
}
