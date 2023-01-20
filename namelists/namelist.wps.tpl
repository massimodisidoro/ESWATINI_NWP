&share
 wrf_core = 'ARW',
 max_dom = 2,
 start_date = '@@start_date@@_@@start_hour@@:00:00','@@start_date@@_@@start_hour@@:00:00',
 end_date   = '@@end_date@@_@@end_hour@@:00:00',@@end_date@@_@@end_hour@@:00:00',
 interval_seconds = 10800,
 opt_output_from_geogrid_path = '@@geogrid_output@@',
 io_form_geogrid = 2,
 debug_level = 0,
/

&geogrid
 parent_id         = 1,1,
 parent_grid_ratio = 1,5,
 i_parent_start    = 1,74,
 j_parent_start    = 1,69,
 e_we          = 200,281,
 e_sn          = 200,296,
 !
 !!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!
 ! The default datasets used to produce the MAXSNOALB and ALBEDO12M
 ! fields have changed in WPS v4.0. These fields are now interpolated
 ! from MODIS-based datasets.
 !
 ! To match the output given by the default namelist.wps in WPS v3.9.1,
 ! the following setting for geog_data_res may be used:
 !
 ! geog_data_res = 'maxsnowalb_ncep+albedo_ncep+default', 'maxsnowalb_ncep+albedo_ncep+default',
 !
 !!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!
 !
 geog_data_res = 'default','default',
 dx = 5000,
 dy = 5000,
 map_proj =  'lambert',
 ref_lat   = -26.388,
 ref_lon   = 31.446,
 truelat1  = -26.388,
 truelat2  = -26.388,
 stand_lon = 31.446,
 geog_data_path = '@@geo_data@@'
 OPT_GEOGRID_TBL_PATH='@@geogrid_table_path@@',
 ref_x = 100.0,
 ref_y = 100.0,
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2, 
 opt_metgrid_tbl_path='@@metgrid_table_path@@',
 opt_output_from_metgrid_path='@@metgrid_output@@',
/

&domain_wizard
 grib_data_path = 'null',
 grib_vtable = 'null',
 dwiz_name    =ESWATINI
 dwiz_desc    =
 dwiz_user_rect_x1 =4551
 dwiz_user_rect_y1 =2423
 dwiz_user_rect_x2 =4966
 dwiz_user_rect_y2 =2815
 dwiz_show_political =true
 dwiz_center_over_gmt =true
 dwiz_latlon_space_in_deg =10
 dwiz_latlon_linecolor =-8355712
 dwiz_map_scale_pct =50.0
 dwiz_map_vert_scrollbar_pos =0
 dwiz_map_horiz_scrollbar_pos =0
 dwiz_gridpt_dist_km =5.0
 dwiz_mpi_command =
 dwiz_tcvitals =null
 dwiz_bigmap =Y
/

