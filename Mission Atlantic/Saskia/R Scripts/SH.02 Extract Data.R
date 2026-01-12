rm(list = ls())

library(dplyr)
library(purrr)
library(ggplot2)
library(ggh4x)

files <- list.files(
  "./Mission Atlantic/Saskia/Objects/Results/Saint Helena",
  pattern = "\\.rds$",      # only RDS files
  full.names = TRUE
)

all_results <- lapply(files, readRDS)

# helper to extract forcing/ssp/region from filenames
get_meta <- function(key, filepath) {
  # key example: "CNRM.ssp126"
  parts <- strsplit(key, "\\.")[[1]]
  list(
    forcing = parts[1],
    ssp     = parts[2],
    region  = "Saint Helena"
  )
}

# flatten all_results into one big dataframe
all <- map2_dfr(all_results, files, function(scenario_data, filepath) {
  
  map_dfr(names(scenario_data), function(key) {
    meta <- get_meta(key, filepath)
    
    map_dfr(names(scenario_data[[key]]), function(yr) {
      res <- scenario_data[[key]][[yr]][["All_results"]][["final.year.outputs"]][["mass_results_wholedomain"]]
      
      res %>%
        transmute(
          description = Description,
          value    = Model_annual_mean,
          units    = Units,
          year     = as.integer(yr),
          forcing  = meta$forcing,
          ssp      = meta$ssp,
          region   = meta$region
        )
    })
  })
})


## What variables do we want?
vars_of_interest <- c("Planktivorous_fish","Planktivorous_fish_larvae",
                      "Demersal_fish","Demersal_fish_larvae",
                      "Omnivorous_zooplankton","Carnivorous_zooplankton",
                      "Surface_layer_phytoplankton","Deep_layer_phytoplankton",
                      "Benthos_susp/dep_feeders","Benthos_carn/scav_feeders",
                      "Birds","Pinnipeds","Cetaceans")

master <- all %>% 
  filter(description %in% vars_of_interest) %>% 
  arrange(description,forcing,ssp)

vars <- unique(master$description)

for (v in vars) {
  p <- master %>% 
    filter(description == v) %>% 
    ggplot(aes(x = year, y = value)) +
    geom_line() +
    geom_point(size = 1) +
    ggh4x::facet_grid2(ssp ~ forcing, scales = "free_y", independent = "y") +
    scale_x_continuous(limits = c(2010, 2019), breaks = 2010:2019) +
    ggtitle(v) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(y = "Model Annual Mean") +
    NULL
  
  # ggsave(filename = paste0("./Mission Atlantic/Saskia/Figures/", v, ".png"), plot = p, width = 8, height = 5)
}

write.csv(master,"./Mission Atlantic/Saskia/Objects/Results/Saint Helena.csv",
          row.names = F)
