# Script information ------------------------------------------------------

# generate the outputs from stock assessment for ane.27.8 

# Authors: Leire Citores (lcitores@azti.es), Leire Ibaibarriaga (libaibarriaga@azti.es)

# Date: 2024/11/21

# Load packages -----------------------------------------------------------

library(icesTAF)
library(r4ss)
library(reshape2)
library(ss3diags)


# basic settings for ggplot

# theme_set(theme_bw(base_size = 25))

# Load ss run ---------------------------------------------------------------

out<-SS_output("model/ane.27.8_ss3_2024assessment_model")

# # reference points
# 
# refpts <- read.csv("data/refpts.csv")
# refpts

# Tables and plots ----------------------------------------------------------

SS_plots(out,html=TRUE,maxyr=2025)

# # residuals test
# sspar(mfrow = c(3, 3))
# pd1<-SSplotRunstest(out,subplot=c("age") ,add = TRUE,verbose = F,print = F)
# pd2<-SSplotRunstest(out,subplot=c("cpue") ,add = TRUE,verbose = F,print = F)
# sspar(mfrow = c(1, 1))
# sspar(mfrow = c(1, 2))
# rmse1<-SSplotJABBAres(out, subplots = "cpue", add = TRUE)
# rmse2<-SSplotJABBAres(out, subplots = "age", add = TRUE)
# sspar(mfrow = c(1, 1))
# SSplotComps(out,subplots = 24,print = T,kind="AGE")
# 
# selec_alter<-melt(subset(out$ageselex,Factor=="Asel")[,c("Fleet","Yr","0","1","2","3")],id.var=c("Yr","Fleet"),variable.name = "age")
# selec_alter<-subset(selec_alter,Fleet!=5)
# selec_alter$Fleet<-factor(selec_alter$Fleet,labels=c("Comm. fl 1","Comm. fl 2","AC. survey","DEPM survey"))
# 
# ps1<-ggplot(selec_alter,aes(as.numeric(age)-1,value,col=factor(Yr)))+geom_line()+geom_point()+facet_wrap(~Fleet)+xlab("age")+ylab("")+ggtitle(paste(" selectivities"))#+theme(legend.position = "none")
# 
# ps2<-ggplot(selec_alter,aes(Yr,value))+geom_line()+geom_point()+facet_grid(Fleet~age)+
#   geom_vline(xintercept=2010,col=2)+ylab("selec")+ggtitle("selectivities in time")+xlim(1987,2024)
# 
# print(ps1)
# 
# print(ps2)

# Save output -------------------------------------------------------------

save(out, file="output/run/output_run.RData")
