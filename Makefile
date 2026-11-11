CXX      = g++
# UTF-8 garante acentos/π nos graficos independentemente do locale da maquina
RSCRIPT  = LC_ALL=C.UTF-8 Rscript
CXXFLAGS = -fopenmp -O3
TARGET   = bin/monte_carlo
SRC      = src/monte_carlo.cpp

SCRIPT_R_INPUT = scripts/gera_layout.R
SCRIPT_SHELL   = scripts/executor.sh
INPUT_CSV      = dados/input_experimentos.csv
OUTPUT_CSV     = dados/output_resultados.csv

RMD_FILE    = analise.Rmd
REPORT_DIR  = relatorio
REPORT_PDF  = $(REPORT_DIR)/analise.pdf

ENTREGA = 02
AUTOR   = lucas_machado
TGZ     = $(AUTOR)_$(ENTREGA).tgz

.PHONY: all compile input run rerun relatorio test clean distclean tgz

all: relatorio

dirs:
	mkdir -p bin dados figuras

$(TARGET): $(SRC) | dirs
	$(CXX) $(SRC) -o $(TARGET) $(CXXFLAGS)
compile: $(TARGET)

$(INPUT_CSV): $(SCRIPT_R_INPUT) | dirs
	$(RSCRIPT) $(SCRIPT_R_INPUT)
input: $(INPUT_CSV)

# Resultados so sao gerados se NAO existirem (prerequisitos order-only):
# mexer em timestamps (git checkout, tar) nunca dispara re-medicao.
$(OUTPUT_CSV): | $(TARGET) $(INPUT_CSV)
	bash $(SCRIPT_SHELL)
run: $(OUTPUT_CSV)

# Refazer as medicoes de proposito (guarda a copia anterior).
rerun:
	@if [ -f $(OUTPUT_CSV) ]; then mv $(OUTPUT_CSV) $(OUTPUT_CSV).anterior; echo "Anterior salvo em $(OUTPUT_CSV).anterior"; fi
	$(MAKE) $(OUTPUT_CSV)

test: $(TARGET)
	bash scripts/teste_rapido.sh

relatorio: $(REPORT_PDF)
$(REPORT_PDF): $(RMD_FILE) $(OUTPUT_CSV)
	mkdir -p $(REPORT_DIR) figuras
	$(RSCRIPT) -e "rmarkdown::render('$(RMD_FILE)', output_dir = '$(REPORT_DIR)')"


# destino deve ser entregas/slides.pdf, mas org-beamer nao permite especificar o nome do arquivo de saida. 
# emacs entregas/slides.org --batch --eval="(org-beamer-export-to-pdf)"
# Obs: estou mantendo o slides.tex
.PHONY: slides
slides:
	@mkdir -p entregas
	emacs docs/slides.org --batch --eval="(org-beamer-export-to-pdf)"
	@mv docs/slides.pdf entregas/slides.pdf
	@rm -f docs/slides.{aux,log,nav,out,snm,toc,vrb,fls,fdb_latexmk}
	@echo "→ entregas/slides.pdf"
	
# 'clean' NAO apaga dados/ (medicoes sao insubstituiveis); use distclean.
clean:
	rm -rf bin/ figuras/ $(REPORT_DIR)/ analise_cache/
distclean: clean
	rm -rf dados/



PROJECT_FILES       = $(wildcard Makefile .gitignore README.md)
NIX                 = $(wildcard flake.nix flake.lock)
ORG_FILES           = $(wildcard analise.org docs/slides.org LabBook.org)
RMD_FILES           = $(wildcard analise.Rmd)
DIR_PDFS_ENTREGA_02 = $(wildcard pdfs_entrega_02)

INCLUIR = $(NIX) $(ORG_FILES) $(RMD_FILES) $(DIR_PDFS_ENTREGA_02) $(PROJECT_FILES) $(wildcard src scripts)

.PHONY: compress tgz
compress: tgz
tgz:
	tar -czf $(TGZ) --exclude='*.anterior' --exclude='*.tmp' --exclude='*.tgz' --transform 's,^,entrega$(ENTREGA)/,' $(INCLUIR)
	@echo "Gerado: $(TGZ)"
	@tar -tzf $(TGZ) | head -40