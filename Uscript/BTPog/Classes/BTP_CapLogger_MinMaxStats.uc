class BTP_CapLogger_MinMaxStats extends Info dependson(BTP_CapLogger_Structs);

var BTP_CapLogger_Structs.StatsMinMaxAnalysis Analysis;

function AddValue(int Value)
{
    if (Value == 0) return;
    
    if (Analysis.Min == 0 || Value < Analysis.Min)
        Analysis.Min = Value;
    if (Analysis.Max == 0 || Value > Analysis.Max)
        Analysis.Max = Value;
}

function BTP_CapLogger_Structs.StatsMinMaxAnalysis Analyze()
{
    return Analysis;
}
