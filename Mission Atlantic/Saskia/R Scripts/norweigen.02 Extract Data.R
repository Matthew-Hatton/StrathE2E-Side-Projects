rm(list = ls())

library(dplyr)
library(purrr)
library(ggplot2)


files <- list.files(
  "./Mission Atlantic/Saskia/Objects/Results/",
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
    region  = "Norweigen"   # still fixed, or extract from filename if needed
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
                     "Surface_layer_phytoplankton","Deep_layer_phytoplankton")

master <- all %>% 
  filter(description %in% vars_of_interest) %>% 
  arrange(description,forcing,ssp)

ggplot(master, aes(x = year, y = value, color = description)) +
  geom_line() +
  geom_point(size = 1) +
  facet_grid(ssp ~ forcing) +
  scale_y_continuous(name = "Value") +
  scale_x_continuous(name = "Year", breaks = seq(min(master$year), max(master$year), by = 1)) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

write.csv(master,"./Mission Atlantic/Saskia/Objects/Results/Norweigen.csv",
          row.names = F)
