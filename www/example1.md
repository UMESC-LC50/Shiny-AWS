---
output: 
  html_document: 
    css: custom.css
---



```{r setup, include=TRUE, tidy=TRUE, echo=FALSE}
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
```

#### Effects of exposure to high concentrations of waterborne Tl on K and Tl concentrations in <i>Chironomus riparius</i> larvae

Belowitz, R., Leonard, E. M., & O'Donnell, M. J. (2014). Effects of exposure to high concentrations of waterborne Tl on K and Tl concentrations in Chironomus riparius larvae. Comparative Biochemistry and Physiology Part C: Toxicology & Pharmacology, 166, 59-64.

This example compares the published data from the cited article to results of this web application using the same raw data. 

##### The Shapiro test using the data from the publication:

##### The result of the Shapiro test with p values greater than 0.05 assume the both sets of data come from normal distribution.

##### The Levene test results:

##### The Levene's test result of a p-value greater than 0.05 indicates that the variances for both sets of data are not different.

##### The ANOVA analysis:

##### The ANOVA analysis shows that both data sets have statiscally equal means.

##### The Tukey HSD analysis:

##### The Tukey HSD analysis indicates that no significant differences exist between the means of the publication results and the web application  results. 


