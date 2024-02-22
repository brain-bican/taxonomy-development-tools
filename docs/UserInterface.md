# Taxonomy Development Tools User Interface Guide

Welcome to the Taxonomy Development Tools User Interface Guide. This document is designed to provide comprehensive details on navigating and utilizing the TDT interface efficiently. Whether you are looking to manage data tables, edit information, or leverage advanced features, this guide will assist you in making the most out of TDT.

1. [Tables](#tables)
1. [Table Management](#table-management)
   1. [Adding new Records](#add-new-records)
   1. [Editing Existing Data](#editing-existing-data)
   1. [Sorting and Filtering Data](#sorting-and-filtering-data)
1. [Actions](#actions)
   1. [Save](#save)
   1. [GitHub Controls](#github-controls)
   1. [Make a Release](#make-a-release)
   1. [Publish PURL](#publish-purl)
   1. [Export CAS Json](#export-cas-json)
   1. [Export to AnnData](#export-to-anndata)
1. [Views](#views)

## Tables

At the heart of the Taxonomy Development Tools is a robust internal database designed to streamline the management and curation of taxonomy-related data. Access to this database is facilitated through a user-friendly interface, with tables being a central component.

To view the available tables, simply navigate to the Tables dropdown menu at the top of the interface.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/tables.png" alt="Tables" width="300"/>
</p>

TDT categorizes tables into two main types, each serving distinct purposes:

**User tables:** User tables are created when data is uploaded to the TDT using the `load_data` operation (https://brain-bican.github.io/taxonomy-development-tools/Curation/). This data is formatted according to the [Cell Annotation Schema](https://github.com/cellannotation/cell-annotation-schema) and organized into multiple interrelated tables. These tables include: 
- `*_metadata`: Contains metadata related to the taxonomy.
- `*_labelset`: Houses definitions of the label sets.
- `*_annotation`: Stores annotations for cell types, classes, or states, along with supporting evidence and provenance information. It is designed to be flexible, allowing for additional fields to accommodate user needs or project-specific metadata.
- `*_annotation_transfer`: Tracks annotation transfer records.
For detailed information on table structures and fields, refer to the Cell Annotation Schema [documentation](https://github.com/cellannotation/cell-annotation-schema/blob/main/build/BICAN_schema.md).

**System tables:** System tables are essential for the internal configurations of TDT and are typically not modified by users. Currently, only a single system table is visible to the users:
- `table`: Lists all loaded tables and the physical location of the backing files.

## Table Management

### Adding New Records

`Add row` button can be used to add new records to the table.

### Editing Existing Data

Users can initiate the editing of records by clicking on the pen icon located at the start of each row. This action directs them to a data submission form that supports auto-completion, allowing for efficient data entry. After validating the entered data, users can finalize their edits by clicking the Submit button.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/edit_form.png" alt="Edit Form" width="600"/>
</p>

### Sorting and Filtering Data

By clicking on column names, data sort and filter pop-up widget can be activated. This widget allows for the alphabetical sorting of data and the application of conditions to filter data accordingly. Icons next to the column header indicate active sorting or filtering, and clicking the column header again lets you update or clear these parameters.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/sort_and_filter.png" alt="Sort and Filter by Column" width="400"/>
</p>

## Actions

### Save

All user modifications are automatically saved to the internal database. However, if user wants to save changes back to the source tsv files located in the project `curation_tables/` folder, `save` action can be utilized.

### GitHub Controls

### Make a Release

### Publish PURL

A Permanent URL (PURL) provides a stable link that always directs users to the same digital content. The `Publish PURL` allows you to generate a PURL for the current taxonomy version, ensuring consistent access to it. For instance, a taxonomy might be accessible through a PURL like:

https://purl.brain-bican.org/taxonomy/CCN202210140/CS202210140_neurons.json --> redirects to --> https://raw.githubusercontent.com/brain-bican/human-brain-cell-atlas_v1_neurons/main/CS202210140.json

Create a PURL once you deem the taxonomy mature enough for community sharing. This process will generate a PURL configuration file and initiate a pull request to the [purl.brain-bican.org repository](https://github.com/brain-bican/purl.brain-bican.org).

Note: This step requires a fork of the [purl.brain-bican.org](https://github.com/brain-bican/purl.brain-bican.org) repository in case you lack write access. Please ensure any existing forks are removed to avoid conflicts. The system will alert you if an existing fork is detected.
### Export CAS Json

This action converts all data into a JSON file formatted according to the [Cell Annotation Schema](https://github.com/cellannotation/cell-annotation-schema) located in the project's root directory.

### Export to AnnData

Apply your modifications directly to the associated AnnData file for the taxonomy.

The `*_metadata` table contains a `matrix_file_id` column, representing a resolvable ID for a cell-by-gene matrix file, formatted as `namespace:accession`. For example, `CellXGene_dataset:8e10f1c4-8e98-41e5-b65f-8cd89a887122` (Please refer to the [cell-annotation-schema registry](https://github.com/cellannotation/cell-annotation-schema/registry/registry.json) for a list of supported namespaces.)

WUpon initial launch, TDT creates a `tdt_datasets` directory in the user home folder. It attempts to resolve all matrix_file_id references within this directory. The system searches for the corresponding file (e.g., `$HOME/tdt_datasets/8e10f1c4-8e98-41e5-b65f-8cd89a887122.h5ad`) and then initiates a [cas-tools flatten operation](https://github.com/cellannotation/cas-tools/blob/main/docs/cli.md#flatten-onto-anndata). This process, which may vary in duration depending on the taxonomy's size, results in a new AnnData file (`/tdt_datasets/$$TAXONOMY_ID$$.h5ad`) incorporating the user's annotations.

## Views

Annotation tables are equipped to display data in a hierarchical structure, offering a more intuitive understanding of relationships within the taxonomy. To access this perspective, simply click on the `Taxonomy View` button.
<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/tree_view.png" alt="Sort and Filter by Column" width="500"/>
</p>

While in the Taxonomy View, users can visually explore the taxonomy's structure in a read-only format, providing a clear overview of the hierarchical relationships. To switch back to a more detailed and interactive tabular format, click the `Table View` button.