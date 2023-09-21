class BTP_CapLogger_Stats extends Object dependson(BTP_CapLogger_Structs);

var float Values[1024];
var int Index;

function AddValue(float Value)
{
    if (Index == ArrayCount(Values))
    {
        Log("[BTPog/CapLogger] Not recording anymore stats. Too many entries.");
        return;
    }
    Values[Index++] = Value;
}

function BTP_CapLogger_Structs.StatsAnalysis Analyze()
{
    local BTP_CapLogger_Structs.StatsAnalysis StatsAnalysis;

    if (Index > 1) SortArray(0, Index - 1);

    StatsAnalysis.PC1 = Values[0];
    StatsAnalysis.PC5 = Values[int(Index*0.05)];
    StatsAnalysis.PC25 = Values[int(Index*0.25)];
    StatsAnalysis.PC50 = Values[int(Index*0.50)];
    StatsAnalysis.PC100 = Values[Max(Index - 1, 0)];
    StatsAnalysis.NumberOfDataPoints = Index;

    return StatsAnalysis;
}

// Taken from http://www.unreal.ut-files.com/3DEditing/Tutorials/unrealwiki-offline/quicksort.html
function SortArray(int Low, int High)
{
    local int i,j;
    local float x;

    i = Low;
    j = High;
    x = Values[(Low+High)/2];

    do
    {    
        while (Values[i] < x)
            i += 1; 
        while (Values[j] > x)
            j -= 1;
        if (i <= j)
        {
            SwapArray(i,j);
            i += 1; 
            j -= 1;
        }
    } until (i > j);

    if (low < j)
        SortArray(low, j);
    if (i < high)
        SortArray(i, high);
}

function SwapArray(int EL1, int EL2)
{
    local float AZ1;
    local float AZ2;

    AZ2 = Values[EL1];
    AZ1 = Values[EL2];

    Values[EL2] = AZ2;
    Values[EL1] = AZ1;
}
