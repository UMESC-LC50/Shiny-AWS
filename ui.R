library(shiny)
library(shinycssloaders)
library(rmarkdown)
library(markdown)
#sets up the side panal with interactive options

  #theme brings the Times New Roman font into the application
  fluidPage(#theme="custom.css",
    
            tags$html(lang='en'),
            
            # a style that will apply the color of the banner and the placement of the logo:
            tags$head(
              tags$link(rel = "stylesheet", type = "text/css", href = "common.css"),
              tags$link(rel = "stylesheet", type = "text/css", href = "custom-Aaron.css")
            ),
            
             includeHTML("/srv/shiny-server/LC_calculator/www/header.html"),
     
            #title of application with USGS image
            titlePanel(windowTitle = "Lethal dose estimator",
                       "Lethal dose estimator"),
            sidebarLayout(              
              #creates the left hand side bar with text input user interactive options.
              sidebarPanel(
                
                
                tags$div(
                  id="file1", class="form-group shiny-input-container",
                  tags$label(class="input-group", `for`="file1", "Select File..."),
                  
                  tags$label(
                    tags$input(type="button", name="file1", value="rnorm", checked="checked",
                               tags$span(HTML("Normal &mu;<sub>1</sub")))
                  )
                  
                ),
                
                
                
                
                fileInput("file1",   label=NULL,#h3(strong("Choose CSV File:")),
               #h3(strong("Choose CSV File:")),
                          placeholder = "Choose CSV File:" ,#tags$input(id='test'),#tags$Choose CSV File:
                          accept = c(
                            "text/csv",
                            "text/comma-separated-values,text/plain",
                            ".csv")
                          
                ),
               

                #this allows a file with toxicity data to be selected into the application                
               
                #this allows the selected file to be added to the application
                actionButton("Load", h3(strong("Load file")),
                             style="color: #fff; background-color:#337ab7; border-color: #2e6da4"),
                actionButton("reset_input", h3(strong("Calculate")),
                             style="color: #fff; background-color:#337ab7; border-color: #2e6da4"),
                           
                #this adds a button to start the calculation  
                #actionButton('cancel', 'Cancel'),
                #actionButton('status', 'Check Status'),
                
                #each of the user selected inputs:    
                textInput("caption", h3(strong("species:")), ""),
                sliderInput("L.1", h3(strong("Lowest response level:")),
                            min = 1, max = 25, value = 10
                ),
                sliderInput("L.2", h3(strong("Highest response level:")),
                            min = 85, max = 99.9, value = 99 , step = 0.5
                ),
                textInput("time", h3(strong("time point:")), "" ),
                textInput("start", h3(strong("first replicate:")), "" ),
                textInput("end", h3(strong("last replicate:")), ""),
                radioButtons("LW",h3(strong("Use Litchfield-Wilcox:")),
                             choices=c("yes","no"), "no"),
                radioButtons("all",h3(strong("Use all data:")),
                             choices=c("yes","no"),"no"),
                textInput("mod",h3(strong("Use specific model:")), ""),
                
                
                
                #white space between selection options and authorship and sponsor logo
                HTML("<br><br><br>"),
                HTML("<br><br><br>"),
                includeMarkdown("www/purpose-3a.md"),
                img(src="GLRI.png", width=200, height=75,alt = "This project is funded by the Great Lake Restoration Intiative"),
                width=3),#
              #this sets the size of the side bar,
            
            mainPanel(                
              fluidRow(#337ab7
                tags$style(HTML("
    .tabbable > .nav > li > a                  {background-color: white;  color:#337ab7}
                      .tabbable > .nav > li > a[data-value='results'] {background-color: #337ab7;   color:#337ab7}
                      .tabbable > .nav > li > a[data-value='data'] {background-color: white;  color:#337ab7}
                      .tabbable > .nav > li > a[data-value='pooled results'] {background-color: white; color:#337ab7}
                      .tabbable > .nav > li > a[data-value='instructions'] {background-color: white; color:#337ab7}  
                      .tabbable > .nav > li > a[data-value='models'] {background-color: white; color:#337ab7}
                      .tabbable > .nav > li[class=active]    > a {background-color: #337ab7; color:white}
                      ")),

                tabsetPanel(
                  #tags$head(tags$style(type = "text/css", "#diamonds1 {width:115vh !important;}")),
                  
                  #this is where the instructions are, each line adds a new section to the instructions
                  tabPanel(h3(strong("Instructions")),
                           #textOutput("env.1"),
                           uiOutput('purpose')
                           ),                  
                  
                  tabPanel(h3(strong("Results")),
                           #textOutput("eventTimeRemaining"),
                           #div(h3(DT::dataTableOutput("result"),include.rownames=TRUE)),
                           div(h3(withSpinner(imageOutput("image2"),type=3,color.background ="#F5F5F5" ))),
                           h1("Model Results"),
                           div(h3(withSpinner(DT::dataTableOutput("my_output_data"),type=1),include.rownames=TRUE)),
                           h1("Best model for each replicate:"), 
                           div(h3(withSpinner(DT::dataTableOutput("stats2"),type=1),include.rownames=TRUE))
                           
                           ),
                  
                  tabPanel(h3(strong("Data")),
                           div(h3(withSpinner(DT::dataTableOutput("data2"),type=1),include.rownames=TRUE))
                           ),

                  tabPanel(h3(strong("Pooled Results")),
                           div(h3(withSpinner(DT::dataTableOutput("compare.2"),type=1),include.rownames=TRUE))
                           ),
                  tabPanel(h3(strong("Model Statistics")),
                           h1("Best model for each replicate (repeated from the Results tab): "), 
                           div(h3(withSpinner(DT::dataTableOutput("stats3"),type=1), include.rownames=TRUE)),
                           h1("These are the coefficients for each replicate using the best model:"),
                           div(h3(withSpinner(DT::dataTableOutput("coef.1"),type=1),include.rownames=TRUE)),
                           uiOutput('inc')
                           ),
                  tabPanel(h3(strong("Available Models")),
                           div(h3(withSpinner(DT::dataTableOutput("models"),type=1))),
                           h1("References and additional information on the drc package and dose response models can be found at:"), 
                           h1(a("the drc package documentation file",
                                href="https://cran.r-project.org/web/packages/drc/drc.pdf")),
                           h1("Additional information on the LW1949 package and Litchfield-Wilcox model can be found at:"), 
                           h1(a("the LW1949 package documentation file",
                                href="https://cran.r-project.org/web/packages/LW1949/LW1949.pdf"))
                           ),
                  tabPanel(h3(strong("Validation")),
                           tabsetPanel(
                             tabPanel(strong("Example 1"),
                                      uiOutput('ex.1')
                                      ),
                             tabPanel(strong("Example 2"),
                                      uiOutput('ex.2')
                                      )
                             )#tabsetPanel end
                           )#Validation end
                )#tabsetPanel end
              )#fluidRow end
            ),#mainPanel end
),#,#sidebarLayout end
includeHTML("/srv/shiny-server/LC_calculator/www/footer.html")
  )#fluidPage end


