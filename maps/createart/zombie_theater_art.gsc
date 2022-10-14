main()
{
level.tweakfile = true;
start_dist = 155.625;
half_dist = 2332.79;
half_height = 677.241;
base_height = 23.2733;
fog_r = 0.639216;
fog_g = 0.639216;
fog_b = 0.639216;
fog_scale = 1;
sun_col_r = 0.243137;
sun_col_g = 0.270588;
sun_col_b = 0.270588;
sun_dir_x = 0.291692;
sun_dir_y = -0.720765;
sun_dir_z = 0.628819;
sun_start_ang = 0;
sun_stop_ang = 0;
time = 0;
max_fog_opacity = 1;
setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
sun_stop_ang, time, max_fog_opacity);
setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
sun_stop_ang, time, max_fog_opacity);
level thread fog_settings();
VisionSetNaked( "zombie_theater", 0 );
SetSavedDvar( "sm_sunSampleSizeNear", "0.93" );
SetSavedDvar( "r_lightGridEnableTweaks", 1 );
SetSavedDvar( "r_lightGridIntensity", 1.45 );
SetSavedDvar( "r_lightGridContrast", 0.15 );
SetSavedDvar("r_lightTweakSunLight", 22);
}
fog_settings()
{
}
