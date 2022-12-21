#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 10 11:11:39 2022

@author: massimo
"""
import numpy as np

def color_levels(levels_tag):
    if levels_tag == 'mslp':
        levels = np.arange(990, 1040, 2.)
        extend_colorbar = 'both'
    elif levels_tag == 't2m':
        levels = np.arange(0, 40., 2.)
        extend_colorbar = 'both'
    elif levels_tag == 'rh2m':
        levels = np.arange(0, 110., 10.)
        extend_colorbar = 'neither'
    elif levels_tag == 'w10m':
        levels = np.arange(2, 22., 2.)
        extend_colorbar = 'both'
    elif levels_tag == 'tcc':
        levels = np.arange(0, 100., 5.)
        extend_colorbar = 'max'
    elif levels_tag == 'cape':
        levels=(100, 250., 500, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 6000)
        extend_colorbar = 'both'
    elif levels_tag == 'cin':
        levels=(100, 250., 500, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 6000)
        extend_colorbar = 'both'
    elif levels_tag == 'totprec_acc':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        extend_colorbar = 'both'
    elif levels_tag == 'hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        #levels = (0.5,2.5,5,10,15,20,25,30,35,40,45,50,60,70,80,100,120)
        extend_colorbar = 'both'
    elif levels_tag == '3hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        #levels = (0.5,1,3,5,10,15,25,50,75,100,125,150,175,200,225,250,300,350)
        extend_colorbar = 'both'
    elif levels_tag == '6hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        #levels = (1,3,5,10,15,25,50,75,100,125,150,175,200,225,250,300,350)
        extend_colorbar = 'both'
    elif levels_tag == '12hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        #levels = (1,3,5,10,15,25,50,75,100,125,150,175,200,225,250,300,350)
        extend_colorbar = 'both'
    elif levels_tag == '24hourly_prec':
        levels = (0.5,1,3,5,7,10,15,20,25,30,40,50,60,70,80,100,125,150,175,200,250,300,350)
        #levels = (1,3,5,10,15,25,50,75,100,125,150,175,200,225,250,300,350)
        extend_colorbar = 'both'
    elif levels_tag == 'z850':
        levels = np.arange(150, 180, 2)
        extend_colorbar = 'both'
    elif levels_tag == 'z700':
        levels = np.arange(300, 380, 3)
        extend_colorbar = 'both'
    elif levels_tag == 'z500':
        levels = np.arange(560, 600, 2)
        extend_colorbar = 'both'
    elif levels_tag == 'z300':
        levels = np.arange(920, 1000, 5)
        extend_colorbar = 'both'
    elif levels_tag == 'z250':
        levels = np.arange(1900, 2200, 12)
        extend_colorbar = 'both'
    elif levels_tag == 't850':
        levels = np.arange(0, 26, 2)
        extend_colorbar = 'both'
    elif levels_tag == 't700':
        levels = np.arange(-2, 20, 1)
        extend_colorbar = 'both'
    elif levels_tag == 't500':
        levels = np.arange(-20,4, 8)
        extend_colorbar = 'both'
    elif levels_tag == 't300':
        levels = np.arange(-50, -24, 2)
        extend_colorbar = 'both'
    elif levels_tag == 't250':
        levels = np.arange(-60, -34, 2)
        extend_colorbar = 'both'
    elif levels_tag == 'w850':
        levels = np.arange(2, 36, 2)
        extend_colorbar = 'both'
    elif levels_tag == 'w700':
        levels = np.arange(2, 40, 3)
        extend_colorbar = 'both'
    elif levels_tag == 'w500':
        levels = np.arange(2,65, 5)
        extend_colorbar = 'both'
    elif levels_tag == 'w300':
        levels = np.arange(10, 70, 5)
        extend_colorbar = 'both'
    elif levels_tag == 'w250':
        levels = np.arange(10, 82, 5)
        extend_colorbar = 'both'
    else:
        levels =np.arange(0, 30., 2.)
        extend_colorbar = 'both'

    return levels, extend_colorbar # returns two values

