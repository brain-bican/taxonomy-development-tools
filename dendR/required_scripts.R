# source: https://github.com/AllenInstitute/CCN/blob/master/R/required_scripts.R
######################################################################################
## MAIN NOMENCLATURE FUNCTIONS

#' Apply CCN (**BETA**)
#'
#' This **BETA** function is a wrapper for most of the other functions in the CCN library. It takes
#'   as input whatever information is available (e.g., dend, nomenclature, cell_assignment, metadata)
#'   and uses this to try and output a standard nomenclature table and other CCN outputs.  Please see
#'   the "Applying CCN to an existing taxonomy: one function" vignette for examples of how to use
#'   this function to apply the CCN in various contexts.
#'
#' @param dend dendrogram of cell types to annotate.  At least one of dend, nomenclature, cell_assignment, or metadata must be provided.
#' @param nomenclature the nomenclature table output from `build_nomenclature_table` or related/downstream functions.
#' @param cell_assignment a named vector linking each unique cell id ('names(cell_assignment)') to their cell type assignments ('cell_assignment')
#' @param metadata cell or cell type metadata table that includes the columns to annotate
#' @param first_label a named vector used as prefix for cell_set_label
#' @param taxonomy_id unique accession ID for the taxonomy also used to prefix the cell sets accessions.  Defaults to `CCN[YYYYMMDD]0`
#' @param taxonomy_author the name of a point person for this taxonomy
#' @param taxonomy_citation permanent data identifier corresponding to the taxonomy (or default="" if none). Ideally the DOI for a relevant publication.
#' @param structure the location in the brain (or body) from where the data in the taxonomy was collected
#' @param ontology_tag a standard ontology term (e.g., from UBERON) for the `structure`, or "none" if unavailable.  NULL (default) attempts to find one in UBERON using `find_ontology_terms`.
#' @param metadata_columns a character vector of column names corresponding to the metadata fields to add annotations. Only used if "metadata" is provided
#' @param metadata_order optional character vector of column names indicating the order to include metadata.  If supplied, must be the same length as "metadata_columns". Only used if "metadata" is provided
#' @param annotation_columns character vector indicating which column to annotate for each metadata column supplied (default is is "cell_set_preferred_alias"). Only used if "metadata" is provided
#' @param cluster_column column name in "metadata" that corresponds to values in the "cell_set_preferred_alias" column of "cell_set_information". Only used if "metadata" is provided
#' @param append_metadata If TRUE, it will append info; if FALSE (default), it will skip cases where there is already an entry. Only used if "metadata" is provided
#' @param ccn_filename file name for zip file with final CCN files containing the same information that is returned.  Will output to current working directory unless full path is specified.  Will not output anywhere if set to NULL.
#' @param duplicate_annotations either NULL or a character indicating which column to append annotations if the annotation_columns column already has an entry.  Only used if append=TRUE. Default "cell_set_additional_aliases"

