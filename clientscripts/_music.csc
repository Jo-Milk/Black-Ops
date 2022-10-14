#include clientscripts\_utility;
music_init()
{
level.activeMusicState = "";
level.nextMusicState = "";
level.musicStates = [];
level.musicEnt = spawnfakeent(0);
level.stingerEnt = spawnfakeent(0);
thread updateMusic();
thread musicSaveWait();
registerSystem("musicCmd", ::musicCmdHandler);
}
musicSaveWait()
{
for(;;)
{
level waittill("save_restore");
if(level.nextMusicState == "")
level.nextMusicState = level.activeMusicState;
level.activeMusicState = "";
println("resetting music state to "+level.nextMusicState);
states = getArrayKeys( level.musicStates );
for ( i = 0; i < states.size; i++ )
{
stopLoopSound( 0, level.musicStates[states[i]].aliasEnt, 0 );
}
thread updateMusic();
}
}
musicCmdHandler(clientNum, state, oldState)
{
if(clientNum != 0)
return;
level.nextMusicState = state;
println("music debug: got state '"+state+"'");
level notify("new_music");
}
updateMusic()
{
level endon("save_restore");
while(1)
{
if(level.activeMusicState == level.nextMusicState)
level waittill("new_music");
if(level.activeMusicState == level.nextMusicState)
continue;
active = level.activeMusicState;
next = level.nextMusicState;
if(next != "" && !isdefined(level.musicStates[next]))
{
assertmsg("unknown music state '"+next+"'");
level.nextMusicState = level.activeMusicState;
continue;
}
if(active != "")
transitionOut(active, next);
if(next != "")
transitionIn(active, next);
level.activeMusicState = next;
}
}
fadeOutAndStopSound(id, time)
{
rate = 0;
if(isdefined(time) && time != 0)
rate = 1.0 / time;
setSoundVolumeRate(id, rate);
setSoundVolume(id, 0.0);
wait(time);
stopSound(id);
}
transitionOut(previous, next)
{
if(previous == "")
return;
println("music transition out state "+next);
if(!isdefined(level.musicStates[previous]))
{
assertmsg("unknown music state '"+previous+"'");
return;
}
ent = level.musicStates[previous].aliasEnt;
loopalias = level.musicStates[previous].loopalias;
oneshotalias = level.musicStates[previous].oneshotalias;
fadeout = level.musicStates[previous].fadeout;
waittilldone = level.musicStates[previous].waittilldone;
waittillstingerdone = level.musicStates[previous].waittillstingerdone;
stinger = level.musicStates[previous].stinger;
id = level.musicStates[previous].id;
startDelay = level.musicStates[previous].startDelay;
forceStinger = level.musicStates[previous].forceStinger;
if(next == "")
{
nextloopalias = "";
nextoneshotalias = "";
}
else
{
nextloopalias = level.musicStates[next].loopalias;
nextoneshotalias = level.musicStates[next].oneshotalias;
}
stingerid = -1;
loopMatches = loopalias == nextloopalias;
haveOneShot = nextoneshotalias != "";
if(stinger != "" && (!loopMatches || haveOneShot || forceStinger))
{
stingerid = playSound(0, stinger, (0,0,0));
}
if(loopalias != "")
{
if(loopalias != nextloopalias || nextoneshotalias != "")
{
stopLoopSound( 0, ent, fadeout );
if(waittilldone)
{
wait(fadeout);
}
}
else
{
}
}
else
{
if(waittilldone)
{
while(SoundPlaying(id))
{
wait(.01);
}
}
else
{
thread fadeOutAndStopSound(id,fadeout);
}
}
while(startDelay > 0 && SoundPlaying(stingerid) && GetPlaybackTime(stingerid) < startDelay * 1000)
wait(.01);
if(waittillstingerdone)
{
while(SoundPlaying(stingerid))
wait(.01);
}
if(loopalias != nextloopalias)
level.musicStates[previous].id = -1;
}
transitionIn(previous, next)
{
ent = level.musicStates[next].aliasEnt;
loopalias = level.musicStates[next].loopalias;
oneshotalias = level.musicStates[next].oneshotalias;
fadein = level.musicStates[next].fadein;
loop	= level.musicStates[next].loop;
println("music transition in state "+next);
if(previous == "")
{
oldloopalias = "";
oldoneshotalias = "";
oldid = -1;
oldstartDelay = 0;
startDelay = 0;
}
else
{
oldloopalias = level.musicStates[previous].loopalias;
oldoneshotalias = level.musicStates[previous].oneshotalias;
oldid = level.musicStates[previous].id;
}
if(oneshotalias != "")
{
level.musicStates[next].id = playSound( 0, oneshotalias, (0,0,0) );
if(loopalias != "")
{
while(SoundPlaying(level.musicStates[next].id) )
{
length = GetKnownLength(level.musicStates[next].id);
time = 0;
if(length != 0)
{
time = GetPlaybackTime(level.musicStates[next].id);
if(length-time <= fadein*1000 )
break;
}
wait(.01);
}
}
}
if(oldloopalias == loopalias && oldid != -1 && oneshotalias == "")
{
level.musicStates[next].id = level.musicStates[previous].id;
level.musicStates[previous].id = -1;
oldent = level.musicStates[previous].aliasEnt;
level.musicStates[previous].aliasEnt = level.musicStates[next].aliasEnt;
level.musicStates[next].aliasEnt = oldent;
}
else if(loopalias != "")
{
level.musicStates[next].id = playLoopSound( 0, ent, loopalias, fadein );
}
}
declareMusicState(name)
{
if ( isdefined( level.musicStates[name] ) )
return;
level.musicDeclareName = name;
level.musicStates[name] = spawnStruct();
level.musicStates[name].aliasEnt = spawnfakeent(0);
level.musicStates[name].loopalias = "";
level.musicStates[name].oneshotalias = "";
level.musicStates[name].fadein = 0;
level.musicStates[name].fadeout = 0;
level.musicStates[name].id = -1;
level.musicStates[name].waittilldone = false;
level.musicStates[name].stinger = "";
level.musicStates[name].waittillstingerdone = false;
level.musicStates[name].startDelay = 0;
level.musicStates[name].forceStinger = false;
}
musicWaitTillDone()
{
assert(isdefined(level.musicDeclareName));
name = level.musicDeclareName;
level.musicStates[name].waittilldone = true;
}
musicWaitTillStingerDone()
{
assert(isdefined(level.musicDeclareName));
name = level.musicDeclareName;
level.musicStates[name].waittillstingerdone = true;
}
musicStinger(stinger, delay, force)
{
assert(isdefined(level.musicDeclareName));
if(!isdefined(delay))
delay = 0;
name = level.musicDeclareName;
level.musicStates[name].stinger = stinger;
level.musicStates[name].startDelay = delay;
if(isdefined(force))
{
level.musicStates[name].forceStinger = force;
}
}
_musicAlias(alias, fadein, fadeout, loop)
{
assert(isdefined(level.musicDeclareName));
name = level.musicDeclareName;
if(loop)
level.musicStates[name].loopalias = alias;
else
level.musicStates[name].oneshotalias = alias;
level.musicStates[name].fadein = fadein;
level.musicStates[name].fadeout = fadeout;
}
musicAliasLoop(alias, fadein, fadeout)
{
_musicAlias(alias, fadein, fadeout, true);
}
musicAlias(alias, fadeout)
{
_musicAlias(alias, 0, fadeout, false);
}






