# Script information ------------------------------------------------------

# generate the tabs & figs for the report for ane.27.8 

# Authors: Leire Citores (lcitores@azti.es), Leire Ibaibarriaga (libaibarriaga@azti.es)

# Date: 2024/11/22

# Load packages -----------------------------------------------------------

library(icesTAF)
library(r4ss)
library(reshape2)
library(ss3diags)
# Load data ---------------------------------------------------------------

# input data

load("data/inputData.RData") 

# # reference points
# 
# refpts <- read.csv("data/refpts.csv")
# refpts

# load summary tables from output

load("output/run/output_run.RData")

# Input figures and tables -----------------------------------------------------------

# generate html for survey data

rmarkdown::render(input = "boot/initial/software/eda_surveys.Rmd",output_dir = "report", clean=F)

# generate html for catch data

rmarkdown::render(input = "boot/initial/software/eda_catch.Rmd",output_dir = "report",clean=F)

# plot from the ss3 run at "model/ane.27.8_ss3_2024assessment_model"

#input data table
input<-SS_read(dir="model/ane.27.8_ss3_2024assessment_model")

input_idx<-(input$dat$CPUE[,-2] %>% 
              pivot_wider(names_from=index,values_from=c(obs,se_log)))[,c(1,2,5,3,6,4,7)]%>% 
  arrange(year)

input_idx$se_log_3<- sqrt(exp(input_idx$se_log_3^2)-1)
input_idx$se_log_4<- sqrt(exp(input_idx$se_log_4^2)-1)
input_idx$se_log_5<- sqrt(exp(input_idx$se_log_5^2)-1)

input_catch<-(input$dat$catch %>%
                pivot_wider(names_from=c(fleet,seas),values_from=catch))[,c(1,3,4)]%>% 
  arrange(year)%>% round(.,2)
tab_input1<-merge(input_idx,input_catch, by="year")%>% round(.,2)
names(tab_input1)<-c("Year","Pelgas SSB","Pelgas CV","Bioman SSB","Bioman CV","Juvena N0","Juvena CV","Catch sem1","Catch sem2")



# Output figures and tables -----------------------------------------------------------

#compare with previous assessment
load("output/run/output_run.RData")
out_prev<-SS_output("boot/initial/software/ane.27.8_ss3_2024benchmark_final_model")
out_prev_cor <-SS_output("boot/initial/software/ane.27.8_ss3_2024benchmark_datacorrected")

outs<-SSsummarize(list(out, out_prev, out_prev_cor))
SSplotComparisons(outs, subplots=2, endyrvec = c(2024.5, 2023.5, 2023.5), legendlabels = c("ass 2024","ass benchmark", "ass benchmark cor"))

outs<-SSsummarize(list(out, out_prev))
SSplotComparisons(outs, subplots=2, endyrvec = c(2024.5, 2023.5), legendlabels = c("ass 2024", "ass benchmark"))


# table for SAG
out <-SS_output("model/ane.27.8_ss3_2024assessment_model")

summ_out<-SSsummarize(list(out,out))

SSB<-filter(summ_out$SpawnBio,Yr %in% 1987:ass.yr)[,1]
SSBupper<-filter(summ_out$SpawnBioUpper,Yr %in% 1987:ass.yr)[,1]
SSBlower<-filter(summ_out$SpawnBioLower,Yr %in% 1987:ass.yr)[,1]

# SSBdf<-as.data.frame(cbind(SSB,SSBupper,SSBlower,Year=1987:ass.yr))
# ggplot(SSBdf,aes(Year,SSB))+geom_line()+geom_point()+
#   geom_ribbon(aes(ymin=SSBlower,ymax=SSBupper),alpha=0.3)+
#   geom_hline(yintercept = 26600,lty=2)

Rec<-filter(summ_out$recruits,Yr %in% 1987:ass.yr)[,1]
Recupper<-filter(summ_out$recruitsUpper,Yr %in% 1987:ass.yr)[,1]
Reclower<-filter(summ_out$recruitsLower,Yr %in% 1987:ass.yr)[,1]

Fvalue<-filter(summ_out$Fvalue,Yr %in% 1987:ass.yr)[,c(1,4)]
Fvalueupper<-filter(summ_out$FvalueUpper,Yr %in% 1987:ass.yr)[,c(1,4)]
Fvaluelower<-filter(summ_out$FvalueLower,Yr %in% 1987:ass.yr)[,c(1,4)]

