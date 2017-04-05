
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

**DP algorithm**:  
First approach, $T=\infty$. (no salvage value).
$J_N(x_N)=0$.  
$J_{k}(x_k)=\underset{\underset{u_{k}\leq x_{k}}{u_{k}\leq m_{k},}}{\max}\mathbb{E}[u_k(\rho w_k^c+(1-\rho)w_k^t-c)+J_{k+1}(x_k-u_k)]$.  

**Solving the DP problem**:
\begin{align}
	J_{N-1}(x_{N-1})&=\underset{\underset{u_{N-1}^i\leq x_{N-1}^i}{u_{N-1}^i\leq m_{N-1}^i,}}{\max}\mathbb{E}\left[w_{N-1}^c\sum\limits_{i=1}^6\rho_iu_{N-1}^i +w_{N-1}^t\sum\limits_{i=1}^6(1-\rho_i)u_{N-1}^i-c\sum\limits_{i=1}^6u_{N-1}^i\right]\\
	&=\underset{\underset{\ u_{N-1}^i\leq x_{N-1}^i}{u_{N-1}^i\leq m_{N-1}^i,}}{\max}\left\{\mathbb{E}[w_{N-1}]\sum\limits_{i=1}^6\rho_iu_{N-1}^i+\mathbb{E}[w_{N-1}]\sum\limits_{i=1}^6(1-\rho_i)u_{N-1}^i-c\sum\limits_{i=1}^6u_{N-1}^i\right\}
\end{align}
Th. $u_{N-1}^i=\min\{m_{N-1}^i,x_{N-1}^i\}$.  
Now, for $N-2$:  
\begin{align}
	J_{N-2}(x_{N-2})&=\underset{\underset{\ u_{N-2}\leq x_{N-2}}{u_{N-2}\leq m_{N-2},}}{\max}\mathbb{E}[u_{N-2}(\rho w_{N-2}^c+(1-\rho)w_{N-2}^t-c)+J_{N-1}(x_{N-2}-u_{N-1})]=\\
	&=\underset{\underset{\ u_{N-2}\leq x_{N-1}}{u_{N-2}\leq m_{N-2},}}{\max}\{u_{N-2}(\rho(a_c(N-2)+b_c)+(1-\rho)(a_t(N-2)+b_t)-c)+\\
	&+\min\{m_{N-1},x_{N-2}-u_{N-2}\}(\rho(a_c(N-1)+b_c)+(1-\rho)(a_t(N-1)+b_t)-c)\}.
\end{align}
Since $\rho(a_c(N-1)+b_c)+(1-\rho)(a_t(N-1)+b_t)-c>\rho(a_c(N-2)+b_c)+(1-\rho)(a_t(N-2)+b_t)-c$, in order to maximize we need $\min\{m_{N-1},x_{N-2}-u_{N-2}\}$ to be as big as possible. That means 
$$\max\left\{\begin{array}{ll}
m_{N-1} & \text{if }x_{N-2}-u_{N-2}>m_{N-1}\\
x_{N-2}-u_{N-2} & \text{otherwise}
\end{array}\right.,$$
which will be attained when $u_{N-2}=(x_{N-2}-m_{N-1})^+$. However, since it could happen that $(m_{N-1}-x_{N-2})^+>m_{N-2}$, the optimal policy would be $u_k=\min\{(x_{N-2}-m_{N-1})^+,m_{N-2}\}$.  

Backward induction proves that $u_k=\min\{(x_{k}-\sum_{i=k+1}^{N-1}m_i)^+,m_{k}\}$