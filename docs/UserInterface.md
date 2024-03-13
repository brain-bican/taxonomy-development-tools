# Taxonomy Development Tools User Interface Guide

Welcome to the Taxonomy Development Tools User Interface Guide. This document is designed to provide comprehensive details on navigating and utilizing the TDT interface efficiently. Whether you are looking to manage data tables, edit information, or leverage advanced features, this guide will assist you in making the most out of TDT.

## Tables

At the heart of the Taxonomy Development Tools is a robust internal database designed to streamline the management and curation of taxonomy-related data. Access to this database is facilitated through a user-friendly interface, with tables being a central component.

To view the available tables,  navigate to the Tables dropdown menu at the top of the interface.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/table_dropdownmenu.png" alt="Select a table" width="900"/>
</p>

TDT categorizes tables into two main types, **switch system tables** and **user tables**, each serving distinct purposes:

### Switch system tables:
these tables are essential for the internal configuration of the TDT and cannot be modified by the users.

- `table`: this table lists all the tables present in the TDT and it appears in the default page of the TDT

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/table_AITT.png" alt="Select a table" width="900"/>
</p>

- `datatype` : this table shows all the datatype columns present in each table.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/datatype_table_AITT.png" alt="Sort and filter by column" width="900"/>
</p>

- `column`: this table contains all the columns present in each table.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/column_table_AITT.png" alt="Sort and filter by column" width="900"/>
</p>

- `message`: this table contains all the messages present one very row of each table.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/message_table_AITT.png" alt="Sort and filter by colummn" width = "900"/>
</p>

### User tables

