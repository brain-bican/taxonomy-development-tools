# CCN2 Taxonomy Curation with the Taxonomy Development Tools

Place your data (ex. [AIT115_annotation_sheet_std.tsv](https://github.com/brain-bican/taxonomy-development-tools/blob/nanobot_rs/examples/human_m1/AIT115_annotation_sheet_std.tsv)) and configuration file (ex. [test_config.yaml](https://github.com/brain-bican/taxonomy-development-tools/blob/nanobot_rs/examples/human_m1/test_config.yaml)) into your project's `input_data` folder.  

Run following command to ingest your data files:
```
bash ./run.sh make build_nomenclature_tables
```

Then, run following command to run the online data editor:

```
bash ./run.sh make serve
```

This command will print a set of logs including a log like `nanobot::serve: listening on 0.0.0.0:3000`. This means your web editor is ready, and you can start editing your data.

Web editor url: http://localhost:3000/table


## Saving Edited Data

Once you complete your editing, you can run the following command to save your online edited data to your local: 

```
bash ./run.sh make save
```

Your data will be saved into `curation_tables` folder