Catches<-round(ctot %>% group_by(Year) %>% summarize(ctot=sum(ctot)) %>% filter(Year %in% 1987:ass.yr),2)
Catches$Yr<-Catches$Year

Catch_F <- Catches[,3:2] %>%
  left_join(Fvaluelower, by='Yr')%>%
  left_join(Fvalue, by='Yr') %>%
  left_join(Fvalueupper, by='Yr') 

names(Catch_F)[2:5]<-c("Landings","Fvaluelower","F","Fvalueupper")

tab_deriv_quants<-cbind(Catch_F[,1:2],Reclower,Rec,Recupper,SSBlower,SSB,SSBupper,Catch_F[,3:5])

tab_deriv_quants$HR<-tab_deriv_quants$Landings/tab_deriv_quants$SSBlower

tab_deriv_quants<-tab_deriv_quants %>% mutate(across(where(is.numeric), round, 2))
tab_deriv_quants[,1:8]<-round(tab_deriv_quants[,1:8],0)

# tables for report

#model output
tab_params<-subset(out$parameters,Active_Cnt>0 & Pr_type!="dev")[,c("Label","Value","Parm_StDev","Min","Max","Init","Status")] %>%
  mutate(across(where(is.numeric), round, 2))

tab_fage<-subset(out$fatage,Fleet==Seas)[,c("Yr","Seas","0","1","2","3")] %>%
  pivot_wider(names_from=c(Seas),values_from=c(`0`,`1`, `2`, `3`)) %>%
  arrange(Yr) %>% filter(Yr>1986 & Yr<=2024) %>% mutate(across(where(is.numeric), round, 2))

names(tab_fage)<-c("Year",paste0(rep(0:3,each=2),"_s",1:2))

tab_nage<-subset(out$natage,Seas==1&`Beg/Mid`=="B")[,c("Yr","0","1","2","3")] %>%
  arrange(Yr) %>% filter(Yr>1986& Yr<=2024) %>% mutate(across(where(is.numeric), round, 0))

names(tab_nage)[1]<-c("Year")


save(tab_input1,tab_params,tab_deriv_quants,tab_fage,tab_nage,file="report/tables_report.RData")


# figures for report

# Fs and HR
ggplot(tab_fage,aes(Year,`2_s1`,col="F_sem1"))+geom_line()+
  geom_line(aes(Year,`2_s2`,col="F_sem2"))+ylab("F")
ggsave(file="report/figs_report/F1F2.png",width =6 ,height =3)

ggplot(tab_deriv_quants,aes(Yr,HR))+geom_line()

ggsave(file="report/figs_report/HR.png",width =6 ,height =3 )


#selectivity

selec_alter<-melt(subset(out$ageselex,Factor=="Asel")[,c("Fleet","Yr","0","1","2","3")],id.var=c("Yr","Fleet"),variable.name = "age")
selec_alter<-subset(selec_alter,Fleet!=5 & Yr>1986 & Yr<=2024)
selec_alter$Fleet<-factor(selec_alter$Fleet,labels=c("Comm. fl. sem1","Comm. fl. sem2","Acoustic survey","DEPM survey"))

ggplot(subset(selec_alter,Fleet %in% c("Acoustic survey", "DEPM survey")),aes(as.numeric(age)-1,value,col=factor(Yr)))+
  geom_line()+geom_point()+facet_wrap(~Fleet)+xlab("age")+ylab("sel")

ggsave(file="report/figs_report/sel_surv.png",width =6 ,height =3 )


ggplot(subset(selec_alter,Fleet %in% c("Comm. fl. sem1","Comm. fl. sem2")),aes(Yr,value))+geom_line()+geom_point(size=0.5)+facet_grid(Fleet~age)+ylab("sel")

ggsave(file="report/figs_report/sel_fishery.png",width =6 ,height =3 )

# runst test and RMSE

# residuals test

png("report/figs_report/runs_test.png",width = 14,height = 6,unit="in",res=100)
sspar(mfrow = c(2, 4))
pd1<-SSplotRunstest(out,subplot=c("age") ,add = TRUE,verbose = F,print = F)
pd2<-SSplotRunstest(out,subplot=c("cpue") ,add = TRUE,verbose = F,print = F)
sspar(mfrow = c(1, 1))
dev.off()

