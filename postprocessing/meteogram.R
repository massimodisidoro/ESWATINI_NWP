library("optparse")
library(plyr)
library(dplyr)
library(ggplot2)
library(stringr)
library(lubridate)
library(tidyr)


#source("./function_scale_individual_facet_y_axes.R")

# a function useful for plots 
scale_inidividual_facet_y_axes = function(plot, ylims) {
  init_scales_orig = plot$facet$init_scales
  
  init_scales_new = function(...) {
    r = init_scales_orig(...)
    # Extract the Y Scale Limits
    y = r$y
    # If this is not the y axis, then return the original values
    if(is.null(y)) return(r)
    # If these are the y axis limits, then we iterate over them, replacing them as specified by our ylims parameter
    for (i in seq(1, length(y))) {
      ylim = ylims[[i]]
      if(!is.null(ylim)) {
        y[[i]]$limits = ylim
      }
    }
    # Now we reattach the modified Y axis limit list to the original return object
    r$y = y
    return(r)
  }
  
  plot$facet$init_scales = init_scales_new
  
  return(plot)
}

option_list = list(
    make_option(c("-p", "--pathin"), type="character", default=NULL, 
             help="path of input .TS files", metavar="character"),
    make_option(c("-d", "--date_forecast, format=yyyymmddhh"), type="character", default=NULL, 
             help="date_forecast", metavar="character"),
    make_option(c("-o", "--out"), type="character", default="./", 
             help="output [default= %default]", metavar="character")
    )
 
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

print(opt$pathin)
print(opt$date_forecast)

if (is.null(opt$pathin)|| is.null(opt$date_forecast)){
  print_help(opt_parser)
  stop("At least path of *.TS files and date_forecast arguments must be supplied (--pathin --date_forecast)", call.=FALSE)
}



date_forecast_char <- opt$date_forecast
pathin <- opt$pathin
pathout <- opt$out


length <- str_length(date_forecast_char)
if (length != 10){
   message <- paste("date_forecast ",date_forecast_char," not in format yyyymmddhh. STOP", sep=" ")
   stop(message)
}