#'
#' @return a list containing the three CCN standard outputs:
#' \describe{  # Describe is optional and can go after and param or return
#'   \item{cell_set_information}{Final nomenclature table where rows correspond to cell sets and columns correspond to standard CCN columns.}
#'   \item{initial_dendrogram}{A dendrogram updated with node numeric labels, if dend was provided.  These are useful for post-hoc manual annotations but otherwise can be ignored.}
#'   \item{final_dendrogram}{A dendrogram updated with node labels and CCN annotations, if dend was provided.  This is what is output in dend.json}
#'   \item{mapping}{A data frame where the first columns corresponds to each cell's unique ID (if cell_assignment or metadata is provided) and the remaining columns correspond to cell sets. Entries are either 0 = cell unassigned to cell set or 1 = cell assigned to cell set.}
#' }
#'
#' @export
apply_CCN <- function(dend = NULL,
                      nomenclature = NULL,
                      cell_assignment = NULL,
                      metadata = NULL,
                      first_label  = setNames("All",1),
                      taxonomy_id  = paste0("CCN",format(Sys.time(), "%Y%m%d"),0),
                      taxonomy_author = "Unspecified",
                      taxonomy_citation = "",
                      structure    = "neocortex",
                      ontology_tag = NULL,
                      metadata_columns = c("subclass_label"),
                      metadata_order = NULL,
                      annotation_columns = rep("cell_set_preferred_alias",length(metadata_columns)),
                      cluster_column = "cluster_label",
                      append_metadata = FALSE,
                      ccn_filename = "nomenclature.zip",
                      duplicate_annotations = "cell_set_additional_aliases"){

  ##############################################################
  # Load libraries
  suppressPackageStartupMessages({
    library(dplyr)
    library(dendextend)
    library(data.table)
    library(jsonlite)
  })


  ##############################################################
  # Variable prep and error check
  if(is.null(ontology_tag)) {
    ontology_tag <- find_ontology_terms(structure)[1,2]
    if(ontology_tag=="") ontology_tag = "none"
  }
  if((is.null(dend))&(is.null(nomenclature))&(is.null(cell_assignment))&(is.null(metadata))){
    stop("Error: at least one of dend, nomenclature, cell_assignment, or metadata must be provided.")
  }


  ##############################################################
  # Define starting nomenclature table
  if (!is.null(nomenclature)){

    # If nomenclature table is provided, do not generate it
    if (!is.null(dend)){
      warning("Since both `nomenclature` and `dend` are provided final dendrogram will be annotated exclusively from provided nomenclature and it's updates, and not from any extra information in `dend`.  We recommend providing both ONLY when the inputted nomenclature table was originally generated from the inputted dendrogram.\n")
    }
    # Confirm "All cells" exists and if not, then generate it
    nomenclature <- as.data.frame(nomenclature)
    if(sum(nomenclature$cell_set_preferred_alias=="All cells")==0){
      cell_set_accession <- max(as.numeric(as.character(unclass(
        sapply(nomenclature$cell_set_accession, function(x) strsplit(x,"_")[[1]][2])))))
      cell_set_accession <- gsub("CCN","CS",paste0(taxonomy_id,"_",1:(cell_set_accession+1)))
      cell_set_label <- sort(unique(as.numeric(gsub(".*?([0-9]+).*", "\\1", nomenclature$cell_set_label))))
      cell_set_label <- substr(10^max(nchar(cell_set_label))+cell_set_label,2,100)
      cell_set_label <- merge_cell_set_labels(paste(first_label[1],cell_set_label))
      nomenclature = rbind(nomenclature, data.frame(
        cell_set_accession = cell_set_accession,
        original_label = "",
        cell_set_label = cell_set_label,
        cell_set_preferred_alias = "All cells",
        cell_set_aligned_alias = "",
        cell_set_additional_aliases = "",
        cell_set_structure = structure,
        cell_set_ontology_tag = ontology_tag,
        cell_set_alias_assignee = taxonomy_author,
        cell_set_alias_citation = taxonomy_citation,
        taxonomy_id = taxonomy_id
      ))

    }
  } else if(!is.null(dend)){

    # Build a starting nomenclature table from the dendrogram, if it is provided.
    dend <- try(as.dendrogram(dend),silent=TRUE)
    if(class(dend)=="try-error") stop("Error: dend is not in a format that can be converted to a dendrogram.")
    nomenclature_information <- build_nomenclature_table(dend,  first_label, taxonomy_id, taxonomy_author,
                                                         taxonomy_citation, structure, ontology_tag)
    nomenclature = nomenclature_information$cell_set_information
    initial_dendrogram = nomenclature_information$initial_dendrogram
  } else if ((!is.null(cell_assignment))|(!is.null(metadata))){

    # Define cell_assignment from metadata if not provided and if possible, otherwise throw and error
    if(is.null(cell_assignment)){
      if(class(try(metadata[,cluster_column],silent = TRUE))=="try-error"){
        stop("Error: Valid cluster_column in metadata must be provided if dend, nomenclature, and cell_assignment are unspecified.")
      } else{
        cell_assignment <- setNames(metadata[,cluster_column],rownames(metadata))
        warning("cell_assignment is derived from metadata and therefore outputted `mapping` matrix may be innaccurate.\n")
      }
    }

    # Get the cell types from inputted or derived cell_assignment
    if(is.factor(cell_assignment)) {
      types <- levels(cell_assignment)
    } else {
      types <- as.character(unique(cell_assignment))
    }
    # Set the nomenclature table
    cell_set_accession <- gsub("CCN","CS",paste0(taxonomy_id,"_",1:(length(types)+1)))
    cs_digits   <- nchar(length(types))+1
    if(length(first_label)>1)
      warning("Only first `first_label` entry is used when dend and nomenclature are set to NULL.\n")
    first_label <- setNames(first_label[1],"1")
    num <- substr(10^cs_digits+(1:length(types)),2,100)
    cell_set_label <- paste(first_label[1],num)

    nomenclature = data.frame(
      cell_set_accession = cell_set_accession,
      original_label = "",
      cell_set_label = c(cell_set_label,"All cells"),
      cell_set_preferred_alias = c(types,"temp All cells"),
      cell_set_aligned_alias = "",
      cell_set_additional_aliases = "",
      cell_set_structure = structure,
      cell_set_ontology_tag = ontology_tag,
      cell_set_alias_assignee = taxonomy_author,
      cell_set_alias_citation = taxonomy_citation,
      taxonomy_id = taxonomy_id
    )

    # Move cell_set_label="All cells" to cell_set_preferred_alias
    nomenclature$cell_set_preferred_alias[nomenclature$cell_set_label=="All cells"] = "All cells"
    labNew <- merge_cell_set_labels(nomenclature$cell_set_label[nomenclature$cell_set_label!="All cells"])
    nomenclature$cell_set_label[nomenclature$cell_set_preferred_alias=="All cells"] = labNew
  }


  ##############################################################
  ## If metadata and associated columns are provided, add additional cell_sets based on metadata
  nomenclature <- annotate_nomenclature_from_metadata(
    nomenclature, metadata, metadata_columns, metadata_order, annotation_columns,
    cluster_column, append_metadata, duplicate_annotations)
  # NOTE: any error checks should be completed within the above function


  ##############################################################
  ## Define cell set children
  nomenclature <- define_child_accessions(nomenclature)


  ##############################################################
  ## Update and save the dendrogram, if a dendrogram was provided
  if(!is.null(dend)){
    # Update the dendogram
    if(!exists("initial_dendrogram")) {
      initial_dendrogram = overwrite_dend_node_labels(dend)$dend
    }
    updated_dendrogram <- update_dendrogram_with_nomenclature(initial_dendrogram,nomenclature)

    # Convert to list
    dend_list <- dend_to_list(updated_dendrogram, omit_names = c("markers","markers.byCl","class"))

    # Save as a json file
    dend_JSON <- toJSON(dend_list, complex = "list", pretty = TRUE)
    out <- file("dend.json", open = "w")
    writeLines(dend_JSON, out)
    close(out)
  }


  ##############################################################
  ## Define cell to cell set mappings, if cell_assignment is available

  # If cell_assignment not provided, try to guess cell_assignment from metadata table
  if(is.null(cell_assignment)&(!is.null(metadata))){
    if(class(try(metadata[,cluster_column],silent = TRUE))!="try-error"){
      cell_assignment  <- metadata[,cluster_column]
      name_col <- grepl("name",colnames(metadata))+grepl("sample",colnames(metadata))+grepl("cell",colnames(metadata))
      if(sum(name_col)==0){
        names(cell_assignment) <- 1:length(cell_assignment)
        warning("cell_assignment was not provided with names. Names are set as an ordered vector 1:length(cell_assignment).\n")
      } else {
        names(cell_assignment) <- metadata[,which.max(name_col)[1]]
        cn <- colnames(metadata)[which.max(name_col)[1]]
        warning(paste0("cell_assignment was not provided with names. Names are set as metadata$",cn,".\n"))
      }
    }
  }
  cell_id <- cell_assignment
  samples <- names(cell_assignment)  # I think this is correct...

  if(!is.null(cell_assignment)){
    # Add cell names if needed
    if(is.null(names(cell_assignment))){
      names(cell_assignment) <- 1:length(cell_assignment)
      warning("cell_assignment was not provided with names. Names are set as an ordered vector 1:length(cell_assignment).\n")
    }

    # Define the cell_id (e.g., cell set accession id) from the cell_assignment
    cell_id <- nomenclature[match(cell_assignment,nomenclature$cell_set_preferred_alias),"cell_set_accession"]
    names(cell_id) <- names(cell_assignment)

    # Assign dendrogram cell sets (if dendrogram provided)
    if(!is.null(dend)){
      mapping <- cell_assignment_from_dendrogram(updated_dendrogram,names(cell_id),cell_id)
    } else{
      # If no dendrogram, initialize mapping matrix
      mapping <- data.frame(sample_name=samples, call=((cell_id==cell_id[1])+1-1))
      colnames(mapping) <- c("sample_name",cell_id[1])
      if(length(first_label)>1){
        warning("Currently nomenclature tables without dendrograms, but with more than one cell_set_label prefix sometimes cause issues in generating the cell by cell set assignment matrix.\n")
      }
    }

    # Assign remaining mappings based on cell sets
    mapping <- cell_assignment_from_groups_of_cell_types(nomenclature,cell_id,mapping,FALSE)

    # Output any missed cell set accession IDs
    missed_ids <- setdiff(nomenclature$cell_set_accession,colnames(mapping))
    if (length(missed_ids)>0){
      warning(paste("The following cell sets were not used for cell mapping:",paste0(missed_ids,collapse="; ")))
    }

    # Output cell to cell set assignments
    fwrite(mapping,"cell_to_cell_set_assignments.csv")

  }


  ##############################################################
  ## Create standard CCN file and return results

  # Zip existing files, if requested
  if(!is.null(nomenclature))
    fwrite(nomenclature,"nomenclature_table.csv")
  files = c("dend.json","nomenclature_table.csv","cell_to_cell_set_assignments.csv")
  files = intersect(files,dir())
  if(!is.null(ccn_filename))
    zip(ccn_filename, files=files)
  file.remove(files)

  # Return results
  if(!exists("nomenclature"))       nomenclature = NULL
  if(!exists("updated_dendrogram")) updated_dendrogram = NULL
  if(!exists("initial_dendrogram")) initial_dendrogram = NULL
  if(!exists("mapping"))            mapping = NULL
  list(cell_set_information = nomenclature,
       initial_dendrogram = initial_dendrogram,
       final_dendrogram = updated_dendrogram,
       mapping = mapping)

}





