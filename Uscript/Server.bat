@echo off
cd C:\Program Files (x86)\Unreal Tournament GOTY\

if [%1]==[] exit

System\ucc.exe server CTF-%1?game=BTPlusPlusPublicUTBT_fork.BunnyTrackGame?Mutator=MapVoteLAv2.BDBMapVote
