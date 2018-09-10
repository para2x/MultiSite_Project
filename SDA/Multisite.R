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
listviewer::jsonedit(settings)
#sample from parameters used for both sensitivity analysis and Ens
get.parameter.samples(settings, ens.sample.method = settings$ensemble$samplingspace$parameters$method)  ## Aside: if method were set to unscented, would take minimal changes to do UnKF
load("sda.obs.Rdata")

#------------------------------------------ OBS -------------------------------------
#for multi site both mean and cov needs to be a list like this 
# +date
#   +siteid
#     c(state variables)/matrix(cov state variables)
obs.mean <- obs.list$obs.mean %>%
  map(~list(.x,.x) %>% setNames(site.ids))



obs.cov<-obs.list$obs.cov %>%
  map(~list(.x,.x) %>% setNames(site.ids))

#------------------------------------------ SDA -------------------------------------
sda.enkf.multisite(settings,obs.mean =obs.mean ,obs.cov = obs.cov, control=list(trace=T, interactivePlot=F, TimeseriesPlot=T,
                                 BiasPlot=F, plot.title="With IC (analysis result) for the forecast",
                                 debug=F)
        )
