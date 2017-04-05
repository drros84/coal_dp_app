# Parameters
N <- 100 # number of concession years 
#real_capacity_per_year <- read.csv("~/Dropbox/Documents/BGSE/Second_Term/SMO/project/Programming/mine_limits.csv")[,-1]
real_capacity_per_year <- read.csv("/home/roger/Desktop/BGSE/14D006 Stochastic Models and Optimization/coal_dp_app/code/mine_limits.csv")[,-1]
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



flow=function(i,weighted_price,price_c,price_t,capacity_per_year){
  u=rep(0,6)
  if(sum(capacity_per_year)>Trans_lim){
    Trans_left=Trans_lim
    for(j in order(rho,decreasing=TRUE)){
      if(Trans_left>0){
        u[j]=min(capacity_per_year[j]*rho[j],Trans_left)/rho[j]
        Trans_left=Trans_left-u[j]*rho[j]
      }else{
        u[j]=0
      }
    }
  }
  u_overflow=u
  g_overflow=sum(u*rho*price_c)-extraction_cost_per_tone*sum(u)+sum(salvage*price_t*(1-rho)*u)
  
  Trans_left=Trans_lim
  for(j in order(rho,decreasing = TRUE)){
    if(Trans_left>0){
      u[j]=min(capacity_per_year[j],Trans_left)
      Trans_left=Trans_left-u[j]
    }else{
      u[j]=0
    }
  }
  u_underflow=u
  g_underflow=sum(u*rho*price_c)+sum(u*(1-rho)*price_t)-extraction_cost_per_tone*sum(u)
  
  if(g_overflow>g_underflow){
    u=u_overflow
    g=u*rho*price_c-extraction_cost_per_tone*u
  }else{
    u=u_underflow
    g=u*rho*price_c+u*(1-rho)*price_t-extraction_cost_per_tone*u
  }
  return(list(u=u,g=g))  
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
g_k <- NULL
alpha_coking <- 150
b_coking <- 1.2
error_lag_coking = rnorm(1, mean = 0, sd = 20)

alpha_thermal <- 130
b_thermal <- 1.1
error_lag_thermal = rnorm(1, mean = 0, sd = 20)
rho <- c(0.6,0.7,0.75,0.8,0.5,0.65)

weighted_alpha <- (1 - rho) * alpha_thermal + rho * alpha_coking
real_prices <- NULL
Trans_lim=20
extraction_cost_per_tone=50
salvage=0.5


rho <- NULL
rho_prior <- c(0.65,0.7,0.7,0.8,0.7,0.5)
rho_mean <- c(0.72,0.64,0.75,0.81,0.63,0.57)
rho_std <- c(0.02,0.03,0.025,0.01,0.03,0.02)
rho <- rnorm(6,rho_mean,rho_std)
for(i in 1:N) {
  error_coking     <- rnorm(1, mean = 0, sd = 20)
  Price_k_coking   <- alpha_coking + b_coking*error_lag_coking + error_coking
  Price_k_forecast_coking <- alpha_coking + b_coking*error_coking
  error_thermal     <- rnorm(1, mean = 0, sd = 20)
  Price_k_thermal   <- alpha_thermal + b_thermal*error_lag_thermal + error_thermal
  Price_k_forecast_thermal <- alpha_thermal + b_thermal*error_thermal
  weighted_price <- (1 - rho) * Price_k_thermal  + rho * Price_k_coking
  weighted_price_forecast <- (1- rho) * Price_k_forecast_thermal + rho * Price_k_forecast_coking
  weighted_price_vector <- rbind(weighted_price_forecast, matrix(rep(weighted_alpha, (N-i)),ncol=6))
  u_forecast=NULL
  g_forecast=rep(0,N-i+1)
  if(i==N){
    g_mines_fore=NULL
    flow_k=flow(i,weighted_price,Price_k_coking,Price_k_thermal,capacity_per_year[i,])
    u_forecast=rbind(u_forecast,flow_k$u)
    g_mines_fore=rbind(g_mines_fore,flow_k$g)
  }else{
    flow_k=flow(i,weighted_price,Price_k_coking,Price_k_thermal,capacity_per_year[i,])
    u_forecast=rbind(u_forecast,flow_k$u)
    g_forecast[1]=sum(flow_k$g)/sum(u_forecast[1,])
    flow_forecast=flow(i+1,weighted_price_forecast,Price_k_forecast_coking,Price_k_forecast_thermal,capacity_per_year[i+1,])
    u_forecast=rbind(u_forecast,flow_forecast$u)
    g_forecast[2]=sum(flow_forecast$g)/sum(u_forecast[2,])
    if(N-i+1>=3){
      for(j in 3:(N-i+1)){
        flow_forecast=flow(i+j,weighted_price_vector[j],alpha_coking,alpha_thermal,capacity_per_year[i+j,])
        u_forecast=rbind(u_forecast,flow_forecast$u)
        g_forecast[j]=sum(flow_forecast$g)/sum(u_forecast[j,])
      }
    }
    g_mines_fore=matrix(0,ncol=mines,nrow=N)
    mine_remain=total_capacity_of_mine
    cap_year_remain=capacity_per_year
    for(j in order(g_forecast,decreasing=TRUE)){
      cap_year_remain[j+i,]=pmin(cap_year_remain[j+i,],mine_remain)
      if(j==2){
        flow_forecast=flow(j,weighted_price_forecast,Price_k_forecast_coking,Price_k_forecast_thermal,cap_year_remain[j+i,])
        u_forecast[j,]=flow_forecast$u
        g_mines_fore[j,]=flow_forecast$g
      }else if(j==1){
        flow_forecast=flow(j,weighted_price,Price_k_coking,Price_k_thermal,cap_year_remain[j+i,])
        u_forecast[j,]=flow_forecast$u
        g_mines_fore[j,]=flow_forecast$g
      }else{
        flow_forecast=flow(j,weighted_price_vector[j],alpha_coking,alpha_thermal,cap_year_remain[j+i,])
        u_forecast[j,]=flow_forecast$u
        g_mines_fore[j,]=flow_forecast$g
      }
      mine_remain=pmax(mine_remain-u_forecast[j,],rep(0,6))
    }
  }
  X=rbind(X,u_forecast[1,])
  g_k=rbind(g_k,g_mines_fore[1,])
  total_capacity_of_mine <- total_capacity_of_mine - X[i, ]
  error_lag_coking <- error_coking
  error_lag_thermal <- error_thermal
  real_prices <- rbind(real_prices, c(Price_k_coking, Price_k_thermal))
}

X <- as.data.frame(X)
colnames(X) <- colnames(real_capacity_per_year)

colnames(real_prices) <- c("coking", "thermal")

g_k <- (rho * real_prices[,1] + (1 - rho) * real_prices[,2] - 10) * X

g <- matrix(0, nrow = nrow(g_k) + 1, ncol = mines)
for(i in 2:nrow(g)){
  g[i, ] = g_k[i-1, ] + g[i-1,] 
}



