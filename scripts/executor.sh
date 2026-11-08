#!/bin/bash

# Caminhos já definidos na arquitetura do seu Makefile
INPUT_CSV="dados/input_experimentos.csv"
OUTPUT_CSV="dados/output_resultados.csv"
EXEC="bin/monte_carlo"

# 1. Validações de segurança
if [ ! -f "$INPUT_CSV" ]; then
    echo "Erro: Arquivo de entrada $INPUT_CSV não encontrado. Rode 'make input' primeiro."
    exit 1
fi

if [ ! -x "$EXEC" ]; then
    echo "Erro: Executável $EXEC não encontrado. Rode 'make compile' primeiro."
    exit 1
fi

# 2. Prepara o arquivo de saída
# Cria o arquivo gravando o cabeçalho exato que o seu script analise.org espera ler.
echo "Repeticao,Threads,N,M,Pi_Estimado,Erro_Abs,Erro_Rel_Perc,Tempo_Execucao" > "$OUTPUT_CSV"

echo "==================================================="
echo "Iniciando bateria de experimentos Monte Carlo..."
echo "Lendo parâmetros de: $INPUT_CSV"
echo "==================================================="

# 3. Loop de Execução
# O comando tail -n +2 pula a primeira linha (cabeçalho) do input gerado pelo R.
# O loop 'read' quebra cada linha nas variáveis repeticao, threads e n.
tail -n +2 "$INPUT_CSV" | while IFS=',' read -r repeticao threads n; do
    
    # Remove eventuais quebras de linha/CR ocultas caso o CSV venha com formatação de outro SO
    n=$(echo "$n" | tr -d '\r')
    repeticao=$(echo "$repeticao" | tr -d '\r')
    threads=$(echo "$threads" | tr -d '\r')

    # Feedback visual no terminal para acompanhar o progresso
    echo -n "[Executando] N = $n | Threads = $threads | Repetição = $repeticao ... "

    # 4. Executa o binário C++
    # O C++ espera estritamente a ordem: ./monte_carlo <N> <Threads> <Repeticao>
    resultado=$("./$EXEC" "$n" "$threads" "$repeticao")
    
    # Verifica se a execução teve sucesso (código de saída 0)
    if [ $? -eq 0 ]; then
        # Acrescenta a saída padronizada (que já é uma linha CSV) no arquivo final
        echo "$resultado" >> "$OUTPUT_CSV"
        echo "OK"
    else
        echo "FALHA NA EXECUÇÃO!"
        exit 1
    fi
done

echo "==================================================="
echo "Todos os experimentos foram concluídos com sucesso!"
echo "Resultados salvos em: $OUTPUT_CSV"
echo "Pronto para análise."