library(markdown)
library(DT)

navbarPage("Coal Mining in Mozambique | DP Algorithm",
           tabPanel("Demo",
                    sidebarLayout(
                      sidebarPanel(
                        sliderInput("N", label = h4("Number of Years"), min = 20, 
                                    max = 100, value = 50),
                        radioButtons("Coal Type", label= h4("Coal type"),
                                     c("Thermal"="p", "Coking"="l", "Both"="b")
                        ),
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
                      plotOutput("plot")
                    ))
           ),
           tabPanel("Report",
                    includeMarkdown("about.md")
           ),
           tabPanel("Algorithm",
                    includeMarkdown("about.md")
           ),
           tabPanel("Map",
                      fluidRow(
                        column(12,
                               img(src = "http://i63.tinypic.com/20p6gq9.jpg"))                               )
                      )
)