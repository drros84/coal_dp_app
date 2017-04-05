
**Model set-up**

We have a company that has a $N$ years concession of 6 mines of coal from which it extracts two types of coal (thermal coal and coking coal). Both types are mixed in the same rock, so one does not decide which type to mine, when the coal is mined a certain percentage is coking and the rest is thermal. Coking coal is more valuable than thermal coal. Each mine has its own maximum production capacity per year ($m_k^i$, $i=1,\dots,6$), a finite amount of coal ($C^i$, $i=1\dots,6$) and a certain fixed share of coking coal $\rho^i$, and a share of thermal coal $1 - \rho^i$.

The mines are connected to the port (from which they are exported) by railways that have a total transport capacity $T$. The price of each type of coal is a random variable $w_k^c$, $w_k^t$, which we observe at the start of the year, before we decide how much to mine in that year. The prices of coking and thermal coal are generated using fixed expected prices, but with stochastic shocks which persist for one period, in an MA(1) fashion: $w_k^c=a^c + \beta^c\epsilon_{k-1}^c + \epsilon_k^c$, $w_k^t=a^t + \beta^t\epsilon_{k-1}^t + \epsilon_k^t$, where for both coking and thermal, $\mathbb{E}[\epsilon_k] = 0$. There is a fixed cost of extraction per ton of coal $c$ and if the coal is mined but cannot be transported it is sold at a discount to local energy plants, contributing with a value of $s<c$.

**Primitives**:  
$x_k^i$: Remaining coal reserves (stock of coal) in mine i at period $k$ 
$u_k^i$: How much coal to mine in mine i at period $k$
$w_k^c$: Price per ton of coking coal in period k
$w_k^t$: Price per ton of thermal coal in period k
$\rho^i$: Share of coking coal in mine i  
$1 - \rho^i$: Share of thermal coal in mine i  
$c$: Cost of extracting a ton of coal  
$s$: Salvage price per ton of thermal coal  
$m_k^i$: Maximum production capacity for mine i in period k  
$T$: Transport capacity  

**Constrains**:  
$u_k^i\leq m_k^i$  
$x_k^i\geq 0$  
$s < c$  

**Dynamics**:  
$x_{k+1}=x_k-u_k$  
$w_k^c=a^c + \beta^c\epsilon_{k-1}^c + \epsilon_k^c$, where $\mathbb{E}[\epsilon_k^c] = 0$  
$w_k^t=a^t + \beta^t\epsilon_{k-1}^t + \epsilon_k^t$, where $\mathbb{E}[\epsilon_k^t] = 0$  

**Profit**:  
$g_N(x_N)=0$  

