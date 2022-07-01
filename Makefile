BUILDDIR = build

OPTIONS  = -d build/html -t

OPTIONS += $(foreach theme,$(THEMES),-T $(theme))
OPTIONS += $(HTML_OPTS)

.PHONY: usage clean wotef
usage:
	@echo "Targets:"
	@echo "  usage      show this help"
	@echo "  wotef      build The Way Of The Exploding Fist disassembly"
	@echo ""
	@echo "Variables:"
	@echo "  THEMES     CSS theme(s) to use"
	@echo "  HTML_OPTS  options passed to skool2html.py"

.PHONY: clean
clean:
	-rm -rf $(BUILDDIR)/*

.PHONY: wotef
wotef:
	if [ ! -f WayOfTheExplodingFistThe.z80 ]; then tap2sna.py @wotef.t2s; fi
	sna2skool.py -H -c sources/wotef.ctl WayOfTheExplodingFistThe.z80 > sources/wotef.skool
	skool2html.py $(OPTIONS) -D -c Config/GameDir=wotef/dec -c Config/InitModule=sources:bases sources/wotef.skool sources/wotef.ref
	skool2html.py $(OPTIONS) -H -c Config/GameDir=wotef/hex -c Config/InitModule=sources:bases sources/wotef.skool sources/wotef.ref

all : wotef
.PHONY : all