#' Build initial nomenclature table from dendrogram
#'
#' Take a standard R dendrogram variable and some taxonomy metadata and generate an
#'   initial nomenclature table with one cell set corresponding to each dendrogram
#'   node and leaf, retaining leaf labels as preferred aliases.
#'
#' @param dend dendrogram of cell types to annotate
#' @param first_label a named vector used as prefix for cell_set_label
#' @param taxonomy_id unique accession ID for the taxonomy also used to prefix the cell sets accessions.  Defaults to `CCN[YYYYMMDD]0`
#' @param taxonomy_author the name of a point person for this taxonomy
#' @param taxonomy_citation permanent data identifier corresponding to the taxonomy (or default="" if none). Ideally the DOI for a relevant publication.
#' @param structure the location in the brain (or body) from where the data in the taxonomy was collected
#' @param ontology_tag a standard ontology term (e.g., from UBERON) for the `structure`, or "none" if unavailable.  The function `find_ontology_terms` can be used to find one.
#'
#' @return a list containing two dendrogram versions and the initial nomenclature table:
#' \describe{  # Describe is optional and can go after and param or return
#'   \item{cell_set_information}{Initial nomenclature table where rows correspond to cell sets (e.g., dendrogram leaves and nodes) and columns correspond to standard CCN columns.}
#'   \item{initial_dendrogram}{A slightly clean version of the input `dend`.}
#'   \item{updated_dendrogram}{A dendrogram updated with node labels.  This is useful to visualize when manually annotating dendrograms.}
#' }
#'
#' @export
build_nomenclature_table <- function(dend,
                                     first_label  = setNames("All",1),
                                     taxonomy_id  = paste0("CCN",format(Sys.time(), "%Y%m%d"),0),
                                     taxonomy_author = "Unspecified",
                                     taxonomy_citation = "",
                                     structure    = "neocortex",
                                     ontology_tag = "UBERON:0001950"){

  # Load required libraries
  suppressPackageStartupMessages({
    library(dplyr)
    library(dendextend)
  })

  ################################################################
  ## Update the dendrogram labels

  dend <- overwrite_dend_node_labels(dend)$dend
  dend_start <- dend


  ################################################################
  ## Initialize the data frame

  anno <- data.frame(original_label = dend %>% get_nodes_attr("label"),
                     cell_set_accession = "",
                     cell_set_label = "",
                     cell_set_preferred_alias = "",
                     cell_set_aligned_alias = "",
                     cell_set_additional_aliases = ""
                     )
  rownames(anno) <- dend %>% get_nodes_attr("label")


  ################################################################
  ## Update cell_set_preferred_alias for cell types

  anno[labels(dend),"cell_set_preferred_alias"] <- labels(dend)


  ################################################################
  ## Update cell_set_accession

  # Define cluster_id
  num_clusters    <- length(labels(dend))
  is_leaf         <- is.element(rownames(anno),labels(dend))
  anno$cluster_id <- 0
  #anno[labels(dend),"cluster_id"] <- 1:num_clusters  # Replaced with next line, which avoids error
  anno$cluster_id[rownames(anno) %in% labels(dend)] <- 1:num_clusters   #replaces cluster_id=0 with sequential id
  anno[!is_leaf,"cluster_id"] <- (num_clusters+1):dim(anno)[1]
  cluster_id      <- anno$cluster_id

  # How many digits to use for cell set number (as few as possible)
  cs_digits = max(1,nchar(dim(anno)[1]))

  # Define cell_set_accession
  anno$cell_set_accession <- paste0(taxonomy_id,"_",anno$cluster_id) #substr(10^cs_digits+anno$cluster_id,2,100))
  anno$cell_set_accession <- gsub("CCN","CS",anno$cell_set_accession)


  ################################################################
  ## Define cell_set_label
  # NOTE: cell_set_label is deprecated in the CCN, but is still required for this script to run properly

  # First convert from dendrogram index to label if needed
  if(!is.na(suppressWarnings(as.numeric(names(first_label))))){
    index <- as.numeric(names(first_label))
    first_label <- first_label[as.character(intersect(1:length(labels(dend)),index))]
    index <- as.numeric(names(first_label))
    names(first_label) <- labels(dend)[index]
  }

  # For cell types
  first_label <- first_label[intersect(labels(dend),names(first_label))]
  labs <- c(which(is.element(labels(dend),names(first_label))),num_clusters+1)
  for (i in 1:length(first_label)){
    lb  <- labs[i]:(labs[i+1]-1)
    num <- substr(10^cs_digits+anno[is_leaf,]$cluster_id[lb]-labs[i]+1,2,100)
    anno[is_leaf,]$cell_set_label[lb] <- paste(first_label[i],num)
  }

  # For internal nodes (cell sets)
  value <- dend %>% get_nodes_attr("label")
  names(value) <- dend %>% get_nodes_attr("label")
  value[labels(dend)] <- anno[labels(dend),]$cell_set_label
  value <- get_cell_set_designation(dend,value)
  value[1] <- "All cells"
  anno$cell_set_label <- as.character(value)

  # merge_cell_set_labels

  ################################################################
  ## Append the cell_set_structure

  anno$cell_set_structure    <- structure
  anno$cell_set_ontology_tag <- ontology_tag


  ################################################################
  ## Reorganize anno table

  anno <- anno[,c("cell_set_accession","original_label","cell_set_label",
                  "cell_set_preferred_alias","cell_set_aligned_alias","cell_set_additional_aliases",
                  "cell_set_structure","cell_set_ontology_tag")]
  rownames(anno) <- NULL
  anno <- anno[order(cluster_id),]

  anno$cell_set_alias_assignee <- paste0(taxonomy_author)
  anno$cell_set_alias_citation <- paste0(taxonomy_citation)
  anno$taxonomy_id             <- taxonomy_id

  # Move cell_set_label="All cells" to cell_set_preferred_alias
  anno$cell_set_preferred_alias[anno$cell_set_label=="All cells"] = "All cells"
  labNew <- merge_cell_set_labels(anno$cell_set_label[is.element(anno$cell_set_preferred_alias,labels(dend))])
  anno$cell_set_label[anno$cell_set_preferred_alias=="All cells"] = labNew

  ################################################################
  ## Update the dendrogram with this new information

  dend_out <- update_dendrogram_with_nomenclature(dend,anno)


  ################################################################
  ## Return anno and dend

  list(cell_set_information = anno, initial_dendrogram = dend_start, updated_dendrogram = dend_out)

}


