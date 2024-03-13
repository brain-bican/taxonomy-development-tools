# Seed your taxonomy from a spreadsheet

1. Pull the latest TDT docker image via following the steps defined in the project [GitHub Container Registry](https://github.com/brain-bican/taxonomy-development-tools/pkgs/container/taxonomy-development-tools): `docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest`
1. Follow [instructions here](config.md#configure-seeding-a-new-taxonomy-from-an-existing-informal-taxonomy) to prepare your ingest config file
1. Save config file and informal spreadsheet taxonomy (as tsv) into your project's `input_data` folder.  (ex. [AIT115_annotation_sheet.tsv](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/AIT115_annotation_sheet.tsv)) and configuration file (ex. [test_config.yaml](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/ingestion_config.yaml))  
1. In the project root folder, run following command to ingest your data files:
```
bash ./run.sh make load_data
```
> For Windows: 
> ```
> run.bat make load_data
> ```
5. Launch TDT:
```
bash ./run.sh make serve
```
> For Windows: 
> ```
> run.bat make serve
> ```
This command will print a set of logs including a log like `nanobot::serve: listening on 0.0.0.0:3000`. This means your web editor is ready, and you can start editing your data.
6.  You can start browsing web taxonomy editor from: [http://localhost:3000/table](http://localhost:3000/table)



