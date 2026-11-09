CXX = g++
CXXFLAGS = -fopenmp -O3
TARGET = bin/monte_carlo
SRC = src/monte_carlo.cpp

SCRIPT_R_INPUT = scripts/gera_layout.R
SCRIPT_SHELL = scripts/executor.sh
INPUT_CSV = dados/input_experimentos.csv
OUTPUT_CSV = dados/output_resultados.csv

all: run


dirs:
	mkdir -p bin dados

compile: dirs $(SRC)
	$(CXX) $(SRC) -o $(TARGET) $(CXXFLAGS)

input: dirs
	Rscript $(SCRIPT_R_INPUT)

run: compile input
	chmod +x $(SCRIPT_SHELL)
	./$(SCRIPT_SHELL)


clean:
	rm -rf bin/ dados/ figuras/