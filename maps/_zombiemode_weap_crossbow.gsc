
#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
init()
{
if( !maps\_zombiemode_weapons::is_weapon_included( "crossbow_explosive_zm" ) )
{
return;
}
level thread crossbow_on_player_connect();
}
crossbow_on_player_connect()
{
for( ;; )
{
level waittill( "connecting", player );
player thread watch_for_monkey_bolt();
}
}
watch_for_monkey_bolt()
{
self endon( "death" );
self endon( "disconnect" );
if ( GetDvar( #"zombiemode" ) != "1" )
{
return;
}
for (;;)
{
self waittill ( "grenade_fire", grenade, weaponName, parent );
if(isDefined(level.zombiemode_cross_bow_fired))
{
level thread [[level.zombiemode_cross_bow_fired]](grenade, weaponName, parent, self);
}
switch( weaponName )
{
case "explosive_bolt_upgraded_zm":
grenade thread crossbow_monkey_bolt( self );
break;
}
}
}
crossbow_monkey_bolt( player_who_fired )
{
level thread monkey_bolt_cleanup( self );
attract_dist_diff = level.monkey_attract_dist_diff;
if( !isDefined( attract_dist_diff ) )
{
attract_dist_diff = 45;
}
num_attractors = level.num_monkey_attractors;
if( !isDefined( num_attractors ) )
{
num_attractors = 96;
}
max_attract_dist = level.monkey_attract_dist;
if( !isDefined( max_attract_dist ) )
{
max_attract_dist = 1536;
}
if( IsDefined( level.monkey_bolt_holder ) )
{
is_player = IsPlayer( level.monkey_bolt_holder );
if( is_player || is_true( level.monkey_bolt_holder.can_move_with_bolt ) )
{
self create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000, true );
valid_poi = maps\_zombiemode_utility::check_point_in_active_zone( self.origin );
if ( is_player )
{
level._bolt_on_back = 0;
level thread monkey_bolt_on_back( self, player_who_fired, level.monkey_bolt_holder );
}
if( !valid_poi )
{
valid_poi = check_point_in_playable_area( self.origin );
}
if(valid_poi)
{
}
else
{
player_who_fired.script_noteworthy = undefined;
}
}
else if( IsAI( level.monkey_bolt_holder ) )
{
level thread wait_for_monkey_bolt_holder_to_die(self,level.monkey_bolt_holder);
if( is_true(level.monkey_bolt_holder.is_traversing))
{
level.monkey_bolt_holder waittill("zombie_end_traverse");
}
if( IsAlive( level.monkey_bolt_holder ) )
{
level.monkey_bolt_holder thread monkey_bolt_taunts( self );
}
else
if ( !isDefined( self ) )
{
player_who_fired.script_noteworthy = undefined;
return;
}
self create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000, true );
valid_poi = maps\_zombiemode_utility::check_point_in_active_zone( self.origin );
if( !valid_poi )
{
valid_poi = check_point_in_playable_area( self.origin );
}
if(valid_poi)
{
self thread create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
}
else
{
player_who_fired.script_noteworthy = undefined;
}
}
}
else
{
valid_poi = maps\_zombiemode_utility::check_point_in_active_zone( self.origin );
if( !valid_poi )
{
valid_poi = check_point_in_playable_area( self.origin );
}
if(!valid_poi && is_true(level.use_alternate_poi_positioning ))
{
bkwd = AnglesToForward( self.angles ) * -20;
new_pos = self.origin + bkwd + (0,0,-50);
valid_poi = check_point_in_playable_area( new_pos);
if(valid_poi)
{
alt_poi = spawn("script_origin",new_pos);
alt_poi create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000, true );
alt_poi thread create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
alt_poi thread wait_for_bolt_death(self);
return;
}
}
if(valid_poi)
{
self create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000, true );
self thread create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
}
else
{
player_who_fired.script_noteworthy = undefined;
}
}
}
wait_for_bolt_death(bolt)
{
bolt waittill("death");
self delete();
}
wait_for_monkey_bolt_holder_to_die(bolt,zombie)
{
bolt endon("death");
zombie waittill("death");
if ( !isdefined( level.delete_monkey_bolt_on_zombie_holder_death ) || !zombie [[level.delete_monkey_bolt_on_zombie_holder_death]]() )
{
return;
}
if ( isDefined( bolt ) )
{
bolt delete();
}
}
monkey_bolt_taunts( ent_grenade )
{
self endon( "death" );
if( isDefined(self.monkey_bolt_taunts) && self [[self.monkey_bolt_taunts]](ent_grenade))
{
return;
}
else if ( self.isdog || !self.has_legs )
{
return;
}
else if( IsDefined( self.animname ) && self.animname == "thief_zombie" )
{
return;
}
else if ( IsDefined( self.in_the_ceiling ) && self.in_the_ceiling )
{
return;
}
while( IsDefined( ent_grenade ) )
{
if( IsDefined( level._zombie_board_taunt[self.animname] ) )
{
taunt_anim = random( level._zombie_board_taunt[self.animname] );
if( self.animname == "zombie" )
{
self thread maps\_zombiemode_audio::do_zombies_playvocals( "taunt", self.animname );
}
if( !IsAlive( self ) )
{
return;
}
self.allowdeath = 1;
self animscripted( "zombie_taunt", self.origin, self.angles, taunt_anim, "normal", undefined, 1, 0.4 );
if( !IsAlive( self ) )
{
return;
}
wait( getanimlength( taunt_anim ) );
}
wait( 0.05 );
}
level.monkey_bolt_holder = undefined;
}
monkey_bolt_cleanup( ent_grenade )
{
while( IsDefined( ent_grenade ) )
{
wait( 0.1 );
}
if( IsDefined( level.monkey_bolt_holder ) )
{
level.monkey_bolt_holder = undefined;
}
}
monkey_bolt_on_back( monkey_bolt, player_who_fired, player_with_back_bolt )
{
if( !IsDefined( level._bolt_on_back ) )
{
level._bolt_on_back = 0;
}
monkey_bolt waittill( "explode" );
wait( 0.2 );
if( level._bolt_on_back >= 6 )
{
if( is_player_valid( player_with_back_bolt ) && !player_who_fired IsNoTarget() )
{
if( IsDefined( player_who_fired ) )
{
player_who_fired giveachievement_wrapper( "SP_ZOM_SILVERBACK" );
}
player_with_back_bolt giveachievement_wrapper( "SP_ZOM_SILVERBACK" );
}
}
}�
