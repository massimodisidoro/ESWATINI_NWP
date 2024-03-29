# -*- coding: utf-8 -*
"""
Spyder Editor

This is a temporary script file.
"""

from __future__ import print_function

import argparse
import numpy as np
from def_vars import def_vars
import pandas as pd 
from netCDF4 import Dataset
import os    
import tempfile
os.environ['MPLCONFIGDIR'] = tempfile.mkdtemp()
import matplotlib.pyplot as plt
from matplotlib.cm import get_cmap
import matplotlib.colors as mcolors
import cartopy.crs as crs
import cartopy.feature as cf
#import cartopy.io.shapereader as shpreader

from ruamel.yaml import YAML, YAMLError ; yaml = YAML()
import logging
from functools import partial
import multiprocessing



#from cartopy.feature import NaturalEarthFeature
from wrf import (to_np, getvar, interplevel,smooth2d,ALL_TIMES,
                 get_cartopy, cartopy_xlim, cartopy_ylim, latlon_coords)


#%%
def plot_map(varname,
             field_fill,
             cart_proj,
             lons,
             lats,
             string_date_init,
             string_date_forecast, 
             title, 
             colormap, 
             figurename,
             varname_additional = 'none',
             field_contour = 'none',
             u_wind = 'none',
             v_wind = 'none',
             ws = 'none',
             contour = False,
             windvectors = False,
             overlap_fields = False):


    #define color levels
        #init figure for plot
    #fig, ax = plt.subplots()
    #fig = plt.figure(figsize=(12,9))
    ax = plt.axes(projection=cart_proj)
    #ax.add_feature(cf.LAND)
    ax.add_feature(cf.COASTLINE, linewidths=1.3)
    ax.add_feature(cf.BORDERS, linewidths=1.3)
    if colormap == 'prec':
        levels_fill = def_vars(varname)[0]
        extend_colorbar = def_vars(varname)[1]
        cmap_data = [(160/255,1,1),
           (100/255, 1, 1), 
           (67/255,195/255,1), 
           (65/255,155/255,1), 
           (90/255,100/255,1), 
           (65/255,75/255,1), 
           (60/255,188/255,61/255), 
           (165/255,215/255,31/255), 
           (1,230/255,0), 
           (1,195/255,0), 
           (1,0,0), 
           (200/255,0,0), 
           (212/255,100/255,195/255), 
           (181/255,25/255,157/255), 
           (132/255,0,148/255), 
           (180/255,180/255,180/255), 
           (140/255,140/255,140/255), 
           (90/255,90/255,90/255), 
           (50/255,50/255,50/255), 
           (165/255,120/255,35/255), 
           (128/255,82/255,0), 
           (100/255,50/255,0)]

        colmap = mcolors.ListedColormap(cmap_data, 'custom_prec')
        cmap=get_cmap(colmap)
        cmap.set_extremes(under='white', over=(80/255,35/255,0))
        norm = mcolors.BoundaryNorm(levels_fill, colmap.N)
        plt.contourf(to_np(lons), to_np(lats), to_np(field_fill), 10,
                 levels = levels_fill,transform=crs.PlateCarree(),
                 cmap=cmap, norm=norm, 
                 extend = extend_colorbar)   
    else: #not precipitation
        if not windvectors:
            if overlap_fields:
               levels_contour = def_vars(varname)[0]
               levels_fill = def_vars(varname_additional)[0]
               extend_colorbar = def_vars(varname_additional)[1]
               cnt = plt.contour(to_np(lons),to_np(lats), 
                                     to_np(field_contour),
                                     levels=levels_contour, 
                                     colors="black",
                                     linewidths=0.75,
                                     transform=crs.PlateCarree())
               plt.clabel(cnt, inline=1, fontsize=10, fmt="%i")
               cmap = get_cmap(colormap).copy()
               cmap.set_extremes(under='white') 
               if varname[0:2] == 'rh':
                  cmap = cmap.reversed() #reverse colors for RH
               plt.contourf(to_np(lons), to_np(lats), to_np(field_fill), 10,
                    levels=levels_fill,transform=crs.PlateCarree(),
                    cmap=get_cmap(colormap), extend = extend_colorbar)
            else: #not overlap fields
                if contour:
                   cmap = get_cmap(colormap).copy()
                   cmap.set_extremes(under='white') 
                   levels_fill = def_vars(varname)[0]
                   #print('zzzzz ',varname, ' ',levels_fill)
                   cnt = plt.contour(to_np(lons),to_np(lats),to_np(field_fill),
                                  levels=levels_fill,
                                  colors="black", linewidths=0.75,
                                  transform=crs.PlateCarree())
                   plt.clabel(cnt, inline=1, fontsize=10, fmt="%i")
                   #plt.clabel(cnt, inline=1)
                   extend_colorbar = def_vars(varname)[1]
                   if varname[0:2] == 'rh': #if rh reverse colorbar
                      map_reversed = cmap.reversed()
                      plt.contourf(to_np(lons), to_np(lats), to_np(field_fill),
                          nchunk=10, levels=levels_fill,
                          transform=crs.PlateCarree(),
                          cmap=map_reversed, extend = extend_colorbar)
                   else: #if not RH
                       plt.contourf(to_np(lons), to_np(lats), to_np(field_fill),
                          nchunk=10, levels=levels_fill,
                          transform=crs.PlateCarree(),
                          cmap=get_cmap(colormap), extend = extend_colorbar)
                else: #not contour
                   levels_fill = def_vars(varname)[0]
                   extend_colorbar = def_vars(varname)[1]
                   cmap = get_cmap(colormap).copy()
                   cmap.set_extremes(under='white') 
                   if varname[0:2] == 'rh':
                      cmap = cmap.reversed()
                   plt.contourf(to_np(lons), to_np(lats), to_np(field_fill), 10,
                        levels=levels_fill,transform=crs.PlateCarree(),
                        cmap=get_cmap(colormap), extend = extend_colorbar)
        else: #windvectors
            levels_fill = def_vars(varname)[0]
            extend_colorbar = def_vars(varname)[1]
            cmap_data = [(127/255, 1, 0),
              (0, 205/255, 0),
              (0, 139/255, 0),
              (16/255, 78/255, 139/255), 
              (30/255, 144/255, 1), 
              (0, 178/255, 238/255), 
              (0, 238/255, 238/255),  
              (137/255, 104/255, 205/255), 
              (145/255, 44/255, 238/255), 
              (139/255, 0, 139/255), 
              (1, 1, 0),
              (1, 215/255, 0), 
              (1, 127/255, 0), 
              (238/255, 64/255, 0),  
              (205/255, 0, 0),
              (139/255, 0, 0)]
            colmap = mcolors.ListedColormap(cmap_data, 'custom_bar')
            cmap=get_cmap(colmap)
            cmap.set_extremes(under='white', over=(77/255,0,0))
            norm = mcolors.BoundaryNorm(levels_fill, colmap.N)
           
            plt.contourf(to_np(lons), to_np(lats), to_np(ws), 10,
                        levels=levels_fill,transform=crs.PlateCarree(),
                        cmap=get_cmap(cmap), extend = extend_colorbar)
            jumpx = round( len(lons)/30 )     
            jumpy = round( len(lats)/30 )          
            plt.barbs(to_np(lons[::jumpx,::jumpy]),to_np(lats[::jumpx,::jumpy]),
               to_np(u_wind[::jumpx, ::jumpy]), to_np(v_wind[::jumpx, ::jumpy]),
               transform=crs.PlateCarree(), length=5)
    # Add a color bar
    plt.colorbar(ax=ax,shrink=.98,ticks = levels_fill, extend = extend_colorbar)
    # Set the map bounds
    ax.set_xlim(cartopy_xlim(mslp))
    ax.set_ylim(cartopy_ylim(mslp))
    ax.gridlines()
    plt.title(title)
    plt.savefig(figurename, dpi=120, bbox_inches='tight')
    plt.close()
    logger.info('plotted {}\n'.format(varname))
    

