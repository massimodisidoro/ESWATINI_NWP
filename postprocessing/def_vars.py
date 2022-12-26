#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 10 11:11:39 2022

@author: massimo
"""
import numpy as np

def def_vars(varname):
    if varname == 'mslp':
        levels = np.arange(990, 1040, 2.)
        extend_colorbar = 'both'
    elif varname == 't2m':
        levels = np.arange(0, 40., 2.)
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
    elif varname == 'cin':
        levels=(100, 250., 500, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 6000)
        extend_colorbar = 'both'
    elif varname == 'totprec_acc':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
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
        levels = np.arange(150, 180, 2)
        extend_colorbar = 'both'
    elif varname == 'z700':
        levels = np.arange(300, 380, 3)
        extend_colorbar = 'both'
    elif varname == 'z500':
        levels = np.arange(560, 600, 2)
        extend_colorbar = 'both'
    elif varname == 'z300':
        levels = np.arange(920, 1000, 5)
        extend_colorbar = 'both'
    elif varname == 'z250':
        levels = np.arange(1900, 2200, 12)
        extend_colorbar = 'both'
    elif varname == 't850':
        levels = np.arange(0, 26, 2)
        extend_colorbar = 'both'
    elif varname == 't700':
        levels = np.arange(-2, 20, 1)
        extend_colorbar = 'both'
    elif varname == 't500':
        levels = np.arange(-20, 8, 4)
        extend_colorbar = 'both'
    elif varname == 't300':
        levels = np.arange(-50, -24, 2)
        extend_colorbar = 'both'
    elif varname == 't250':
        levels = np.arange(-60, -34, 2)
        extend_colorbar = 'both'
    elif varname == 'w850':
        levels = np.arange(2, 36, 2)
        extend_colorbar = 'both'
    elif varname == 'w700':
        levels = np.arange(2, 40, 3)
        extend_colorbar = 'both'
    elif varname == 'w500':
        levels = np.arange(2,65, 5)
        extend_colorbar = 'both'
    elif varname == 'w300':
        levels = np.arange(10, 70, 5)
        extend_colorbar = 'both'
    elif varname == 'w250':
        levels = np.arange(10, 82, 5)
        extend_colorbar = 'both'
    else:
        levels =np.arange(0, 30., 2.)
        extend_colorbar = 'both'

    return levels, extend_colorbar # returns two values
