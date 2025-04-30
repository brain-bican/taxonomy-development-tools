WORKSPACE=/tools
NANOBOT := build/nanobot
NANOBOTDB := build/nanobot.db

RLTBL := bin/rltbl
RLTBLDB_DIR := .relatable
RLTBLDB_FILE := relatable.db
RLTBLDB := $(RLTBLDB_DIR)/$(RLTBLDB_FILE)

TABLES := annotation annotation_transfer flags labelset metadata review

EXPORT := $(WORKSPACE)/scripts/export.py
IMPORT := $(WORKSPACE)/scripts/import.py
UPGRADE := $(WORKSPACE)/scripts/upgrade.py
CONFIGURATIONS := $(WORKSPACE)/scripts/configurations.py
AUTO_SYNCH := false

build/:
	mkdir -p $@

build/nanobot: | build/
	# upgrade /nanobot/src/resources as well
	curl -L -o $@ "https://github.com/hkir-dev/nanobot.rs/releases/download/v2024-12-28/nanobot-v20241228-x86_64-linux"
	chmod +x $@

$(RLTBL):
	chmod +x $@

# For first time data loading. Skips table creation if tables already exist.
.PHONY: load_data
load_data:
	python3 $(IMPORT) import-data --input input_data/ --curation_tables curation_tables/

# Forcefully loads data. Drops and recreates tables.
.PHONY: reload_data
reload_data: clean
	python3 $(IMPORT) import-data --input input_data/ --curation_tables curation_tables/ --force --preserve

.PHONY: runR
runR:
	Rscript dendR/nomenclature_builder.R

$(NANOBOTDB): | $(NANOBOT)
	$(NANOBOT) init

$(RLTBLDB): | $(RLTBL)
	chmod +x $(RLTBL)
	$(RLTBL) init --force || (echo "Error: run 'rltbl init'" && exit 1)

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
		tdta merge -p ./ -m "Auto-commit on startup."; \
		rm -f build/nanobot.db; \
		$(NANOBOT) init; \
	fi
	/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf


# Import tables into the database
import_tables: $(RLTBLDB)
	@echo "Current working directory is: $(PWD)"
	@echo "Processing tables: $(TABLES)"
	for TABLE in $(TABLES); do \
		echo "Processing table: $$TABLE"; \
		sqlite3 $(RLTBLDB) ".mode tabs" \
			".import curation_tables/$${TABLE}.tsv $${TABLE}_temp" \
			|| { echo "Error: Failed to import $${TABLE}.tsv"; exit 1; }; \
		sqlite3 $(RLTBLDB) "CREATE TABLE $${TABLE} AS SELECT rowid AS _id, CAST(1000*rowid AS NUMERIC) AS _order, * FROM '$${TABLE}_temp';" \
			|| { echo "Error: create table $${TABLE}"; exit 1; }; \
		sqlite3 $(RLTBLDB) "DROP TABLE $${TABLE}_temp" \
			|| { echo "Error: drop table $${TABLE}"; exit 1; }; \
		sqlite3 $(RLTBLDB) "INSERT INTO 'table' ('table') VALUES ('$${TABLE}')" \
			|| { echo "Error: update 'table' table with $${TABLE}"; exit 1; }; \
	done

define UPDATE_REVIEW_SQL
INSERT INTO 'review' \
SELECT rowid, (1000 * rowid), cell_set_accession, datetime(), 'james', 'approved', '' \
FROM annotation \
LIMIT 1;
endef

# Update the 'review' table to add a dummy review
update_review: $(RLTBLDB)
	@echo "Updating the review table."
	@echo "$(UPDATE_REVIEW_SQL)" | sqlite3 $(RLTBLDB)

define CREATE_VIEW_SQL
CREATE VIEW annotation_default_view AS  \
SELECT  \
	CASE (SELECT review FROM review  \
		WHERE cell_set_accession = review.target_node_accession  \
		LIMIT 1)  \
	WHEN 'approved' THEN 'https://icons.getbootstrap.com/assets/icons/chat-heart.svg'  \
	ELSE 'https://icons.getbootstrap.com/assets/icons/chat.svg'  \
	END AS review,  \
	*  \
FROM annotation;
endef

# Create the 'annotation_default_view'
create_view: $(RLTBLDB)
	@echo "$(CREATE_VIEW_SQL)" | sqlite3 $(RLTBLDB)

.PHONY: init
init: $(RLTBLDB) import_tables update_review create_view
	@echo "Initialized database successfully."

.PHONY: clean
clean:
	rm -rf build/

.PHONY: upgrade
upgrade: clean
	python3 $(UPGRADE) upgrade --root_folder ./ --workspace $(WORKSPACE)
	python3 $(IMPORT) import-data --input input_data/ --curation_tables curation_tables/
