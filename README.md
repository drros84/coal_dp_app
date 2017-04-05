# BGSE Stochastic Modeling and Optimization Project: Coal Mining in Mozambique | DP Algorithm

### Overview

Motivation
- This project is motivated by a historical example of the surge in coal mining investment in Mozambique in the late 2000s'.

The objectives of our project are to:

- Give insight into how dynamic programming can be used to optimise decision-making in sectors with depletable assets such as in mining.
- Provide an app that can be used to forecast and simulate future output and revenue based on on a set of assumptions which can be modified by the user. The app is also useful for government officials who wish to have a better understanding of economic growth in the mining sector and the factors it depends on.

### Structure

The core of the analysis is contained in these two files:

- `NPO_schema.sql`
- `analysis.R`

### Implementation

To develop the LASSO regression, we first have identified 80 relevant variables with respect to total revenue. Then we carried out a LASSO regression using the `glmnet` package with the objective to select variables with a significant marginal contribution to revenue. 

### Required packages

The `R` analysis relies on the following packages. 

- `glmnet`
- `dplyr`
- `RMySQL`

### Languages Used
- R
- HTML/CSS