######################################################################################
## ADDITIONAL NOMENCLATURE FUNCTIONS

#' Add nomenclature annotations to dendrogram
#'
#' This code will take the information from the table above and add it to the initial
#'   dendrogram object. When plotted the only visible difference will be that the new
#'   cell set alias names (if any) will show up to replace the n## labels from the initial
#'   plot. However, ALL of the meta-data read in from the table will be added to the
#'   relevant nodes or leafs.
#'
#' @param dend dendrogram of cell types to annotate
#' @param cell_set_information any table or data frame with information to annotate a dendrogram, typically the nomenclature table output from `build_nomenclature_table`
#' @param current_label column name in `cell_set_information` that contains dendrogram labels (default of "original_label" should be retained if running this function after `build_nomenclature_table`)
#' @param new_label column name holding desired dendrogram labels after running script (default "cell_set_preferred_alias" )
#'
#' @return An annotated dendrogram with updated labels
#'
#' @export
update_dendrogram_with_nomenclature <- function(dend, cell_set_information,
  current_label = "original_label", new_label = "cell_set_preferred_alias"){

  # Add all relevant information
  for (cn in colnames(cell_set_information)){
    value <- cell_set_information[,cn]
    names(value) <- cell_set_information[,current_label]
    dend <- add_attr_to_dend(dend,value,cn)
  }

  # Make the label match cell_set_preferred_alias
  value <- cell_set_information[,new_label]
  names(value) <- cell_set_information[,current_label]
  dend <- add_attr_to_dend(dend,value,"label")

  # Return dendrogram
  dend
}


