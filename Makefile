ASSETS	:=	assets
UMLDIR	:=	diagrams
IMGDIR	:=	images
DISTDIR	:=	dist
DIRS	:=	$(shell find ./ -type d \
	-not -path '*/\.*' -and \
	-not -path '*/$(IMGDIR)' -and \
	-not -path '*/$(DISTDIR)' -and \
	-not -path '*/$(UMLDIR)' -and \
	-not -path '*/')

UML	:=	$(wildcard $(UMLDIR)/*.uml)
ADOC	:=	index.adoc
EPUB	:=	$(ADOC:%.adoc=$(DISTDIR)/%.epub)
HTML	:=	$(ADOC:%.adoc=$(DISTDIR)/%.html)
PDFA4	:=	$(ADOC:%.adoc=$(DISTDIR)/%.pdf)
PDFA5	:=	$(ADOC:%.adoc=$(DISTDIR)/%-a5.pdf)
PNG	:=	$(UML:$(UMLDIR)/%.uml=$(IMGDIR)/%.png)
PATH	:=	~/bin:$(PATH)

.SUFFIXES: .adoc .epub .html .pdf .png .uml
.PHONY: all dirs

all: dirs $(PNG) $(HTML) $(PDFA4) $(PDFA5) $(EPUB)

$(IMGDIR)/%.png: $(UMLDIR)/%.uml
	@echo converting $< to $@
	@plantuml -o "$(CURDIR)/$(IMGDIR)" "$<"
	@pngquant -f --ext .png "$@"

$(DISTDIR)/%.pdf: %.adoc
	@echo converting $< to $@
	@asciidoctor-pdf -D "$(DISTDIR)" "$<"

$(DISTDIR)/%-a5.pdf: %.adoc
	@echo converting $< to $@
	@asciidoctor-pdf -o "$@" \
	-a pdf-stylesdir="$(ASSETS)" -a pdf-style=a5 "$<"

$(DISTDIR)/%.epub: %.adoc
	@echo converting $< to $@
	@asciidoctor-epub3 -D "$(DISTDIR)" "$<"

$(DISTDIR)/%.html: %.adoc
	@echo converting $< to $@
	@asciidoctor -D "$(DISTDIR)" "$<"

dirs:
	@mkdir -p $(IMGDIR)
	@mkdir -p $(DISTDIR)

