# CCN2 Taxonomy Curation with the Taxonomy Development Tools

1- Pull the latest TDT docker image via following the steps defined in the project [GitHub Container Registry](https://github.com/brain-bican/taxonomy-development-tools/pkgs/container/taxonomy-development-tools). 
```
docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest
```

2- Place your data (ex. [AIT115_annotation_sheet.tsv](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/AIT115_annotation_sheet.tsv)) and configuration file (ex. [test_config.yaml](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/ingestion_config.yaml)) into your project's `input_data` folder.  

3- Run following command to ingest your data files:
```
bash ./run.sh make load_data
```

4- Run following command to run the online data editor:
```
bash ./run.sh make serve
```

This command will print a set of logs including a log like `nanobot::serve: listening on 0.0.0.0:3000`. This means your web editor is ready, and you can start editing your data.

5- You can start browsing web taxonomy editor from: [http://localhost:3000/table](http://localhost:3000/table)

## Saving Edited Data

Once you complete your editing, you can run the following command to save your online edited data to your local: 

```
bash ./run.sh make save
```

Your data will be saved into `curation_tables` folder