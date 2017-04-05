function(input, output, session) {
  output$plot <- renderPlot({
    # Parameters
    N <- input$N  # number of concession years 
    real_capacity_per_year <- read.csv("/Users/k2/GSE/Semester2/Stochastic/coal_dp_app/app/mine_limits.csv")[,-1]
    mines <- ncol(real_capacity_per_year)  # number of mines
    capacity <- "constant"
    
    if(capacity == "sampling") {
      capacity_per_year <- matrix(0, nrow = N, ncol = mines)
      for(i in 1:mines) {
        mine_capacity_aux <- table(as.numeric(na.exclude(real_capacity_per_year[,i])))
        mine_capacity_aux <- mine_capacity_aux / sum(mine_capacity_aux)
        capacity_per_year_aux <- NULL
        for(j in 1:length(mine_capacity_aux)) {
          capacity_per_year_aux <- c(capacity_per_year_aux,
                                     rep(as.numeric(names(mine_capacity_aux[j])), ceiling(N*mine_capacity_aux[j])))
        }
        if(length(capacitp_per_year_aux) > N){
          capacity_per_year[1:N, i] <- capacity_per_year_aux[1:N]
        } else {
          capacity_per_year[1:length(capacity_per_year_aux), i] <- capacity_per_year_aux
        }
      }  
    }
    
    if(capacity == "random") {
      capacity_per_year <- NULL
      for(i in 1:mines) {
        capacity_per_year <- cbind(capacity_per_year, floor(runif(N, min = 0, max = total_capacity_of_mine[i])))
      }
    }
    
    if(capacity == "constant"){
        real_capacity_per_year[is.na(real_capacity_per_year)] <- 0
        capacity_per_year <- NULL
        for(i in 1:mines){
          capacity_per_year <- cbind(capacity_per_year,
                                     c(real_capacity_per_year[, i],
                                       rep(tail(real_capacity_per_year[, i], 1), N - nrow(real_capacity_per_year))))
        }
      }
    
    
    #extraction_cost_per_tone <- 10 # extraction cost per tone of coal
    
    #b_coking_coal <- 2
    #a_coking_coal <- 3
    
    #b_thermal_coal <- 2
    #a_thermal_coal <- 5
    
    total_capacity_of_mine = rep(1000, mines)
    
    capacity_per_year <- rbind(capacity_per_year, rep(0, mines))
    
    # Variables
    # coking_coal_price_expected_value <- b_coking_coal + a_coking_coal * seq(1,N) # expeted value of coking coal price
    # thermal_coal_price_expected_value <- b_thermal_coal + a_thermal_coal * seq(1,N) # expected value thermal coal price
    
    # Auxiliar functions
    
    colSums2 <- function(x) {
      if(is.matrix(x) == TRUE){
        colSums(x)
      } else {
        colSums(t(as.matrix(x)))
      }
    }
    
    # Dynamics of the model
    X <- NULL
    for(i in 1:N) {
      X <- rbind(X, pmin(pmax(rep(0, mines), total_capacity_of_mine - colSums2(capacity_per_year[(i+1):(N+1),])),
                         capacity_per_year[i]))
      total_capacity_of_mine <- total_capacity_of_mine - X[i, ]
    }
    
    X <- as.data.frame(X)
    colnames(X) <- colnames(real_capacity_per_year)
    ##### Reshaping Data
    
    X_coking <- X + rnorm(nrow(X), mean = 10, sd = 2)
    X_thermal <- X - rnorm(nrow(X), mean = 3, sd = 2)
    
    # Create a vector for the number of years under consideration
    years <- c(2011:(2011+N-1))
    # Reshape total coal output for ggplot
    X <- cbind(years, X)
    X <- melt(X, id = "years")
    # Reshape coking coal output for ggplot
    X_coking <- cbind(years, X_coking)
    X_coking <- melt(X_coking, id = "years")
    # Reshape thermal coal output for ggplot
    X_thermal <- cbind(years, X_thermal)
    X_thermal <- melt(X_thermal, id = "years")
    
    g_k <- X
    g <- g_k
    g_k <- cbind(years, g_k)
    g_k <- melt(g_k, id = "years")
    g <- cbind(years, g)
    g <- melt(g, id = "years")
    
    # plot(as.ts(X), type=input$plotType)
    
    # Plot total coal production
    # output$total_coal_graph <- renderPlot({
      ggplot(X, aes(x = years, y = value, colour = variable)) +
        geom_line(size  = 2) +
        ylab("Production in million tons per annum") +
        ggtitle("Coking coal extraction per annum") +
        theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
        theme(panel.background = element_blank(), panel.grid = element_blank(), 
              axis.line = element_line(color = "black"), 
              axis.ticks = element_line(color = "black"), 
              panel.grid.major.y = element_line(linetype = 2, color = "gray"),
              axis.title = element_text(face = "bold"), 
              axis.text = element_text(face = "bold")) +
        scale_y_continuous(expand = c(0,0.5)) +
        scale_x_continuous(expand = c(0, 0))
      # Plot the reward g_k
      
      
   # })
  })
  output$g_k_graph <- renderPlot({
    ggplot(g_k, aes(x = years, y = value, colour = variable)) +
      geom_line(size  = 2) +
      ylab("Annual profit per annum") +
      ggtitle("Annual profit") +
      theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
      theme(panel.background = element_blank(), panel.grid = element_blank(), 
            axis.line = element_line(color = "black"), 
            axis.ticks = element_line(color = "black"), 
            panel.grid.major.y = element_line(linetype = 2, color = "gray"),
            axis.title = element_text(face = "bold"), 
            axis.text = element_text(face = "bold")) +
      scale_y_continuous(expand = c(0,0.5)) +
      scale_x_continuous(expand = c(0, 0))
  })
  # Plot the accumulated reward g
  output$g_graph <- renderPlot({
    ggplot(g, aes(x = years, y = value, colour = variable)) +
      geom_line(size  = 2) +
      ylab("Annual profit per annum") +
      ggtitle("Annual profit") +
      theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
      theme(panel.background = element_blank(), panel.grid = element_blank(), 
            axis.line = element_line(color = "black"), 
            axis.ticks = element_line(color = "black"), 
            panel.grid.major.y = element_line(linetype = 2, color = "gray"),
            axis.title = element_text(face = "bold"), 
            axis.text = element_text(face = "bold")) +
      scale_y_continuous(expand = c(0,0.5)) +
      scale_x_continuous(expand = c(0, 0))
  })
  output$summary <- renderPrint({
    summary(cars)
  })
  output$value <- renderPrint({ input$slider1 })

  }
