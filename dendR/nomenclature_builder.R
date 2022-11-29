# Using the AllenInstitute CCN library generates CCN2 data curation tables
#
# This script follows the steps from the following sources:
# - https://github.com/AllenInstitute/nomenclature
# - http://htmlpreview.github.io/?https://github.com/AllenInstitute/nomenclature/blob/master/scripts/build_annotation_tables_SEAAD.nb.html


generate_ccn2_curation_tables <- function(taxonomy_id, nomenclature, output_folder){
    taxonomy_metadata_table <- data.frame("taxonomy_id" = c(taxonomy_id),
                     "species_id" = "",  # TODO from config??
                     "species_name" = "", # TODO from OLS ???
                     "brain_region_id" = "", # TODO from config??
                     "brain_region_name" = "", # TODO from OLS ???
                     "assay_id" = "",
                     "assay_name" = "",
                     "provenance" = ""
                     )
    write.table(taxonomy_metadata_table, file=paste0(output_folder, taxonomy_id, "_taxonomy.tsv"), quote=FALSE, sep='\t', row.names=FALSE)

    accession_ids = nomenclature[["cell_set_accession"]]
    synonyms <- vector(length=length(accession_ids))
    for (i in 1:length(accession_ids)) {
        x <- c(nomenclature[["cell_set_preferred_alias"]][i], nomenclature[["cell_set_aligned_alias"]][i], nomenclature[["cell_set_additional_aliases"]][i])
        x <- x[x != ""]
        synonyms[i] <- paste(x[!duplicated(x)], collapse="|")
    }
    taxonomy_table <- data.frame("cell_set_accession" = nomenclature[["cell_set_accession"]],
                         "cell_type_name" = nomenclature[["cell_set_preferred_alias"]],
                         "parent_cell_set_accession" = "", # TODO add logic
                         "synonyms" = synonyms,
                         "synonym_provenance" = "",
                         "description" = "",
                         "classifying ontology_term_name" = "",
                         "classification_provenance" = "",
                         "classification_comment" = "",
                         "rank" = ""
                         )
    write.table(taxonomy_table, file=paste0(output_folder, taxonomy_id, ".tsv"), quote=FALSE, sep='\t', row.names=FALSE)

    cross_taxonomy_table <- data.frame("cell_set_accession" = nomenclature[["cell_set_accession"]],
                     "cell_type_name" = nomenclature[["cell_set_preferred_alias"]],
                     "mapped_cell_set_accession" = "",
                     "mapped_cell_type_name" = "",
                     "evidence_comment" = "",
                     "similarity_score" = ""
                     )
    write.table(cross_taxonomy_table, file=paste0(output_folder, taxonomy_id, "_cross_taxonomy.tsv"), quote=FALSE, sep='\t', row.names=FALSE)

    location_mapping_table <- data.frame("cell_set_accession" = nomenclature[["cell_set_accession"]],
                     "cell_type_name" = nomenclature[["cell_set_preferred_alias"]],
                     "location_ontology_term_id" = "", # TODO from config???
                     "location_ontology_term_name" = "", # TODO from OLS?
                     "evidence_comment" = "",
                     "supporting_data" = "",
                     "provenance" = ""
                     )
    write.table(location_mapping_table, file=paste0(output_folder, taxonomy_id, "_location_mapping.tsv"), quote=FALSE, sep='\t', row.names=FALSE)
}

get_input_file <- function(input_folder, file_extension, file_type){
    input_files <- list.files(path=input_folder,pattern=paste0('.',file_extension,'$'))
    if(length(input_files) == 0) {
        stop(sprintf("A %s file (with '.%s' extension) cannot be found in input_data folder: %s", file_type, file_extension, input_folder))
    } else if (length(input_files) > 1) {
        input_file <- input_files[1]
        warning(sprintf("%d %s files (with '.%s' extension) found in input_data folder (%s). Continuing process with file: %s", length(dend_files), file_type, file_extension, input_folder, dend_file))
    } else {
        input_file <- input_files[1]
    }
    paste0(input_folder, "/", input_file)
}


build_nomenclature_tables <- function() {
    work_folder <- getwd()
#     work_folder <- "/home/huseyin/Downloads/dendR_experiments/target/human_m1"
    print(paste0("R script work folder:", work_folder))
    if(!endsWith(work_folder, "/")){
        work_folder <- paste0(work_folder,"/")
    }
    input_folder <- paste0(work_folder, "input_data")

    # TODO mention files in config???
    dendrogram_file <- get_input_file(input_folder, "rda", "dendrogram")
    metadata_file <- get_input_file(input_folder, "csv", "metadata")


    output_folder <- paste0(work_folder,"/curation_tables/")

    suppressPackageStartupMessages({
      library(dplyr)
      library(dendextend)
      library(ggplot2)
      library(data.table)
      library(jsonlite)
    })

    source("dendR/required_scripts.R")  # Additional required files
    options(stringsAsFactors = FALSE)

    # TODO read from config file
    taxonomy_id <- "CCN202204130"
    taxonomy_author <- "Jeremy Miller"
    taxonomy_citation <- "" # Unpublished as of April 2022, but please check the SEA-AD website for a soon-to-be submitted publication!

    # For a single labeling index for the whole taxonomy
    first_label <- setNames("SEAAD_MTG", 1)

    # If you want to use Neurons and Non-neurons
    #first_label <- setNames(
    #    c("Neuron", "Non-neuron"),
    #    c(1       , 111)

    # TODO move to config ???
    structure    = "middle temporal gyrus"
    ontology_tag = "UBERON:0002771"  # or "none" if no tag is available.

    load(dendrogram_file)
    # Attempt to format dendrogram if the input is in a different format
    dend <- as.dendrogram(dend)

    nomenclature_information <- build_nomenclature_table(dend,  first_label, taxonomy_id, taxonomy_author, taxonomy_citation, structure, ontology_tag)

    metadata <- read.csv(metadata_file)

    cell_set_information <- nomenclature_information$cell_set_information
    metadata_columns     <- c("subclass_label", "class_label")
    metadata_order       <- c("subclass_order", "class_order")  # Optional column indicating the order to include metadata
    annotation_columns   <- c("cell_set_preferred_alias","cell_set_preferred_alias") # Default is cell_set_preferred_alias
    cluster_column       <- "cluster_label"  # Column where the cluster information that went into "cell_set_preferred_alias"
                                             #     is stored (default is "cluster_label")
    append               <- FALSE # If TRUE (default), it will append info; if FALSE, it will ignore cases where there is already an entry
    cell_set_information <- annotate_nomenclature_from_metadata(cell_set_information, metadata, metadata_columns,
                                                                metadata_order, annotation_columns, cluster_column, append)

    # Since we used aligned alias terms, we will also save these terms in the cell_set_aligned_alias_slot
    annotation_columns   <- c("cell_set_aligned_alias","cell_set_aligned_alias")
    append               <- TRUE # If TRUE, it will append info; if FALSE, it will ignore cases where there is already an entry
    cell_set_information <- annotate_nomenclature_from_metadata(cell_set_information, metadata, metadata_columns,
                                                                metadata_order, annotation_columns, cluster_column, append)

    # TODO check this
#     write.csv(cell_set_information, paste0(output_folder, "initial_nomenclature_table.csv") ,row.names=FALSE)

    updated_nomenclature <- cell_set_information
    updated_nomenclature <- define_child_accessions(updated_nomenclature)

    generate_ccn2_curation_tables(taxonomy_id, updated_nomenclature, output_folder)
}

build_nomenclature_tables()
