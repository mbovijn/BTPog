# Description
BTPog is a Unreal Tournament (UT99) ServerActor to enhance the [Bunnytrack](https://github.com/mbovijn/BTPlusPlusTE_beta3) experience. See the section below to get to know more about the individual modules.

# Modules

## ZeroPing Module
<details>
<summary>Click for more info</summary><p>

After having dodged the game blocks you from dodging again for [0.35](https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4254) seconds (0.32 for BT whichs runs on [hardcore](https://github.com/mbovijn/UT99/blob/master/Botpack/DeathMatchPlus.uc#L139) mode). Unfortunately, players with a higher ping experience a large dodge block duration. BTP_ZeroPing_Main's aim is to level the playing field, and provide an equal dodge block duration for all players, regardless of ping.

Click [here](https://github.com/mbovijn/BTPog/blob/master/DodgeBlock.md) to get to know more about why this is happening.

| Command                                           | Description
| ---                                               | ---
| `!btpog zpdodge`                                  | Toggles the functionality on/off. Enabled by default.
| `!btpog zpdodge debug`                            | Toggles the display of a message on/off each time ZeroPingDodge kicks in.
</details>

## Stats Module
<details>
<summary>Click for more info</summary><p>

Shows the following information on-screen:
#### Ground Time
Time in seconds you spent on the ground.
#### Air Time
Time in seconds you spent in the air i.e. when jumping/falling.
#### Dodge Double Tap Interval
Time in seconds between two consecutive key presses that resulted in a dodge.
#### Dodge Block Duration
Time in seconds that you're blocked from dodging again after just having dodged.
#### Time Between Dodges
Time between the end of the last dodge (player landed), and the beginning of the next dodge.
#### Tick Hit Rate
This can be used to measure how effective you're able to bounce. In order to bounce, you need to jump on the exact tick that your character landed on the ground. So generally people do this by binding jump to the scroll wheel, as you're able to input jumps way faster like that.

To use this, first change your scoll wheel bind as follows: `set input mousewheeldown jump | btpoginputtest`. Now, each time you jump with the scroll wheel, you'll see a stat such as for example `0.068 (5/73)`. This means that for a duration of 73 ticks, UT99 registered 5 jump inputs, with the first and last ticks (of those 73 ticks) being ticks with jump inputs.

You'll want to strive to get this value to `1.000`. This can be done by:
- Lowering your FPS with the command `fps <number>`.
- Buying a mouse which allows you to "unlock" the scroll wheel.
- Buying a mouse with a high polling rate. Generally bluetooth mice have a very low polling rate. Test this [here](https://www.clickspeedtester.com/mouse-polling-rate-checker/).

Though, from my experience, even with a value `1.000`, bouncing would sometimes still not work. I don't know why.. But lowering my FPS helped.
#### Key Presses Before Dodge
The amount of key presses just before a dodge occurs.

| Command                                           | Description
| ---                                               | ---
| `!btpog stats`                                    | Toggles the on-screen stats on/off.
| `!btpog stats debug`                              | Toggles debug logging for stats on/off. These can be found in your `UnrealTournament.log` file.
</details>

## CapLogger Module
<details>
<summary>Click for more info</summary><p>

Logs some information each time a player caps. These logs can be found in the UT `Logs` folder. Example:
```
Id,Timestamp,ServerName,Map,PlayerName,IP,CustomID,CustomIDOtherPlayersOnTeam,HWID,EngineVersion,Renderer,SpawnCount,Team,CapTime,ClientCapTime,ZoneCheckpoints,TrackedLocations,DodgeBlock_1PC,DodgeBlock_5PC,DodgeBlock_25PC,DodgeBlock_50PC,DodgeBlock_100PC,DodgeBlock_Count,DodgeDoubleTap_1PC,DodgeDoubleTap_5PC,DodgeDoubleTap_25PC,DodgeDoubleTap_50PC,DodgeDoubleTap_100PC,DodgeDoubleTap_Count,DodgeAfterLanding_1PC,DodgeAfterLanding_5PC,DodgeAfterLanding_25PC,DodgeAfterLanding_50PC,DodgeAfterLanding_100PC,DodgeAfterLanding_Count,TimeBetweenDodges_1PC,TimeBetweenDodges_5PC,TimeBetweenDodges_25PC,TimeBetweenDodges_50PC,TimeBetweenDodges_100PC,TimeBetweenDodges_Count,FPS_1PC,FPS_5PC,FPS_25PC,FPS_50PC,Ping_1PC,Ping_5PC,Ping_25PC,Ping_50PC,Netspeed_Min,Netspeed_Max
BOESRVETOZE8JRU8ARPTSK86,2023-09-18T20:14:11.845,UT Server,CTF-BT-andACTION-dbl,Ful,127.0.0.1,227009880093884416,,,469d - Aug  9 2023 Preview,OpenGLDrv,1,1,8.544,+0.057,,1143.553711|-700.053894|-768.297058|4.598;,0.318,0.318,0.319,0.320,0.322,4,0.072,0.072,0.131,0.163,0.191,5,0.000,0.000,0.000,0.000,0.000,0,0.000,0.000,0.000,0.000,0.000,0,166,182,184,185,24,24,24,24,25000,25000
```
- ClientCapTime: the CapTime from the perspective of the client. This should be roughly equal to the server-side CapTime. If the client-side CapTime is significantly higher than the server-side CapTime, it could mean that the player is using a speed hack. See [this diagram](https://github.com/mbovijn/BTPog/blob/master/Resources/ClientCapTime.drawio.png) for more information on how this works.
- DodgeBlock: percentiles on how long a player got blocked from dodging after just having dodged.
- DodgeDoubleTap: percentiles on the time interval between two consecutive key presses which resulted in a dodge.
- DodgeAfterLanding: percentiles on how quick a player dodged after having landed on the ground. Only values below 0.2 seconds are taken into account.
- TimeBetweenDodges: percentiles on the time between the end of the last dodge (player landed), and the beginning of the next dodge. Only values below 0.6 seconds are taken into account.
- KeyPressesBeforeDodge: percentiles on the amount of key presses before a dodge. Normally this value should be always 2. 
- FPS: percentiles on the FPS of a player. The FPS calculation can be tweaked with the 'TicksPerFPSCalculation' server-side setting.
- Ping: percentiles on the ping of a player.
- SpawnCount: the amount of times a player has spawned before the cap. If the count is 1, it could mean that the player used a reconnect bug to have a faster cap time.
- HWID: ACE hardware ID. If ACE isn't installed on the server this value will be left empty.
- CustomID: if the `IdPropertyToLog` field is configured in BTPog.ini, then the value associated with the propery will be logged. For example, if you wish to log the ACE HWID, then `ACEReplicationInfo.hwHash` would have to be provided. `ACEReplicationInfo` is the class name, and `hwHash` is a property in that class. All that's required is that the actor instance has the Owner field set to the PlayerPawn in question.
- ZoneCheckpoints: when a player runs through a map and caps, he/she will usually transition through different zones. Each time the player changes zone, the current time and zone identifiers are stored.
- Id: unique identifier for the cap.
- ServerName: identifies which server a cap was made on. This value is taken from the server INI from the `ShortName` key under `[Engine.GameReplicationInfo]`.
- TrackedLocations: every X seconds the player location will be logged together with the player's timer. Can be configured with `MaxTrackedLocations` and `TrackedLocationPeriod` in the ServerSettings.
- CustomIDOtherPlayersOnTeam: similar to the `CustomID` field, but for other players on the team of the player that capped.

These statistics are interesting if you want to analyze whether a player cheated. You could also use this data to keep track of player caps.
</details>

## Stopwatch Module
<details>
<summary>Click for more info</summary><p>

Are you sometimes not sure which particular set of moves is faster in order to pass a certain obstacle? Just set a !cp before the obstacle, and a stopwatch after the obstacle. Once you touch the invisible stopwatch, the time it took to reach the stopwatch will appear on screen.

You could also set stopwatches when rushing in order to get quicker feedback on how the run is going. On top of that, whenever you cap and it's a personal best, the individual stopwatch times are saved, in order to give a delta time for the next run.

| Command                                           | Description
| ---                                               | ---
| `!btpog sw` or `!btpog sw <id>`                   | Sets an invisible stopwatch at your current location. You can set up to 14 stopwatches. Valid id values: 0, 1, 2, ... 13
| `!btpog sw <id> 50,10,-10`                        | Sets an invisible stopwatch at location 50,10,-10.
| `!btpog sw reset`                                 | Removes the best times associated with all stopwatches.
| `!btpog sw delete <id>/all`                       | Delete a stopwatch. Valid id values: 0, 1, 2, ... 31, all
| `!btpog sw precision 3`                           | Sets the amount of decimals after the dot for stopwatch times. Defaults to 2 (e.g. 8.63), but any value between 0 and 3 is valid.
| `!btpog sw print`                                 | Prints all configured stopwatches with parameters to the console.
| `!btpog sw toggle`                                | Turns on/off the display of the stopwatch times when you go over them.
| `!btpog sw retriggerdelay 0.5`                    | How many seconds after having triggered a stopwatch, should it be triggerable again? The default value is set to 1.5, but any value between 0.2 and 10 is valid.
| `!btpog sw texture`                               | Hide or show stopwatches.
</details>

## Suicide Module
<details>
<summary>Click for more info</summary><p>

Got loop movers in the map you want to rush? Use this in order to suicide at the right time, so that when you arrive at the mover, the mover is in the optimal location.

>Not all BT maps are deterministic. Some of them have movers that are looping continuously. So when you try to rush such a map, it usually comes down to a matter of luck when you arrive at such a mover. The mover could be in an optimal position, or not. If not, you're losing valuable time.
What rushers can do is, go to the mover, and suicide when the mover is in a particular position, such that when you respawn and rush the map, the mover is in the optimal location. This works, but it's annoying, since you repeat the whole process over and over again. This mutator is trying to address that by allowing you to queue up a suicide action, and only actually executing the suicide when the mover is in the configured location.

Up to 4 movers can be selected. As such, when executing some commands, a slot/id needs to be specified. Values values are 0, 1, 2 and 3.

| Command                                            | Description
| ---                                                | ---
| `!btpog suicide <id> select`                       | Select which mover you want to base your suicide time on. Just aim at the mover and execute the command.
| `!btpog suicide <id> select Mover12`               | Select which mover you want to base your suicide time on by providing the name of the mover.
| `!btpog suicide <id> time`                         | When the mover is in the correct location, execute this command to set the time.
| `!btpog suicide <id> time 0.35`                    | Same as the previous command, but here you can enter a timepoint yourself.
| `!btpog suicide <id> alpha 0.1`                    | How much time the suicide can deviate from the configured time value. This is needed when tracking multiple movers.
| `!btpog suicide suicide`                           | Queue up a suicide action. The mutator will make you suicide you as soon as the movers are in the configured location.
| `!btpog suicide print`                             | Prints all selected movers with parameters to the screen.

For ease of use you could bind your suicide key to the suicide command e.g. `set input g mutate btpog suicide suicide`.

# Installation
1. Download the latest release from the [Releases page](https://github.com/mbovijn/BTPog/releases/).
2. Extract the contents of the `Build` folder to the UT99 `System` folder.
3. Configure BTPog accordingly by editing `BTPog.ini`.
4. Add the following lines under the `[Engine.GameEngine]` section in `UnrealTournament.ini`:
```
ServerActors=BTPog_v21.BTP_Main
ServerPackages=BTPog_v21
```
</details><p>

# Configuration
As a server admin you can configure which modules you want to be active on your server. Here's an example of a BTPog.ini file:
```
[Settings]
IsDebugging=False
IsBTStatsEnabled=True
IsBTStopwatchEnabled=True
IsBTSuicideEnabled=True
IsBTZeroPingDodgeEnabled=True
IsBTCapLoggerEnabled=True

[BTCapLoggerSettings]
TicksPerFPSCalculation=10
IdPropertyToLog=
FilePerCap=False
IsDebugging=False
```