#%%
def interp_pressure_level(ncfile,level, field, pressure):
    interpolated = interplevel(field, pressure, str(level))
    return interpolated
#%%
def make_plots(wrf_vars,v):
    logger.info('Variables to process: {}'.format(v))
    #defaults
    contour = False
    plot_colormap = "Turbo"
    plot_type = "surf"
    overlap_fields = False
    windvectors = False
    pressure_level = 0
    varname = 'none'
    varname_additional = 'none'
    wrfv = 0
    wrfv2 = 0
    ua = 0
    va = 0
    ws = 0
   
    #setting keys for plots
    plot_type = wrf_vars[v]['type']
    contour = wrf_vars[v]['contour']
    plot_colormap = wrf_vars[v]['colormap']
    windvectors = wrf_vars[v]['windvectors']
    overlap_fields = wrf_vars[v]['overlap_fields']
    #print(plot_type,contour,plot_colormap,windvectors)
   
   
    if plot_type == 'surf':
        if windvectors:
           ua = getvar(ncfile, "U10", timeidx=timeindex)
           va = getvar(ncfile, "V10", timeidx=timeindex)
           #ws = getvar(ncfile, "wspd_wdir10",units="kt",timeidx=timeindex)[0,:]
           ws = getvar(ncfile, "wspd_wdir10",timeidx=timeindex)[0,:]
           ua=ua*1.94384 # conversion toknots
           va=va*1.94384 # conversion toknots
           ws=ws*1.94384 
           varname = wrf_vars[v]['varname']
           varname_additional = wrf_vars[v]['varname_additional']
        else:
           if overlap_fields:
              wrfv = getvar(ncfile, wrf_vars[v]['wrf_name'], timeidx = timeindex)
              wrfv2 = getvar(ncfile, wrf_vars[v]['wrf_name2'], timeidx = timeindex)
              varname = wrf_vars[v]['varname']
              varname_additional = wrf_vars[v]['varname_additional']
           else:
              if wrf_vars[v]['wrf_name'] == 'cloudfrac':
                 cloudfrac = getvar(ncfile,'cloudfrac', timeidx=timeindex)*100
                 wrfv = np.amax(cloudfrac, axis=0)
              elif wrf_vars[v]['wrf_name'] == 'cape':
                 cape_2d = getvar(ncfile, "cape_2d", timeidx = timeindex)
                 wrfv = cape_2d[0]
              else:
                 wrfv = getvar(ncfile, wrf_vars[v]['wrf_name'], timeidx = timeindex)
              varname = wrf_vars[v]['varname']
              wrfv2 = 'none'
              varname_additional = 'none'
        figurename = out_path + '/' + domain +'_' + varname+forecast_step +".png"
    elif plot_type == 'lev': #pressurelevels
        pressure_level = wrf_vars[v]['pressure_level']
        pressure = getvar(ncfile,'pres', timeidx = timeindex, units='hPa')

        if windvectors:
            #ua = getvar(ncfile, "ua",units="kt",timeidx=timeindex)
            #va = getvar(ncfile, "va",units="kt",timeidx=timeindex)
            #ws = getvar(ncfile, "wspd_wdir",units="kt",timeidx=timeindex)[0,:]
            ua = getvar(ncfile, "ua",timeidx=timeindex)
            va = getvar(ncfile, "va",timeidx=timeindex)
            ws = getvar(ncfile, "wspd_wdir",timeidx=timeindex)[0,:]
            ua=ua*1.94384 # conversion toknots
            va=va*1.94384 # conversion toknots
            ws=ws*1.94384 # conversion toknots
            ua = interp_pressure_level(ncfile,pressure_level,ua,pressure)
            va = interp_pressure_level(ncfile,pressure_level,va,pressure)
            ws = interp_pressure_level(ncfile,pressure_level,ws,pressure)
            varname = wrf_vars[v]['varname']
            varname_additional = wrf_vars[v]['varname_additional']
        else:
            if overlap_fields:
               wrfv=getvar(ncfile, wrf_vars[v]['wrf_name'], timeidx = timeindex)
               wrfv2=getvar(ncfile,wrf_vars[v]['wrf_name2'],timeidx = timeindex)
               wrfv=interp_pressure_level(ncfile,pressure_level, wrfv, pressure)
               wrfv2=interp_pressure_level(ncfile,pressure_level,wrfv2,pressure)
               varname = wrf_vars[v]['varname']
               varname_additional = wrf_vars[v]['varname_additional']
            else:
               wrfv = getvar(ncfile,wrf_vars[v]['wrf_name'], timeidx=timeindex)
               wrfv= interp_pressure_level(ncfile, pressure_level,wrfv,pressure)
               wrfv2 = 'none'
               varname = wrf_vars[v]['varname']
               varname_additional = 'none'
        figurename = out_path + '/' + domain +'_' + \
                     varname+forecast_step +".png"

    #if wrf_vars[v]['wrf_name'] == 'geopt' and wrf_vars[v]['pressure_level'] > 700:
    if wrf_vars[v]['wrf_name'] == 'geopt':
        wrfv = wrfv/98.1 #dam
    if wrf_vars[v]['wrf_name'] == 'T2':
        wrfv = wrfv-273.13 #°C


    if v == 'slp':
        wrfv = smooth2d(wrfv,3, cenweight=4)
    
    if plot_type != 'prec': 
        # Create the figures except precipitation
        varname = wrf_vars[v]['varname']
        title1 = wrf_vars[v]['title']
        title2 = string_date_init + "\n" + string_date_forecast
        title = title1 + "\n" + title2
        plot_map(varname = varname,
                 field_fill = wrfv,
                 cart_proj = cart_proj,
                 lons = lons,
                 lats = lats,
                 string_date_init = string_date_init,
                 string_date_forecast = string_date_forecast, 
                 title = title, 
                 colormap = plot_colormap, 
                 figurename = figurename,
                 varname_additional = varname_additional,
                 field_contour = wrfv2,
                 u_wind = ua,
                 v_wind = va,
                 ws = ws,
                 contour = contour,
                 windvectors = windvectors,
                 overlap_fields = overlap_fields)
        del(wrfv)




