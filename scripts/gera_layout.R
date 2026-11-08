# Desativa a notação científica para evitar que 10^9 vire "1e+09" no CSV,
# garantindo que o stoll() do C++ consiga fazer o parse dos inteiros.
options(scipen = 999)

# Define os parametros do experimento
n_pontos <- c(10^4, 10^6, 10^8, 10^9) 
n_threads <- c(1, 2, 4, 8) 
k_repeticoes <- 1:5 

# Cria o design layout
design_layout <- expand.grid(Repeticao = k_repeticoes, 
                             Threads = n_threads, 
                             N = n_pontos)

# Ordena a execucao
design_layout <- design_layout[order(design_layout$N, design_layout$Threads, design_layout$Repeticao), ]

# Cria a pasta caso o script seja rodado isoladamente
dir.create("dados", showWarnings = FALSE)

# Exporta diretamente para a pasta "dados" esperada pelo pipeline
write.csv(design_layout, "dados/input_experimentos.csv", row.names = FALSE, quote = FALSE)