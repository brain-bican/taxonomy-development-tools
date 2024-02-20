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

**System tables:** System tables are essential for the internal configurations of TDT and are typically not modified by users. These tables include:
- `table`: Lists all loaded tables and the physical location of the backing files.
- `column`: Associates table columns with their respective data types.
- `datatype`: Lists all datatypes existing in the system. Datatypes allow users to define regex patterns for cell values. The datatypes are a hierarchy of types, and when a datatype is provided as a condition, all parent values are also checked.
- `message`: TDT allows users to load invalid data (invalid datatypes, value not matching with regex etc.) and displays issues on top of each table and column. `messages` table stores the found errors in the data.

## Table Management

### Adding New Records

`Add row` button can be used to add new records to the table.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/add_row.png" alt="Edit Form" width="300"/>
</p>

### Editing Existing Data

Users can initiate the editing of records by clicking on the pen icon located at the start of each row. This action directs them to a data submission form that supports auto-completion, allowing for efficient data entry. After validating the entered data, users can finalize their edits by clicking the Submit button.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/edit_form.png" alt="Edit Form" width="400"/>
</p>

### Sorting and Filtering Data

By clicking on column names, data sort and filter pop-up widget can be activated. This widget allows for the alphabetical sorting of data and the application of conditions to filter data accordingly. Icons next to the column header indicate active sorting or filtering, and clicking the column header again lets you update or clear these parameters.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/sort_and_filter.png" alt="Sort and Filter by Column" width="400"/>
</p>

## Actions

### Save

### GitHub Controls

### Make a Release

### Publish PURL

### Export CAS Json

### Export to AnnData

## Views