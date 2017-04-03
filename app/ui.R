library(shiny)
library(shinythemes)

ui <- dashboardPage(
  dashboardHeader(title = "DP Algorithm | Coal Mining in Mozambique",
                  titleWidth = 550),
  dashboardSidebar(
      sidebarMenu(
        menuItem("Summary", tabName = "Summary", icon = icon("dashboard")),
        menuItem("Widgets", icon = icon("th"), tabName = "widgets",
                 badgeLabel = "new", badgeColor = "green")
      )
    ),
  dashboardBody(
    tags$head(tags$style(HTML('
      .main-header .logo {
                              font-family: "Source Sans Pro",Calibri,Candara,Arial,sans-serif;
                              font-weight: bold;
                              font-size: 24px;
                              }
                              '))),
    tags$head(tags$style(HTML('
      .content {
                              background:white;
      }
      .skin-blue .left-side, .skin-blue .main-sidebar, .skin-blue .wrapper {
                              background:rgb(14, 14, 14);
      }
      .skin-blue .main-header .logo {
                            background-color: #36a949;
      }
      .skin-blue .main-header .navbar {
                            background-color: #36a949;
      }
                              .main-header > .navbar {
                              margin-left: 1375px;
                              }
    .main-header {
                          background-color: #36a949;
    }

                              '))),
    # Boxes need to be put in a row (or column)
    fluidRow(
      #box(plotOutput("plot1", height = 250)),
      
      box(
        title = "Histogram", status = "warning", solidHeader = TRUE,
        collapsible = TRUE,
        plotOutput("plot1", height = 250)
      ),
      
      box(
        title = "Inputs", status = "warning", solidHeader = TRUE,height = 310,
        "Box content here", br(), "More box content",
        sliderInput("slider", "Slider input:", 1, 100, 50, round = TRUE),
        textInput("text", "Text input:")
      )
    )
  )
)
#)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)