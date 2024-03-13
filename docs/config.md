# Configuring a new project

New projects need configuration 

## Project Config

To start a new project, we need to collect some general metadata. Here, for example, is a project configuration for the non-neuronal component of  Human Brain Cell Atlas v1.0:

```yaml
id: CS202210140 
title: Human Brain Cell Atlas v1.0 - non neuronal
description: "Atlas of human primary motor cortex (M1), developed in collaboration with the BRAIN Initiative Cell Census Network (BICCN), non neuronal cells.
matrix_file_id: CellXGene_dataset:b165f033-9dec-468a-9248-802fc6902a74  
github_org: brain-bican
repo: human-brain-cell-atlas_v1_non-neuronal
author: https://orcid.org/0000-0001-7620-8973
accession_id_prefix: CS202210140_
citation: DOI:10.1126/science.add7046
creators:
  - https://orcid.org/0000-0001-7258-9596
  - https://orcid.org/0000-0002-3315-2794
```

* `id`: should specify a unique ID for the taxonomy.  This is used to name files as well as URLs from which the taxonomy can be retrieved.
* `title` and `description` should be self-explanatory.
* `matrix_file_id`:  An ID that can be used to resolve a cell by gene matrix file in AnnData (h5ad) format.  In this case the file in question is present on CZ CELLxGENE.  TDT (and CAS-Tools) recognises the prefix and uses this to retrieve the relevant file.
* `github_org`: The GitHub organization that hosts the taxonomy.  For BICAN this should be brain-bican, although you could use your own GitHub username if you want to experiment.
* `author`: Every taxonomy must have a primary author.  We use ORCID to record this.
* `accession_id_prefix`: The prefix used to create IDs for new cell sets added to the taxonomy
* `citation`: DOI of associated paper (where the taxonomy is for a published dataset)
* creators: ORCIDs or all other authors should be included here

## Configure seeding a new taxonomy from an existing informal taxonomy.

TDT supports seeding of new taxonomies from existing informal taxonomy spreadsheets. The entire content of these spreadsheets is preserved and editable within the TDT annotation table. A simple configuration file supports mapping of relevant content into the  content in  Cell Annotation Schema (CAS) Taxonomy standard.

Configuration assumes informal taxonomies will have 1 row per cluster (where cluster is the most granular level in the hierarchy), 1 column per heirarchy level and that additional columns record information about clusters. For example, the following informal taxonomy has one row per cluster - with cluster identity indicated by the first 2 columns.

![image](https://github.com/brain-bican/taxonomy-development-tools/assets/112839/b11e5f81-3016-47b3-8004-32a23a93bb4e)

The next 3 columns specify different taxonomy levels.

We record this in the config as follows:

```yaml
fields:
  - column_name: cluster_id
    column_type: cluster_id
    rank: 0
  - column_name: Cluster
    column_type: cluster_name
    rank: 0
  - column_name: Subclass
    column_type: cell_set
    rank: 1
  - column_name: Neighborhood
    column_type: cell_set
    rank: 2
  - column_name: Class
    column_type: cell_set
    rank: 3
```

The rank field indicates level in the heirarchy. The most granular level (cluster) gets `rank: 0`, the next level up in the heirarchy gets `rank: 1` etc.

Our aim is to gradually increase the number of types of field that can be mapped into the schema and can benefit from autocomplete editing, including fields for recording markers and anatomical locations.