#%%
#debug
#out_path='./'
#wrf_file='/home/massimo/tmp/eswatini/wrfout_d02_2022-12-20_00:00:00'
#start_step=2
#end_step=2
#deltastep =1
#config_file='var.yaml'
#%%
parser=argparse.ArgumentParser()
parser.add_argument("wrfout_file",
                    type=str,
                    help="wrf output file name with absolute path")
parser.add_argument("--start",
                    type=int,
                    help="forecast step start", 
                    default = 1)
parser.add_argument("--end",
                    type=int,
                    help="forecast step end")
parser.add_argument("--deltastep",
                    type=int,
                    help="times processed every deltastep. Default=1",
                    default = 1)
parser.add_argument("--out",
                    type=str,
                    help="absolute path for outputs")
parser.add_argument("--config_file",
                    type=str,
                    help="yaml configuration file containing variables"
                         "to be plotted in output")

args = parser.parse_args()
wrf_file = args.wrfout_file
start_step = args.start
end_step = args.end
deltastep = args.deltastep
out_path = args.out
config_file = args.config_file
#%%
logger = logging.getLogger()
logger.debug = print
logger.info = print
logger.error = print

# read yaml configuration
with open(config_file) as f:
  try:
      var_dict = yaml.load(f)
  except YAMLError as e:
      logger.error('Error reading WRF variables file:\n {}'.format(e))
      #return False


