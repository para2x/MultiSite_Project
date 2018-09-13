library(PEcAn.all)
library(PEcAn.SIPNET)
library(PEcAn.LINKAGES)
library(PEcAn.visualization)
library(PEcAn.assim.sequential)
library(nimble)
library(lubridate)
library(PEcAn.visualization)
#PEcAn.assim.sequential::
library(rgdal) # need to put in assim.sequential
library(ncdf4) # need to put in assim.sequential
library(purrr)
#------------------------------------------ Setup -------------------------------------
setwd("/fs/data3/hamzed/MultiSite_Project/SDA")
unlink(c('run','out','SDA'),recursive = T)
rm(list=ls())
settings <- read.settings("pecan.SDA.multisite.xml")
if ("MultiSettings" %in% class(settings)) site.ids <- settings %>% map(~.x[['run']] ) %>% map('site') %>% map('id') %>% unlist() %>% as.character()
#sample from parameters used for both sensitivity analysis and Ens
get.parameter.samples(settings, ens.sample.method = settings$ensemble$samplingspace$parameters$method)  ## Aside: if method were set to unscented, would take minimal changes to do UnKF
load("../Obs/example_AGB_output.RData")

  
#listviewer::jsonedit(point_list)
#------------------------------------------ OBS -------------------------------------
#for multi site both mean and cov needs to be a list like this 
# +date
#   +siteid
#     c(state variables)/matrix(cov state variables)
# 
date.obs <- strsplit(names(point_list$median_AGB[[1]]),"_")[2:length(point_list$median_AGB[[1]])] %>%
  map_chr(~.x[2]) %>% paste0(.,"/12/31") 

obs.mean <-names(point_list$median_AGB[[1]])[2:length(point_list$median_AGB[[1]])] %>%
  map(function(namesl){
    ((point_list$median_AGB[[1]])[[namesl]] %>% 
        map(~.x/10 %>% as.data.frame %>% `colnames<-`(c('AbvGrndWood'))) %>% 
        setNames(site.ids)
      )
  }) %>% setNames(date.obs)

#listviewer::jsonedit(obs.mean)


obs.cov <-names(point_list$stdv_AGB[[1]])[2:length(point_list$median_AGB[[1]])] %>%
  map(function(namesl) {
    ((point_list$stdv_AGB[[1]])[[namesl]] %>%
       map( ~ (.x/10) ^ 2%>% as.matrix()) %>%
       setNames(site.ids))
    
  }) %>% setNames(date.obs)


source("/fs/data3/hamzed/pecan/modules/assim.sequential/R/sda.enkf_MultiSite.R")
#------------------------------------------ SDA -------------------------------------
sda.enkf.multisite(settings,obs.mean =obs.mean ,obs.cov = obs.cov, 
                   control=list(trace=T, 
                                interactivePlot=F, 
                                TimeseriesPlot=T,
                                BiasPlot=F,
                                plot.title="With IC (analysis result) for the forecast",
                                debug=F,
                                pause=F)
        )


# Plotting site locations -----------------------------

