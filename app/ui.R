library(markdown)
library(DT)

navbarPage("Coal Mining in Mozambique | DP Algorithm",
           tabPanel("Motivation",
                    includeHTML("about.html")
           ),
           tabPanel("DP Algorithm",
                    includeHTML("algorithm.html")
           ),
           tabPanel("Modeling",
                    sidebarLayout(
                      sidebarPanel(
                        radioButtons("Coal_Type", "Coal type",
                                     c("Total"="total_graphs",
                                       "Thermal"="thermal_graphs", 
                                       "Coking"="coking_graphs")),
                        radioButtons("CPY", "Capacity per year",
                                     c("Real (constant)"="constant",
                                       "Real (sampling)"="sampling")),
                        sliderInput("N", label = "Number of Years", min = 20, 
                                    max = 100, value = 50),
                        sliderInput("C", label = "Cost per ton", min = 5, 
                                    max = 80, value = 10),
                        sliderInput("alpha_coking", label = "Mean price coking", min = 102, 
                                    max = 170, value = 102),
                        sliderInput("alpha_thermal", label = "Mean price thermal", min = 63, 
                                    max = 110, value = 63),
                        sliderInput("b_coking", label = "coking price sensibility", min = 0.1, 
                                    max = 5, value = 1.5),
                        sliderInput("b_thermal", label = "thermal price sensibility", min = 0.1, 
                                    max = 5, value = 0.8),
                        sliderInput("sd_coking", label = "coking shocks sd", min = 41 * 0.3, 
                                    max = 81 * 0.3, value = 61 * 0.3),
                        sliderInput("sd_thermal", label = "thermal shocks sd", min = 1 * 0.3, 
                                    max = 41 * 0.3, value = 21 * 0.3),
                        inputPanel(h4("Reserves"),
                                   numericInput("num1", 
                                                label = "Ncondezi", 
                                                value = 1000,
                                                min = 1000,
                                                max = 10000,
                                                step = 100,
                                                width = "75%"),
                                   numericInput("num2", 
                                                label = "Revobue", 
                                                value = 1000,
                                                min = 1000,
                                                max = 10000,
                                                step = 100,
                                                width = "75%"),
                                   numericInput("num3", 
                                                label = "Zambeze", 
                                                value = 900,
                                                min = 900,
                                                max = 1500,
                                                step = 100,
                                                width = "75%"),
                                   numericInput("num4", 
                                                label = "Beacon Hill", 
                                                value = 360,
                                                min = 360,
                                                max = 1000,
                                                step = 20,
                                                width = "75%"),
                                   numericInput("num5", 
                                                label = "Benga", 
                                                value = 500,
                                                min = 500,
                                                max = 700,
                                                step = 50,
                                                width = "75%"),
                                   numericInput("num6", 
                                                label = "Moatize", 
                                                value = 425,
                                                min = 425,
                                                max = 950,
                                                step = 25,
                                                width = "75%")
                        ),
                        inputPanel(h4("Share of coking coal"),
                                   sliderInput("rho1", label = "Ncondezi", min = 0, 
                                               max = 1, value = 0),
                                   sliderInput("rho2", label = "Revobue", min = 0, 
                                               max = 1, value = 0.6),
                                   sliderInput("rho3", label = "Zambeze", min = 0, 
                                               max = 1, value = 0.6),
                                   sliderInput("rho4", label = "Beacon Hill", min = 0, 
                                               max = 1, value = 0.31),
                                   sliderInput("rho5", label = "Benga", min = 0, 
                                               max = 1, value = 0.6),
                                   sliderInput("rho6", label = "Moatize", min = 0, 
                                               max = 1, value = 0.8)
                        )
                      ),
                    mainPanel(
                      plotOutput("plot"),
                      plotOutput("g_k_graph"),
                      plotOutput("g_graph")
                    ))
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
