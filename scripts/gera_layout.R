# Projeto experimental (DOE): fatorial completo N x Threads x Repeticao,
# execucao em ordem ALEATORIA (controla deriva temporal) e uma semente
# distinta por execucao (registrada no CSV e repassada ao C++).
options(scipen = 999)          # evita 1e+09 no CSV (stoll() do C++)

SEED_DOE <- 20260809           # semente do proprio projeto (muda => outro plano)
n_pontos <- c(10^4, 10^6, 10^8, 10^9)
n_threads <- c(1, 2, 4, 8)
k_repeticoes <- 1:5

set.seed(SEED_DOE)
design <- expand.grid(Repeticao = k_repeticoes, Threads = n_threads, N = n_pontos)
design <- design[sample(nrow(design)), ]                  # ordem aleatoria
design$Semente <- sample.int(2^31 - 1, nrow(design))      # unicas (sem reposicao)
design$Ordem <- seq_len(nrow(design))
design <- design[, c("Ordem", "Repeticao", "Threads", "N", "Semente")]

dir.create("dados", showWarnings = FALSE)
write.csv(design, "dados/input_experimentos.csv", row.names = FALSE, quote = FALSE)
