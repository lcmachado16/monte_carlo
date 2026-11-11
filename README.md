

# Monte Carlo Simulation 

PERF - 2026 

Implementação 

Simulação de Monte Carlo: Estimação de $\pi$

O objeto computacional deste estudo é um algoritmo de Simulação de Monte Carlo utilizado para estimar o valor de $\pi$. A lógica consiste em gerar coordenadas aleatórias $(x,y)$ no intervalo $[-1, 1] \times [-1, 1]$ e verificar se pertencem a um círculo inscrito no quadrado, sob a condição $x^2 + y^2 \leq 1$.

A relação advém da razão entre as áreas do círculo ($\pi$) e do quadrado ($4$). Sendo a probabilidade de acerto $\pi/4$, para $N$ pontos totais e $M$ pontos no círculo, a estimativa é dada por:

$$\hat{\pi} = 4 \frac{M}{N}$$

O parâmetro principal é $N$. O problema justifica-se por combinar geração de números pseudoaleatórios, simulação numérica e programação paralela (OpenMP), escalando a carga computacional para bilhões de pontos.

## Como reproduzir

Pré-requisito: [Nix](https://nixos.org/) com flakes habilitados.

```bash
nix develop        # entra no ambiente (gcc, make, R, pandoc, LaTeX)
make test          # teste rápido: mesma semente => mesmo M
make run           # compila, gera o plano e mede (80 execuções)
make relatorio     # gera relatorio/analise.pdf (e as figuras em figuras/)
```

Deixe a máquina ociosa durante `make run`; o ambiente da medição fica em `dados/ambiente.txt`.
Para refazer as medições de propósito: `make rerun` (guarda a anterior como `.anterior`).
`make clean` não apaga `dados/`; `make distclean` apaga tudo.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `src/monte_carlo.cpp` | objeto computacional (C++ / OpenMP) |
| `scripts/gera_layout.R` | projeto experimental (DOE) |
| `scripts/executor.sh` | executa o plano e gera o CSV de resultados |
| `scripts/registra_ambiente.sh` | registra hardware e software na medição |
| `dados/` | plano, resultados brutos e ambiente |
| `analise.Rmd` | análise literal (gera o PDF) |
| `slides/` | apresentação |

Uso direto do binário: `./bin/monte_carlo <N> <Threads> <Repeticao> [Semente]`