#' Assign cells to cell sets from dendrogram
#'
#' Automatically link each cell to each cell set that is available in the dendrogram to
#'   produce a table of the probabilities of each cell mapping to each cell type.  In this
#'   case we define hard probabilities (0 = unassigned to cell set; 1 = assigned to cell
#'   set) but this could be adapted to reflect real probabilities calculated elsewhere.
#'
#' @param dend dendrogram of annotated cell types
#' @param samples a character vector of unique sample (e.g., cell or nucleus) names
#' @param cell_id a character vector of cell_set_accession_ids that corresponds to each sample
#' @param mapping do not set this parameter
#' @param continue do not set this parameter
#'
#' @return A data frame where the first columns corresponds to the cell sample_name and the remaining columns correspond to cell sets from the dendrogram. Entries are either 0 = cell unassigned to cell set or 1 = cell assigned to cell set.
#'
#' @export
cell_assignment_from_dendrogram <- function(dend, samples, cell_id,
  mapping=data.frame(sample_name=samples),continue=TRUE){

  # Add the mapping for the current cell set
  cell_set_id <- (dend %>% get_nodes_attr("cell_set_accession"))[1]
  kp <- is.element(cell_id,dend %>% get_leaves_attr("cell_set_accession"))
  if(sum(kp)>0){
    mapping[,cell_set_id] <- ifelse(kp,1,0)
  }

  # Recursively work through the dendrogram adding all mappings
  if(length(dend)>1)
    for (i in 1:length(dend)){
       mapping <- cell_assignment_from_dendrogram(dend[[i]],samples,cell_id,mapping,continue)
  } else if(continue) {
    continue <- FALSE
    mapping  <- cell_assignment_from_dendrogram(dend,samples,cell_id,mapping,continue)
  }

  # Return results
  mapping
}


#' Label cell set children
#'
#' Create an additional tag called child_cell_set_accessions, which is a “|”-separated character
#'   vector indicating all of the child set sets. This is calculated by parsing the cell_set_label
#'   tags and is helpful for integration into downstream ontology use cases.
#'
#' @param nomenclature the nomenclature table output from `build_nomenclature_table` or related/downstream functions
#'
#' @return An updated nomenclature table with a "child_cell_set_accessions" column appended
#'
#' @export
define_child_accessions <- function(nomenclature){
  nomenclature <- as.data.frame(nomenclature)
  nomenclature$child_cell_set_accessions = ""
  for (i in 1:dim(nomenclature)[1]){
    # Split out all the children in the cell_set_label
    lab    = nomenclature$cell_set_label[i]
	tax    = nomenclature$taxonomy_id[i]
	prefix = strsplit(lab," ")[[1]][1]
	suffix = gsub(prefix,"",lab)
	suffix = gsub("-",":",suffix)
	suffix = eval(parse(text=paste("try({c(",suffix,")},silent=TRUE)")))
	if(class(suffix)=="try-error") suffix = 0

	# Allow for different numbers of leading 0s
	suffix1  <- suffix
	for (j in 1:10) suffix <- c(suffix1,paste("0",suffix,sep=""))
    children <- intersect(nomenclature$cell_set_label,paste(prefix,suffix))

	# Convert to cell_set_accessions and save
	children <- nomenclature$cell_set_accession[is.element(nomenclature$cell_set_label,children)&
	            (nomenclature$taxonomy_id==tax)]
	children <- setdiff(children,nomenclature$cell_set_accession[i])
	if(length(children)>1)
	  nomenclature$child_cell_set_accessions[i] <- paste(children,collapse="|")
  }
  nomenclature
}


#' Assign cells to cell sets from nomenclature table
#'
#' Automatically link each cell to each cell set that is included in a nomenclature table
#'   to produce a table of the probabilities of each cell mapping to each cell type.  In
#'   this case we define hard probabilities (0 = unassigned to cell set; 1 = assigned to
#'   cell set) but this could be adapted to reflect real probabilities calculated
#'   elsewhere. Only cell sets not already included in input mapping table are added.
#'   NOTE: This function has some issues if more than one "first_label" is in use.
#'
#' @param updated_nomenclature nomenclature table of annotated cell types
#' @param cell_id a character vector of cell_set_accession_ids that corresponds to each sample
#' @param mapping A data frame where the first columns corresponds to the cell sample_name and the remaining columns correspond to cell sets (e.g., the output from `cell_assignment_from_dendrogram`)
#' @param verbose A logical indicating whether to output cell set accession IDs of new annotations to screen (default=TRUE)
#'
#' @return An updated "mapping" variable with additional cells sets added from nomenclature table. Entries are either 0 = cell unassigned to cell set or 1 = cell assigned to cell set.
#'
#' @export
cell_assignment_from_groups_of_cell_types <- function(updated_nomenclature,cell_id,mapping,verbose=TRUE){

  ## Determine the relevant cell sets to annotate
  used_ids      <- intersect(updated_nomenclature$cell_set_accession,colnames(mapping))
  missed_ids    <- setdiff(updated_nomenclature$cell_set_accession,colnames(mapping))
  missed_labels <- updated_nomenclature$cell_set_label[match(missed_ids,updated_nomenclature$cell_set_accession)]
  used_labels   <- setdiff(updated_nomenclature$cell_set_label,missed_labels)

  used_class       <- as.character(lapply(used_labels,function(x) strsplit(x," ")[[1]][1]))
  missed_class     <- as.character(lapply(missed_labels,function(x) strsplit(x," ")[[1]][1]))
  cell_type_labels <- missed_labels[is.element(missed_class,used_class)]

  ## Find the corresponding cell types for those cell sets
  labsL     <- list()
  nClusters <- sum(!(grepl(",",updated_nomenclature$cell_set_label)|grepl("-",updated_nomenclature$cell_set_label)))
  #cs_digits <- max(1,nchar(nClusters))
  cs_digits <- nchar(strsplit(updated_nomenclature$cell_set_label[1]," ")[[1]][-1]) # infer from input cell_set_labels
  if (length(missed_labels)>0){
    for (i in 1:length(missed_labels)){
      m <- eval(parse(text=paste("c(",gsub("-",":",gsub(missed_class[i],"",missed_labels[i])),")")))
      m <- substr(10^cs_digits+m,2,100)
      labsL[[missed_labels[i]]] <- paste(missed_class[i],m)
    }
  }

  ## Now annotate them!
  if(verbose) print("Cell sets added to table:")
  for (cl in cell_type_labels){
    ids <- updated_nomenclature$cell_set_accession[match(labsL[[cl]],updated_nomenclature$cell_set_label)]
    kp  <- is.element(cell_id,ids)
    if(sum(kp)>0){
      cell_set_id <- updated_nomenclature$cell_set_accession[match(cl,updated_nomenclature$cell_set_label)]
      mapping[,cell_set_id] <- ifelse(kp,1,0)
      if(verbose) print(cell_set_id)
    }
  }

  # Return results
  mapping
}


