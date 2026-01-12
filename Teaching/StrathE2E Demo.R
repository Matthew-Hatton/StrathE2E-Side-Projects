## What's everyone been coding this week?
# I've been developing a set of functions with Ben which are now available on the StrathE2E(Polar) R package dev branch
# Allows us to conduct Shapley analysis on permutations of drivers within StrathE2E. Shapley was first derived in Game Theory to fairly split winnings
# of a game with multiple players.

# Ben and I are using this framework to assess which StrathE2E drivers are most important in explaining changes in biomass. 
# I initially assumed that Shapley values could be interpreted as the percentage of biomass change attributable to, 
# for example, ice, but this turns out not to be correct. In a modelling context, we are using variance-based Shapley effects, 
# which quantify how much of the variability in model output, across all permutations (e.g all combinations of drivers set to two distinct time periods),
# is explained by each driver, rather than attributing absolute biomass units to individual drivers.

# I’ve therefore reframed the problem to show the distribution of modelled biomass outcomes across driver permutations,
# visualised as violin plots, alongside the proportional contribution of each driver group to the variance in biomass. (Show plots)
# “Across all driver permutations for 2011–2020, about 70% of the variability in demersal fish biomass is explained by ice.”
# “The spread of biomass outcomes increases over time, reflecting growing sensitivity to environmental drivers.
# Shapley values indicate which drivers contribute most to that variability,
# but do not quantify the magnitude of biomass change caused by each driver.”


## What is StrathE2E? How is it different to other ecosystem models?
# StrathE2E is an end-to-end ecosystem model representing everything from Plankton to Whales.

# Simplifies ecology and space making the model FAST and easily changeable

# Allows for the exploration of what if scenarios. What if the temperature increases in the future?

# And in the future...
# What if we have increased shipping rates, leading to increased pollutants.

# What if phenological timings change?

# Like to think of it as a model where we put lots of information in about an ecosystem (physical oceanography and human activities)
# and output metrics about the state of the ecosystem.

# Difference between other models?
# Ecopath assumes mass balance ie for every group, production must be entirely accounted for. Nothing is created or lost beyond what is explicitly specified.
# no dynamic restructuring of internal structure. Production is predefined (P/B ratios are predefined )

# StrathE2E is driven by the physics and chemistry. Things like primary production aren't imposed.

## How do I install StrathE2E?
# Go To https://www.marineresourcemodelling.maths.strath.ac.uk/strathe2e/
install.packages("StrathE2E2", repos="https://www.marineresourcemodelling.maths.strath.ac.uk/sran/")

## How do I load a model? Mention the help files
library(StrathE2E2)
e2e_ls()

model <- e2e_read("North_Sea", "1970-1999") # just a bunch of csv files

## What does a model object look like?

## How do I run a model? about 2s per simulation year
results <- e2e_run(model = model,
                   nyears = 50)

# First thing to check is if we have reached a steady state
e2e_plot_ts(model = model,
            results = results)

## How do I set up my own experiment? Changing temperature etc.
model[["data"]][["physics.drivers"]]$so_temp <- model[["data"]][["physics.drivers"]]$so_temp * 10
results2 <- e2e_run(model = model,nyears = 50)
e2e_plot_ts(model = model,results = results2)

e2e_compare_runs_bar(results1 = results,results2=results2) # compare the differences - obviously you can make the plot yourself!

## How do I generate a yield curve?

## Adding things to StrathE2E? The dreaded C code.
# Download the source package from the gitlab
# The C code is written by someone who knows R and not C and is therefore very inefficient and 'slow'.
# All in a single script


