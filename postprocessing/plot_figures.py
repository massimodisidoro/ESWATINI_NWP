# -*- coding: utf-8 -*
"""
Spyder Editor

This is a temporary script file.
"""

from __future__ import print_function

import argparse
from func_color_levels import color_levels
import numpy as np
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
import cartopy.io.shapereader as shpreader

#from cartopy.feature import NaturalEarthFeature
from wrf import (to_np, getvar, vinterp, interplevel,smooth2d,ALL_TIMES,
                 get_cartopy, cartopy_xlim, cartopy_ylim, latlon_coords)


#%%
def plotta_mappa(levels_tag,field,cart_proj,lons,lats,string_date_init,
                 string_date_forecast, title, colormap, figurename):
    #global reader    
    #define color levels
    levels = color_levels(levels_tag)[0]
    extend_colorbar = color_levels(levels_tag)[1]
    #init figure for plot
    fig = plt.figure(figsize=(12,9))
    ax = plt.axes(projection=cart_proj)
    #reader = shpreader.Reader("/afs/enea.it/por/user/forair/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #reader = shpreader.Reader("/home/massimo/data/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #regioni = cf.ShapelyFeature(reader.geometries(),
    #          crs=crs.UTM(32),facecolor="none", edgecolor='black', lw=1)
    #ax.add_feature(regioni)
    ax.add_feature(cf.LAND)
    ax.add_feature(cf.COASTLINE)
    ax.add_feature(cf.BORDERS)
    if colormap == 'prec':
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
        plt.contourf(to_np(lons), to_np(lats), to_np(field), 10,
                 levels = levels,transform=crs.PlateCarree(),
                 cmap=cmap, norm=norm, 
                 extend = extend_colorbar)   
    else:
        #cmap=get_cmap(colormap)
        cmap = get_cmap(colormap).copy()
        cmap.set_extremes(under='white') 
        plt.contourf(to_np(lons), to_np(lats), to_np(field), 10,
                 levels=levels,transform=crs.PlateCarree(),
                 cmap=get_cmap(colormap), extend = extend_colorbar)
                 #cmap=get_cmap("hsv_r"))
                 #cmap=get_cmap("gist_rainbow_r"))
                 #cmap=get_cmap("jet"))
    # Add a color bar
    plt.colorbar(ax=ax, shrink=.98, ticks = levels, extend = extend_colorbar)
    # Set the map bounds
    ax.set_xlim(cartopy_xlim(mslp))
    ax.set_ylim(cartopy_ylim(mslp))
    ax.gridlines()
    plt.title(title)
    #print('plotting ' + levels_tag)
    plt.savefig(figurename, dpi=90, bbox_inches='tight')
    plt.close()
    print('plotted ' + levels_tag)
    
    #return fig

#%%
def plotta_mappa_contour(levels_tag,field,cart_proj,lons,lats,string_date_init,
                 string_date_forecast, title, colormap, figurename):
    #global reader
    #define color levels
    levels = color_levels(levels_tag)[0]
    extend_colorbar = color_levels(levels_tag)[1]
    
    #init figure for plot
    fig = plt.figure(figsize=(12,9))
    ax = plt.axes(projection=cart_proj)
    #reader = shpreader.Reader("/afs/enea.it/por/user/forair/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #reader = shpreader.Reader("/home/massimo/data/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #regioni = cf.ShapelyFeature(reader.geometries(),
              #crs=crs.UTM(32),facecolor="none", edgecolor='black', lw=1)
    #ax.add_feature(regioni)

    ax.add_feature(cf.LAND)
    ax.add_feature(cf.COASTLINE)
    ax.add_feature(cf.BORDERS)
    
    contours = plt.contour(to_np(lons), to_np(lats), to_np(field),
                       levels=levels, colors="black",
                       transform=crs.PlateCarree())
    plt.clabel(contours)

    plt.contourf(to_np(lons), to_np(lats), to_np(field), 10,
             levels=levels,transform=crs.PlateCarree(),
             cmap=get_cmap(colormap), extend = extend_colorbar)

    # Add a color bar
    plt.colorbar(ax=ax, shrink=.98, ticks = levels, extend = extend_colorbar)

    # Set the map bounds
    ax.set_xlim(cartopy_xlim(mslp))
    ax.set_ylim(cartopy_ylim(mslp))

    ax.gridlines()

    plt.title(title)
    #print('plotting ' + levels_tag)
    plt.savefig(figurename, dpi=90, bbox_inches='tight')
    plt.close()
    print('plotted ' + levels_tag)
    
    #return fig

