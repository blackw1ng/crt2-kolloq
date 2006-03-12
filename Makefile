# mainfile = project-directory-name
MAINFILE=$(shell pwd | sed 's/\/tex$$//; s/.*\///')

# set compiler: either pdflatex or latex
TEX=latex
BIBTEX=bibtex

# set generic viewer applications
DVIVIEW=xdvi
PSVIEW=gv
PDFVIEW=acroread

# set converters
DVIPS=dvips
PS2PDF=ps2pdf

# set helper applications
LPR=lpr
PSNUP=psnup
PSBOOK=psbook
PSTOPS=pstops
THUMBPDF=thumbpdf

# determine wether to use bibtex:
NEEDS_BIBTEX=$(shell egrep "^[^%]+cite(\{|\[)" *.tex | wc -l)

####################################################
# dispatcher targets (USE THESE!)
all: pdf
show: showpdf

pdf: $(MAINFILE).pdf clean wipe-ps wipe-dvi
ps: $(MAINFILE).ps clean wipe-dvi
dvi: $(MAINFILE).dvi clean 

net: net-pdf clean wipe-ps wipe-dvi
halfpage: half-pdf clean wipe-ps wipe-dvi
book: book-pdf clean wipe-ps wipe-dvi

clean: wipe-temp
distclean: clean wipe-pdf wipe-ps wipe-dvi

####################################################
# viewing / printing targets
showdvi: dvi
	$(DVIVIEW) $(MAINFILE).dvi

showpdf: pdf
	$(PDFVIEW) $(MAINFILE).pdf
        
print: ps
	$(LPR) $(MAINFILE).ps

####################################################
# special output versions

# generate net-pdf, that has embedded page-thumbnails
net-ps: $(MAINFILE).pdf
	$(THUMBPDF) --modes=ps2pdf $(MAINFILE).pdf
	$(TEX) $(MAINFILE).tex
	$(DVIPS) -t a4 $(MAINFILE).dvi -o $(MAINFILE).net.ps
	
net-pdf: net-ps
	$(PS2PDF) $(MAINFILE).net.ps $(MAINFILE).net.pdf

# generate half-paged (2 A4 on 1 Sheet) ps
half-ps: ps
	$(PSNUP) -q -2 < $(MAINFILE).ps | $(PSTOPS) -q "2:0,1U(1w,1h)" > \
	$(MAINFILE).halfsize.ps

half-pdf: half-ps
	$(PS2PDF) $(MAINFILE).halfsize.ps $(MAINFILE).halfsize.pdf

# generate book-style 
book-ps: ps
	$(PSBOOK) -q  < $(MAINFILE).ps | $(PSNUP) -q -2 | \
	$(PSTOPS) -q "2:0,1U(1w,1h)" > $(MAINFILE).book.ps

book-pdf: book-ps
	$(PS2PDF) $(MAINFILE).book.ps $(MAINFILE).book.pdf

####################################################
# cleanup rouines

# remove all temporary files, also in subdirs
wipe-temp: 
	rm -f *.{blg,bbl,out,bm,toc,tpm,lof,lot}
	find . \( -name "*.aux" -o -name "*.log" \) -print | xargs rm -f

# removal targets for target files
wipe-pdf: 
	rm -f *.pdf

wipe-ps: 
	rm -f *.ps

wipe-dvi:
	rm -f *.dvi

####################################################
# now the generic conversion makros

.SUFFIXES: .tex .dvi .ps .pdf
# compile .tex to .dvi, invoke bibtex as needed
.tex.dvi: 
ifneq ($(NEEDS_BIBTEX) , 0)
	$(TEX) $<
	bibtex $*
endif
	$(TEX) $<
	$(TEX) $<

# convert a .dvi to .ps
.dvi.ps:
	dvips -t a4 $< -o $*.ps


# convert .ps to .pdf
.ps.pdf:
	ps2pdf $< $*.pdf
