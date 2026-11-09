#!/bin/bash
set -uo pipefail
INPUT_CSV="dados/input_experimentos.csv"
OUTPUT_CSV="dados/output_resultados.csv"
TMP_CSV="${OUTPUT_CSV}.tmp"
EXEC="bin/monte_carlo"
NCOL=11   # Ordem + 10 colunas do C++

[ -f "$INPUT_CSV" ] || { echo "Erro: $INPUT_CSV nao encontrado (make input)."; exit 1; }
[ -x "$EXEC" ]      || { echo "Erro: $EXEC nao encontrado (make compile)."; exit 1; }

bash scripts/registra_ambiente.sh dados/ambiente.txt
echo "Ordem,Repeticao,Threads,N,M,Pi_Estimado,Erro_Abs,Erro_Rel_Perc,Tempo_Execucao,Semente,Threads_Reais" > "$TMP_CSV"

echo "Aquecimento (resultado descartado)..."
"$EXEC" 100000000 1 0 1 > /dev/null || exit 1

# done < <(...) evita o subshell do pipe: antes, 'exit 1' dentro de 'tail | while'
# so saia do subshell e o script ainda imprimia "concluidos com sucesso".
while IFS=',' read -r ordem repeticao threads n semente; do
    ordem=${ordem%$'\r'}; semente=${semente%$'\r'}
    echo -n "[$ordem] N=$n Threads=$threads Rep=$repeticao ... "
    if ! resultado=$("$EXEC" "$n" "$threads" "$repeticao" "$semente"); then
        echo "FALHA"; rm -f "$TMP_CSV"; exit 1
    fi
    if [ "$(echo "$resultado" | awk -F, '{print NF}')" -ne $((NCOL-1)) ]; then
        echo "FALHA (saida inesperada: $resultado)"; rm -f "$TMP_CSV"; exit 1
    fi
    echo "$ordem,$resultado" >> "$TMP_CSV"
    echo OK
done < <(tail -n +2 "$INPUT_CSV")

echo "LOADAVG_FIM=$(cut -d' ' -f1-3 /proc/loadavg)" >> dados/ambiente.txt
mv "$TMP_CSV" "$OUTPUT_CSV"   # so existe saida final se tudo deu certo
echo "Concluido: $OUTPUT_CSV"
