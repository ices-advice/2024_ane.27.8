# Script information ------------------------------------------------------

# generate the retro outputs from stock assessment for ane.27.8 

# Authors: Leire Citores (lcitores@azti.es), Leire Ibaibarriaga (libaibarriaga@azti.es)

# Date: 2024/11/21

# Load packages -----------------------------------------------------------

library(icesTAF)
library(r4ss)
library(ss3diags)

# basic settings for ggplot

# theme_set(theme_bw(base_size = 25))

# Load ss run ---------------------------------------------------------------

dir_retro<-"model/ane.27.8_ss3_2024assessment_model"

retro_mods <- r4ss::SSgetoutput(dirvec = file.path(dir_retro, "retrospectives", paste0("retro", seq(0, -5, by = -1))), verbose = F)
retroSummary <- r4ss::SSsummarize(retro_mods, verbose = F,SpawnOutputUnits="biomass")


# Tables and plots ----------------------------------------------------------

SSmohnsrho(retroSummary, verbose = TRUE)

SSplotRetro(retroSummary, subplots = "SSB",forecast = F,add = T)
SSplotRetro(retroSummary, subplots = "SSB",forecast = T,add = T)

SSplotComparisons(retroSummary,subplots=9,endyrvec = c(2023,2022,2021,2020,2019,2018)+1,legendlabels = paste0("retro", seq(0, -5, by = -1)))
SSplotComparisons(retroSummary,subplots=8,endyrvec = c(2023,2022,2021,2020,2019,2018)+2,legendlabels = paste0("retro", seq(0, -5, by = -1)))

r4ss::sspar(mfrow = c(2, 2))
hind1<-SSplotHCxval(retroSummary, subplots = "cpue", add = TRUE,verbose = F)
retroSummary_comps <- SSretroComps(retro_mods)
print(hind1)
r4ss::sspar(mfrow = c(2, 2))
hind2<-SSplotHCxval(retroSummary_comps, subplots = "age", add = TRUE,verbose=F)
print(hind2)
r4ss::sspar(mfrow = c(1, 1))

# Save output -------------------------------------------------------------

save(retro_mods,retroSummary, file="output/retro/output_retro.RData")


