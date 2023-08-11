class BTP_CapLogger_MinMaxStats extends BTP_CapLogger_Abstract;

var StatsMinMaxAnalysis Analysis;

function AddValue(int Value)
{
    if (Value == 0) return;
    
    if (Analysis.Min == 0 || Value < Analysis.Min)
        Analysis.Min = Value;
    if (Analysis.Max == 0 || Value > Analysis.Max)
        Analysis.Max = Value;
}

function StatsMinMaxAnalysis Analyze()
{
    return Analysis;
}
