rm(list = ls()) # reset

library(tidyverse)
library(lubridate)
library(StrathE2E2)
library(furrr)
library(purrr)
source("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/@_Region file.R")
source("./StrathE2E_Upgrades/R Scripts/Functions/e2e_transient.R")

# Define the scenarios you actually want
forcings <- c("CNRM", "GFDL")
ssps <- c("ssp126", "ssp370")

scenarios <- expand.grid(forcing = forcings, ssp = ssps, stringsAsFactors = FALSE)

plan(multisession,workers = availableCores()-2)

# Function for one scenario
run_scenario <- function(forcing, ssp) {
  model <- e2e_read(
    model.name = "Celtic_Sea_MA",
    model.variant = paste0("2010-2019-", forcing, "-", ssp)
  )
  
  results <- e2e_transient(
    model = model,
    transient_years = seq(2010, 2019),
    ssp = ssp,
    forcing = forcing,
    My_scale = My_scale,
    My_atmosphere = My_atmosphere,
    My_volumes = My_volumes,
    My_light = My_light,
    My_H_Flows = My_H_Flows,
    My_V_Flows = My_V_Flows,
    My_V_Diff = My_V_Diff,
    My_Waves = My_Waves,
    My_SPM = My_SPM,
    My_boundary = My_boundary,
    My_overhang = My_overhang,
    My_overhang_diffusivity = My_overhang_diffusivity,
    My_overhang_exchanges = My_overhang_exchanges
  )
  
  # Save results
  saveRDS(
    results,
    paste0("./Mission Atlantic/Saskia/Objects/Results/Celtic/RAW.Celtic.", forcing, ".", ssp, ".rds")
  )
  
  return(paste("Finished:", forcing, ssp))
}


## Read in all the StrathE2E Driving data
My_scale <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/Domains.rds")

My_boundary <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/Boundary measurements.rds")

My_volumes <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/TS.rds") 

My_light <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/light.rds")

My_H_Flows <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/H-Flows.rds")

My_V_Flows <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/SO_DO exchanges.rds")

My_V_Diff <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/vertical diffusivity.rds")

My_Waves <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/Significant wave height.rds")

My_atmosphere <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/Atmospheric N deposition.rds")

My_SPM <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/Suspended particulate matter.rds")

My_Rivers <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/NE River Input.rds")

My_DIN_fix <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Ammonia to DIN.rds")

# My_overhang <-  readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/overhang exchanges.rds")
# 
# My_overhang_diffusivity <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/overhang diffusivity.rds")
# 
# My_overhang_exchanges <- readRDS("./Mission Atlantic/Saskia/Objects/Mission Atlantic Transients/Celtic Transient/Celtic Transient/overhang exchanges.rds")

# Run all 4 scenarios in parallel
future_pmap(scenarios, run_scenario)