files <- list.files(path = pathin , pattern = "d02.TS")
for (filein in  files) {
   site <- sub("\\..*", "", filein)
   filein <- paste(pathin,filein,sep="/") 
   print(filein)

   date_forecast <- lubridate::as_datetime(date_forecast_char,format="%Y%m%d%H")
   day = format.Date(date_forecast, "%d")
   year = format.Date(date_forecast, "%Y")
   month = format.Date(date_forecast, "%m")
   hour = format.Date(date_forecast, "%H")
   check_string <- paste0(as.character(year),"-",as.character(month),"-",as.character(day),"_",as.character(hour))
   # chech if date in filein is the same as date_forecast required 
   first_line <- readLines(filein,n=1)
   if(!str_detect(first_line,check_string)) {
      message <- paste("input file ", filein,"doesn't match date_forecast ",check_string," STOP", sep=" ")
   stop(message)
   }

   #!!! the following works ONLY being "2" the number of the grid
   # the command takes the header substring from the beginning to "2", which
   # is the grid id number.
   date_string <- paste0(as.character(year),"-",as.character(month),"-",as.character(day)," ",as.character(hour),"UTC")
   site_long_name <- str_trim(sub(" 2.*", "", first_line))
   #fig_title <- paste0(site_long_name,"\n","Forecast init: ",date_string) 
   fig_title <- paste0("Forecast_init: ",date_string,"\n",site_long_name)

   dati <- readr::read_table(filein,
                      skip=1,
                      col_names=c("grid_id", 
                                  "hours", 
                                  "ts_id", 
                                  "i",     
                                  "j", 
                                  "t2m_K", 
                                  "q_kg/kg", 
                                  "u10", 
                                  "v10", 
                                  "surf_press", 
                                  "global_longwave", 
                                  "net_shortwave", 
                                  "sensible_heat_flux", 
                                  "latent_heat_flux", 
                                  "tskin_K", 
                                  "top_soil_temp", 
                                  "rainc", 
                                  "rainnc", 
                                  "total_column_water")) %>% 
           dplyr::mutate(date= date_forecast + round(hours*3600)) %>%  
           dplyr::mutate(t2m = t2m_K - 273.13) %>%
           dplyr::mutate(ws = sqrt(u10*u10 + v10*v10)) %>%
           dplyr::mutate(surf_press = surf_press*0.01) %>%
           dplyr::mutate(rain_istant = 
                  rainnc - lag(rainnc, default = first(rainnc), order_by =date))%>%
           dplyr::mutate(hour = lubridate::hour(date), 
                  day = lubridate::day(date),
                  year = lubridate::year(date),
                  month = lubridate::month(date)) %>%
           dplyr::select(year,month,day,hour, t2m, ws, surf_press, rain_istant) %>%
           group_by(year, month,day,hour) %>% 
           dplyr::summarize(t2_mean = mean(t2m),
                            ws_mean = mean(ws),
                 #          surf_press_mean = mean(surf_press),
                            rain_mean = sum(rain_istant)) %>%
           dplyr::ungroup() %>%
           dplyr::mutate( 
                      date=lubridate::make_datetime(year, month, day, hour)) %>%
           dplyr::select(-year, -month, -day, -hour) %>%
           dplyr::select(date, everything())
   
   round_flag <- 5
   ymax_t2 <-   plyr::round_any(max(dati$t2_mean),round_flag, f = ceiling)
   ymax_ws <-   plyr::round_any(max(dati$ws_mean),round_flag, f = ceiling)
   ymax_prec <- plyr::round_any(max(dati$rain_mean),round_flag, f = ceiling)
   ymin_t2 <-   plyr::round_any(min(dati$t2_mean),round_flag, f = floor)
   ymin_ws <-   plyr::round_any(min(dati$ws_mean),round_flag, f = floor)
   ymin_prec <- plyr::round_any(min(dati$rain_mean),round_flag, f = floor)

   if (ymax_prec < 0.5){
     ymax_prec <- 5
     ymin_prec <- 0
   }
   
   dati_longer <-pivot_longer(dati,
                              cols=contains("mean"), 
                              values_to="value")
   
   labeller <- labeller(name = c("rain_mean" = "Precipitation (mm/h)",
                                 "t2_mean" = "2 m Temperature (°C)",
                                 "ws_mean" = "10 m wind speed (m/s)"))
   p <- ggplot(dati_longer, aes(x=date, y=value)) + 
     labs(y="",title=fig_title)+
     scale_x_datetime(date_labels = "%m/%d %HUTC ",
                      date_breaks = "6 hour", 
                      date_minor_breaks = "3 hour",
                      guide = guide_axis(angle = 40)) +
     facet_wrap(~name, scales = "free", labeller = labeller,ncol=1) +
     geom_line(data=subset(dati_longer, name=="t2_mean"), color = "red") +
     geom_line(data=subset(dati_longer, name=="ws_mean"), color = "springgreen4") +
     #geom_line(data=subset(dati_longer, name=="surf_press_mean")) +
     geom_bar(data=subset(dati_longer, name=="rain_mean"), 
          fill="blue",stat="identity")   
   # y axex limits (in alphabetical order of names)
   ylims <- list(c(ymin_prec, ymax_prec),  # rain_mean
   #              c(ymin_sp, ymax_sp), # surf press
                 c(ymin_t2, ymax_t2), # t2_mean
                 c(ymin_ws, ymax_ws)) # ws_mean
   plot <- scale_inidividual_facet_y_axes(p,ylims= ylims)
   
   filename <- paste0(pathout,"/meteogram_",site,"_",date_forecast_char,".png")
   print(filename)
   ggsave(filename, plot, scale=0.5)     
   
  remove(dati, p, plot, labeller) 
}
