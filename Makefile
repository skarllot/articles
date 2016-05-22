ASSETS	:=	assets
DIADIR	:=	diagrams
IMGDIR	:=	images
DISTDIR	:=	dist
PKGNAME	:=	jwt-hole
ADOCINC	:=	$(shell find ./ \
	-type f -name '*.adoc' \
	-not -path '*/$(PKGNAME).adoc')

UML	:=	$(wildcard $(DIADIR)/*.uml)
DOT	:=	$(wildcard $(DIADIR)/*.dot)
ADOC	:=	$(PKGNAME).adoc
EPUB	:=	$(ADOC:%.adoc=$(DISTDIR)/%.epub)
HTML	:=	$(ADOC:%.adoc=$(DISTDIR)/%.html)
PDFA4	:=	$(ADOC:%.adoc=$(DISTDIR)/%.pdf)
PDFA5	:=	$(ADOC:%.adoc=$(DISTDIR)/%-a5.pdf)
PNGUML	:=	$(UML:$(DIADIR)/%.uml=$(IMGDIR)/%.png)
PNGDOT	:=	$(DOT:$(DIADIR)/%.dot=$(IMGDIR)/%.png)
PATH	:=	$(HOME)/bin:$(PATH)

.SUFFIXES: .adoc .dot .epub .html .pdf .png .uml
.PHONY: all clean clean-dist clean-images

all: $(PNGUML) $(PNGDOT) $(HTML) $(PDFA4) $(PDFA5) $(EPUB)

clean: clean-dist clean-images

clean-dist:
	@rm -f $(DISTDIR)/*

clean-images:
	@rm -f $(IMGDIR)/*.png

$(IMGDIR)/%.png: $(DIADIR)/%.uml
	@echo "[PLANTUML] Converting $< to $@"
	@plantuml -o "$(CURDIR)/$(IMGDIR)" "$<"
	@pngquant -f --ext .png "$@"

$(IMGDIR)/%.png: $(DIADIR)/%.dot
	@echo "[GRAPHVIZ] Converting $< to $@"
	@dot "$<" -Tpng -o "$@"
	@pngquant -f --ext .png "$@"

$(DISTDIR)/%.pdf: %.adoc
	@echo "Converting $< to $@"
	@asciidoctor-pdf -D "$(DISTDIR)" "$<"

$(DISTDIR)/%-a5.pdf: %.adoc
	@echo "Converting $< to $@"
	@asciidoctor-pdf -o "$@" \
	-a pdf-stylesdir="$(ASSETS)" -a pdf-style=a5 "$<"

$(DISTDIR)/%.epub: %.adoc
	@echo "Converting $< to $@"
	@asciidoctor-epub3 -D "$(DISTDIR)" "$<"

$(DISTDIR)/%.html: %.adoc
	@echo "Converting $< to $@"
	@asciidoctor -D "$(DISTDIR)" "$<"

$(ADOC): $(ADOCINC) $(PNGUML) $(PNGDOT)
#	@echo "File $< modified"
	@touch "$@"

