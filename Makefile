WORKSPACE=/tools
NANOBOT := build/nanobot
NANOBOTDB := build/nanobot.db
EXPORT := build/export.py

build/:
	mkdir -p $@

build/nanobot: | build/
	curl -L -o $@ "https://github.com/ontodev/nanobot.rs/releases/download/v2023-06-29/nanobot-x86_64-unknown-linux-musl"
	chmod +x $@

build/export.py: | build/
	curl -L -o $@ "https://github.com/ontodev/valve.rs/raw/main/scripts/export.py"

.PHONY: build_nomenclature_tables
build_nomenclature_tables:
	Rscript $(WORKSPACE)/dendR/nomenclature_builder.R

.PHONY: runR
runR:
	Rscript dendR/nomenclature_builder.R

$(NANOBOTDB): | $(NANOBOT)
	$(NANOBOT) init

.PHONY: load
load: clean | $(NANOBOT)
	$(NANOBOT) init

.PHONY:
save: $(EXPORT) $(NANOBOTDB)
	python3 $(EXPORT) data $(NANOBOTDB) src/schema/ table column datatype
	python3 $(EXPORT) data $(NANOBOTDB) curation_tables/ $$(cut -f1 src/schema/table.tsv | grep CCN2 | tr '\n' ' ')

.PHONY: serve
serve: $(NANOBOTDB)
	$(NANOBOT) serve

.PHONY: clean
clean:
	rm -rf build/
