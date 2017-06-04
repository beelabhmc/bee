# install.packages('gsheet')
# install.packages("ggplot2")
# install.packages("reshape2")
#install.packages('corrplot')
# install.packages('nlme')
# install.packages('Deducer')
library(Deducer)
library(corrplot)
library(ggplot2)
library(GGally)
library(reshape2)
library(gsheet)
#install.packages('GenABEL')
library(GenABEL)
library(nlme)
#install.packages("glmm")
library(glmm)
data=read.csv('pollinator_nectar_data.csv')
head(data)
summary(data)
data_dt=split(data, data$Date)


theshold=c()
wholedf=data.frame()
for( i in 1:length(data_dt)){
  theshold[i]=median(data_dt[[i]]$Honeybees)
  data_dt[[i]]$visits=(data_dt[[i]]$Honeybees>=theshold[i])
  wholedf=rbind(wholedf, data_dt[[i]])
}


col=c(5, 6,9,10,11,12,13)

pdf("6-03-17/logplots_median.pdf")
for (i in col){
  vars=wholedf[,c(2,i, 14)]
  names(vars)[2]=names(wholedf)[i]
  p=ggplot(data=vars, aes(x=vars[,2], y=visits))+
      geom_point()+
      labs(x=names(vars)[2])+
      facet_wrap(~Date)
    plot(p)
}
graphics.off()


###

theshold=c()
wholedf=data.frame()
for( i in 1:length(data_dt)){
  theshold[i]=mean(data_dt[[i]]$Honeybees)
  data_dt[[i]]$visits=(data_dt[[i]]$Honeybees>=theshold[i])
  wholedf=rbind(wholedf, data_dt[[i]])
}


col=c(5, 6,9,10,11,12,13)

pdf("6-03-17/logplots_mean.pdf")
for (i in col){
  vars=wholedf[,c(2,i, 14)]
  names(vars)[2]=names(wholedf)[i]
  p=ggplot(data=vars, aes(x=vars[,2], y=visits))+
    geom_point()+
    labs(x=names(vars)[2])+
    facet_wrap(~Date)
  plot(p)
}
graphics.off()


####


theshold=c()
wholedf=data.frame()
for( i in 1:length(data_dt)){
  theshold[i]=as.numeric(summary(data_dt[[i]]$Honeybees)[5])
  data_dt[[i]]$visits=(data_dt[[i]]$Honeybees>=theshold[i])
  wholedf=rbind(wholedf, data_dt[[i]])
}


col=c(5, 6,9,10,11,12,13)

pdf("6-03-17/logplots_3rd_qt.pdf")
for (i in col){
  vars=wholedf[,c(2,i, 14)]
  names(vars)[2]=names(wholedf)[i]
  p=ggplot(data=vars, aes(x=vars[,2], y=visits))+
    geom_point()+
    labs(x=names(vars)[2])+
    facet_wrap(~Date)
  plot(p)
}
graphics.off()

###glmm and lmes


wholedf$visits=as.numeric(visits)
mylogit_med <- glmm(visits ~  Avg..open.flowers.per.inflorescence+
                      Total...inflorescenses+tot_flowers
                    ,  random = list(~ 0 + factor(Date), ~ 0 + factor(Location)), 
                    varcomps.names = c("Date", "Location"),data = wholedf, 
                    family.glmm = binomial.glmm, m = 10^3)
summary(mylogit_med)


lme_mod=lme(Honeybees ~ Avg..open.flowers.per.inflorescence+
              Total...inflorescenses+tot_flowers,
            data = wholedf, random=~1|factor(Date))

summary(lme_mod)
###