#%%
def plotta_mappa_contour_and_fill(levels_tag_contour,
                                  levels_tag_fill,
                                  field_contour,
                                  field_fill,
                                  cart_proj,
                                  lons,
                                  lats,
                                  string_date_init,
                                  string_date_forecast, 
                                  title, 
                                  colormap, 
                                  figurename):
    #define color levels
    levels_contour = color_levels(levels_tag_contour)[0]
    levels_fill = color_levels(levels_tag_fill)[0]
    extend_colorbar = color_levels(levels_tag_fill)[1]
    
    #init figure for plot
    fig = plt.figure(figsize=(12,9))
    ax = plt.axes(projection=cart_proj)
    #reader = shpreader.Reader("/afs/enea.it/por/user/forair/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #reader = shpreader.Reader("/home/massimo/data/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #regioni = cf.ShapelyFeature(reader.geometries(),
              #crs=crs.UTM(32),facecolor="none", edgecolor='black', lw=1)
    #ax.add_feature(regioni)

    ax.add_feature(cf.LAND)
    ax.add_feature(cf.COASTLINE)
    ax.add_feature(cf.BORDERS)
    
    contours = plt.contour(to_np(lons), to_np(lats), to_np(field_contour),
                       levels=levels_contour, colors="black",
                       transform=crs.PlateCarree())
    plt.clabel(contours)

    plt.contourf(to_np(lons), to_np(lats), to_np(field_fill), 10,
             levels=levels_fill,transform=crs.PlateCarree(),
             cmap=get_cmap(colormap), extend = extend_colorbar)
             #cmap=get_cmap("hsv_r"))
             #cmap=get_cmap("gist_rainbow_r"))
             #cmap=get_cmap("jet"))


    # Add a color bar
    plt.colorbar(ax=ax, shrink=.98, ticks = levels_fill, extend = extend_colorbar)

    # Set the map bounds
    #ax.set_xlim(cartopy_xlim(mslp))
    #ax.set_ylim(cartopy_ylim(mslp))

    ax.gridlines()

    plt.title(title)
    #print('plotting ' + levels_tag_contour + 'and' + levels_tag_fill)
    plt.savefig(figurename, dpi=90, bbox_inches='tight')
    plt.close()
    print('plotted ' + levels_tag_contour + 'and' + levels_tag_fill)
    
    return fig

#%%
def plotta_mappa_wind(levels_tag,filled_contour, u, v,cart_proj,lons,lats,
                      string_date_init, string_date_forecast, title, figurename):
    #global reader    
    #define color levels
    levels = color_levels(levels_tag)[0]
    extend_colorbar = color_levels(levels_tag)[1]
    #init figure for plot
    fig = plt.figure(figsize=(12,9))
    ax = plt.axes(projection=cart_proj)
    #reader = shpreader.Reader("/afs/enea.it/por/user/forair/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #reader = shpreader.Reader("/home/massimo/data/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
    #regioni = cf.ShapelyFeature(reader.geometries(),
              #crs=crs.UTM(32),facecolor="none", edgecolor='black', lw=1)
    #ax.add_feature(regioni)
    
    ax.add_feature(cf.COASTLINE)
    ax.add_feature(cf.BORDERS)
   # states = NaturalEarthFeature(category="cultural", scale="50m",
   #                              facecolor="none",
   #                              name="admin_1_states_provinces_shp")
   # ax.add_feature(states, linewidth=0.5, edgecolor="black")
    ax.coastlines('50m', linewidth=0.8)


    # add filled contours
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
       
    colmap = mcolors.ListedColormap(cmap_data, 'custom_prec')
    cmap=get_cmap(colmap)
    cmap.set_extremes(under='white', over=(77/255,0,0))
    norm = mcolors.BoundaryNorm(levels, colmap.N)
    
    plt.contourf(to_np(lons), to_np(lats), to_np(filled_contour), 10,
                 levels=levels,transform=crs.PlateCarree(),
                 cmap=get_cmap(cmap), extend = extend_colorbar)
                 #cmap=get_cmap("hsv_r"))
                 #cmap=get_cmap("gist_rainbow_r"))
                 #cmap=get_cmap("jet"))
    
    jumpx = round( len(lons)/30 )     
    jumpy = round( len(lats)/30 )          
            
    plt.barbs(to_np(lons[::jumpx,::jumpy]), to_np(lats[::jumpx,::jumpy]),
          to_np(u[::jumpx, ::jumpy]), to_np(v[::jumpx, ::jumpy]),
          transform=crs.PlateCarree(), length=5)



    # Add a color bar
    plt.colorbar(ax=ax, shrink=.98, ticks = levels, extend = extend_colorbar)

    # Set the map bounds
    ax.set_xlim(cartopy_xlim(mslp))
    ax.set_ylim(cartopy_ylim(mslp))

    ax.gridlines()

    plt.title(title)
    #print('plotting ' + levels_tag)
    plt.savefig(figurename, dpi=90, bbox_inches='tight')
    plt.close()
    print('plotted ' + levels_tag)
    
    #return fig   

