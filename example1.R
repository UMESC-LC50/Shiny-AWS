## ----setup, include=TRUE, tidy=TRUE, echo=FALSE--------------------------
knitr::opts_chunk$set(echo = FALSE)
library(car)
library(DT)
library(knitr)
bel.1<-read.csv("belowitz-1.csv", row.names = NULL, sep= ",")
names(bel.1)<-c("Experiment","LC<sub>50</sub> (&mu;g/L)","lower confidence limit (&mu;g/L)","upper confidence limit (&mu;g/L)")

bel.2<-read.csv("belowitz-2.csv", row.names = NULL, sep= ",")
names(bel.2)<-c("Experiment","LC<sub>50</sub> (&mu;g/L)","lower confidence limit (&mu;g/L)","upper confidence limit (&mu;g/L)")

groups = factor(c(bel.1$Condition,bel.2$Condition))
a<-c(bel.1$LC)
b<-c(bel.2$LC)
ab<-c(a,b)
location<-as.factor(c(rep("publication",12),rep("application",12)))
dati.1<-data.frame(ab,location)
shapiro.test(dati.1$ab[location=="publication"])
shapiro.test(dati.1$ab[location=="application"])
leveneTest(ab~location, data=dati.1, center=mean)
results.lm <- lm(ab~location, data=dati.1)
aov.1<-aov(results.lm)
summary(aov.1)
TukeyHSD(aov.1, conf.level=0.95)

