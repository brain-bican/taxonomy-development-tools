# $$TAXONOMY_NAME$$ ($$TAXONOMY_ID$$)

$$TAXONOMY_DESCRIPTION$$

Curate your taxonomy in 3 simple steps:

1. [Get Taxonomy Development Tools](#get-taxonomy-development-tools)  
1. [Load your data](#load-your-data)  
1. [Browse](#browse)  

## Get Taxonomy Development Tools 

Pull the latest TDT docker image via following the steps defined in the project [GitHub Container Registry](https://github.com/brain-bican/taxonomy-development-tools/pkgs/container/taxonomy-development-tools). 

```
docker pull ghcr.io/brain-bican/taxonomy-development-tools:latest
```

## Load your data

Place your data (ex. [AIT115_annotation_sheet.tsv](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/AIT115_annotation_sheet.tsv)) and configuration file (ex. [ingestion_config.yaml](https://github.com/brain-bican/taxonomy-development-tools/tree/main/examples/nhp_basal_ganglia/ingestion_config.yaml)) into your project's `input_data` folder.  

Run following command in your project root folder to ingest your data files:

```
bash ./run.sh make load_data
```

## Browse

Run following command in your project root folder to run the online data editor:
```
bash ./run.sh make serve
```

This command will print a set of logs including a log like `nanobot::serve: listening on 0.0.0.0:3000`. This means your web editor is ready, and you can start editing your data.

You can start browsing web taxonomy editor from: [http://localhost:3000/table](http://localhost:3000/table)

_For further details see [Taxonomy Development Tools Documentation](https://brain-bican.github.io/taxonomy-development-tools/)_