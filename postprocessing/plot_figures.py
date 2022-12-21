# -*- coding: utf-8 -*
"""
Spyder Editor

This is a temporary script file.
"""

from __future__ import print_function

import argparse
from func_color_levels import color_levels
#import numpy as np
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
def plot_map(levels_tag,
             field_fill,
             cart_proj,
             lons,
             lats,
             string_date_init,
             string_date_forecast, 
             title, 
             colormap, 
             figurename,
             levels_tag2 = 'none',
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
    ax.add_feature(cf.LAND)
    ax.add_feature(cf.COASTLINE)
    ax.add_feature(cf.BORDERS)
    if colormap == 'prec':
        levels = color_levels(levels_tag)[0]
        extend_colorbar = color_levels(levels_tag)[1]
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
        norm = mcolors.BoundaryNorm(levels, colmap.N)
        plt.contourf(to_np(lons), to_np(lats), to_np(field_fill), 10,
                 levels = levels,transform=crs.PlateCarree(),
                 cmap=cmap, norm=norm, 
                 extend = extend_colorbar)   
    else:
        if not windvectors:
            if overlap_fields:
               levels_contour = color_levels(levels_tag)[0]
               levels_fill = color_levels(levels_tag2)[0]
               extend_colorbar = color_levels(levels_tag2)[1]
               contours = plt.contour(to_np(lons),to_np(lats), 
                                     to_np(field_contour),
                                     levels=levels_contour, colors="black",
                                     transform=crs.PlateCarree())
               plt.clabel(contours)
               cmap = get_cmap(colormap).copy()
               cmap.set_extremes(under='white') 
               plt.contourf(to_np(lons), to_np(lats), to_np(field_fill), 10,
                    levels=levels_fill,transform=crs.PlateCarree(),
                    cmap=get_cmap(colormap), extend = extend_colorbar)
            else: #not overlap fields
               levels_fill = color_levels(levels_tag)[0]
               extend_colorbar = color_levels(levels_tag)[1]
               cmap = get_cmap(colormap).copy()
               cmap.set_extremes(under='white') 
               plt.contourf(to_np(lons), to_np(lats), to_np(field_fill), 10,
                    levels=levels_fill,transform=crs.PlateCarree(),
                    cmap=get_cmap(colormap), extend = extend_colorbar)
        else: #windvectors
            levels_fill = color_levels(levels_tag)[0]
            extend_colorbar = color_levels(levels_tag)[1]
            cmap_data = [(127/255, 1, 0),
              (0, 205/255, 0),
              (0, 139/255, 0),
              (16/255, 78/255, 139/255), 
              (30/255, 144/255, 1), 
              (0, 178/255, 238/255), 
              (0, 238/255, 238/255),  #celeste 
              (137/255, 104/255, 205/255), 
              (145/255, 44/255, 238/255), 
              (139/255, 0, 139/255), # viola scuro
              (1, 1, 0),#giallo
              (1, 215/255, 0), #giallino
              (1, 127/255, 0), #aranciuo
              (238/255, 64/255, 0),  #rosso
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
    print('plotted ' + levels_tag)
    

#%%
def interp_pressure_level(ncfile,level, field, pressure):
    interpolated = interplevel(field, pressure, str(level))
    return interpolated
#%%
def make_plots(wrf_vars,v):
    logger.info('Processing variable: {}\n'.format(v))
    #defaults
    contour = False
    plot_colormap = "Turbo"
    plot_type = "surf"
    overlap_fields = False
    windvectors = False
    pressure_level = 0
    levels_tag = 'none'
    levels_tag2 = 'none'
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
        if overlap_fields:
           wrfv = getvar(ncfile, wrf_vars[v]['wrf_name'], timeidx = timeindex)
           wrfv2 = getvar(ncfile, wrf_vars[v]['wrf_name2'], timeidx = timeindex)
           levels_tag = wrf_vars[v]['levels_tag']
           levels_tag2 = wrf_vars[v]['levels_tag2']
        else:
           wrfv = getvar(ncfile, wrf_vars[v]['wrf_name'], timeidx = timeindex)
           levels_tag = wrf_vars[v]['levels_tag']
           wrfv2 = 'none'
           levels_tag2 = 'none'

        if windvectors:
           ua = getvar(ncfile, "U10", timeidx=timeindex)
           va = getvar(ncfile, "V10", timeidx=timeindex)
           ws = getvar(ncfile, "wspd_wdir10",timeidx=timeindex)[0,:]
           levels_tag = wrf_vars[v]['levels_tag']
           levels_tag2 = wrf_vars[v]['levels_tag2']

        figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    else if plot_type == 'lev': #pressurelevels
        pressure_level = wrf_vars[v]['pressure_level']
        pressure = getvar(ncfile,'pres', timeidx = timeindex, units='hPa')

        if windvectors:
            ua = getvar(ncfile, "ua",timeidx=timeindex)
            va = getvar(ncfile, "va",timeidx=timeindex)
            ws = getvar(ncfile, "wspd_wdir",timeidx=timeindex)[0,:]
            ua = interp_pressure_level(ncfile,pressure_level,ua,pressure)
            va = interp_pressure_level(ncfile,pressure_level,va,pressure)
            ws = interp_pressure_level(ncfile,pressure_level,ws,pressure)
            levels_tag = wrf_vars[v]['levels_tag']
            levels_tag2 = wrf_vars[v]['levels_tag2']
        else:
            if overlap_fields:
               wrfv=getvar(ncfile, wrf_vars[v]['wrf_name'], timeidx = timeindex)
               wrfv2=getvar(ncfile,wrf_vars[v]['wrf_name2'],timeidx = timeindex)
               wrfv=interp_pressure_level(ncfile,pressure_level, wrfv, pressure)
               wrfv2=interp_pressure_level(ncfile,pressure_level,wrfv2,pressure)
               levels_tag = wrf_vars[v]['levels_tag']
               levels_tag2 = wrf_vars[v]['levels_tag2']
            else:
               wrfv = getvar(ncfile,wrf_vars[v]['wrf_name'], timeidx=timeindex)
               wrfv= interp_pressure_level(ncfile, pressure_level,wrfv,pressure)
               wrfv2 = 'none'
               levels_tag = wrf_vars[v]['levels_tag']
               levels_tag2 = 'none'
        figurename = out_path + '/' + domain +'_' + \
                     levels_tag+forecast_step +".png"

    if wrf_vars[v]['wrf_name'] == 'geopt':
        wrfv = wrfv/98.1 #dam
    if wrf_vars[v]['wrf_name'] == 'T2':
        wrfv = wrfv-273.13 #°C


    if v == 'slp':
        wrfv = smooth2d(wrfv,3, cenweight=4)
    
    # Create the figures
    #mean sea level pressure
    title1 = wrf_vars[v]['title']
    title2 = string_date_init + "\n" + string_date_forecast
    title = title1 + "\n" + title2
    print('WWWWWWWWWWWWWw '+title1)
    plot_map(levels_tag = levels_tag,
             field_fill = wrfv,
             cart_proj = cart_proj,
             lons = lons,
             lats = lats,
             string_date_init = string_date_init,
             string_date_forecast = string_date_forecast, 
             title = title, 
             colormap = plot_colormap, 
             figurename = figurename,
             levels_tag2 = levels_tag2,
             field_contour = wrfv2,
             u_wind = ua,
             v_wind = va,
             ws = ws,
             contour = contour,
             windvectors = windvectors,
             overlap_fields = overlap_fields)
    del(wrfv)
    
    #precipitation sprocessed separately
    if plot_type == 'prec': 
        totprec_h = getvar(ncfile, 'PREC_ACC_NC', timeidx=timeindex) + \
                    getvar(ncfile, 'PREC_ACC_C', timeidx=timeindex)
        totprec_3h = totprec_3h + totprec_h
        totprec_6h = totprec_6h + totprec_h
        totprec_12h = totprec_12h + totprec_h
        totprec_24h = totprec_24h + totprec_h
        title1 = wrf_vars[v]['title']
        title2 = string_date_init + "\n" + string_date_forecast
        title = title1 + "\n" + title2
        if timeindex % 3 == 0:
            if wrf_vars[v]['levels_tag'] == '3hourly_prec'
                figurename = out_path + '/' + domain +'_' + levels_tag + \
                             forecast_step +".png"
                plot_map(levels_tag = levels_tag,
                         field_fill = totprec_3h,
                         cart_proj = cart_proj,
                         lons = lons,
                         lats = lats,
                         string_date_init = string_date_init,
                         string_date_forecast = string_date_forecast,
                         title = title,
                         colormap = 'prec',
                         figurename = figurename,
                         levels_tag2 = 'none',
                         field_contour = 'none',
                         u_wind = 'none',
                         v_wind = 'none',
                         ws = 'none',
                         contour = False,
                         windvectors = False,
                         overlap_fields =False)
        if timeindex % 6 == 0:
            if wrf_vars[v]['levels_tag'] == '6hourly_prec'
                figurename = out_path + '/' + domain +'_' + levels_tag + \
                             forecast_step +".png"
                plot_map(levels_tag = levels_tag,
                         field_fill = totprec_6h,
                         cart_proj = cart_proj,
                         lons = lons,
                         lats = lats,
                         string_date_init = string_date_init,
                         string_date_forecast = string_date_forecast,
                         title = title,
                         colormap = 'prec',
                         figurename = figurename,
                         levels_tag2 = 'none',
                         field_contour = 'none',
                         u_wind = 'none',
                         v_wind = 'none',
                         ws = 'none',
                         contour = False,
                         windvectors = False,
                         overlap_fields =False)
        if timeindex % 12 == 0:
            if wrf_vars[v]['levels_tag'] == '12hourly_prec'
                figurename = out_path + '/' + domain +'_' + levels_tag + \
                             forecast_step +".png"
                plot_map(levels_tag = levels_tag,
                         field_fill = totprec_12h,
                         cart_proj = cart_proj,
                         lons = lons,
                         lats = lats,
                         string_date_init = string_date_init,
                         string_date_forecast = string_date_forecast,
                         title = title,
                         colormap = 'prec',
                         figurename = figurename,
                         levels_tag2 = 'none',
                         field_contour = 'none',
                         u_wind = 'none',
                         v_wind = 'none',
                         ws = 'none',
                         contour = False,
                         windvectors = False,
                         overlap_fields =False)
        if timeindex % 24 == 0:
            if wrf_vars[v]['levels_tag'] == '24hourly_prec'
                figurename = out_path + '/' + domain +'_' + levels_tag + \
                             forecast_step +".png"
                plot_map(levels_tag = levels_tag,
                         field_fill = totprec_24h,
                         cart_proj = cart_proj,
                         lons = lons,
                         lats = lats,
                         string_date_init = string_date_init,
                         string_date_forecast = string_date_forecast,
                         title = title,
                         colormap = 'prec',
                         figurename = figurename,
                         levels_tag2 = 'none',
                         field_contour = 'none',
                         u_wind = 'none',
                         v_wind = 'none',
                         ws = 'none',
                         contour = False,
                         windvectors = False,
                         overlap_fields =False)
   del(wrfv) 

#%%
#debug
out_path='./'
wrf_file='/home/massimo/tmp/eswatini/wrfout_d02_2022-12-20_00:00:00'
start_step=2
end_step=2
deltastep =1
config_file='var.yaml'
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
iterable = list(wrf_vars)
totprec_3h = 0
totprec_6h = 0
totprec_12h = 0
totprec_24h = 0
for timeindex in range(start_step,end_step+1,1):
    forecast_step = "+" + str(timeindex)
    timeforecast = pd.to_datetime(str(wrf_time[timeindex]))
    day_forecast = timeforecast.strftime("%a")
    string_date_forecast = "Forecast Date: " + day_forecast + ", " + \
        timeforecast.strftime("%b %d %Y, %H:%M") + " UTC"
    string_forecast_step = "Forecast Time: " + forecast_step + \
    " hours, " + timeforecast.strftime("%d %B %Y, %H:%M")+ " UTC"
    print(string_forecast_step) 
    t2 = timeforecast.strftime("%Y%m%d_%H%M")

    num_cores = min(multiprocessing.cpu_count(),len(wrf_vars))
    print('Parallel process: using '+str(num_cores)+' cores')
    pool = multiprocessing.Pool(processes=num_cores)
    func = partial(make_plots,wrf_vars)
    pool.map(func,iterable)
    pool.close()
    pool.join()