#' Automatic annotation of nomenclature table from metadata
#'
#' Automatically annotate existing cell sets and add new cell sets as needed based on existing
#'   metadata columns, for metadata that represent groups of cell types (e.g., something like "sex"
#'   would not be appropriate, but "broad class" would). More specifically, this function will:
#'   1. Identify all values corresponding to that column
#'   2. For each value it (i) finds all relevant dendrogram labels, (ii) generates the corresponding
#'   cell set label, and (iii) cross-references this label with the existing table
#'   3. If the label exists, the new metadata is added to the requested column in the nomenclature
#'   table, and if not it will generate a new entree in the table and then add the requested metadata
#'   4. Repeat this processes for all relevant metadata columns and associated values
#'
#' @param cell_set_information the nomenclature table output from `build_nomenclature_table` or related/downstream functions
#' @param metadata cell or cell type metadata table that includes the columns to annotate
#' @param metadata_columns a character vector of column names corresponding to the metadata fields to add annotations
#' @param metadata_order optional character vector of column names indicating the order to include metadata.  If supplied, must be the same lengthh as "metadata_columns"
#' @param annotation_columns character vector indicating which column to annotate for each metadata column supplied (default is is "cell_set_preferred_alias")
#' @param cluster_column column name in "metadata" that corresponds to values in the "cell_set_preferred_alias" column of "cell_set_information"
#' @param append If TRUE (default), it will append info; if FALSE, it will skip cases where there is already an entry
#' @param duplicate_annotations either NULL (default) or a character indicating which column to append annotations if the annotation_columns column already has an entry.  Only used if append=TRUE.
#'
#' @return An updated nomenclature table with new cell sets and updated annotations based on requested metadata
#'
#' @export
annotate_nomenclature_from_metadata <- function(cell_set_information, metadata, metadata_columns,
                                                metadata_order = NULL,
                                                annotation_columns = rep("cell_set_preferred_alias",length(metadata_columns)),
                                                cluster_column = "cluster_label",
                                                append = TRUE,
                                                duplicate_annotations = NULL)
{
  # Set up some variables and do some input checks
  cell_set_information <- as.data.frame(cell_set_information)
  if(length(metadata_order)!=length(metadata_columns)){
    metadata_order <- rep("none",length(metadata_columns))
  }
  names(metadata_order) <- names(annotation_columns) <- metadata_columns
  metadata_columns <- intersect(metadata_columns,colnames(metadata))
  if(length(metadata_columns)==0){
    print("No valid columns input. Returning inputted cell_set_information.")
    return(cell_set_information)
  }
  metadata_order <- metadata_order[metadata_columns]
  annotation_columns <- annotation_columns[metadata_columns]
  if(length(setdiff(annotation_columns,colnames(cell_set_information)))>0){
    print("At least one annotation_column is invalid.  Please correct and try again.")
    return(cell_set_information)
  }
  if(!is.null(duplicate_annotations))
    if(length(setdiff(duplicate_annotations,colnames(cell_set_information)))>0){
      print("duplicate_annotations is not NULL or a valid column.  Please correct and try again.")
      return(cell_set_information)
    }

  # Run the script for each value column
  for (column in metadata_columns){
    print(paste("Updating table for",column))
    annotations <- sort(unique(metadata[,column]))
    ord <- as.character(metadata_order[column])
    if((ord!="none")&is.element(ord,colnames(metadata))){
      annotations <- metadata[match(sort(unique(metadata[,ord])),metadata[,ord]),column]
    }
    for (ann in annotations){
      cls  <- metadata[,cluster_column][metadata[,column]==ann]
      labs <- cell_set_information$cell_set_label[is.element(cell_set_information$cell_set_preferred_alias,cls)]
      lab  <- merge_cell_set_labels(labs)

      # Create cell set, if needed
      if(!is.element(lab,cell_set_information$cell_set_label)){
        newInfo <- head(cell_set_information,1)
        max <- max(as.numeric(as.character(lapply(cell_set_information$cell_set_accession, function(x) strsplit(x,"_")[[1]][2]))))
        newInfo$cell_set_accession       <- paste(strsplit(newInfo$cell_set_accession,"_")[[1]][1],max+1,sep="_")
        newInfo$cell_set_label           <- lab
        newInfo$cell_set_preferred_alias <- ann
        keepCols <- c("cell_set_accession","cell_set_label","cell_set_structure","cell_set_ontology_tag",
                      "cell_set_alias_assignee","cell_set_alias_citation","taxonomy_id")
        newInfo[,setdiff(colnames(newInfo),keepCols)] <- ""
        cell_set_information <- rbind(cell_set_information,newInfo)
      }

      # Add information to cell set
      ann2 <- cell_set_information[which(cell_set_information$cell_set_label==lab)[1],annotation_columns[column]]
      column2 = annotation_columns[column]
      if (!((nchar(ann2)>0)&(!append))){
       ann2 <- paste(ann2,ann,sep="|")
       if(substr(ann2,1,1)=="|") {
         ann2 <- substr(ann2,2,nchar(ann2))
       } else {
         # This section instead updates the duplicate_annotations column if annotation_columns[column] already has an entry
         if(!is.null(duplicate_annotations))
           column2 = duplicate_annotations
           ann2 <- cell_set_information[which(cell_set_information$cell_set_label==lab)[1],column2]
           ann2 <- paste(ann2,ann,sep="|")
           if(substr(ann2,1,1)=="|") ann2 <- substr(ann2,2,nchar(ann2))
       }
       cell_set_information[which(cell_set_information$cell_set_label==lab)[1],column2] <- ann2
      }
    }
  }
  cell_set_information
}


