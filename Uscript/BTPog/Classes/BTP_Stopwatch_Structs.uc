class BTP_Stopwatch_Structs extends Object;

struct ClientConfigDto {
    var int PrecisionDecimals;
    var float ReTriggerDelay;
    var bool DisplayTimes;
};

struct Stopwatch {
	var float Time;
	var string Loc;
};

struct StopwatchCollection {
    var string Map;
    var byte Team;
    var float Time;
    var Stopwatch Sw[14];
};

static function StopwatchCollection CreateEmptyStopwatchCollection(string Map, byte Team)
{
    local StopwatchCollection S;
    S.Map = Map;
    S.Team = Team;
    return S;
}