User tables are created when data is uploaded to the TDT using the `load_data` operation (https://brain-bican.github.io/taxonomy-development-tools/Curation/). This data is formatted according to the [Cell Annotation Schema](https://github.com/cellannotation/cell-annotation-schema) and organized into multiple interrelated tables. 

> Example: the [nhp_basal_ganglia_taxonomy](https://github.com/hkir-dev/nhp_basal_ganglia_taxonomy) present an annotation table named `AIT115_annotation_sheet` from this table a series of `user tables` are generated and displayed in the TDT.


The user tables are the following: 

- `original data table` : This table is provided by the author and contains their original annotations.

> Exp. AIT115_annotation_sheet



- `*_metadata`: This table contains all the medatadata related to the taxonomy. For full specifications of the metadata properties, look up the cell annotation schema documentation under the section [properties](https://github.com/cellannotation/cell-annotation-schema/blob/main/build/BICAN_schema.md#properties). The `*_metadata` column names are explained below:

`author name` : the name of the first author of the taxonomy.
`author contact` : author's email.
`author list`: name of secondary authors.
`matrix file ID`: a resolvable ID for a cell by gene matrix file. 
`cellannotation schema version`: the version of the cell annotation schema. 
`cellannotation timestamp`: the time (yyyy-mm-dd) of when the cell annotations are published.
`cellannotation url`: a URL where all cell annotations are published for each dataset.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/AIT115_annotation_sheet_metadata.png" alt="Sort and filter by colummn" width = "900"/>
</p>




- `*_labelset`: This table contains the definition of the labels used in the annotation and the methodology used to acquire those labels. Full specifications of the label set can be found in the Cell annotation schema documentation under the [labelsets](https://github.com/cellannotation/cell-annotation-schema/blob/main/build/BICAN_schema.md#properties) section. 
`name` : the name of the type of annotation key
`description` : description of the annotation key
`rank` : the level of granularity of the annotation with 0 being the most specific 
`annotation method` : the method used for the type of annotation, it can either be algorithmic, manual or both 
`automated annotation algorithm name` : the name of the algorithm used for the automated annotation 
`automated annotation algorithm verision` : the version used for the algorithm 
`automated annotation algorithm repo url` : a resolvable URL of the version control of the algorithm used.
`automated annotation reference location` : a resolvable URL of the source of the data. 
	
<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/AIT115_annotation_sheet_labelset.png" alt = "Sort and filter by column" width = "900"/>
</p>




- `*_annotation`: Stores annotations for cell types, classes, or states, along with supporting evidence and provenance information. It is designed to be flexible, allowing for additional fields to accommodate user needs or project-specific metadata. Further information on the annotation columns can be found in the Cell annotation schema documentation under the [annotations](https://github.com/cellannotation/cell-annotation-schema/blob/main/build/BICAN_schema.md) section.

`cell set accession` : an identifier that can be used to consistently refer to the set of cells being annotated, even if the cell_label changes.
`cell label` : the cell annotation provided by the author.
`cell fullname` : the full-length term of the annotated cell set. 
`parent cell set accession` : similar to the `cell set accession`, this is the term for a set of cells on step higher than the cells in the row in the hierarchical classification.
`labelset` : the type of cell annotation from the AnnData/Seurat file.
`cell ontology term id` : the ontology term ID that define the cell type. I has to be the closest term matching the `cell label` 
`cell ontology term` : the ontology term name from the ontology term ID
`rationale` : The short name of the publications used to define the `cell ontology term`.
`rationale dois` : The DOI of the paper mentioned in the `rationale`
`maker gene evidence` : List of names of genes whose expression in the cells being annotated is explicitly used as evidence for this cell annotation. Each gene MUST be included in the matrix of the AnnData/Seurat file.
`synonyms` : synonyms of the `cell label`



<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/AIT115_annotation_sheet_annotation.png" alt = "Sort and filter by column" width = "900"/>
</p>




- `*_annotation_transfer`: Tracks annotation transfer records. **I need some help for this part** @dosumis maybe we could discuss about it.
For detailed information on table structures and fields, refer to the Cell Annotation Schema [documentation](https://github.com/cellannotation/cell-annotation-schema/blob/main/build/BICAN_schema.md).


<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/AIT115_annotation_sheet_annotation_transfer.png" alt = "Sort and filter by column" width = "900"/>
</p>




## Table Management

This section shows how to interact with the Tables within the TDT. In this documentation, the overview of the table management is shown with the `*_annotation` table.

### Change Table Format

The table format can be changed by selecting the `Format` button underneath the table name. This will open a dropdown menu with a series of options to display the data in different format of a `TSV` or a `CSV` table; `Plain Text` or in a `Json` raw or page format (for more information about Json format have a look at [additional resources](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Objects/JSON)). In addition to the `Json` raw or page option, the options `Json(raw, pretty)` and `Json(page, pretty)` are available to display the data in a Json format that is easier to read. 

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/table_format_AITT.png" alt = "Select dropdown menu" width = "900"/>
</p>


### Sorting and Filtering Data

By clicking on column names, data sort and filter pop-up widget can be activated. This widget allows for the alphabetical sorting of data and the application of conditions to filter data accordingly. Icons next to the column header indicate active sorting or filtering, and clicking the column header again lets you update or clear these parameters. 

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/sort_and_filter.png" alt = "Sort and filter" width = "500" />
</p>

### Reset Table

To reset the sorting and filtering of the table select the `Reset` button underneath the table name.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/reset_button.png" alt = "Select reset button to reset the table order" width = "900"/>
</p>

### Change Table View

Annotation tables are equipped to display data in a hierarchical structure, offering a more intuitive understanding of relationships within the taxonomy. To access this perspective, simply click on the `Taxonomy View` button.
<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/tree_view.png" alt="Sort and Filter by Column" width="500"/>
</p>

While in the Taxonomy View, users can visually explore the taxonomy's structure in a read-only format, providing a clear overview of the hierarchical relationships. To switch back to a more detailed and interactive tabular format, click the `Table View` button.


### Adding New Records

`Add row` button can be used to add new records to the table. By selecting `Add row`, a new page will open, start inserting the informations for the new row. The option `cell set accession` will be auto-filled with a new cell set unique identifier.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/add_row2.png" alt="Edit Form" width="400"/>
</p>

To know what each option represents, over on the question mark icon near each option. 

> Picture needs to be added once the new release is out

Some options will have a dropdown menu with suggested terms. For instance, by selecting the empty box for the `labelset` option the dropdown options `Class`, `Cluster`, `Neighborhood`, `Subclass` will appear. 

To add a pre-existing [Cell Ontology](https://www.ebi.ac.uk/ols4) term select the `cell ontology term` option and start typing the cell term of interest. A dropdown menu will appear with different options for pre-existing ontology terms.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/cell_ontology_term_dropdown_menu.png" alt="Select cell ontology term" width="400"/>
</p>
After selecting the cell ontology term of interest, the `cell ontology term` option and the `cell ontology term ID` will be autofilled. 
<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/cell_ontology_term_ID.png" alt="Select cell ontology term" width="400"/>
</p>
 

### Editing Existing Data

Users can initiate the editing of records by clicking on the pen icon located at the start of each row. This action directs them to a data submission form that supports auto-completion, allowing for efficient data entry. After validating the entered data, users can finalize their edits by clicking the Submit button.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/edit_form.png" alt="Edit Form" width="600"/>
</p>


### Saving existing or new data

To save the modified or newly added row select `Submit` at the bottom right corner of the page. 
The `Validate` option will ensure that the terms added in each column follow the [Cell Annotation Schema](https://github.com/cellannotation/cell-annotation-schema)

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/submit_button.png" alt="Select option" width="400"/>
</p>



## Actions

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/actions.png" alt="Sort and Filter by Column" width="300"/>
</p>

### Save

All user modifications are automatically saved to the internal database. However, if user wants to save changes back to the source tsv files located in the project `curation_tables/` folder, `save` action can be utilized.

### Version Control with GitHub

The `Version Control` feature enables users to seamlessly perform GitHub operations directly from our interface. Before you can leverage these capabilities, it's essential to configure your environment by setting the `GH_TOKEN` variable. This step is critical for authentication and authorization purposes. For a comprehensive guide on setting up your environment, please refer to our [prerequisites installation guide](https://github.com/brain-bican/taxonomy-development-tools/blob/main/docs/Build.md#git). 

Details to be added

### Make a Release

The `Release` action facilitates the creation of a new GitHub release for the taxonomy project. This feature is part of our broader `Version Control` toolkit and requires the `GH_TOKEN` environment variable to be set for operation. For detailed instructions on how to configure this, please visit our [prerequisites installation guide](https://github.com/brain-bican/taxonomy-development-tools/blob/main/docs/Build.md#git).

When initiating a release, the action will prompt you for a release tag. The current date is the default value for this tag, but you can specify your own. It's important to ensure that your tag is valid and adheres to GitHub's naming conventions. Avoid using disallowed characters such as spaces ( ), carriage returns (\r), new lines (\n), tildes (~), carets (^), colons (:), double quotes ("), question marks (?), brackets ([), and asterisks (*). For more information on creating well-formed tags, please consult the [Git documentation on reference formats](https://git-scm.com/docs/git-check-ref-format). 

Upon successful creation of a release, you will be notified of the new release's URL, allowing you to easily share or promote your latest version.

### Publish PURL

A Permanent URL (PURL) provides a stable link that always directs users to the same digital content. The `Publish PURL` allows you to generate a PURL for the current taxonomy version, ensuring consistent access to it. For instance, a taxonomy might be accessible through a PURL like:

> https://purl.brain-bican.org/taxonomy/CCN202210140/CS202210140_neurons.json --> redirects to --> https://raw.githubusercontent.com/brain-bican/human-brain-cell-atlas_v1_neurons/main/CS202210140.json

Create a PURL once you deem the taxonomy mature enough for community sharing. This process will generate a PURL configuration file and initiate a pull request to the [purl.brain-bican.org repository](https://github.com/brain-bican/purl.brain-bican.org).

Note: This step requires a fork of the [purl.brain-bican.org](https://github.com/brain-bican/purl.brain-bican.org) repository in case you lack write access. Please ensure any existing forks are removed to avoid conflicts. The system will alert you if an existing fork is detected.
### Export CAS Json

This action converts all data into a JSON file formatted according to the [Cell Annotation Schema](https://github.com/cellannotation/cell-annotation-schema) located in the project's root directory.

### Export to AnnData

Apply your modifications directly to the associated AnnData file for the taxonomy.

The `*_metadata` table contains a `matrix_file_id` column, representing a resolvable ID for a cell-by-gene matrix file, formatted as `namespace:accession`. For example, `CellXGene_dataset:8e10f1c4-8e98-41e5-b65f-8cd89a887122` (Please refer to the [cell-annotation-schema registry](https://github.com/cellannotation/cell-annotation-schema/blob/main/registry/registry.json) for a list of supported namespaces.)

WUpon initial launch, TDT creates a `tdt_datasets` directory in the user home folder. It attempts to resolve all matrix_file_id references within this directory. The system searches for the corresponding file (e.g., `$HOME/tdt_datasets/8e10f1c4-8e98-41e5-b65f-8cd89a887122.h5ad`) and then initiates a [cas-tools flatten operation](https://github.com/cellannotation/cas-tools/blob/main/docs/cli.md#flatten-onto-anndata). This process, which may vary in duration depending on the taxonomy's size, results in a new AnnData file (`/tdt_datasets/$$TAXONOMY_ID$$.h5ad`) incorporating the user's annotations.