wrf_vars = var_dict

#%%


#start
ncfile = Dataset(wrf_file)
#define wrf domain
if wrf_file.find('d01') != -1:
    domain = 'd01'
elif wrf_file.find('d02') != -1:
    domain = 'd02'
else:
    domain = 'd03'

wrf_time = getvar(ncfile, 'times', timeidx=ALL_TIMES, meta=False)
ntimes = len(wrf_time)


if end_step > ntimes:
    print("WARNING: end_step > final forecast step")
    print("  setting end_step to ", ntimes)
    print(" ... ...")
    end_step = ntimes

timeinit = pd.to_datetime(str(wrf_time[0]))
# strings for composing figure names
t1 = timeinit.strftime("%Y%m%d_%H%M")
day_init = timeinit.strftime("%a")
string_date_init = "Init: " + day_init + ", " + \
    timeinit.strftime("%d %B %Y, %H:%M")+ " UTC"

#get map info before time cycle
mslp = getvar(ncfile,'slp',timeidx=1)
# Get the lat/lon coordinates
lats, lons = latlon_coords(mslp)
# Get the map projection information
cart_proj = get_cartopy(mslp)

#%%
#time_offset = 0 # 6 hours (forecast starts at 18utc)
# parallelize map creration except for precipitation (to be accumulated)
scalar_vars={}
parallel_vars={}
for v in wrf_vars:
    if wrf_vars[v]['type']=='prec':
       scalar_vars[v]=wrf_vars[v]
    else:
       parallel_vars[v]=wrf_vars[v]

totprec_h = 0
totprec_3h = 0
totprec_6h = 0
totprec_12h = 0
totprec_24h = 0

