#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 10 11:11:39 2022

@author: Massimo D'Isidoro (massimo.disidoro@enea.it)

This function defines some features of the maps plotted:
    Note that varname is the correspondend "varname" key in
    the configuration file vars.yaml, in which the actual
    variables to be plotted are defined
    Here are defined the color/contour leveld (variable "levels") values
    in terms of range (np.range) or single values.
    The variable "extend_colorbar" indicates if colorbar must indicate
    out of range values in max and min (extend_colorbar = 'both') 
    or only  for maximum extend_colorbar = 'max') or minimum 
    (extend_colorbar = 'min') values.
    NOTE: ONLY for Precipitation the NUMBER of levels is FIXED, you
    can change the values but not level number. For the other
    fields you can change values and number of levels.

Report Bugs to massimo.disidoro@enea.it
"""

import numpy as np

def def_vars(varname):
    if varname == 'mslp':
        levels = np.arange(990, 1040, 2.)
        extend_colorbar = 'both'
    elif varname == 't2m':
        levels = np.arange(0, 46., 2.)
        extend_colorbar = 'both'
    elif varname == 'rh2m':
        levels = np.arange(0, 110., 10.)
        extend_colorbar = 'neither'
    elif varname == 'w10m':
        levels = np.arange(2, 22., 2.)
        extend_colorbar = 'both'
    elif varname == 'tcc':
        levels = np.arange(0, 100., 5.)
        extend_colorbar = 'max'
    elif varname == 'cape':
        levels=(100, 250., 500, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 6000)
        extend_colorbar = 'both'
    elif varname == 'hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        extend_colorbar = 'both'
    elif varname == '3hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        extend_colorbar = 'both'
    elif varname == '6hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        extend_colorbar = 'both'
    elif varname == '12hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        extend_colorbar = 'both'
    elif varname == '24hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        extend_colorbar = 'both'
    elif varname == 'z850':
        levels = np.arange(150, 160, 2)
        extend_colorbar = 'both'
    elif varname == 'z700':
        levels = np.arange(300, 330, 3)
        extend_colorbar = 'both'
    elif varname == 'z500':
        levels = np.arange(580, 590, 2)
        extend_colorbar = 'both'
    elif varname == 'z300':
        levels = np.arange(920, 1000, 5)
        extend_colorbar = 'both'
    elif varname == 'z250':
        levels = np.arange(1100, 1200, 12)
        extend_colorbar = 'both'
    elif varname == 't850':
        levels = np.arange(0, 26, 2)
        extend_colorbar = 'both'
    elif varname == 't700':
        levels = np.arange(-2, 20, 1)
        extend_colorbar = 'both'
    elif varname == 't500':
        levels = np.arange(-10, 6, 2)
        extend_colorbar = 'both'
    elif varname == 't300':
        levels = np.arange(-42, -30, 2)
        extend_colorbar = 'both'
    elif varname == 't250':
        levels = np.arange(-50, -40, 1)
        extend_colorbar = 'both'
    elif varname == 'w850':
        levels = np.arange(2, 32, 2)
        extend_colorbar = 'both'
    elif varname == 'w700':
        levels = np.arange(2, 34, 3)
        extend_colorbar = 'both'
    elif varname == 'w500':
        levels = np.arange(2,40, 4)
        extend_colorbar = 'both'
    elif varname == 'w300':
        levels = np.arange(5, 50, 5)
        extend_colorbar = 'both'
    elif varname == 'w250':
        levels = np.arange(10, 60, 5)
        extend_colorbar = 'both'
    else:
        levels =np.arange(0, 30., 2.)
        extend_colorbar = 'both'

    return levels, extend_colorbar # returns two values
