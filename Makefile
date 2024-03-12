WORKSPACE=/tools
NANOBOT := build/nanobot
NANOBOTDB := build/nanobot.db
EXPORT := $(WORKSPACE)/scripts/export.py
IMPORT := $(WORKSPACE)/scripts/import.py
CONFIGURATIONS := $(WORKSPACE)/scripts/configurations.py
AUTO_SYNCH := true

build/:
	mkdir -p $@

build/nanobot: | build/
	curl -L -o $@ "https://github.com/hkir-dev/nanobot.rs/releases/download/v2024-02-05-tdt/nanobot-x86_64-unknown-linux-musl"
	chmod +x $@

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
save: $(NANOBOTDB)
	python3 $(EXPORT) data $(NANOBOTDB) src/schema/ table column datatype
	python3 $(EXPORT) data $(NANOBOTDB) curation_tables/ $(foreach t,$(wildcard curation_tables/*.tsv), $(basename $(notdir $t)))
	#python3 $(EXPORT) data $(NANOBOTDB) curation_tables/ $$(cut -f1 src/schema/table.tsv | grep CCN2 | tr '\n' ' ')

.PHONY: serve
serve: $(NANOBOTDB)
	python3 $(CONFIGURATIONS) configure-git --root_folder ./
	if [ $(AUTO_SYNCH) = true ]; then \
		python3 $(EXPORT) data $(NANOBOTDB) src/schema/ table column datatype; \
		python3 $(EXPORT) data $(NANOBOTDB) curation_tables/ $(foreach t,$(wildcard curation_tables/*.tsv), $(basename $(notdir $t))); \
		git commit --message "Auto-commit on startup."; \
		git pull; \
		git push; \
	fi
	$(NANOBOT) serve

.PHONY: clean
clean:
	rm -rf build/
