# Parameters
N <- 1000 # number of concession years 
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

if(capacity == "constant")
  else{
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
cost=50

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
  weighted_price_vector <- c(weighted_price_forecast, rep(weighted_alpha, (N-i)))
  u_forecast=NULL
  g_forecast=rep(0,N-i)
  flow_k=flow(i,weighted_price,Price_k_coking,Price_k_thermal)
  u_k=flow_k$u
  g_k=flow_k$g
  flow_forecast=flow(i+1,weighted_price_forecast,Price_k_forecast_coking,Price_k_forecast_thermal)
  u_forecast=rbind(u_forecast,flow_forecast$u)
  g_forecast[1]=flow_forecast$g
  for(j in 2:(N-i)){#cambiar para que cada vez mire cuanto está ocupado en el futuro.
    flow_forecast=flow(i+j,weighted_price_vector[j],alpha_coking,alpha_thermal)
    u_forecast=rbind(u_forecast,flow_forecast$u)
    g_forecast[j]=flow_forecast$g
  }
  colSums(u_forecast[g_forecast > g_k,])
  if(sum(weighted_price_vector > weighted_price) == 0 | is.vector(capacity_per_year[(i+1):(N+1),])) {
    X <- rbind(X, pmin(pmax(rep(0, mines), total_capacity_of_mine - rep(0, mines)),
                       capacity_per_year[i,]))
  } else {
    X <- rbind(X, pmin(pmax(rep(0, mines), total_capacity_of_mine - colSums2(capacity_per_year[(i+1):(N+1),][weighted_price_vector > weighted_price,])),
                       capacity_per_year[i,]))
  }
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




price_c=Price_k_coking
price_t=Price_k_thermal

flow=function(i,weighted_price,price_c,price_t){
  u=rep(0,6)
  if(sum(capacity_per_year[i,])>Trans_lim){
    Trans_left=Trans_lim
    for(j in order(rho,decreasing=TRUE)){
      if(Trans_left>0){
        u[j]=min(capacity_per_year[i,j]*rho[j],Trans_left)/rho[j]
        Trans_left=Trans_left-u[j]*rho[j]
      }else{
        u[j]=0
      }
    }
  }
  u_overflow=u
  g_overflow=sum(u*rho*price_c)-cost*sum(u)
  
  Trans_left=Trans_lim
  for(j in order(weighted_price,decreasing = TRUE)){
    if(Trans_left>0){
      u[j]=min(capacity_per_year[i,j],Trans_left)
      Trans_left=Trans_left-u[j]
    }else{
      u[j]=0
    }
  }
  u_underflow=u
  g_underflow=sum(u*rho*price_c)+sum(u*(1-rho)*price_t)-cost*sum(u)
  
  if(g_overflow>g_underflow){
    u=u_overflow
    g=g_overflow
  }else{
    u=u_underflow
    g=g_underflow
  }
  return(list(u=u,g=g))  
}

