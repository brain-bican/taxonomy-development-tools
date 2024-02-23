# TDT Quick Start Guide

1. [Install requirements](https://brain-bican.github.io/taxonomy-development-tools/Build/) (Docker and Git)
2. Git clone one of the reference projects:
    - [human-brain-cell-atlas_v1_neurons](https://github.com/brain-bican/human-brain-cell-atlas_v1_neurons)
    - [human-brain-cell-atlas_v1_non-neuronal](https://github.com/brain-bican/human-brain-cell-atlas_v1_non-neuronal)
    - [nhp_basal_ganglia_taxonomy](https://github.com/hkir-dev/nhp_basal_ganglia_taxonomy)
   
   In this guide `nhp_basal_ganglia_taxonomy` is used:
   ```
    git clone https://github.com/hkir-dev/nhp_basal_ganglia_taxonomy.git
   ```
3. Navigate to the project folder:
    ```
    cd nhp_basal_ganglia_taxonomy
   ```
4. Run Taxonomy Development Tools:
    MacOS and Linux:
    ```
    bash ./run.sh make serve
    ```
    
    Windows: 
    ```
    run.bat make serve
    ```
5. Upon successful execution, you should observe a log stating `listening on 0.0.0.0:3000` in the terminal and then be able to browse TDT from http://localhost:3000/table
6. Details of the TDT user interface can be found at [user interface](https://brain-bican.github.io/taxonomy-development-tools/UserInterface/) guide.

To create and curate your own taxonomy please follow [create your first repository](https://brain-bican.github.io/taxonomy-development-tools/NewRepo/) guide.