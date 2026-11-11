#!/bin/bash
set -uo pipefail
export LC_ALL=C   # ponto decimal (em pt_BR o printf do bash esperava virgula)
INPUT_CSV="dados/input_experimentos.csv"
OUTPUT_CSV="dados/output_resultados.csv"
TMP_CSV="${OUTPUT_CSV}.tmp"
EXEC="bin/monte_carlo"
NCOL=11   # Ordem + 10 colunas do C++

[ -f "$INPUT_CSV" ] || { echo "Erro: $INPUT_CSV nao encontrado (make input)."; exit 1; }
[ -x "$EXEC" ]      || { echo "Erro: $EXEC nao encontrado (make compile)."; exit 1; }

TOTAL=$(( $(wc -l < "$INPUT_CSV") - 1 ))
echo "==================================================="
echo "Monte Carlo: $TOTAL execucoes | entrada: $INPUT_CSV"
echo "Binario: $EXEC | inicio: $(date '+%H:%M:%S')"
echo "==================================================="
echo "Registrando ambiente em dados/ambiente.txt"
bash scripts/registra_ambiente.sh dados/ambiente.txt
grep -E '^(CPU_MODELO|NUCLEOS_FISICOS|CPUS_LOGICAS|COMPILADOR|LOADAVG_INICIO)=' dados/ambiente.txt | sed 's/^/  /'
FEITAS=0
echo "Ordem,Repeticao,Threads,N,M,Pi_Estimado,Erro_Abs,Erro_Rel_Perc,Tempo_Execucao,Semente,Threads_Reais" > "$TMP_CSV"

echo "Aquecimento (resultado descartado)..."
"$EXEC" 100000000 1 0 1 > /dev/null || exit 1
SECONDS=0   # cronometro so conta as execucoes medidas

# done < <(...) evita o subshell do pipe: antes, 'exit 1' dentro de 'tail | while'
# so saia do subshell e o script ainda imprimia "concluidos com sucesso".
while IFS=',' read -r ordem repeticao threads n semente; do
    ordem=${ordem%$'\r'}; semente=${semente%$'\r'}
    echo -n "[$ordem/$TOTAL] N=$n Threads=$threads Rep=$repeticao ... "
    if ! resultado=$("$EXEC" "$n" "$threads" "$repeticao" "$semente"); then
        echo "FALHA"; rm -f "$TMP_CSV"; exit 1
    fi
    if [ "$(echo "$resultado" | awk -F, '{print NF}')" -ne $((NCOL-1)) ]; then
        echo "FALHA (saida inesperada: $resultado)"; rm -f "$TMP_CSV"; exit 1
    fi
    echo "$ordem,$resultado" >> "$TMP_CSV"
    FEITAS=$((FEITAS+1))
    pi_est=$(echo "$resultado" | cut -d, -f5); t=$(echo "$resultado" | cut -d, -f8)
    restante=$(( SECONDS * (TOTAL-FEITAS) / FEITAS ))
    printf 'OK  pi=%.6f  t=%.4fs  | decorrido %ds, faltam ~%ds\n' "$pi_est" "$t" "$SECONDS" "$restante"
done < <(tail -n +2 "$INPUT_CSV")

echo "LOADAVG_FIM=$(cut -d' ' -f1-3 /proc/loadavg)" >> dados/ambiente.txt
mv "$TMP_CSV" "$OUTPUT_CSV"   # so existe saida final se tudo deu certo
echo "==================================================="
echo "Concluido: $FEITAS/$TOTAL execucoes em ${SECONDS}s -> $OUTPUT_CSV"
echo "Linhas no CSV (esperado $((TOTAL+1))): $(wc -l < "$OUTPUT_CSV")"
echo "Proximo passo: make relatorio"