trace(ss3diags::SSplotJABBAres,edit=T)
#line 90: yr <- sort(unique(Res[["Time"]]))
#line 162: axis(1, at = mean.res[["Yr"]], labels = sort(unique(Res[["Yr"]])))
#RMSE
png("report/figs_report/RMSE.png",width = 14,height = 6,unit="in",res=100)
sspar(mfrow = c(1, 2))
SSplotJABBAres(out, subplots = "age", add = TRUE)
SSplotJABBAres(out, subplots = "cpue", add = TRUE)
dev.off()




# STF plot ----------------------------------------------------------------

load("output/stf/out_stf.RData")

ggplot(Table_fmult,aes(Fmult,pBpa2025))+geom_point()+geom_line()+
  geom_hline(yintercept=0.05,linetype=2)+xlim(0,2)+ylim(0.02,0.08)+theme_bw()+
  ylab("p(SSB2025<Bpa)")

ggsave(file="report/figs_report/stf_interpol_Bpa.png",width =6 ,height =3 )

ggplot(Table_fmult,aes(F2025,SSB2025))+geom_line()+
  theme_bw()+
  geom_ribbon(aes(ymin=SSB2025-1.95*SSBsd2025,ymax=SSB2025+1.95*SSBsd2025),alpha=0.4,col=NA)
              
ggsave(file="report/figs_report/stf_F_SSB.png",width =6 ,height =3 )

# compare to CBBM 2024 ----------------------------------------------------------------

#load CBBM 2023 output
load("~/Leire/ICES/2023/WGHANSA2/wghansa2023_nov/cbbm/runs/main.RData")

SS_SSB<-cbind(subset(out$timeseries,Seas==1)[3:40,c("Yr","SpawnBio")],
              out$stdtable[grep("SSB",out$stdtable$name)[3:40],])
ggplot(SS_SSB,aes(Yr,SpawnBio,col="SS 2024"))+geom_line()+geom_point()+xlim(1987,2024)+expand_limits(y=0)+
  geom_point(data=tab2[-38,],aes(Year+1986,SSB_0.5,col="CBBM 2023"))+
  geom_line(data=tab2[-38,],aes(Year+1986,SSB_0.5,col="CBBM 2023"))+theme_bw()+
  geom_ribbon(aes(ymin=SpawnBio-1.645*std, ymax=SpawnBio+1.645*std,fill="SS 2024"),col=NA,alpha=0.4)+
  geom_ribbon(data=tab2[-38,],aes(x=Year+1986,y=SSB_0.5,ymin=SSB_0.05,ymax=SSB_0.95,fill="CBBM 2023"),col=NA,alpha=0.4)+
  guides(fill = "none")

ggsave(file="report/figs_report/SSBcurrent_SS_CBBM.png",width =6 ,height =3 )


SS_HR<-cbind(subset(out$timeseries,Seas==1)[3:40,c("Yr","dead(B):_1","SpawnBio")])
SS_HR$C2<-subset(out$timeseries,Seas==2)[3:40,c("dead(B):_2")]
SS_HR$C<-SS_HR$`dead(B):_1`+SS_HR$C2
SS_HR$HR<-SS_HR$C/SS_HR$SpawnBio

ggplot(SS_HR,aes(Yr,HR,col="Final SS model"))+geom_line()+geom_point()+xlim(1987,2024)+expand_limits(y=0)+
  geom_point(data=tab2[-38,],aes(Year+1986,hr_0.5,col="CBBM"))+
  geom_line(data=tab2[-38,],aes(Year+1986,hr_0.5,col="CBBM"))

SS_rec<-cbind(subset(out$timeseries,Seas==2)[3:40,c("Yr","Recruit_0")],
              out$stdtable[grep("Recr_",out$stdtable$name)[5:42],])

ggplot(SS_rec,aes(Yr,Recruit_0/mean(Recruit_0),col="SS 2024"))+geom_line()+geom_point()+xlim(1987,2024)+expand_limits(y=0)+
geom_point(data=tab2[,],aes(Year+1986-1,R_0.5/mean(R_0.5),col="CBBM 2023"))+
  geom_line(data=tab2[,],aes(Year+1986-1,R_0.5/mean(R_0.5),col="CBBM 2023"))+
  geom_hline(yintercept=1,linetype=2)+theme_bw()+ylab("relative recruitment")

ggsave(file="report/figs_report/relative_rec_SS_CBBM.png",width =6 ,height =3 )