iterable = list(parallel_vars)
for timeindex in range(start_step,end_step+1,deltastep):
   forecast_step = "+" + str(timeindex).zfill(2)
   timeforecast = pd.to_datetime(str(wrf_time[timeindex]))
   day_forecast = timeforecast.strftime("%a")
   string_date_forecast = "Forecast Date: " + day_forecast + ", " + \
       timeforecast.strftime("%b %d %Y, %H:%M") + " UTC"
   string_forecast_step = "Forecast Time: " + forecast_step + \
   " hours, " + timeforecast.strftime("%d %B %Y, %H:%M")+ " UTC"
   print(string_forecast_step) 
   t2 = timeforecast.strftime("%Y%m%d_%H%M")

   #parallel process (not precipitation)
   num_cores = min(multiprocessing.cpu_count(),len(parallel_vars))
   print('Parallel process: using '+str(num_cores)+' cores\n')
   pool = multiprocessing.Pool(processes=num_cores) 
   #pool = multiprocessing.Pool(processes=1)
   func = partial(make_plots,parallel_vars)
   pool.map(func,iterable)
   pool.close()
   pool.join()

   #scalar process (precipitation)
   totprec_h = getvar(ncfile, 'PREC_ACC_NC', timeidx=timeindex) + \
               getvar(ncfile, 'PREC_ACC_C', timeidx=timeindex)
   totprec_3h = totprec_3h + totprec_h
   totprec_6h = totprec_6h + totprec_h
   totprec_12h = totprec_12h + totprec_h
   totprec_24h = totprec_24h + totprec_h

   for v in scalar_vars:
      varname = scalar_vars[v]['varname']
      title1 = scalar_vars[v]['title']
      title2 = string_date_init + "\n" + string_date_forecast
      title = title1 + "\n" + title2
      if scalar_vars[v]['varname'] == 'hourly_prec':
          logger.info('Processing: {}\n'.format(v))
          figurename = out_path + '/' + domain +'_' + varname + \
                      forecast_step +".png"
          plot_map(varname = varname,
                       field_fill =totprec_h,
                       cart_proj = cart_proj,
                       lons = lons,
                       lats = lats,
                       string_date_init = string_date_init,
                       string_date_forecast = string_date_forecast,
                       title = title,
                       colormap = 'prec',
                       figurename = figurename,
                       varname_additional = 'none',
                       field_contour = 'none',
                       u_wind = 'none',
                       v_wind = 'none',
                       ws = 'none',
                       contour = False,
                       windvectors = False,
                       overlap_fields =False)
      if timeindex % 3 == 0:
          if scalar_vars[v]['varname'] == '3hourly_prec':
              logger.info('Processing: {}'.format(v))
              figurename = out_path + '/' + domain +'_' + varname + \
                           forecast_step +".png"
              plot_map(varname = varname,
                       field_fill = totprec_3h,
                       cart_proj = cart_proj,
                       lons = lons,
                       lats = lats,
                       string_date_init = string_date_init,
                       string_date_forecast = string_date_forecast,
                       title = title,
                       colormap = 'prec',
                       figurename = figurename,
                       varname_additional = 'none',
                       field_contour = 'none',
                       u_wind = 'none',
                       v_wind = 'none',
                       ws = 'none',
                       contour = False,
                       windvectors = False,
                       overlap_fields =False)
              totprec_3h=0
      if timeindex % 6 == 0:
          if scalar_vars[v]['varname'] == '6hourly_prec':
              logger.info('Processing: {}'.format(v))
              figurename = out_path + '/' + domain +'_' + varname + \
                           forecast_step +".png"
              plot_map(varname = varname,
                       field_fill = totprec_6h,
                       cart_proj = cart_proj,
                       lons = lons,
                       lats = lats,
                       string_date_init = string_date_init,
                       string_date_forecast = string_date_forecast,
                       title = title,
                       colormap = 'prec',
                       figurename = figurename,
                       varname_additional = 'none',
                       field_contour = 'none',
                       u_wind = 'none',
                       v_wind = 'none',
                       ws = 'none',
                       contour = False,
                       windvectors = False,
                       overlap_fields =False)
              totprec_6h=0
      if timeindex % 12 == 0:
          if scalar_vars[v]['varname'] == '12hourly_prec':
              logger.info('Processing: {}'.format(v))
              figurename = out_path + '/' + domain +'_' + varname + \
                           forecast_step +".png"
              plot_map(varname = varname,
                       field_fill = totprec_12h,
                       cart_proj = cart_proj,
                       lons = lons,
                       lats = lats,
                       string_date_init = string_date_init,
                       string_date_forecast = string_date_forecast,
                       title = title,
                       colormap = 'prec',
                       figurename = figurename,
                       varname_additional = 'none',
                       field_contour = 'none',
                       u_wind = 'none',
                       v_wind = 'none',
                       ws = 'none',
                       contour = False,
                       windvectors = False,
                       overlap_fields =False)
              totprec_12h=0
      if timeindex % 24 == 0:
          if scalar_vars[v]['varname'] == '24hourly_prec':
              logger.info('Processing: {}'.format(v))
              figurename = out_path + '/' + domain +'_' + varname + \
                           forecast_step +".png"
              plot_map(varname = varname,
                       field_fill = totprec_24h,
                       cart_proj = cart_proj,
                       lons = lons,
                       lats = lats,
                       string_date_init = string_date_init,
                       string_date_forecast = string_date_forecast,
                       title = title,
                       colormap = 'prec',
                       figurename = figurename,
                       varname_additional = 'none',
                       field_contour = 'none',
                       u_wind = 'none',
                       v_wind = 'none',
                       ws = 'none',
                       contour = False,
                       windvectors = False,
                       overlap_fields =False)
              totprec_24h=0
