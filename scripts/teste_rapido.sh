#!/bin/bash
# Teste de reprodutibilidade: mesma (N,threads,semente) => mesmo M; semente outra => M outro.
E=bin/monte_carlo
a=$($E 2000000 4 1 777 | cut -d, -f4); b=$($E 2000000 4 1 777 | cut -d, -f4); c=$($E 2000000 4 1 778 | cut -d, -f4)
echo "M(777)=$a  M(777 de novo)=$b  M(778)=$c"
[ "$a" = "$b" ] && [ "$a" != "$c" ] && echo "OK: execucao deterministica." || { echo "FALHOU"; exit 1; }
