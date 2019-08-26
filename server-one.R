#.libPaths("/srv/shiny-server/LC_calculator/library")

#library(markdown)

library(shiny)
library(drc)
library(LW1949)
library(gplots)
library(shinycssloaders)
library(Matrix)
library(DT)
library(knitr)
library(markdown)

#library(rsconnect)
library(reshape)
library(dplyr)
library(tidyverse)
#library(ggplot2)
library(RColorBrewer)
library(data.table)
library(car)
library(Hmisc)
library(shiny)
library(promises)
library(future)
plan(multiprocess)


  LC50.a<-read.csv("thiram example.csv",header=TRUE)  
  test.1<-read.csv("example.csv",header=TRUE)
# line 27 is the "server" command for this application
  #options(shiny.maxRequestSize = "5MB")
  EventTime <- Sys.time() + 4*60
shinyServer(function(input, output,session) {
  N <- 10
  values <- reactiveValues()
  status_file <- tempfile()
  
  get_status <- function(){
    scan(status_file, what = "character",sep="\n")
  }
  
  set_status <- function(msg){
    write(msg, status_file)
  }
  
  fire_interrupt <- function(){
    set_status("interrupt")
  }
  
  fire_ready <- function(){
    set_status("Ready")
  }
  
  fire_running <- function(perc_complete){
    if(missing(perc_complete))
      msg <- "Running..."
    else
      msg <- paste0("Running... ", perc_complete, "% Complete")
    set_status(msg)
  }
  
  interrupted <- function(){
    get_status() == "interrupt"
  }
  
  # Delete file at end of session
  onStop(function(){
    print(status_file)
    if(file.exists(status_file))
      unlink(status_file)
  })
  
  # Create Status File
  fire_ready()
  
  
  nclicks <- reactiveVal(0)
  result_val <- reactiveVal()
  output$purpose <- renderUI({
    HTML(markdown::markdownToHTML(knit('www/purpose-11a.Rmd'),fragment.only = TRUE), quiet = FALSE,rmarkdown=TRUE)
  })

  #output$header.1 <- renderUI({
    #tags$iframe(src='header.html',width="100%",overflow = "auto",allowtransparency="no",style="display:block;position:maximum;z-index:-900;")
      
  #})
  
  #output is the matrix of tables and values printed on the application interface page
  #s the csv file "example.csv" into a table for use in the application
  output$example<-renderTable({
    example<-test.1
  })  

    output$data.2 <- renderUI({
      output$aa <- renderDataTable(LC50.a)
      dataTableOutput("aa")
    })
    
    output$inc <- renderUI({
    #tags$iframe(src='model-stat.html',width="100%",frameBorder="0")
    
    withMathJax(includeMarkdown("www/model-stat.Rmd"))
    #HTML(markdown::markdownToHTML(withMathJax(includeMarkdown("www/model-stat.md")),fragment.only = TRUE), quiet = FALSE,rmarkdown=TRUE)
    })
    
    output$ex.1 <- renderUI({
      HTML(markdown::markdownToHTML(knit('example1.Rmd'),fragment.only = TRUE), quiet = FALSE,rmarkdown=TRUE)
    })
    
    output$ex.2 <- renderUI({
      HTML(markdown::markdownToHTML(knit('example2.Rmd'),fragment.only = TRUE), quiet = FALSE,rmarkdown=TRUE)
    })
    
    
    output$eventTimeRemaining <- renderText({
      invalidateLater(1000, session)
      paste("The time remaining for the Event:", 
            round(difftime(EventTime, Sys.time(), units='secs')), 'secs')
    })
    
    #allows a file to be inported to the shiny app
    data1 <- reactive({
      if(input$Load == 0){return()}
      inFile <- input$file1
      if (is.null(inFile)){return(NULL)}
      
      #isolates the user selected file for use in application
      isolate({ 
        input$Load
        my_data <- read.csv(inFile$datapath,na.strings="")
        my_data.1<-my_data[,1:6]
        my_data.1$species<-as.character(my_data.1$species)
        my_data.1$replicate<-as.numeric(my_data.1$replicate)
        my_data.1$conc<-as.numeric(my_data.1$conc)
        my_data.1$time<-as.numeric(my_data.1$time)
        my_data.1$total<-as.numeric(my_data.1$total)
        my_data.1$effect<-as.numeric(my_data.1$effect)
        #my_data.1$initial<-as.numeric(my_data.1$initial)
        
        my_data.1
        #my_data<-read.csv("thiram.csv",colClasses=c("factor","numeric","numeric","numeric","numeric","numeric"))
      })
    })
    
    #result_val <- reactiveVal()
    #observeEvent(input$reset_input,{
      #result_val(NULL)
      #withProgress(message = 'Calculation in progress', {
        #for(i in 1:N){
          stat2a<- reactive({
            #this section of code places a "in-progress bar" in application window
            input$reset_input # Re-run when button is clicked
            
            # Create 0-row data frame which will be used to store data
            dat <- data.frame(x = numeric(0), y = numeric(0))
            
            
            
            #This is the list of global variables; initially (and after pressing calculate)
            #these values are set to "NULL"
            #values<-NULL
            LC50.3<-NULL
            LC50<-NULL
            LC50.a<-LC50.a
            values$LC50.3<-NULL
            values$species.2<-NULL
            values$L50<-NULL
            values$species.1<-NULL
            values$how.1<-NULL
            values$end.1<-NULL
            values$mod<-NULL
            values$ED.25c<-NULL
            values$ED.50c<-NULL
            values$ED.99c<-NULL
            values$drm<-NULL
            
            #this loads the user selected data file into calculation for model selection 
            LC50<-as.data.frame(data1())
            #cols<-c("2,3,4,5,6,7")
            #LC50[,2:7] = apply(LC50[,2:7],2, function(x) as.numeric(as.character(x)))
            
            if(length(LC50)==0){
              LC50<-LC50.a
            } else {LC50<-data1()}
            #View(head(LC50))
            #a if statement to print "waiting for data" on application page
            LC50$species<-as.character(LC50$species)
            LC50$replicate<-as.numeric(LC50$replicate)
            LC50$conc<-as.numeric(LC50$conc)
            LC50$time<-as.numeric(LC50$time)
            LC50$total<-as.numeric(LC50$total)
            LC50$effect<-as.numeric(LC50$effect)
            #LC50$initial<-as.numeric(LC50$initial)
            values$species.all<-LC50$species
            values$LC50<-LC50
            #View(head(LC50))
            #allows for user selection of which species is being calculated
            species.1<-input$caption
            
            # if statement that allows the first species in data file to be use in calculator
            if(species.1==""){
              species.1<-LC50$species[2]
            }
            #identification of all species in data file
            spec.1<-unique(LC50$species)
            
            #checking to verify if inputed species is in data file
            spec.2<-species.1%in%as.character(spec.1)
            
            #if(species.1%in%as.character(spec.1)==FALSE){
            #  fb.6<-cbind.data.frame(spec.1,spec.1)
            #} else {
            
            #allows the user to select which replicate data set to begin calculations  
            how.1<-input$start #inputs first replicated trial number
            #if no start replicated is selected, this automatically selects the first replicate in data set
            if(as.character(how.1)==""){
              how.1<-min(LC50$replicate)
            } 
            
            #allows the user to select which replicated data set to be the last used in the calculation  
            end.1<-input$end
            
            #if no end replicated is selected, this automatically selects the last replicate in data set 
            if(as.character(end.1)==""){
              end.1<-max(LC50$replicate)
            } 
            
            #allows the user to select which time point to use within a replicate for LC50 calcuation
            time.1<-input$time
            
            #if not time point is user selected, the maximum time point for specific replicate is used
            if(time.1==""){
              time.1<-max(LC50$time)
            } else {time.1<-time.1}
            #places the selected time point into a global variable    
            values$time<-time.1
            
            #checks to varify the selected time point is in user's data file    
            ss1<-time.1 %in% LC50$time
            LC10.1a<-LC50[,1:6]
            LC50.1<-subset(LC50,species==species.1,select=species:effect)
            
            #subseting data based on species, replicate, and time 
            LC50.1a<-subset(LC50.1,replicate>=as.numeric(how.1) & replicate<=as.numeric(end.1))
            LC50.3a<-subset(LC50.1a,time==time.1)
            
            #this application require at least 15% of test animals in one chamber have either 
            #been effected or not, instead of attempting to create a model where there is no inflection point
            #this line determines all the concentrations in selected data file
            b.1<-aggregate(data.frame(count = LC50.3a$conc), list(value =  LC50.3a$conc), length)
            
            #determines the relationship between the effect (response) and concentration
            b.2<- aggregate(effect~conc,FUN=sum,data=LC50.3a)$effect
            
            #determines the relationship between total # of animals and concentration
            b.3<- aggregate(total~conc,FUN=sum,data=LC50.3a)$total
            
            #combines all three of the previous calculation to provide a data frame to complete test
            b.4<-cbind(b.1,b.2,b.3)
            
            #tests the number of effected animals per concentration
            b.4$test.1<-b.2/b.3
            
            #setting up a minimum pass condition
            b.4$min.test<-0.15*(as.numeric(b.4$b.3))
            
            #setting up a maximum pass condition
            b.4$max.test<-0.85*(as.numeric(b.4$b.3))
            
            #these two lines test which test conditions pass the previous test conditions
            b.4$min.p<-b.4$b.2>=b.4$min.test
            b.4$max.p<-b.4$b.2<=b.4$max.test
            
            #sets the concentrations which pass the test into one data frame containing the test conditions
            b.5<-subset(b.4,min.p==TRUE & max.p==TRUE)
            
            #isolates the replicates that have concentrations that pass the test conditions
            b.6<-which(LC50.3a$conc%in%b.5[,1])
            
            #creates a data frame with concentrations that pass the test conditions
            LC50.3b<-LC50.3a[b.6,]
            
            #tests which replicates have test chambers with no effect
            b.7<-subset(LC50.3a,LC50.3a$effect==0)
            
            #tests which replicates have test chambers with 100% effect
            b.8<-subset(LC50.3a,LC50.3a$effect==LC50.3a$total)
            
            #combines replicates that have passed the 15% test and have both test chambers with
            #no effect and 100% effect
            b.9<-intersect(intersect(b.7$replicate,b.8$replicate),LC50.3b$replicate)
            
            #creates data frame with passing replicates
            b.10<-LC50.3a[LC50.3a$replicate%in%b.9,]
            
            #creates data frame with failing replicates
            b.11<-LC50.3a[!LC50.3a$replicate%in%b.9,]
            
            #labels replicates that pass as accepted  
            if(length(b.10[,1])!=0){
              b.10$qual<-"accepted"
              b.20a<-b.10
            }
            
            #labels replicates that do not pass as poor
            if(length(b.11[,1])!=0){
              b.11$qual<-"poor"
              b.20a<-b.11
            }
            
            #labels replicates that do not pass as poor
            #if(length(b.11[,1])!=0){
            #if(length(b.6)==0){
            #  b.11$qual<-"missing partial response"
            #  b.20a<-b.11
            #}
            
            #if(length(b.8[,1])==0){
            #  b.11$qual<-"missing total response"
            #  b.20a<-b.11
            #}
            #}
            mod<-input$mod
            #combines both passing replicates and poor replicates together with quality defined
            if(length(b.10[,1])!=0 && length(b.11[,1])!=0){
              b.20a<-rbind(b.10,b.11)
            }
            #MW.1<-as.numeric(input$MW)
            #values$MW.1<-MW.1
            b.20<-b.20a[order(b.20a$replicate),]
            LC50.3b<-b.20 
            #View(head(LC50.3b))
            LC50.3<-b.20     
            #View(head(LC50.3))
            values$LC50.3<-LC50.3
          })
          
          stats2b <- reactive({
            LC50.3<- as.data.frame(stat2a())#values$LC50.3#stat2a()
            #View(head(LC50.3))
            end.1<-max(LC50.3$replicate)
            how.1<-min(LC50.3$replicate)
            #values$time.1<-input$time.1
            #values$end.1<-end.1
            #values$how.1<-how.1
            #values$species.1<-input$caption#species.1
            
            #if (as.character(input$LW=="yes")){
            #  s.1<-end.1-how.1+1
            #} else {
            #  s.1<-end.1-how.1+1}
            
            s.1<-end.1-how.1+1
            fb.5<-data.frame(models=rep(0,s.1),loglike=rep(0,s.1),AIC=rep(0,s.1),fit=rep(0,s.1),RSE=rep(0,s.1))
            #View(head(fb.5))
            for (i.1 in 1:s.1){
              s.2<-how.1+i.1-1
              LC50.3c<-LC50.3
              LC50.3c<-subset(LC50.3c,replicate==s.2)
              #values$LC50.3a<-LC50.3a
              fish.drm.2a<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LL.2(),type="continuous",separate=TRUE)
              ff.1<-mselect(fish.drm.2a,list(LL.2()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2b<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LL.3(),type="continuous",separate=TRUE)
              ff.2<-mselect(fish.drm.2b,list(LL.3()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2c<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LL.3u(),type="continuous",separate=TRUE)
              ff.3<-mselect(fish.drm.2c,list(LL.3u()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2d<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LL.4(),type="continuous",separate=TRUE)
              ff.4<-mselect(fish.drm.2d,list(LL.4()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2e<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LL.5(),type="continuous",separate=TRUE)
              ff.5<-mselect(fish.drm.2e,list(LL.5()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              
              fish.drm.2f<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LN.2(),type="continuous",separate=TRUE)
              ff.6<-mselect(fish.drm.2f,list(LN.2()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2g<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LN.3(),type="continuous",separate=TRUE)
              ff.7<-mselect(fish.drm.2g,list(LN.3()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2h<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LN.4(),type="continuous",separate=TRUE)
              ff.8<-mselect(fish.drm.2h,list(LN.4()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              
              fish.drm.2i<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W1.2(),type="continuous",separate=TRUE)
              ff.9<-mselect(fish.drm.2i,list(W1.2()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2j<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W1.3(),type="continuous",separate=TRUE)
              ff.10<-mselect(fish.drm.2j,list(W1.3()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2k<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W1.4(),type="continuous",separate=TRUE)
              ff.11<-mselect(fish.drm.2k,list(W1.4()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              
              fish.drm.2l<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W2.2(),type="continuous",separate=TRUE)
              ff.12<-mselect(fish.drm.2l,list(W2.2()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2m<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W2.3(),type="continuous",separate=TRUE)
              ff.13<-mselect(fish.drm.2m,list(W2.3()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.2n<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W2.4(),type="continuous",separate=TRUE)
              ff.14<-mselect(fish.drm.2n,list(W2.4()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              
              fish.drm.3a<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W1.3u(),type="continuous",separate=TRUE)
              ff.15<-mselect(fish.drm.3a,list(W1.3u()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.3b<-drm(effect/total~conc,data=LC50.3c,replicate,fct=W2.3u(),type="continuous",separate=TRUE)
              ff.16<-mselect(fish.drm.3b,list(W2.3u()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              fish.drm.3c<-drm(effect/total~conc,data=LC50.3c,replicate,fct=LN.3u(),type="continuous",separate=TRUE)
              ff.17<-mselect(fish.drm.3c,list(LN.3u()),nested=FALSE,sort="IC",linreg=FALSE,icfct=BIC)
              
              ff.1a<-ff.1[1,]
              ff.2a<-ff.2[1,]
              ff.3a<-ff.3[1,]
              ff.4a<-ff.4[1,]
              ff.5a<-ff.5[1,]
              ff.6a<-ff.6[1,]
              ff.7a<-ff.7[1,]
              ff.8a<-ff.8[1,]
              ff.9a<-ff.9[1,]
              ff.10a<-ff.10[1,]
              ff.11a<-ff.11[1,]
              ff.12a<-ff.12[1,]
              ff.13a<-ff.13[1,]
              ff.14a<-ff.14[1,]
              ff.15a<-ff.15[1,]
              ff.16a<-ff.16[1,]
              ff.17a<-ff.17[1,]
              
              
              fb.1<-rbind.data.frame(ff.1a,ff.2a,ff.3a,ff.4a,ff.5a,ff.6a,ff.7a,ff.8a,ff.9a,ff.10a,ff.11a,ff.12a,ff.13a,ff.14a,ff.15a,ff.16a,ff.17a)
              n.1<-as.character(c("LL.2","LL.3","LL.3u","LL.4","LL.5","LN.2","LN.3","LN.4","W1.2","W1.3","W1.4","W2.2","W2.3","W2.4","W1.3u","W2.3u","LN.3u"))
              fb.1<-signif(fb.1,4)
              fb.2<-cbind.data.frame(n.1,fb.1[,1],fb.1[,2],fb.1[,3],fb.1[,4])
              names(fb.2)<-c("models","loglike","AIC","fit","RSE")
              #fb.2$models<-         
              fb.2$models <- lapply(fb.2[,1], as.character)
              fb.3<-fb.2[order(fb.2$AIC),] 
              fb.4<-fb.3[1,]
              fb.5[i.1,]<-fb.4
              
              
            }
            
            fb.6b<-as.data.frame(fb.5)
            replicate<-c(how.1:end.1)
            fb.6<-cbind.data.frame(replicate,as.character(fb.6b$models),fb.6b$loglike,fb.6b$AIC,fb.6b$fit,fb.6b$RSE)
            names(fb.6)<-c("Replicate","Model","loglike","AIC","fit","RSE")
            #View(head(fb.6))
            values$mod<-fb.6[1,2]
            #print(fb.6[1,2])
            values$models<-fb.6[,2]
            #print(fb.6[,2])
            #values$fish.14<-fb.6
            fb.6
            #}
            #fb.6<-as.data.frame(fb.6)
            #View(head(fb.2))
            #fb.2
          })

          
          #prepares to print the graph of the data selected by user
          output$image2 <- renderPlot({ 
            par(family="serif") 
            
            while(is.null(LC50.3)){
              plot(4,4,main="load file",cex=3,cex.lab=1.3,font.lab=2,cex.main=3)
            } 
            

            #this loads the user selected data file into calculation for model selection 
            LC50.3<-stat2a()#values$LC50.3
            
            #this loads the selected model to use in the calculation
            mod<- as.character(values$mod)
            
            #this loads the selected species to use in the calculation
            species.1<-as.character(input$caption)
            if(species.1==" "){
              species.1<-LC50.3$species
            } else {species.1<-species.1}
            #this loads the first selected replicate to use in the calculation
            end.1<-max(LC50.3$replicate)
            how.1<-min(LC50.3$replicate)
            
            #indentifing the first replicate number selected
            replicate.1<-as.numeric(how.1)
            
            #allows the replicate box to be left empty by selecting the 1st replicate in data frame
            if (is.null(replicate.1)==TRUE) {
              replicate.1<-1
            }
            
            #loads the global variable of time into calculation
            time.1<-values$time
            
            #logic to determine which time point to use  
            if(length(time.1==0)){
              
              #if no timepoint is selected , the 
              time.1<-as.numeric(max(LC50.3$time))
            }
            spec.1<-unique(species.1)
            #checking to verify if inputed species is in data file
            spec.2<-species.1%in%as.character(spec.1)
            
            if(species.1%in%as.character(spec.1)==FALSE){
              
              plot(4,4,main="Wrong species",cex=3,cex.lab=1.3,font.lab=2,cex.main=3,ylab="fraction effected",xlab="conc. (ppb)")
            } else {
              
              #this creates a vector of replication number in subsetted data frame
              rep.5<-as.numeric(unique(LC50.3$replicate))
              
              #loads subsetted global data frame with dose respones data into calculation
              LC50.3<-LC50.3
              
              #plots the graph using the LW1949 model
              #print(input$LW)
              if(as.character(input$LW)=="yes"){
                
                #creates a title for plot which includes the selected species and timepoint
                main.1<-paste(species.1,"Dose Response Curve ","at ",time.1," hour using model: LW1949")
                #ensures that the model variable is read, which will eliminate incorrect error message 
                mod<-"" 
                
                #subsets selected data to the first replicate, LW1949 only calculates using one replicate
                LC50.3<-subset(LC50.3,replicate==as.numeric(how.1))
                #View(head(LC50.3))
                #prepares the user subsetted data frame for the LW1949 model to calculate estimated concentration
                mydat<-dataprep(dose=LC50.3$conc,ntot=LC50.3$total,nfx=LC50.3$effect)
                
                #plots selected data on the log10-probit scale 
                plotDELP(mydat,main=main.1,cex=3,cex.lab=1.3,font.lab=2,cex.main=1)
                
                #optimizes the best fit line to dose-effect experiment
                intslope<-fitLWauto(mydat)
                
                #generates the estimated lethal concentration 
                fLW<-LWestimate(intslope,mydat)
                
                #adds prediction from model to the plot
                predLinesLP(fLW)}
              
              #this loads the last selected replicate to use in the calculation
              else  {
                mod<- unlist(as.character(values$models))
                
                #creates a title for plot which includes the selected species and timepoint
                main.1<-paste(species.1,"Dose Response Curve ","at ",time.1," hour")
                
                end.1<-max(LC50.3$replicate)
                
                #determines the maximum x-axis value for graph
                max.x<-max(LC50.3$conc)
                
                #determines the minimum x-axis value for graph
                min.x<-min(LC50.3$conc)
                #View(head(LC50.3))
                LC50.4<-LC50.3
                #
                #print(how.1)
                LC50.4<-subset(LC50.4,replicate==how.1)
                #print(input$mod)
                if((as.character(input$mod)=="")==TRUE){
                  mod<-values$models[1]
                } else {mod<-input$mod}
                #print(mod)
                function.name<-as.character(mod)
                model.2<-get(function.name)
                model.2a<-assign(function.name,get(function.name))
                fish.drm<-drm(effect/total~conc,replicate,data=LC50.4,fct=model.2a(),type="continuous",separate=TRUE)
                
                #plots the dose response model using user selected data and values
                plot(fish.drm,main=main.1,type = "confidence",ylab="fraction effected",xlab="conc. (ppb)",cex=3,cex.lab=1.3,axes=FALSE,font.lab=2,ylim=c(0,1.0),log="x",
                     legend=FALSE,xlim=c(min.x,max.x),normal=TRUE,normRef=1,lty=unique(LC50.4$replicate),col=unique(LC50.4$replicate), pch=unique(LC50.4$replicate))
                
                #
                #cex.main=3
                
                
                #vector of y data 
                y.1<-LC50.3$effect/LC50.3$total
                
                #adds tick marks for easier reading of application plot
                minor.tick(nx=5,ny=2,tick.ratio=0.5)
                
                #sets up x-axis tick marks values and prints them on graph
                axis(1, font.axis=2,at=c(min.x,round(0.1*max.x,0),round(0.2*max.x,0),round(0.5*max.x,0),max.x),labels=TRUE,font.lab=2,tick=TRUE,lwd.ticks=1)
                
                #sets up y-axis tick marks values and prints them on graph
                axis(2, font.axis=2,font.lab=2)
                
                #sets the symbols on the graph to replicates
                xx.1<-unique(LC50.3$replicate)
                legend("topleft","(x,y)" ,xx.1,col=unique(LC50.3$replicate),pch=unique(LC50.3$replicate),title="replicate",lty=unique(LC50.3$replicate))
                
                #prints the symbol for each replicate
                points(x=LC50.3$conc,y=y.1,type="p",xlog=TRUE,cex=3,col=c(LC50.3$replicate),pch=c(LC50.3$replicate))
                
                
                #adds tick marks to the axis
                axTicks(1,axp=NULL, log=TRUE)
                
                m.1<-length(unique(LC50.3$replicate))-1
                if((m.1)>=2){
                  
                  for (i.1 in 1:(m.1)){
                    s.2<-how.1+i.1
                    LC50.4<-subset(LC50.3,replicate==as.numeric(s.2)) 
                    
                    if(as.character(input$mod)==""){
                      
                      mod<-values$models#[s.2]
                      
                      
                      
                    } else if (as.character(input$mod)!=""){
                      mod<-input$mod
                    }
                    function.name<-as.character(mod)
                    model.2<-get(function.name)
                    model.2a<-assign(function.name,get(function.name))
                    #loads the dose reponse model global variable into calculation
                    fish.drm<-drm(effect/total~conc,data=LC50.4,fct=model.2a(),type="continuous",separate=TRUE)
                    
                    #plots the dose response model using user selected data and values
                    plot(fish.drm, type = "confidence",ylab="fraction effected",add=TRUE,
                         axes=FALSE,ylim=c(0,1.0),log="x",col=unique(LC50.4$replicate),pch=unique(LC50.3$replicate),lty=unique(LC50.3$replicate),
                         legend=FALSE,xlim=c(min.x,max.x),normal=TRUE,normRef=1)
                    
                  }
                }
              }
            }
          })
          
          

          
          my_output_data <- reactive({
            req(stat2a())
            #this loads the user selected data file into calculation for model selection 
            LC50.3<- stat2a()#values$LC50.3)
            LC50.1<-data1()
            LC50.1$species<-as.character(LC50.1$species)
            #this loads the selected model to use in the calculation
            mod<- as.character(values$mod)
            
            #this loads the selected species to use in the calculation
            #allows for user selection of which species is being calculated
            species.1<-as.character(input$caption)
            
            # if statement that allows the first species in data file to be use in calculator
            if(species.1==""){
              species.1<-LC50.3$species[2]
            }
            #identification of all species in data file
            spec.1<-values$species.all
            
            spec.2<-species.1%in%spec.1
            
            if(species.1%in%as.character(spec.1)==FALSE){
              #species.2<-LC50.1$species
              species<-unique(spec.1)
              ED.2<-cbind.data.frame(species,species)
            } else {
              #this loads the first selected replicate to use in the calculation
              end.1<-max(LC50.3$replicate)
              how.1<-min(LC50.3$replicate)
              
              #indentifing the first replicate number selected
              replicate.1<-as.numeric(how.1)
              
              #allows the replicate box to be left empty by selecting the 1st replicate in data frame
              if (is.null(replicate.1)==TRUE) {
                replicate.1<-1
              }
              
              #loads the global variable of time into calculation
              time.1<-values$time
              
              #logic to determine which time point to use  
              if(length(time.1==0)){
                
                #if no timepoint is selected , the 
                time.1<-as.numeric(max(LC50.3$time))
              }
              if(length(LC50.3$species)==0){
                spec.1<-unique(LC50.3$species)
                #creating data.frame of available species
                ED.2<-cbind.data.frame(spec.1,spec.1)
                #names(ED.2)<-c("Available Species")
                #making sure that model does not create error
                #formattable(fb.6,list(
                #  Waiting = color_tile("orange","orange")))
              } else {
                
                #this creates a vector of replication number in subsetted data frame
                rep.5<-as.numeric(unique(LC50.3$replicate))
                
                if (as.character(input$LW)=="yes"){
                  
                  
                  #the LW1949 model does not handle multiple replicates, as a result the first replicate selected is used
                  LC50.3<-subset(LC50.3,replicate==how.1)
                  
                  #prepares the user subsetted data frame for the LW1949 model to calculate estimated concentration
                  mydat<-dataprep(dose=as.numeric(LC50.3$conc),ntot=as.numeric(LC50.3$total),nfx=as.numeric(LC50.3$effect))
                  
                  #optimizes the best fit line to dose-effect experiment
                  intslope<-fitLWauto(mydat)
                  
                  #generates the estimated lethal concentration 
                  fLW<-LWestimate(intslope,mydat)
                  
                  #sets up a list of endpoints to estimate
                  pctaffected<-c(25,50,99)
                  nn.1<-c("LC<sub>25</sub>","LC<sub>50</sub>","LC<sub>99</sub>")
                  
                  #makes a data frame of the estimated lethal concentration at the three endpoints
                  ED.2a<-as.data.frame(signif(predlinear(pctaffected,fLW),4))
                  ED.1a<-nn.1
                  ED.1b<-ED.2a$ED
                  ED.1c<-ED.2a$lower
                  ED.1d<-ED.2a$upper
                  
                  ED.2<-cbind.data.frame(ED.1a,ED.1b,ED.1c,ED.1d)
                  ED.2$replicate<-rep(how.1,nrow(ED.2)) 
                  ED.2<-ED.2[,c(5,1,2,3,4)]
                  names(ED.2)<-c("replicate","endpoint","estimated concentration","lower confidence limit","upper confidence limit")
                  ED.LW<-ED.2
                }
                #logic function to handle the LW1949 model selection 
                
                else {
                  s.1<-end.1-how.1+1
                  s.3<-s.1
                  ED.25c<-data.frame(rep.5=c(rep(0,s.3)),V.2=c(rep(0,s.3)),
                                     Estimate=c(rep(0,s.3)),'Std.Error'=c(rep(0,s.3)),Lower=c(rep(0,s.3)),
                                     Upper=c(rep(0,s.3)),qual.3=c(rep(0,s.3)))
                  ED.50c<-data.frame(rep.5=c(rep(0,s.3)),V.2=c(rep(0,s.3)),
                                     Estimate=c(rep(0,s.3)),'Std.Error'=c(rep(0,s.3)),Lower=c(rep(0,s.3)),
                                     Upper=c(rep(0,s.3)),qual.3=c(rep(0,s.3)))
                  ED.99c<-data.frame(rep.5=c(rep(0,s.3)),V.2=c(rep(0,s.3)),
                                     Estimate=c(rep(0,s.3)),'Std.Error'=c(rep(0,s.3)),Lower=c(rep(0,s.3)),
                                     Upper=c(rep(0,s.3)),qual.3=c(rep(0,s.3)))
                  s.4<-end.1-how.1+1
                  for (i.1 in 1:s.4){
                    s.2<-how.1+i.1-1
                    LC50.4<-LC50.3
                    LC50.4<-subset(LC50.4,replicate==s.2) 
                    if(input$mod==""){
                      mod<-values$models
                      function.name<-as.character(mod[i.1])
                    } else {
                      mod<-input$mod
                      function.name<-as.character(mod)
                    }
                    
                    model.2<-get(function.name)
                    model.2a<-assign(function.name,get(function.name))
                    
                    #loads the dose reponse model global variable into calculation
                    fish.drm<-drm(effect/total~conc,data=LC50.4,fct=model.2a(),type="continuous",separate=TRUE)
                    
                    #these lines set up the model to calculate the LC25, LC50, and LC99 concentrations
                    levels.1a<-as.numeric(input$L.1)
                    levels.1b<-as.numeric(50)
                    levels.1c<-as.numeric(input$L.2)
                    
                    #data frame with unique  quality of each replicate 
                    qual.2<-LC50.4[!duplicated(LC50.4$replicate), ]
                    
                    #a vector of the quality for each replicate
                    qual.3<-qual.2$qual
                    rep.5<-as.numeric(unique(LC50.4$replicate))
                    #calculates the estimated concentration for LC25, LC50, and LC99
                    #the number of animals effected in each tank is considered an exact number, so 
                    #the number of significant figures is dependant on the error in the calculation
                    #as a result, 4 significant figures will be reported so that additional rounding 
                    #can be done without risk of losing significance
                    ED.25a<-signif(ED(fish.drm,levels.1a,interval = "delta",bound=TRUE,pool=FALSE,od=TRUE,display=FALSE),4) 
                    ED.50a<-signif(ED(fish.drm,levels.1b,interval ="delta",bound=TRUE,pool=FALSE,od=TRUE,display=FALSE),4) 
                    ED.99a<-signif(ED(fish.drm,levels.1c,interval = "delta",bound=TRUE,pool=FALSE,od=TRUE,display=FALSE),4)
                    
                    #creates vectors of the specific EDXX containing the names given to ED.2
                    ED.25b<-cbind(rep.5,paste("LC<sub>",as.character(input$L.1),"</sub>"),ED.25a,qual.3)
                    ED.25b[ED.25b<0]<-0
                    ED.50b<-cbind(rep.5,"LC<sub>50</sub>",ED.50a,qual.3)
                    ED.50b[ED.50b<0]<-0
                    ED.99b<-cbind(rep.5,paste("LC<sub>",as.character(input$L.2),"</sub>"),ED.99a,qual.3)
                    ED.99b[ED.99b<0]<-0
                    ED.3<-rbind.data.frame(ED.25b,ED.50b,ED.99b)
                    names(ED.25b)<-c("rep.5","V.2","Estimate","Std. Error","Lower","Upper","qual.3")
                    names(ED.50b)<-c("rep.5","V.2","Estimate","Std. Error","Lower","Upper","qual.3")
                    names(ED.99b)<-c("rep.5","V.2","Estimate","Std. Error","Lower","Upper","qual.3")
                    
                    #orders the ED.2 by replicate number
                    #ED.3<-ED.3[order(as.numeric(ED.3$replicate)),]
                    
                    #makes the EDXX values global
                    values$ED.25c<-ED.25b
                    values$ED.50c<-ED.50b
                    values$ED.99c<-ED.99b
                    #ED.3<-ED.3[order(ED.3[,1]),]
                    ED.99c[i.1,]<-ED.99b
                    ED.50c[i.1,]<-ED.50b
                    ED.25c[i.1,]<-ED.25b
                  } 
                  
                  ED.99d<-as.data.frame(ED.99c)
                  ED.50d<-as.data.frame(ED.50c)
                  ED.25d<-as.data.frame(ED.25c)
                  ED.22<-rbind.data.frame(ED.25d,ED.50d)
                  ED.2<-rbind.data.frame(ED.22,ED.99d)
                  names(ED.2)<-c("replicate","endpoint","estimated dose (ppb)","std. error","lower confidence limit","upper confidence limit","quality")
                  ED.2<-ED.2[order(as.numeric(ED.2[,1])),]
                }
              }
            } 
            if(input$LW=="yes"){
              ED.2<-ED.LW
            }
            #prints the estimated lethal concentration in the application window
            ED.2
          })
          
          #pooling the data from multiple replicates
          compare.2<-reactive({
            #loads selected toxicity data into calculation for pooling data
            LC50.2<-stat2a()#values$LC50.3
            req(stat2a())
            if(input$all=="no"){
              #removes the replicates that do not have good endpoints
              LC50.3<-subset(LC50.2,qual=="accepted")#LC50.2
            } else {LC50.3<-LC50.2}
            #number of unique replicates in data
            sm.len.25<-as.numeric(length(unique(LC50.3$replicate)))
            
            if (as.character(input$LW)=="yes"){
              
              
              data<-data.frame(c("This model","only estimates","one replicate.","No pooling of data."))
              names(data)<-"Model information"
              
            } else {
              
              #this creates a vector of replication number in subsetted data frame
              rep.5<-as.numeric(unique(LC50.3$replicate))
              
              sm.len.25<-as.numeric(length(unique(LC50.3$replicate)))
              
              if (sm.len.25<=2){
                
                data<-data.frame(c("Not enough","data","available"))
                names(data)<-"Model information"
                
                
              } else {
                
                end.1<-length(rep.5)
                how.1<-1
                s.1<-end.1-how.1+1
                s.3<-3
                ED.25c<-data.frame(rep.5=c(rep(0,s.3)),V.2=c(rep(0,s.3)),
                                   Estimate=c(rep(0,s.3)),'Std.Error'=c(rep(0,s.3)),Lower=c(rep(0,s.3)),
                                   Upper=c(rep(0,s.3)),qual.3=c(rep(0,s.3)))
                ED.50c<-data.frame(rep.5=c(rep(0,s.3)),V.2=c(rep(0,s.3)),
                                   Estimate=c(rep(0,s.3)),'Std.Error'=c(rep(0,s.3)),Lower=c(rep(0,s.3)),
                                   Upper=c(rep(0,s.3)),qual.3=c(rep(0,s.3)))
                ED.99c<-data.frame(rep.5=c(rep(0,s.3)),V.2=c(rep(0,s.3)),
                                   Estimate=c(rep(0,s.3)),'Std.Error'=c(rep(0,s.3)),Lower=c(rep(0,s.3)),
                                   Upper=c(rep(0,s.3)),qual.3=c(rep(0,s.3)))
                s.4<-end.1-how.1+1
                
                for (i.1 in 1:s.4){
                  s.2<-how.1+i.1-1
                  s.3<-rep.5[s.2]
                  LC50.4<-LC50.3
                  LC50.4<-subset(LC50.4,replicate==s.3) 
                  if(input$mod==""){
                    LC50.4<-LC50.3
                    mod<-values$models
                    function.name<-as.character(mod[i.1])
                  } else {
                    
                    mod<-input$mod
                    function.name<-as.character(mod)
                  }
                  
                  model.2<-get(function.name)
                  model.2a<-assign(function.name,get(function.name))
                  #loads the dose reponse model global variable into calculation
                  fish.drm<-drm(effect/total~conc,data=LC50.4,fct=model.2a(),type="continuous",separate=TRUE)
                  
                  #sets up to pool data based on percent mortality
                  levels.1a<-as.numeric(input$L.1)
                  levels.1b<-as.numeric(50)
                  levels.1c<-as.numeric(input$L.2)
                  
                  
                  #qual.1<-unique(LC50.3$replicate)
                  qual.2<-LC50.3[!duplicated(LC50.3$replicate), ]
                  qual.3<-qual.2$qual
                  
                  #pools the data selected by calculation in this variable
                  data.25a<-signif(ED(fish.drm,levels.1a,interval = "delta",bound=TRUE,pool=TRUE,od=TRUE,display=FALSE),4) ## Need to explore fls vs delta for interval
                  data.50a<-signif(ED(fish.drm,levels.1b,interval ="delta",bound=TRUE,pool=TRUE,od=TRUE,display=FALSE),4) ## Need to explore fls vs delta for interval
                  data.99a<-signif(ED(fish.drm,levels.1c,interval = "delta",bound=TRUE,pool=TRUE,od=TRUE,display=FALSE),4)
                  #data.25a <- signif(data.25, 4)
                  #data.50a <- signif(data.50, 4)
                  #data.99a <- signif(data.99, 4)
                  data.25b<-cbind(rep.5,paste("LC<sub>",as.character(as.numeric(input$L.1)),"</sub>"),data.25a,qual.3)
                  data.25b[data.25b<0]<-0
                  data.50b<-cbind(rep.5,"LC<sub>50</sub>",data.50a,qual.3)
                  data.50b[data.50b<0]<-0
                  data.99b<-cbind(rep.5,paste("LC<sub>",as.character(as.numeric(input$L.2)),"</sub>"),data.99a,qual.3)
                  data.99b[data.99b<0]<-0
                  data.2<-rbind.data.frame(data.25b,data.50b,data.99b)
                  data.2<-cbind.data.frame(data.2[,2:6])
                  names(data.2)<-c("endpoint","estimated dose (ppb)","std. error","lower CL","upper CL")
                  #rep.1<-c("LC<sub>50</sub>","LC<sub>50</sub>","LC<sub>99</sub>")
                  #data<-cbind.data.frame(rep.1,data.2[,3:6])
                  #names(data)<-c("replicate","endpoint","estimated dose (ppb)","std. error","lower confidence limit","upper confidence limit","quality")
                  #data<-data.2[order(as.numeric(data.2$replicate)),]
                  data<-data.2
                }
              }
            }
            data
          })        
          
          output$compare.2<-renderDataTable(
            datatable(compare.2(),escape=FALSE,options(DT.options = list(pageLength = 25, language = list(search = 'Filter:'),
                                                                         #order = list(list(2, 'asc'), list(1, 'asc')),
                                                                         initComplete = JS(
                                                                           "function(settings, json) {",
                                                                           "$(this.api().table().header()).css({'background-color': '#337ab7', 'color': '#fff'});",
                                                                           "}")
            )),rownames = FALSE )
          )
          
                    # Update progress
          #incProgress(1/N)
        #}
        #})
        #})
          
          output$stats2<-renderDataTable(
            datatable(stats2b(),escape=FALSE,options(DT.options = list(pageLength = 25, language = list(search = 'Filter:'),
                                                                       #order = list(list(2, 'asc'), list(1, 'asc')),
                                                                       initComplete = JS(
                                                                         "function(settings, json) {",
                                                                         "$(this.api().table().header()).css({'background-color': '#337ab7', 'color': '#fff'});",
                                                                         "}")
            )),rownames = FALSE )
          )
          
          
          output$stats3<-renderDataTable(
            datatable(values$fish.14,escape=FALSE,options(DT.options = list(pageLength = 25, language = list(search = 'Filter:'),
                                                                            #order = list(list(2, 'asc'), list(1, 'asc')),
                                                                            initComplete = JS(
                                                                              "function(settings, json) {",
                                                                              "$(this.api().table().header()).css({'background-color': '#337ab7', 'color': '#fff'});",
                                                                              "}")
            )),rownames = FALSE )
          )
          
          
          output$my_output_data<-renderDataTable(
            datatable(my_output_data(),escape=FALSE,options(DT.options = list(pageLength = 25, language = list(search = 'Filter:'),
                                                                              #order = list(list(2, 'asc'), list(1, 'asc')),
                                                                              initComplete = JS(
                                                                                "function(settings, json) {",
                                                                                "$(this.api().table().header()).css({'background-color': '#337ab7', 'color': '#fff'});",
                                                                                "}")
            )),rownames = FALSE )
          )
                    
          
          LC50.3<-reactive({
            req(stat2a())
            LC50.3<-as.data.frame(stat2a())#values$LC50.3)
            #names(LC50.3)<-c("Species","Replicate","Concentration (ppb)","Time (hours)","Total")#,"Effect"
            LC50.3
          })
          #LC50.3()
          #prints the user subsetted data frame in application window 
          output$data2<-renderDataTable(
            datatable(LC50.3(),escape=FALSE,caption = htmltools::tags$caption(style = 'caption-side: top; text-align: center;font-weight: bold; color: #000000;',
                                                                              'Data Table: ', htmltools::strong(
                                                                              )),
                      options(DT.options = list(pageLength = 25, language = list(search = 'Filter:'),
                                                #order = list(list(2, 'asc'), list(1, 'asc')),
                                                initComplete = JS(
                                                  "function(settings, json) {",
                                                  "$(this.api().table().header()).css({'background-color': '#337ab7', 'color': '#fff'});",
                                                  "}")
                      )),rownames = FALSE)
          )
       
})


