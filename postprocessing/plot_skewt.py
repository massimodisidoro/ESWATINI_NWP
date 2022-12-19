import wrf
import argparse
import xarray as xs
import pint_xarray
from netCDF4 import Dataset
import os    
import tempfile
os.environ['MPLCONFIGDIR'] = tempfile.mkdtemp()
import matplotlib.pyplot as plt
import numpy as np
import metpy.calc as mpcalc
import pandas as pd
from metpy.plots import SkewT
from metpy.units import units

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
                    help="difference between steps to be processed Default=1",
                    default =1)
parser.add_argument("--out",
                    type=str,
                    help="absolute path for outputs")
parser.add_argument("--lat",
                    type=float,
                    help="latitude for sounding")
parser.add_argument("--lon",
                    type=float,
                    help="longitude for sounding")
parser.add_argument("--profilename",
                    type=str,
                    help="name of the profile site")

args = parser.parse_args()
wrf_file = args.wrfout_file
start_step = args.start
end_step = args.end
out_path = args.out
lon = args.lon
lat = args.lat
profilename = args.profilename
deltastep = args.deltastep


#%%
#debug
#out_path='./'
#wrf_file='wrfout_d01_2022-10-05_18:00:00'
#start_step=10
#end_step=10
#lat=44.5
#lon=11.3
#profilename="Bologna"
#deltasetp=6

print('Starting parameters:')
print('out_path = ' + out_path)
print('wrf_file = ' + wrf_file)
print('start_step = ', start_step)
print('end_step = ', end_step)
print('deltastep = ', deltastep)
print('profile_name = ' +  profilename)
print('lon = ', lon)
print('lat = ', lat)

#start
wrfin = Dataset(wrf_file)

if wrf_file.find('d01') != -1:
    domain = 'd01'
elif wrf_file.find('d02') != -1:
    domain = 'd02'
else:
    domain = 'd03'
    
wrf_time = wrf.getvar(wrfin, 'times', timeidx=wrf.ALL_TIMES, meta=False)
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
string_date_init = "Initial Time: " + day_init + ", " + \
    timeinit.strftime("%d %B %Y, %H:%M")+ " UTC"

x_y = wrf.ll_to_xy(wrfin, lat, lon)
#%%
for timeindex in range(start_step, end_step,deltastep):
   forecast_step = "+" + str(timeindex)
   timeforecast = pd.to_datetime(str(wrf_time[timeindex]))
   day_forecast = timeforecast.strftime("%a")
   string_date_forecast = "Forecast Date: " + day_forecast + ", " + \
        timeforecast.strftime("%b %d %Y, %H:%M") + " UTC"

   print('computing ' + string_date_forecast)

   p1 = wrf.getvar(wrfin,"pressure",timeidx=timeindex)
   T1 = wrf.getvar(wrfin,"tc",timeidx=timeindex)
   Td1 = wrf.getvar(wrfin,"td",timeidx=timeindex)
   u1 = wrf.getvar(wrfin,"ua",timeidx=timeindex)
   v1 = wrf.getvar(wrfin,"va",timeidx=timeindex)

   p = p1[:,x_y[0],x_y[1]] * units.hPa
   T = T1[:,x_y[0],x_y[1]] * units.degC
   Td = Td1[:,x_y[0],x_y[1]] * units.degC
   u = u1[:,x_y[0],x_y[1]] * units('m/s')
   v = v1[:,x_y[0],x_y[1]] * units('m/s')

   # Calculate the LCL
   lcl_pressure, lcl_temperature = mpcalc.lcl(p[0], T[0], Td[0])
   
   #print(lcl_pressure, lcl_temperature)
   
   # Calculate the parcel profile.
   parcel_prof = mpcalc.parcel_profile(p, T[0], Td[0])
   parcel_prof = parcel_prof.pint.to({parcel_prof.name: "degC"})
   
   
   # Plot the data using normal plotting functions, in this case using
   # log scaling in Y, as dictated by the typical meteorological plot
   skew = SkewT()
   skew.plot(p, T, 'r')
   skew.plot(p, Td, 'g')
   skew.plot_barbs(p, u, v)
   skew.ax.set_ylim(1000, 100)
   skew.ax.set_xlim(-40, 40)# Plot LCL temperature as black dot
   #skew.plot(lcl_pressure, lcl_temperature, 'ko', markerfacecolor='black')
   
   # Plot the parcel profile as a black line
   #skew.plot(p, parcel_prof, 'k', linewidth=2)
   
   # Shade areas of CAPE and CIN
   #skew.shade_cin(p, T, parcel_prof, Td)
   #skew.shade_cape(p, T, parcel_prof)
   
   # Plot a zero degree isotherm
   skew.ax.axvline(0, color='c', linestyle='--', linewidth=2)
   
   # Add the relevant special lines
   skew.plot_dry_adiabats()
   skew.plot_moist_adiabats()
   skew.plot_mixing_lines()
   
 

   #create figure
   skew.ax.set_xlabel('Temperature ($^\circ$C)')
   skew.ax.set_ylabel('Pressure (hPa)')
   #figurename = out_path +'/' + domain + '_skewt_'+ profilename + "_" + t1 + forecast_step +".png"
   figurename = out_path +'/' + domain + '_skewt_'+ profilename + forecast_step +".png"
   print('plot name ' + figurename)
   title1 = 'Skew-T ' + profilename 
   title2 = string_date_init + "\n" + string_date_forecast
   title = title1 + '\n' + title2
   plt.title(title)
   plt.savefig(figurename, bbox_inches='tight')
   #plt.savefig(figurename, dpi=150, bbox_inches='tight')
   plt.close()
   
#plt.show()

