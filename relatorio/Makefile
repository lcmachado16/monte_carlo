MAIN = foobar

.PHONY: all clean distclean

all: $(MAIN).pdf

# Adicionando a classe (acmart.cls), o formato da bibliografia (.bst) e o .bib como dependências.
# O $< continua pegando APENAS o %.tex para passar para o pdflatex.
%.pdf: %.tex acmart.cls ACM-Reference-Format.bst
	pdflatex $<
	bibtex $(basename $<)
	pdflatex $<
	pdflatex $<

clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.toc *.lof *.lot *.fls *.fdb_latexmk *.synctex.gz *.bcf *.run.xml

distclean: clean
	rm -f *.pdf