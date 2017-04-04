# Parameters
N <- 1000 # number of concession years 
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
for(i in 1:N) {
  X <- rbind(X, pmin(pmax(rep(0, mines), total_capacity_of_mine - colSums2(capacity_per_year[(i+1):(N+1),])),
                     capacity_per_year[i]))
  total_capacity_of_mine <- total_capacity_of_mine - X[i, ]
}

X <- as.data.frame(X)
colnames(X) <- colnames(real_capacity_per_year)

X