#%%
def interp_pressure_level(ncfile,level, field, pressure):
    interpolated = interplevel(field, pressure, str(level))
    return interpolated
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
parser.add_argument("--out",
                    type=str,
                    help="absolute path for outputs")

args = parser.parse_args()
wrf_file = args.wrfout_file
start_step = args.start
end_step = args.end
out_path = args.out

#%%
#debug
#out_path='./'
#wrf_file='wrfout_d01_2022-10-05_18:00:00'
#start_step=2
#end_step=2

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

#reader = shpreader.Reader("/afs/enea.it/por/user/forair/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
#reader = shpreader.Reader("/home/massimo/data/shapefiles/Limiti01012021/Reg01012021/Reg01012021_WGS84.shp")
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

    # slp
    mslp = getvar(ncfile,'slp',timeidx=timeindex)
    mslp_smooth = smooth2d(mslp,3, cenweight=4)
    
    # strings for composing figure names
    t2 = timeforecast.strftime("%Y%m%d_%H%M")
    
    # Create the figures
    #mean sea level pressure
    title1 = "Mean Sea Level Pres. (hPa)"
    title2 = string_date_init + "\n" + string_date_forecast
    title = title1 + "\n" + title2
    levels_tag = 'mslp'
    figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    plotta_mappa_contour(levels_tag = levels_tag,
                 field = mslp_smooth,
                 cart_proj = cart_proj,
                 lons = lons,
                 lats = lats,
                 string_date_init = string_date_init,
                 string_date_forecast = string_date_forecast, 
                 title = title, 
                 colormap = "turbo", figurename = figurename)
    #print('plotting ' + levels_tag)
    #plt.savefig(figurename, dpi=90, bbox_inches='tight')
    #plt.close()
    del(mslp_smooth)
    
    #temperature at 2m
    t2m = getvar(ncfile,'T2',timeidx=timeindex)-273.13 # in Celsius
    t2m_smooth = smooth2d(t2m,3, cenweight=4)
    title1 = "Temperature at 2 m (°C)"
    title2 = string_date_init + "\n" + string_date_forecast
    title = title1 + "\n" + title2
    levels_tag='t2m'
    figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    plotta_mappa(levels_tag = levels_tag,
                  field = t2m_smooth,
                  cart_proj = cart_proj,
                  lons = lons,
                  lats = lats,
                  string_date_init = string_date_init,
                  string_date_forecast = string_date_forecast,
                  title = title,
                  colormap = "turbo", figurename = figurename)
    del(t2m)
    
    #wind at 10m
    title1 = "Wind at 10m (m/s)"
    title2 = string_date_init + "\n" + string_date_forecast
    title = title1 + "\n" + title2
    U10 = getvar(ncfile, "U10", timeidx=timeindex)
    V10 = getvar(ncfile, "V10", timeidx=timeindex)
    wspd10 = getvar(ncfile, "wspd_wdir10",timeidx=timeindex)[0,:]
    #wspd10 = np.sqrt(U10*U10+V10*V10)
    levels_tag = 'w10m'
    figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    plotta_mappa_wind(levels_tag = levels_tag, 
                      filled_contour = wspd10, 
                      u = U10, 
                      v = V10, 
                      cart_proj = cart_proj, 
                      lons = lons, 
                      lats = lats, 
                      string_date_init = string_date_init, 
                      string_date_forecast = string_date_forecast, 
                      title = title, figurename = figurename)
    
    # plot t2m + w10 vectors
    #wind at 10m
    #title1 = "2 m Temperature (°C) and Wind vectors at 10 m"
    #title2 = string_date_init + "\n" + string_date_forecast
    #title = title1 + "\n" + title2
    #plotta_mappa_wind(levels_tag = 't2m',
    #                  filled_contour = t2m_smooth,
    #                  u = U10,
    #                  v = V10,
    #                  cart_proj = cart_proj,
    #                  lons = lons,
    #                  lats = lats,
    #                  string_date_init = string_date_init,
    #                  string_date_forecast = string_date_forecast,
    #                  title = title)
    #figurename = out_path +'/' + domain + '_t2m_w10m_init_' + t1 + "-forecast_time_" + t2 + forecast_step +".png"
    #print('plotting ' + levels_tag)
    #figurename = out_path + '/' + domain + '_t2m_w10m_init'+forecast_step +".png"
    #plt.savefig(figurename, dpi=90, bbox_inches='tight')
    #plt.close()
    del(U10, V10, wspd10,t2m_smooth)
 
    #Rel Hum at 2m
    title1 = "Relative Humidity at 2 m (%)"
    title2 = string_date_init + "\n" + string_date_forecast
    title = title1 + "\n" + title2
    rh2m = getvar(ncfile,'rh2', timeidx=timeindex)
    rh2m_smooth = smooth2d(rh2m,3, cenweight=4)
    levels_tag = 'rh2m'
    figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    plotta_mappa_contour(levels_tag = levels_tag,
                 field = rh2m_smooth,
                 cart_proj = cart_proj,
                 lons = lons,
                 lats = lats,
                 string_date_init = string_date_init,
                 string_date_forecast = string_date_forecast,
                 title = title,
                 colormap = "turbo", figurename = figurename)
    del(rh2m, rh2m_smooth)
    
    #CAPE
    #title1 = "CAPE (J/kg)"
    #title2 = string_date_init + "\n" + string_date_forecast
    #title = title1 + "\n" + title2
    #cape_2d = getvar(ncfile, "cape_2d", timeidx = timeindex) 
    #cape = cape_2d[0] #CAPE
    #levels_tag = 'cape'
    #figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    #plotta_mappa(levels_tag = levels_tag,
    #              field = cape,
    #              cart_proj = cart_proj,
    #              lons = lons,
    #              lats = lats,
    #              string_date_init = string_date_init,
    #              string_date_forecast = string_date_forecast,
    #              title = title,
    #              colormap = "turbo", figurename = figurename)
    #del(cape)
    #
    #title1 = "CIN (J/kg)"
    #title2 = string_date_init + "\n" + string_date_forecast
    #title = title1 + "\n" + title2
    #cin = cape_2d[1] #CIN
    #plotta_mappa(levels_tag = 'cin',
    #             field = cin,
    #             cart_proj = cart_proj,
    #             lons = lons,
    #             lats = lats,
    #             string_date_init = string_date_init,
    #             string_date_forecast = string_date_forecast,
    #             title = title,
    #             colormap = "turbo")
    #figurename = out_path + '/' + domain +'_CIN_init_' + t1 + "-forecast_time_" + t2 + forecast_step +".png"
    #print('plotting ' + levels_tag)
    #plt.savefig(figurename, dpi=90, bbox_inches='tight')
    #plt.close()
    #del(cin, cape_2d)
    
    #cloudfraction, low, med, high
    print('reading cloudfrac')
    cloudfrac = getvar(ncfile,'cloudfrac', timeidx=timeindex)*100
    #cloud_low = cloudfrac[0,:,:]
    #cloud_med = cloudfrac[1,:,:]
    #cloud_high = cloudfrac[2,:,:]
    total_cloud_cover = np.amax(cloudfrac, axis=0)
    print('computed  TCC')
    title1 = "Cloud Cover (%)"
    title2 = string_date_init + "\n" + string_date_forecast
    title = title1 + "\n" + title2
    levels_tag = 'tcc'
    figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    plotta_mappa(levels_tag = levels_tag,
                 field = total_cloud_cover,
                 cart_proj = cart_proj,
                 lons = lons,
                 lats = lats,
                 string_date_init = string_date_init,
                 string_date_forecast = string_date_forecast,
                 title = title,
                 colormap = "Blues_r", figurename = figurename)
    del(cloudfrac, total_cloud_cover)
    
    #total precipitation
    
    #title1 = "Total Accumulated Precipitation (mm)"
    #title2 = string_date_init + "\n" + string_date_forecast
    #title = title1 + "\n" + title2
    #totprec_acc = getvar(ncfile, 'RAINC', timeidx=timeindex) + \
                  #getvar(ncfile, 'RAINNC', timeidx=timeindex)
    #levels_tag = 'totprec_acc'         
    #figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    #plotta_mappa(levels_tag = levels_tag,
    #             field = totprec_acc,
    #             cart_proj = cart_proj,
    #             lons = lons,
    #             lats = lats,
    #             string_date_init = string_date_init,
    #             string_date_forecast = string_date_forecast,
    #             title = title,
    #             colormap = "prec", figurename = figurename)
    #del(totprec_acc)
    #if timeindex == start_step:
       #totprec = getvar(ncfile, 'RAINC', timeidx=timeindex) + \
                  #getvar(ncfile, 'RAINNC', timeidx=timeindex)
       #deltaprec = totprec
    #else:
       #totprec = getvar(ncfile, 'RAINC', timeidx=timeindex) + \
                  #getvar(ncfile, 'RAINNC', timeidx=timeindex)
       #totprec_m1 = getvar(ncfile, 'RAINC', timeidx=timeindex) + \
                  #getvar(ncfile, 'RAINNC', timeidx=timeindex -1)
       #deltaprec = totprec - totprec_m1

    #hourly prec, 3h  6h, 12h
    #if timeindex >= time_offset:
    totprec_h = getvar(ncfile, 'PREC_ACC_NC', timeidx=timeindex) + \
                getvar(ncfile, 'PREC_ACC_C', timeidx=timeindex)
    totprec_3h = totprec_3h + totprec_h 
    totprec_6h = totprec_6h + totprec_h 
    totprec_12h = totprec_12h + totprec_h 
    totprec_24h = totprec_24h + totprec_h 
    #3h
    if timeindex % 3 == 0:
       title1 = "Accumulated 3 h precipitation (mm)"
       title2 = string_date_init + "\n" + string_date_forecast
       title = title1 + "\n" + title2
       levels_tag = '3hourly_prec' #levels
       figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
       plotta_mappa(levels_tag = levels_tag,
           field = totprec_3h,
           cart_proj = cart_proj,
           lons = lons,
           lats = lats,
           string_date_init = string_date_init,
           string_date_forecast = string_date_forecast,
           title = title,
           colormap = "prec", figurename = figurename)
       totprec_3h = 0
    #6h
    if timeindex % 6 == 0:
       title1 = "Accumulated 6 h precipitation (mm)"
       title2 = string_date_init + "\n" + string_date_forecast
       title = title1 + "\n" + title2
       levels_tag = '6hourly_prec' #levels
       figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
       plotta_mappa(levels_tag = levels_tag,
           field = totprec_6h,
           cart_proj = cart_proj,
           lons = lons,
           lats = lats,
           string_date_init = string_date_init,
           string_date_forecast = string_date_forecast,
           title = title,
           colormap = "prec", figurename = figurename)
       totprec_6h = 0
    #12h
    if timeindex % 12 == 0: 
       title1 = "Accumulated 12 h precipitation (mm)"
       title2 = string_date_init + "\n" + string_date_forecast
       title = title1 + "\n" + title2
       levels_tag = '12hourly_prec' #levels
       figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
       plotta_mappa(levels_tag = levels_tag,
           field = totprec_12h,
           cart_proj = cart_proj,
           lons = lons,
           lats = lats,
           string_date_init = string_date_init,
           string_date_forecast = string_date_forecast,
           title = title,
           colormap = "prec", figurename = figurename)
       totprec_12h = 0

    if timeindex % 24 == 0: #resto =6
       title1 = "Accumulated 24 h precipitation (mm)"
       title2 = string_date_init + "\n" + string_date_forecast
       title = title1 + "\n" + title2
       levels_tag = '24hourly_prec' #levels
       figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
       plotta_mappa(levels_tag = levels_tag,
           field = totprec_24h,
           cart_proj = cart_proj,
           lons = lons,
           lats = lats,
           string_date_init = string_date_init,
           string_date_forecast = string_date_forecast,
           title = title,
           colormap = "prec", figurename = figurename)
       totprec_24h = 0
    #1h
    title1 = "Hourly Precipitation acc (mm)"
    title2 = string_date_init + "\n" + string_date_forecast
    title = title1 + "\n" + title2
    levels_tag = 'hourly_prec'
    figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
    plotta_mappa(levels_tag = levels_tag,
                 field = totprec_h,
                 cart_proj = cart_proj,
                 lons = lons,
                 lats = lats,
                 string_date_init = string_date_init,
                 string_date_forecast = string_date_forecast,
                 title = title,
                 colormap = "prec", figurename = figurename)
    del(totprec_h)
    
    #pressure levels
    pressure = getvar(ncfile,'pres', timeidx = timeindex, units='hPa')
    geop = getvar(ncfile,'geopt', timeidx=timeindex)/98.1 #dam
    #temp = getvar(ncfile,'temp',units='degC', timeidx = timeindex)
    temp = getvar(ncfile,'tc', timeidx = timeindex)
    ua = getvar(ncfile, "ua",timeidx=timeindex)
    va = getvar(ncfile, "va",timeidx=timeindex)
    wspd = getvar(ncfile, "wspd_wdir",timeidx=timeindex)[0,:]
    
    #pressure_levels = [300, 500, 700, 850]
    #pressure_levels = [500, 700, 850]
    pressure_levels = [250,300, 500, 700, 850]

    for level in pressure_levels:
        if level == 850:
          labelz = 'z850'
          #labelz = -999 # if -999, not computed nor plotted
          labelt = 't850'
          labelw = 'w850'
        elif level == 700:
          labelz = 'z700'
          #labelz = -999 #not computed and plotted
          labelt = 't700'
          labelw = 'w700'
        elif level == 500:
          labelz = 'z500'
          labelt = 't500'
          labelw = 'w500'
        elif level == 300:
          labelz = 'z300'
          labelt = 't300'
          labelw = 'w300'
          #labelz = -999
          #labelt = -999
          #labelw = -999
        elif level == 250:
          #labelz = 'z250'
          #labelt = 't250'
          #labelw = 'w250'
          labelz = -999
          labelt = -999
          labelw = -999

        print("Processing level (hPa) " , level) 
        if isinstance(labelz,str) and len(labelz) > 0 \
           and isinstance(labelt,str) and len(labelt) > 0:
           title1 = "GPH and Temperature at " + str(level) +"hPa (dam)"
           title2 = string_date_init + "\n" + string_date_forecast
           title = title1 + "\n" + title2
           z_press = interp_pressure_level(ncfile, level, geop, pressure)
           t_press = interp_pressure_level(ncfile, level, temp, pressure)
           levels_tag_contour = labelz 
           levels_tag_fill = labelt 
           figurename = out_path + '/' + domain +'_' + levels_tag_contour+forecast_step +".png"
           plotta_mappa_contour_and_fill(
                         levels_tag_contour = levels_tag_contour,
                         levels_tag_fill = levels_tag_fill,
                         field_contour = z_press,
                         field_fill = t_press,
                         cart_proj = cart_proj,
                         lons = lons,
                         lats = lats,
                         string_date_init = string_date_init,
                         string_date_forecast = string_date_forecast,
                         title = title,
                         colormap = "turbo", figurename = figurename)
           del(z_press, t_press)
           
          
