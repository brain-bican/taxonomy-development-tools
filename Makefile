WORKSPACE=/tools
NANOBOT := build/nanobot
NANOBOTDB := build/nanobot.db
EXPORT := $(WORKSPACE)/scripts/export.py
IMPORT := $(WORKSPACE)/scripts/import.py
UPGRADE := $(WORKSPACE)/scripts/upgrade.py
CONFIGURATIONS := $(WORKSPACE)/scripts/configurations.py
AUTO_SYNCH := false

build/:
	mkdir -p $@

build/nanobot: | build/
	# upgrade /nanobot/src/resources as well
	#curl -L -o $@ "https://github.com/hkir-dev/nanobot.rs/releases/download/v2024-02-05-tdt/nanobot-x86_64-unknown-linux-musl"
	curl -L -o $@ "https:/github.com/ontodev/nanobot.rs/releases/download/v2024-03-21/nanobot-v20240321-x86_64-linux"
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
		git commit -a --message "Auto-commit on startup."; \
		git pull; \
		git push; \
		rm -rf build/; \
		$(NANOBOT) init; \
	fi
	$(NANOBOT) serve

.PHONY: clean
clean:
	rm -rf build/

.PHONY: upgrade
upgrade: clean
	python3 $(UPGRADE) upgrade --root_folder ./ --workspace $(WORKSPACE)
	python3 $(IMPORT) import-data --input input_data/ --schema src/schema/ --curation_tables curation_tables/

# This is not a TDT driven rule. Directly run `make pull_tdt` to pull the latest TDT image.
.PHONY: pull_tdt
pull_tdt:
	docker stop $$(docker ps -a -q --filter ancestor=ghcr.io/brain-bican/taxonomy-development-tools:latest) || true
	docker rmi $$(docker images 'ghcr.io/brain-bican/taxonomy-development-tools:latest' -a -q | uniq) || true
	docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest