LATEX = xelatex
PRAAT = praat --run

.PHONY: all demo example clean distclean

all: demo

# Demo: synthesize "Praat" in Praat, then build the PDF
demo: demo_document.pdf

demo.tex demo_wf.pdf demo_spec.pdf: make_demo.praat
	$(PRAAT) make_demo.praat

demo_document.pdf: demo_document.tex demo.tex demo_wf.pdf demo_spec.pdf
	TEXINPUTS="..:$$TEXINPUTS" $(LATEX) demo_document.tex

# Example: uses placeholder images (for testing the .sty without real Praat data)
example: example_document.pdf

example_document.pdf: example_document.tex example_output.tex praatfig_wf.pdf praatfig_spec.pdf
	TEXINPUTS="..:$$TEXINPUTS" $(LATEX) example_document.tex

praatfig_%.pdf:
	printf '\\documentclass{minimal}\\begin{document}\\mbox{}\\end{document}\n' | pdflatex -jobname $* -output-directory .
	@rm -f $*.aux $*.log
	@mv $*.pdf $@

clean:
	rm -f *.aux *.log *.out *.synctex.gz *.fls *.fdb_latexmk *.toc *.bbl *.blg

distclean: clean
	rm -f demo_document.pdf demo.tex demo_wf.pdf demo_spec.pdf
	rm -f example_document.pdf praatfig_wf.pdf praatfig_spec.pdf
