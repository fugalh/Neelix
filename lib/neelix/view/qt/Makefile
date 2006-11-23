uic_generated=mw.rb aboutdialog.rb
all: $(uic_generated)

%.rb: %.ui
	rbuic4 -x $< > $@

clean:
	rm -f $(uic_generated)

.PHONY: all clean