######################################################################################
## Support functions

#' Merge cell set labels
#'
#' Takes as input a vector of cell set labels and outputs a single character that merges
#'   the cell set labels together in a specific format.
#'
#' @param cell_set_label_vector character vector of cell set labels for the form "{prefix} {value}"
#' @param sep delimiter separating prefix from value (default of " " should likely not be changed)
#'
#' @return character corresponding to merged value
#'
#' @export
merge_cell_set_labels <- function(cell_set_label_vector, sep=" "){
  if(length(cell_set_label_vector)==1) return(cell_set_label_vector)
  labs <- as.character(cell_set_label_vector)
  if(length(strsplit(labs[1],sep)[[1]])==1){
    cell_set_label_vector <- paste("All",cell_set_label_vector,sep=sep)
    warning("No first_label provided with cell_set_labels, therefore `All` is set as first_label. This may cause problems later.\n")
  }
  name <- as.character(unclass(sapply(labs, function(x) strsplit(x,sep)[[1]][1])))
  nums <- as.character(unclass(sapply(labs, function(x) strsplit(x,sep)[[1]][2])))
  ints <- suppressWarnings(setNames(as.numeric(nums),nums))
  if(sum(is.na(ints))>0)
    stop("cell_set_label_vector is of a format incompatible by this function. They all must be [first_label][sep][INTEGER_VECTOR].\n")

  val <- NULL
  for (clas in unique(name)){
    int2 <- sort(ints[name==clas])
    seqs <- c(FALSE,int2[1:(length(int2)-1)]-int2[2:(length(int2))]==(-1))
    seqs <- c(which(!seqs),length(seqs)+1)
    out <- paste(names(int2[unique(range(seqs[1]:(seqs[2]-1)))]),collapse="-")
    if(length(seqs)>2) for (i in 2:(length(seqs)-1)){
      out <- c(out,paste(names(int2[unique(range(seqs[i]:(seqs[(i+1)]-1)))]),collapse="-"))
    }
    val <- c(val,paste(clas, paste(out,collapse=", ")))
  }
  val <- paste(val,collapse = "/")
  val
}

#' Expand cell set labels
#'
#' Takes as input a vector of merged cell set labels and outputs a list of all of the cell set
#'   labels as vectors.  If remerge=TRUE, then instead a vector of remerged cell set labels is
#'   output.  Note: this function assumes a single first_label value for all cell sets.
#'
#' @param cell_set_label_vector character vector of cell set labels for the form "{prefix} {value}"
#' @param sep delimiter separating prefix from value (default of " " should likely not be changed)
#' @param remerge should an optimally re-merged vector of cell set labels (TRUE; default) or a list of all separate cell set labels (FALSE) be returned
#'
#' @return character list or vector corresponding to desired output
#'
#' @export
expand_cell_set_labels <- function(cell_set_label_vector, sep=" ", remerge=TRUE){
  first_label <- strsplit(cell_set_label_vector[1],sep)[[1]][1]
  labs <- as.character(cell_set_label_vector)
  labs <- gsub(first_label,"",labs)
  labs <- gsub(" ","",labs)
  cs_digits <- nchar(strsplit(gsub("-",",",labs[1]),",")[[1]][1])

  expand_one <- function(x, cs_digits=5){
    xl <- strsplit(x,",")[[1]]
    xout <- NULL
    for (i in 1:length(xl)) {
      if(!grepl("-",xl[i])){
        xout <- c(xout,as.numeric(xl[i]))
      } else {
        xseq <- as.numeric(as.character(strsplit(xl[[i]],"-")[[1]]))
        xout <- c(xout,xseq[1]:xseq[2])
      }
    }
    xout <- substr(as.character(sort(xout)+10^cs_digits),2,cs_digits+1)
    paste(first_label,xout,sep=sep)
  }

  cell_set_label_list <- lapply(labs,expand_one,cs_digits)
  if(!remerge) return(cell_set_label_list)
  as.character(lapply(cell_set_label_list,merge_cell_set_labels, sep=sep))
}





get_dendrogram_value <- function(dend,value, sep=" "){
  # Function called by get_cell_set_designation to get a dendrogram value
  labs <- as.character(value[labels(dend)])
  clas <- as.character(unclass(sapply(labs, function(x) strsplit(x,sep)[[1]][1])))
  nums <- as.character(unclass(sapply(labs, function(x) strsplit(x,sep)[[1]][2])))
  if(length(unique(clas))>1){
   val <- paste(unique(clas),collapse = "/")
  } else {
   val <- paste(clas[1], paste(unique(range(nums)),collapse="-"))
  }
  return(val)
 }


get_cell_set_designation <- function(dend, value, sep=" ") {
  # Function called by build_nomenclature_table to get cell set labels
  if (length(dend)>1) {
    for(i in 1:length(dend)){
      value[attr(dend[[i]],"label")] <- get_dendrogram_value(dend[[i]],value)
      value = get_cell_set_designation(dend[[i]], value=value)
    }
  }
  return(value)
}