$$g_k(x_k,u_k,w_k)=\left\{\begin{array}{ll}
\min\left\{\sum\limits_{i=1}^6\rho_iu_k^i,T\right\}w_k^c+\left(\min\left\{\sum\limits_{i=1}^6(1-\rho_i)u_k^i,T-\sum\limits_{i=1}^6\rho_iu_k^i\right\}\right)^+w_k^t-c\sum\limits_{i=1}^6u_k^i+s\min\left\{\sum\limits_{i=1}^6(1-\rho_i)u_k^i,\left(T-\sum\limits_{i=1}^6\rho_iu_k^i\right)^+\right\} & \text{If }w_k^c\geq w_k^t\\
\left(\min\left\{\sum\limits_{i=1}^6\rho_iu_k^i,T-\sum\limits_{i=1}^6(1-\rho_i)u_k^i\right\}\right)^+w_k^c+\min\left\{\sum\limits_{i=1}^6(1-\rho_i)u_k^i,T\right\}w_k^t-c\sum\limits_{i=1}^6u_k^i & \text{If }w_k^c<w_k^t
\end{array}\right.$$

**DP algorithm on a toy case**:  
First approach, $T=\infty$. (no salvage value).
$J_N(x_N)=0$.  
$J_{k}(x_k)=\underset{\underset{u_{k}\leq x_{k}}{u_{k}\leq m_{k},}}{\max}\mathbb{E}[u_k(\rho w_k^c+(1-\rho)w_k^t-c)+J_{k+1}(x_k-u_k)]$.  

**Solving the DP problem**:
\begin{align}
	J_{N-1}(x_{N-1})&=\underset{\underset{u_{N-1}^i\leq x_{N-1}^i}{u_{N-1}^i\leq m_{N-1}^i,}}{\max}\mathbb{E}\left[w_{N-1}^c\sum\limits_{i=1}^6\rho_iu_{N-1}^i +w_{N-1}^t\sum\limits_{i=1}^6(1-\rho_i)u_{N-1}^i-c\sum\limits_{i=1}^6u_{N-1}^i\right]\\
	&=\underset{\underset{\ u_{N-1}^i\leq x_{N-1}^i}{u_{N-1}^i\leq m_{N-1}^i,}}{\max}\left\{\mathbb{E}[w_{N-1}]\sum\limits_{i=1}^6\rho_iu_{N-1}^i+\mathbb{E}[w_{N-1}]\sum\limits_{i=1}^6(1-\rho_i)u_{N-1}^i-c\sum\limits_{i=1}^6u_{N-1}^i\right\}
\end{align}
This is function increases with the $u_{N-1}^i$ if $w_{N-1}^c>c$ and $w_{N-1}^t>c$, so in order to be maximal we will mine all we can, which means $u_{N-1}^i=\min\{m_{N-1}^i,x_{N-1}^i\}$.  
Now, for $N-2$:  
\begin{align}
	J_{N-2}(x_{N-2})&=\underset{\underset{\ u_{N-2}\leq x_{N-2}}{u_{N-2}\leq m_{N-2},}}{\max}\mathbb{E}\left[w_{N-2}^c\sum\limits_{i=1}^6\rho_iu_{N-2}^i +w_{N-2}^t\sum\limits_{i=1}^6(1-\rho_i)u_{N-2}^i-c\sum\limits_{i=1}^6u_{N-2}^i+J_{N-1}(x_{N-2}-u_{N-2})\right]=\\
	&=\underset{\underset{u_{N-2}\leq x_{N-2}}{u_{N-2}\leq m_{N-2},}}{\max}\left\{\mathbb{E}[w_{N-2}^c]\sum\limits_{i=1}^6\rho_iu_{N-2}^i +\mathbb{E}[w_{N-2}]^t\sum\limits_{i=1}^6(1-\rho_i)u_{N-2}^i-c\sum\limits_{i=1}^6u_{N-2}^i+J_{N-1}(x_{N-2}-u_{N-2})\right\}.
\end{align}
In this case, it will depend in how much profit we can get next period. It can basically be translated on seeing which period is more "profitable": if the prices expected for the future are higher than the ones expected for today, we would prefer to mine on the future, so $u_{N-2}^i$ will be the maximum such that we are able to mine the maximum possible in $N-1$ given $x_{N-2}$. In practice, we can compare the weighted expected price in $N-2$ ($\bar{w}_{N-2}=w_{N-2}^c\rho_i+w_{N-2}^t(1-\rho_i)$) and the weighted expected price in $N-1$ ($\bar{w}_{N-1}=w_{N-1}^c\rho_i+w_{N-1}^t(1-\rho_i)$) for each mine. If $\bar{w}_{N-1}>\bar{w}_{N-2}$ we want to mine as much as possible (given $x_{N-2}$) on $N-1$. 

Going backwards, in order to maximize the expected profit in the $k$th period we need to let mine as much as possible to the periods from $k+1$ to $N-1$ that have a weighted expected price higher than the weighted expected price on $k$, given $x_k$. So we will assure that in those periods we mine as much as possible given $x_k$ (decisions inside $J_{k+1}$ given $x_{k+1}\leq x_k$), and we will mine the maximum we can on $k$ of the amount is left in each mine.

**DP algorithm on the general case:**

The idea is similar, but in this case we have a transportation capacity $T$ that constrains the amount sold each period and adds a salvage value $s$ for the mined but not sold thermal coal. Depending on the prices of coking coal and thermal coal it may be more profitable to mine more coal than we can transport. Since the profit is linear on the decisions $u_k^i$, the maximum is attained on the support of the constrains. 

We can assume that the price of coking coal is higher than the price of thermal coal (otherwise the problem is similar inversing the types). Recalling the profit equation:
$g_N(x_N)=0.$
$$g_k(x_k,u_k,w_k)=\min\left\{\sum\limits_{i=1}^6\rho_iu_k^i,T\right\}w_k^c+\left(\min\left\{\sum\limits_{i=1}^6(1-\rho_i)u_k^i,T-\sum\limits_{i=1}^6\rho_iu_k^i\right\}\right)^+w_k^t-c\sum\limits_{i=1}^6u_k^i+s\min\left\{\sum\limits_{i=1}^6(1-\rho_i)u_k^i,\left(T-\sum\limits_{i=1}^6\rho_iu_k^i\right)^+\right\}$$,
so
$J_N(x_N)=0.$
$$J_k(x_k)=\underset{u_k\in U_k}{\max}\mathbb{E}\left[\min\left\{\sum\limits_{i=1}^6\rho_iu_k^i,T\right\}w_k^c+\left(\min\left\{\sum\limits_{i=1}^6(1-\rho_i)u_k^i,T-\sum\limits_{i=1}^6\rho_iu_k^i\right\}\right)^+w_k^t-c\sum\limits_{i=1}^6u_k^i+s\min\left\{\sum\limits_{i=1}^6(1-\rho_i)u_k^i,\left(T-\sum\limits_{i=1}^6\rho_iu_k^i\right)^+\right\}\right]$$
$T$ adds a new artificial constrain: 
Consider the period $N-1$, mining $u_{N-1}^i$ such that $\sum\limits_{i=1}^6\rho_i u_{N-1}^i>T$ will be worse than mining $u_{N-1}^i$ such that $\sum\limits_{i=1}^6\rho_i u_{N-1}^i=T$. Also, if $\sum\limits_{i=1}^6 x_{N-1}^i\geq T$, it is better to mine $u_{N-1}^i$ such that $\sum\limits_{i=1}^6 u_{N-1}^i= T$ than $\sum\limits_{i=1}^6 u_{N-1}^i< T$ (the cost is less than the prices and one will be able to sell all the coal mined). Finally, if $\sum\limits_{i=1}^6 x_{N-1}^i< T$, it is better to mine $u_{N-1}^i=x_{N-1}^i$ than $u_{N-1}^i<x_{N-1}^i$ (the cost is less than the prices and one will be able to sell all the coal mined).

Considering now the period $N-2$, those constrains also hold. With the same idea as in the first approach, we have to consider if $N-1$ period is more profitable than $N-2$. Then, our option is to mine as much as possible in $N-1$ given that $x_{N-1}\leqx_{N-2}$, if there is coal left ($x_{N-2}^{i*}=x_{N-2}^i-u_{N-1}^{i*}$>0) we mine in the best way possible (between the options mentioned above and considering the $x_{N-2}^{i*}$ instead of $x_{N-2}^i$).

In general, in the $k$th period one would make sure that the periods from $k+1$ to $N-1$ that are expected to be more profitable than the $k$th have to be mined in the best way possible given $x_{k+1}\leq x_k$ and then mine what is left on the $k$th period in the best way possible considering $x_k^{i*}=x_k^i-\sum\limits_{j=k+1}^{N-1}u_j^{i*}$ as the coal that is left, imposing $u_j^{i*}=0$ for the periods that are expected to be less profitable than the actual.

