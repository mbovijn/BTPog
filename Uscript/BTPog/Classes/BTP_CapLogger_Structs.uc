class BTP_CapLogger_Structs extends Object;

struct StatsAnalysis
{
    var float PC1;
    var float PC5;
    var float PC25;
    var float PC50;
    var float PC100;
    var int NumberOfDataPoints;
};

struct StatsMinMaxAnalysis
{
	var int Min;
	var int Max;
};

struct LogData
{
	var String UniqueId;
	var float CapTime;
	var StatsAnalysis DodgeBlock;
	var StatsAnalysis DodgeDoubleTap;
	var StatsAnalysis DodgeAfterLanding;
	var StatsAnalysis TimeBetweenDodges;
	var StatsAnalysis KeyPressesBeforeDodge;
	var StatsAnalysis KeyPressesAfterDodge;
	var StatsAnalysis FPS;
	var StatsAnalysis Ping;
	var StatsMinMaxAnalysis Netspeed;
	var float ClientCapTimeDelta;
	var String ClientEngineVersion;
	var int SpawnCount;
	var String Renderer;
	var String HardwareID;
	var String CustomID;
	var String ZoneCheckpoints;
	var String TrackedLocations;
	var String CustomIDOtherPlayersOnTeam;
};