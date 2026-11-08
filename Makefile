CXX = g++
CXXFLAGS = -fopenmp -O3
TARGET = bin/monte_carlo
SRC = src/monte_carlo.cpp

SCRIPT_R_INPUT = scripts/gera_layout.R
SCRIPT_SHELL = scripts/executor.sh
INPUT_CSV = dados/input_experimentos.csv
OUTPUT_CSV = dados/output_resultados.csv

all: analyze

# Cria os diretórios necessários caso não existam
dirs:
	mkdir -p bin dados

compile: dirs $(SRC)
	$(CXX) $(SRC) -o $(TARGET) $(CXXFLAGS)

input: dirs
	Rscript $(SCRIPT_R_INPUT)
	mv input_experimentos.csv $(INPUT_CSV)

run: compile input
	chmod +x $(SCRIPT_SHELL)
	./$(SCRIPT_SHELL)

analyze: run
	emacs --batch -l ~/.emacs analise.org -f org-babel-execute-buffer


clean:
	rm -rf bin/ dados/ figuras/