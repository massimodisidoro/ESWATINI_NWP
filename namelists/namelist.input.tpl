 &time_control
 run_days                            = 0,
 run_hours                           = 0,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = yyyy1,  yyyy1,
 start_month                         = mm1, mm1,
 start_day                           = dd1,   dd1,
 start_hour                          = hh1,  hh1,
 end_year                            = yyyy2,  yyyy2,
 end_month                           = mm2, mm2,
 end_day                             = dd2,   dd2,
 end_hour                            = 00,   00,
 interval_seconds                     = 10800,
 input_from_file                     = .true., .true.,
 history_interval                    = 60,  60,
 frames_per_outfile                  = @@frames_wrfout@@, @@frames_wrfout@@,
 restart                             = .false.,
 restart_interval                    = 7200,
 write_hist_at_0h_rst                = .false.,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 io_form_auxinput4                   = 2,
 auxinput4_inname                    = "wrflowinp_d<domain>",
 auxinput4_interval                  = 180, 180,
 auxinput11_interval                 = 1, 1,
 auxinput11_end_h                    = 99999, 99999,
 /

&domains
time_step                = @@wrf_timestep@@,
time_step_fract_num      = 0,
time_step_fract_den      = 1,
use_adaptive_time_step   = .false.
step_to_output_time      = .true.
max_dom                  = 2,
s_we                     = 1,        1,
e_we                     = 200,      281,
s_sn                     = 1,        1,
e_sn                     = 200,      296,
s_vert                   = 1,        1,
e_vert                   = 45,       45,
num_metgrid_levels       = 23,
dx                       = 5000,     1000,
dy                       = 5000,     1000,
grid_id                  = 1,        2,
parent_id                = 1,        1,
i_parent_start           = 1,       74,
j_parent_start           = 1,       69,
parent_grid_ratio        = 1,        5,
parent_time_step_ratio   = 1,        5,
feedback                 = 1,
smooth_option            = 0,
max_ts_locs              = 5,    
ts_buf_size              = @@ts_buf_size@@,
max_ts_level             = 1,
tslist_unstagger_winds   = True,
/


 &physics
 mp_physics                          = 4,    4,
 cu_physics                          = 1,    0,
 ra_lw_physics                       = 4,    4,
 ra_sw_physics                       = 4,    4,
 bl_pbl_physics                      = 1,    1,
 sf_sfclay_physics                   = 91,    91,
 sf_surface_physics                  = 2,    2,
 radt                                = 30,    30,
 bldt                                = 0,     0,
 cudt                                = 5,     5,
 num_land_cat                        = 21,
 isfflx                   = 1,
 ifsnow                   = 0,
 icloud                   = 1,
 surface_input_source     = 1,
 prec_acc_dt              = 60,       60,
 /

 &fdda
 /

&dynamics
dyn_opt                  = 2,
rk_ord                   = 3,
w_damping                = 0,
diff_opt                 = 0,
km_opt                   = 1,
damp_opt                 = 0,
base_temp                = 290.,
zdamp                    = 5000.,    5000.,
dampcoef                 = 0.01,     0.01,
khdif                    = 0,        0,
kvdif                    = 0,        0,
smdiv                    = 0.1,      0.1,
emdiv                    = 0.01,     0.01,
epssm                    = 0.1,      0.1,
non_hydrostatic          = .true.,   .true.,
/


 &bdy_control
 spec_bdy_width                      = 5,
 specified                           = .true.
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
