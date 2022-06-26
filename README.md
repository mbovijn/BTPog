# Author
Fulcrum

# Description
BTPog is a UT99 Mutator most useful for the [Bunnytrack](https://github.com/mbovijn/BTPlusPlusTE_beta3) mod. See the section below to get to know more about the individual modules.

# Modules

## BTZeroPingDodge Module
After having dodged the game blocks you from dodging again for [0.35](https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4254) seconds (0.32 for BT whichs runs on [hardcore](https://github.com/mbovijn/UT99/blob/master/Botpack/DeathMatchPlus.uc#L139) mode). Unfortunately, players with a higher ping experience a large dodge block duration. BTZeroPingDodge's aim is to level the playing field, and provide an equal dodge block duration for all players, regardless of ping.

Click [here](https://github.com/mbovijn/BTPog/blob/master/DodgeBlock.md) to get to know more about why this is happening.

| Command                                           | Description
| ---                                               | ---
| `!btpog zpdodge`                                  | Toggles the functionality on/off. Enabled by default.
| `!btpog zpdodge debug`                            | Toggles the display of a message on/off each time ZeroPingDodge kicks in.

## BTStats Module
Shows the following information on-screen:
- Ground Time = time in seconds you spend on the ground.
- Air Time = time in seconds you spend in the air i.e. when jumping/falling.
- Dodge Double Tap Interval = time in seconds between two consecutive key presses that resulted in a dodge.
- Dodge Block Duration = time in seconds that you're blocked from dodging again after just having dodged.

| Command                                           | Description
| ---                                               | ---
| `!btpog stats`                                    | Toggles the on-screen stats on/off.
| `!btpog stats debug`                              | Toggles debug logging of dodges on/off. These can be found in your `UnrealTournament.log` file.

## BTCapLogger Module
Logs some information each time a player caps. These logs can be found in the UT `Logs` folder. Example:
```
Timestamp,Map,PlayerName,IP,EngineVersion,Renderer,SpawnCount,CapTime,ClientCapTime,DodgeBlock_1PC,DodgeBlock_5PC,DodgeBlock_25PC,DodgeBlock_50PC,DodgeDoubleTap_1PC,DodgeDoubleTap_5PC,DodgeDoubleTap_25PC,DodgeDoubleTap_50PC,DodgeAfterLanding_1PC,DodgeAfterLanding_5PC,DodgeAfterLanding_25PC,DodgeAfterLanding_50PC,FPS_1PC,FPS_5PC,FPS_25PC,FPS_50PC,Ping_1PC,Ping_5PC,Ping_25PC,Ping_50PC
2022-06-26T11:05:05.664,CTF-BT-andAction-dbl,Fulcrum,127.0.0.1,469c - May  4 2022 Preview,OpenGLDrv,1,9.481,+0.084,0.011,0.011,0.319,0.320,0.133,0.133,0.139,0.152,0.000,0.000,0.000,0.000,43,102,191,199,9,9,9,9
2022-06-26T11:05:14.260,CTF-BT-andAction-dbl,Fulcrum,127.0.0.1,469c - May  4 2022 Preview,OpenGLDrv,2,7.656,+0.000,0.010,0.010,0.319,0.319,0.104,0.104,0.122,0.132,0.000,0.000,0.000,0.000,189,197,199,200,9,9,9,9
2022-06-26T11:05:49.127,CTF-BT-andAction-dbl,Fulcrum,127.0.0.1,469c - May  4 2022 Preview,D3D9Drv,1,8.229,-0.092,0.010,0.010,0.016,0.320,0.114,0.114,0.137,0.153,0.000,0.000,0.000,0.000,47,98,188,199,11,11,14,14
2022-06-26T11:05:57.410,CTF-BT-andAction-dbl,Fulcrum,127.0.0.1,469c - May  4 2022 Preview,D3D9Drv,2,7.327,-0.003,0.319,0.319,0.319,0.321,0.122,0.122,0.126,0.143,0.000,0.000,0.000,0.000,192,197,199,200,10,27,27,27
2022-06-26T11:06:05.924,CTF-BT-andAction-dbl,Fulcrum,127.0.0.1,469c - May  4 2022 Preview,D3D9Drv,3,7.325,-0.001,0.319,0.319,0.319,0.320,0.108,0.108,0.133,0.157,0.000,0.000,0.000,0.000,194,194,199,200,10,10,10,10
```
- ClientCapTime: the CapTime from the perspective of the client. This should be roughly equal to the server-side CapTime. If the client-side CapTime is significantly higher than the server-side CapTime, it could mean that the player is using a speed hack.
- DodgeBlock: percentiles on how long a player got blocked from dodging after just having dodged.
- DodgeDoubleTap: percentiles on the time interval between two consecutive key presses which resulted in a dodge.
- DodgeAfterLanding: percentiles on how quick a player dodged after having landed on the ground.
- FPS: percentiles on the FPS of a player. The FPS calculation can be tweaked with the 'TicksPerFPSCalculation' server-side setting.
- Ping: percentiles on the ping of a player.
- SpawnCount: the amount of times a player has spawned before the cap. If the count is 1, it could mean that the player used a reconnect bug to have a faster cap time.

These statistics are interesting if you want to analyze whether a player cheated.

## BTStopwatch Module
Are you sometimes not sure which particular set of moves is faster in order to pass a certain obstacle? Just set a !cp before the obstacle, and a stopwatch after the obstacle. Once you touch the invisible stopwatch, the time it took to reach the stopwatch will appear on screen.

| Command                                           | Description
| ---                                               | ---
| `!btpog stopwatch`                                | Sets an invisible stopwatch at your current location, and deletes any previously set stopwatch.
| `!btpog stopwatch 50,10,-10`                      | Sets an invisible stopwatch at location (50,10,-10), and deletes any previously set stopwatch.

## BTSuicide Module
Got loop movers in the map you want to rush? Use this in order to suicide at the right time, so that when you arrive at the mover, the mover is in the optimal location.

>Not all BT maps are deterministic. Some of them have movers that are looping continuously. So when you try to rush such a map, it usually comes down to a matter of luck when you arrive at such a mover. The mover could be in an optimal position, or not. If not, you're losing valuable time.
What rushers can do is, go to the mover, and suicide when the mover is in a particular position, such that when you respawn and rush the map, the mover is in the optimal location. This works, but it's annoying, since you repeat the whole process over and over again. This mutator is trying to address that by allowing you to queue up a suicide action, and only actually executing the suicide when the mover is in the configured location.

| Command                                            | Description
| ---                                                | ---
| `!btpog suicide select`                            | Select which mover you want to base your suicide time on. Just aim at the mover and execute the command.
| `!btpog suicide time`                              | When the mover is in the correct location, execute this command to set the time.
| `!btpog suicide time 0.35`                         | Same as the previous command, but here you can enter a timepoint yourself.
| `!btpog suicide suicide`                           | Queue up a suicide action. The mutator will make you suicide you as soon as the mover is in the configured location.
| `!btpog suicide fire`                              | Queue up a fire action. The mutator will make you fire as soon as the mover is in the configured location. This was mosly used for debugging.

For ease of use you could bind your suicide key to the suicide command e.g. `set input g mutate btpog suicide suicide`.

# Installation
1. Download the latest release from the [Releases page](https://github.com/mbovijn/BTPog/releases/).
2. Extract the contents of the `Build` folder to the UT99 `System` folder.
3. Configure BTPog accordingly by editing `BTPog.ini`.
4. Add the following lines under the `[Engine.GameEngine]` section in `UnrealTournament.ini`:
```
ServerActors=BTPog_v06.Main
ServerPackages=BTPog_v06
```

# Configuration
As a server admin you can configure which modules you want to be active on your server. Here's an example of a BTPog.ini file:
```
[BTPog_v06.Settings]
IsDebugging=False
IsBTStatsEnabled=True
IsBTStopwatchEnabled=True
IsBTSuicideEnabled=True
IsBTZeroPingDodgeEnabled=True
IsBTCapLoggerEnabled=True

[BTPog_v06.BTCapLoggerSettings]
TicksPerFPSCalculation=10
```
