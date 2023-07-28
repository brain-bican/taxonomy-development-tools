WORKSPACE=/tools
NANOBOT := build/nanobot
NANOBOTDB := build/nanobot.db
EXPORT := build/export.py
IMPORT := $(WORKSPACE)/scripts/import.py

build/:
	mkdir -p $@

build/nanobot: | build/
	curl -L -o $@ "https://github.com/ontodev/nanobot.rs/releases/download/v2023-06-30/nanobot-x86_64-unknown-linux-musl"
	chmod +x $@

build/export.py: | build/
	curl -L -o $@ "https://github.com/ontodev/valve.rs/raw/main/scripts/export.py"

.PHONY: build_nomenclature_tables
build_nomenclature_tables:
	Rscript $(WORKSPACE)/dendR/nomenclature_builder.R

.PHONY: load_data
load_data:
	python3 $(IMPORT) import-data --input input_data/ --schema src/schema/ --curation_tables curation_tables/

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
	python3 $(EXPORT) data $(NANOBOTDB) curation_tables/ $(foreach t,$(wildcard curation_tables/*.tsv), $(basename $(notdir $t)))
	#python3 $(EXPORT) data $(NANOBOTDB) curation_tables/ $$(cut -f1 src/schema/table.tsv | grep CCN2 | tr '\n' ' ')

.PHONY: serve
serve: $(NANOBOTDB)
	$(NANOBOT) serve

.PHONY: clean
clean:
	rm -rf build/
