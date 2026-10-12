# Script information ------------------------------------------------------

# run stock assessment for ane.27.8 

# Authors: Leire Citores (lcitores@azti.es), Leire Ibaibarriaga (libaibarriaga@azti.es)

# Date: 2024/11/21

# Load packages -----------------------------------------------------------

library(r4ss)

# Copy updated assessment folder from data ---------------------------------------------------------------

file.copy(from="data/ane.27.8_ss3_2024assessment_model",
          to="model", 
          overwrite=T,recursive=T) # SS model

# Copy ss executable from boot/software ---------------------------------------------------------------

file.copy(from="boot/software/ss.exe",
          to="model/ane.27.8_ss3_2024assessment_model", 
          overwrite=T,recursive=T) # SS model

# Run SS model---------------------------------------------------------------

r4ss::run(dir="model/ane.27.8_ss3_2024assessment_model",exe="ss",skipfinished=F)