#        if isinstance(labelt,str) and len(labelt) > 0:
#           title1 = "Temperature at " + str(level) +"hPa (°C)"
#           title2 = string_date_init + "\n" + string_date_forecast
#           title = title1 + "\n" + title2
#           t_press = interp_pressure_level(ncfile, level, temp, pressure)
#           levels_tag = labelt
#           figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
#           plotta_mappa_contour(levels_tag = levels_tag,
#                         field = t_press,
#                         cart_proj = cart_proj,
#                         lons = lons,
#                         lats = lats,
#                         string_date_init = string_date_init,
#                         string_date_forecast = string_date_forecast,
#                         title = title,
#                         colormap = "turbo", figurename = figurename)
#           del(t_press)
            
        if isinstance(labelw,str) and len(labelw) > 0:
           title1 = "Wind  at " + str(level) +"hPa (m/s)"
           title2 = string_date_init + "\n" + string_date_forecast
           title = title1 + "\n" + title2
           ua_press = interp_pressure_level(ncfile,level, ua, pressure)
           va_press =interp_pressure_level(ncfile,level, va, pressure)
           wspd_press =interp_pressure_level(ncfile,level, wspd, pressure)
           levels_tag = labelw
           figurename = out_path + '/' + domain +'_' + levels_tag+forecast_step +".png"
           plotta_mappa_wind(levels_tag = levels_tag,
                          filled_contour = wspd_press,
                          u = ua_press,
                          v = va_press,
                          cart_proj = cart_proj,
                          lons = lons,
                          lats = lats,
                          string_date_init = string_date_init,
                          string_date_forecast = string_date_forecast,
                          title = title, figurename = figurename)
           del(wspd_press)

    del(temp, ua, va, pressure, geop)
