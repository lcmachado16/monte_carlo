

# Monte Carlo Simulation 

PERF - 2026 

Implementação 

Simulação de Monte Carlo: Estimação de $\pi$

O objeto computacional deste estudo é um algoritmo de Simulação de Monte Carlo utilizado para estimar o valor de $\pi$. A lógica consiste em gerar coordenadas aleatórias $(x,y)$ no intervalo $[-1, 1] \times [-1, 1]$ e verificar se pertencem a um círculo inscrito no quadrado, sob a condição $x^2 + y^2 \leq 1$.

A relação advém da razão entre as áreas do círculo ($\pi$) e do quadrado ($4$). Sendo a probabilidade de acerto $\pi/4$, para $N$ pontos totais e $M$ pontos no círculo, a estimativa é dada por:

$$\hat{\pi} = 4 \frac{M}{N}$$

O parâmetro principal é $N$. O problema justifica-se por combinar geração de números pseudoaleatórios, simulação numérica e programação paralela (OpenMP), escalando a carga computacional para bilhões de pontos.