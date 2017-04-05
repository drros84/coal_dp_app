library(markdown)
library(DT)

navbarPage("Coal Mining in Mozambique | DP Algorithm",
           tabPanel("Demo",
                    sidebarLayout(
                      sidebarPanel(
                        sliderInput("N", label = h4("Number of Years"), min = 20, 
                                    max = 100, value = 50),
                        # radioButtons("Coal Type", label= h4("Coal type"),
                                    # c("Thermal"="p", "Coking"="l", "Both"="b")
                        #),
                        numericInput("num", 
                                     label = h4("Ncondezi Reserves"), 
                                     value = 1),
                        numericInput("num", 
                                     label = h4("Revobue"), 
                                     value = 1),
                        numericInput("num", 
                                     label = h4("Zambeze"), 
                                     value = 1),
                        numericInput("num", 
                                     label = h4("Beacon Hill"), 
                                     value = 1),
                        numericInput("num", 
                                     label = h4("Benga"), 
                                     value = 1),
                        numericInput("num", 
                                     label = h4("Moatize"), 
                                     value = 1)
                      ),
                    mainPanel(
                      plotOutput("plot"),
                      plotOutput("g_k_graph"),
                      plotOutput("g_graph")
                      # plotOutput("thermal_coal_graph")
                      
                    ))
           ),
           tabPanel("Algorithm",
                    includeMarkdown("about.md")
           ),
          
           tabPanel("Report",
                    includeMarkdown("about.md")
           ),

           tabPanel("Map",
                      fluidRow(
                               img(src = "http://i63.tinypic.com/20p6gq9.jpg")                             )
                      ),
tags$head(tags$style(HTML('
      .irs-bar {
          background: #fb370b;
          border-top:#fb370b;
          border-bottom:#fb370b;
      }
      .irs-bar-edge {
          border: #fb370b;
          background: #fb370b;

      }
    .irs-single {
        background: #fb370b;
    }

                          '))))