#' Add an attribute to dendrogram nodes
#'
#' Adds a specified attribute to labeled nodes of a dendrogram
#'
#' @param dend dendrogram of annotated cell types (with labeled nodes)
#' @param value named vector of attributes to add (values = attribute value; name = dendrogram node labels)
#' @param attribute name of attribute to add or update in "dend"
#'
#' @return The input dendrogram with the new added/updated attribute.
#'
#' @export
add_attr_to_dend <- function(dend, value, attribute="label") {
  # Value must be of length nnodes(dend) and be named as such
  if(!is.na(value[attr(dend,"label")]))
    attr(dend, attribute) <- value[attr(dend,"label")]
  if (length(dend)>1) {
    for(i in 1:length(dend)){
      dend[[i]]=add_attr_to_dend(dend[[i]], value=value, attribute)
    }
  }
  return(dend)
}


#' Plot dendrogram
#'
#' Function for plotting a dendrogram in a way that displays node labels.  This function
#'   is copied from `scrattch.hicat`: https://github.com/AllenInstitute/scrattch.hicat
#'
#' @param dend any R dendrogram of annotated cell types
#' @param dendro_data (I don't know)
#' @param node_size size of nodes (default = 1)
#' @param r (I don't know)
#'
#' @return A plot of the dendrogram in `ggplot2` format
#'
#' @export
plot_dend <- function (dend, dendro_data = NULL, node_size = 1, r = c(-0.1, 1))
{
    suppressPackageStartupMessages({
      library(dendextend)
      library(ggplot2)
    })

    if (is.null(dendro_data)) {
        dendro_data = as.ggdend(dend)
        dendro_data$nodes$label = get_nodes_attr(dend, "label")
        dendro_data$nodes = dendro_data$nodes[is.na(dendro_data$nodes$leaf),
            ]
    }
    node_data = dendro_data$nodes
    label_data <- dendro_data$labels
    segment_data <- dendro_data$segments
    if (is.null(node_data$node_color)) {
        node_data$node_color = "black"
    }
    ggplot() + geom_text(data = node_data, aes(x = x, y = y,
        label = label, color = node_color), size = node_size,
        vjust = 1) + geom_segment(data = segment_data, aes(x = x,
        xend = xend, y = y, yend = yend), color = "gray50") +
        geom_text(data = label_data, aes(x = x, y = -0.01, label = label,
            color = col), size = node_size, angle = 90, hjust = 1) +
        scale_color_identity() + theme_dendro() + scale_y_continuous(limits = r)
}


#' Overwrite dendrogram node labels
#'
#' Overwrites node (but not leaf) labels of a dendrogram with unique labels of the
#'   format "n##".  This is useful for visualization of the dendrogram for manual
#'   annotation of cell sets.  Optionally also change leaf labels.
#'
#' @param dend any R dendrogram of annotated cell types
#' @param n starting value for numbering (default of 1 does not need to be changed)
#' @param lab leaf labels to write, defaults to existing leaf labels
#'
#' @return R dendrogram with new node (and potentially leaf) labels
#'
#' @export
overwrite_dend_node_labels <- function (dend, n = 1, lab = labels(dend))
{
    if ((!is.element(attr(dend, "label"),lab))|(length(dend) > 1)) {
        attr(dend, "label") = paste0("n", n)
        n = n + 1
    }
    if (length(dend) > 1) {
        for (i in 1:length(dend)) {
            tmp = overwrite_dend_node_labels(dend[[i]], n, lab)
            dend[[i]] = tmp[[1]]
            n = tmp[[2]]
        }
    }
    return(list(dend = dend, n))
}


#' Convert R dendrogram to a list
#'
#' Converts an R dendrogram to a list format.  This step is necessary for outputting
#'   a dendrogram in json format. NOTE: If this function crashes, the "omit_names"
#'   variable may need to be updated to exclude additional variables in dend.
#'
#' @param dend any R dendrogram of annotated cell types
#' @param omit_names character vector of attributes to exclude from the conversion to list format.  This is necessary because attributes in complex formats sometimes cannot be properly converted without the function crashing
#'
#' @return The R dendgram information in list format, with all but the omitted attributes
#' @export
dend_to_list <- function(dend, omit_names = c("markers","markers.byCl","class")) {
  node_attributes <- as.data.frame(attributes(dend)[!is.element(names(attributes(dend)),omit_names)])
  node_attributes <- unique(node_attributes[,names(node_attributes) != "names"])
  if("leaf" %in% names(node_attributes)) {
    return(list(leaf_attributes = node_attributes))
  } else {
    y <- dend
    attributes(y) <- NULL
    class(y) <- "list"
    children <- y

    dend <- list(node_attributes = node_attributes,
                 children = children)

    if(length(dend$children) > 1) {
      for(i in 1:length(dend$children)) {
        dend$children[[i]] <- dend_to_list(dend$children[[i]])
      }
    }
    return(dend)
  }

}

#' Find ontology terms by querying the Ontology Lookup Service directly from R. This is useful
#'   for quickly finding UBERON (or other) ontology IDs for inclusion in the CCN.
#'   Note: this is a wrapper for functions from library `rols` (http://lgatto.github.com/rols/)
#'   Please cite as specified in `citation("rols")` if you use this function.
#'
#' @param query Term you want to search for in the ontology (e.g., "neocortex")
#' @param exact Return only exact matches to input term (TRUE; default) or that's that are close
#' @param ontology Which ontology to search. Default is "UBERON".  "" will search all ontologies
#' @param ... Additional parameters to `OlsSearch`
#'
#' @return what is returned
#' \describe{  # Describe is optional and can go after and param or return
#'   \item{name}{description}
#' }
#' @export
#'
find_ontology_terms <- function(query, exact=TRUE, ontology = "UBERON", ...) {
  suppressPackageStartupMessages({
    library(rols)
  })
  qry   <- OlsSearch(q = query, exact = exact, ontology=ontology, ...)
  qry   <- olsSearch(allRows(qry))
  out   <- data.frame(label=qry@response$label,term=qry@response$obo_id)
  if(dim(out)[1]==0)
    out <- data.frame(label=query,term="")
  return(out)
}

