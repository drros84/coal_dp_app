library(reshape2)
library(ggplot2)

real_capacity_per_year <- read.csv("~/Dropbox/Documents/BGSE/Second_Term/SMO/project/Programming/mine_limits.csv")[,-1]
mines <- ncol(real_capacity_per_year)  # number of mines

# Auxiliar functions

colSums2 <- function(x) {
  if(is.matrix(x) == TRUE){
    colSums(x)
  } else {
    colSums(t(as.matrix(x)))
  }
}


simulation_DP_basis <- function(N = 50, # number of concession years
                                mines = 6,
                                capacity = "random",
                                real_capacity_per_year = NULL,
                                extraction_cost_per_tone = 10, # extraction cost per tone of coal
                                total_capacity_of_mine = rep(1000, mines),
                                alpha_coking = 102,
                                b_coking = 1.2,
                                sd_coking = 61 * 0.3,
                                alpha_thermal = 63,
                                b_thermal = 4,
                                sd_thermal = 21 * 0.3,
                                rho = seq(0.3, 0.8, 0.1)) {
  
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
      if(length(capacity_per_year_aux) > N){
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
  
  if(capacity == "constant") {
    real_capacity_per_year[is.na(real_capacity_per_year)] <- 0
    capacity_per_year <- NULL
    for(i in 1:mines){
      capacity_per_year <- cbind(capacity_per_year,
                                 c(real_capacity_per_year[, i],
                                   rep(tail(real_capacity_per_year[, i], 1), N - nrow(real_capacity_per_year))))
    }
  }
  
  capacity_per_year <- rbind(capacity_per_year, rep(0, mines))
  
  # Variables
  
  
  
  # Dynamics of the model
  X <- NULL
  error_lag_coking = rnorm(1, mean = 0, sd = sd_coking)
  error_lag_thermal = rnorm(1, mean = 0, sd = sd_thermal)
  weighted_alpha <- (1 - rho) * alpha_thermal + rho * alpha_coking
  real_prices <- NULL
  for(i in 1:N) {
    error_coking     <- rnorm(1, mean = 0, sd = sd_coking)
    Price_k_coking   <- alpha_coking + b_coking*error_lag_coking + error_coking
    Price_k_forecast_coking <- alpha_coking + b_coking*error_coking
    error_thermal     <- rnorm(1, mean = 0, sd = sd_thermal)
    Price_k_thermal   <- alpha_thermal + b_thermal*error_lag_thermal + error_thermal
    Price_k_forecast_thermal <- alpha_thermal + b_thermal*error_thermal
    weighted_price <- (1 - rho) * Price_k_thermal  + rho * Price_k_coking
    weighted_price_forecast <- (1- rho) * Price_k_forecast_thermal + rho * Price_k_forecast_coking
    weighted_price_vector <- rbind(weighted_price_forecast, matrix(rep(weighted_alpha, (N-i)), ncol = mines))
    X_aux = NULL
    for(j in 1:mines){
      if(sum(weighted_price_vector[,j] > weighted_price[j]) == 0 | is.vector(capacity_per_year[(i+1):(N+1), j])) {
        X_aux <- rbind(X_aux, pmin(pmax(0, total_capacity_of_mine[j] - 0),
                                   capacity_per_year[i,j]))
      } else {
        X_aux <- rbind(X_aux, pmin(pmax(0, total_capacity_of_mine[j] - sum(capacity_per_year[(i+1):(N+1),j][weighted_price_vector[,j] > weighted_price[j]])),
                                   capacity_per_year[i,j]))
      }
      total_capacity_of_mine[j] <- total_capacity_of_mine[j] - X_aux[j,]
    }
    X = rbind(X, as.vector(X_aux))
    error_lag_coking <- error_coking
    error_lag_thermal <- error_thermal
    real_prices <- rbind(real_prices, c(Price_k_coking, Price_k_thermal))
  }
  colnames(real_prices) <- c("coking", "thermal")
  
  X <- as.data.frame(X)
  colnames(X) <- colnames(real_capacity_per_year)
  
  g_k <- NULL
  for(i in 1:mines){
    g_k <- cbind(g_k, (rho[i] * real_prices[,1] + (1 - rho[i]) * real_prices[,2] - extraction_cost_per_tone) * X[,i])
  }
  g_k <- as.data.frame(g_k)
  colnames(g_k) <- colnames(X)
  
  g <- matrix(0, nrow = nrow(g_k) + 1, ncol = mines)
  for(i in 2:nrow(g)){
    g[i, ] = as.numeric(g_k[i-1, ]) + g[i-1,] 
  }
  g <- g[-1,]
  
  g <- as.data.frame(g)
  colnames(g) <- colnames(X)
  
  X_thermal <- NULL
  X_coking  <- NULL
  for(i in 1:ncol(as.matrix(X))) {
    X_thermal <- cbind(X_thermal, (1-rho[i]) * as.matrix(X)[,i])
    X_coking  <-  cbind(X_coking, rho[i] * as.matrix(X)[,i])
  }
  
  X_thermal_g_k <- X_thermal * real_prices[,2]
  X_coking_g_k  <- X_coking * real_prices[,1]
  
  X_thermal_g <- matrix(0, nrow = nrow(X_thermal_g_k) + 1, ncol = mines)
  for(i in 2:nrow(X_thermal_g)){
    X_thermal_g[i, ] = as.numeric(X_thermal_g_k[i-1, ]) + X_thermal_g[i-1,] 
  }
  X_thermal_g <- X_thermal_g[-1, ]
  
  X_coking_g <- matrix(0, nrow = nrow(X_coking_g_k) + 1, ncol = mines)
  for(i in 2:nrow(X_coking_g)){
    X_coking_g[i, ] = as.numeric(X_coking_g_k[i-1, ]) + X_coking_g[i-1,] 
  }
  X_coking_g <- X_coking_g[-1, ]
  
  X_thermal <- as.data.frame(X_thermal)
  colnames(X_thermal) <- colnames(X)
  
  X_thermal_g_k <- as.data.frame(X_thermal_g_k)
  colnames(X_thermal_g_k) <- colnames(X)
  
  X_thermal_g <- as.data.frame(X_thermal_g)
  colnames(X_thermal_g) <- colnames(X)
  
  X_coking <- as.data.frame(X_coking)
  colnames(X_coking) <- colnames(X)
  
  X_coking_g_k <- as.data.frame(X_coking_g_k)
  colnames(X_coking_g_k) <- colnames(X)
  
  X_coking_g <- as.data.frame(X_coking_g)
  colnames(X_coking_g) <- colnames(X)
  
  ##### Reshaping Data
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
  
  g_k <- cbind(years, g_k)
  g_k <- melt(g_k, id = "years")
  
  g <- cbind(years, g)
  g <- melt(g, id = "years")
  
  X_thermal_g_k <- cbind(years, X_thermal_g_k)
  X_thermal_g_k <- melt(X_thermal_g_k, id = "years")
  
  X_thermal_g <- cbind(years, X_thermal_g)
  X_thermal_g <- melt(X_thermal_g, id = "years")
  
  X_coking_g_k <- cbind(years, X_coking_g_k)
  X_coking_g_k <- melt(X_coking_g_k, id = "years")
  
  X_coking_g <- cbind(years, X_coking_g)
  X_coking_g <- melt(X_coking_g, id = "years")
  
  X_plot <- ggplot(X, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("Production in million tons per annum") +
    ggtitle("Coal extraction per annum") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  g_k_plot <- ggplot(g_k, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("profit") +
    ggtitle("Annual profit per annum") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  g_plot <- ggplot(g, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("profit") +
    ggtitle("Cumulative profit") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  X_thermal_plot <- ggplot(X_thermal, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("Production in million tons per annum") +
    ggtitle("Coal extraction per annum") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  X_thermal_g_k_plot <- ggplot(X_thermal_g_k, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("profit") +
    ggtitle("Annual profit per annum") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  X_thermal_g_plot <- ggplot(X_thermal_g, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("profit") +
    ggtitle("Cumulative profit") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  X_coking_plot <- ggplot(X_coking, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("Production in million tons per annum") +
    ggtitle("Coal extraction per annum") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  X_coking_g_k_plot <- ggplot(X_coking_g_k, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("profit") +
    ggtitle("Annual profit per annum") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  X_coking_g_plot <- ggplot(X_coking_g, aes(x = years, y = value, colour = variable)) +
    geom_line(size  = 2) +
    ylab("profit") +
    ggtitle("Cumulative profit") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    theme(panel.background = element_blank(), panel.grid = element_blank(), 
          axis.line = element_line(color = "black"), 
          axis.ticks = element_line(color = "black"), 
          panel.grid.major.y = element_line(linetype = 2, color = "gray"),
          axis.title = element_text(face = "bold"), 
          axis.text = element_text(face = "bold")) +
    scale_y_continuous(expand = c(0,0.5)) +
    scale_x_continuous(expand = c(0, 0))
  
  return(list(X_plot = X_plot, g_k_plot = g_k_plot, g_plot = g_plot,
              X_thermal_plot = X_thermal_plot, X_coking_plot = X_coking_plot,
              X_thermal_g_k_plot = X_thermal_g_k_plot, X_coking_g_k_plot = X_coking_g_k_plot,
              X_thermal_g_plot = X_thermal_g_plot, X_coking_g_plot = X_coking_g_plot))
}

