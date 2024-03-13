# TDT Quick Start Guide

Welcome to the Taxonomy Development Tools User Interface Guide. This document is designed to provide comprehensive details on navigating and utilizing the TDT interface efficiently. Whether you are looking to manage data tables, edit information, or leverage advanced features, this quick start guide will guide you through the set up of TDT

1. [Install requirements](https://brain-bican.github.io/taxonomy-development-tools/Build/):
    - [Install GitHub](https://github.com/brain-bican/taxonomy-development-tools/blob/main/docs/Build.md#git)
    - [Install Docker](https://www.docker.com/products/docker-desktop/)

2. Git clone one of the reference projects: 
    - [human-brain-cell-atlas_v1_neurons](https://github.com/brain-bican/human-brain-cell-atlas_v1_neurons)
    - [human-brain-cell-atlas_v1_non-neuronal](https://github.com/brain-bican/human-brain-cell-atlas_v1_non-neuronal)
    - [nhp_basal_ganglia_taxonomy](https://github.com/hkir-dev/nhp_basal_ganglia_taxonomy)
   
   In this guide `nhp_basal_ganglia_taxonomy` is used:
   ```
    git clone https://github.com/hkir-dev/nhp_basal_ganglia_taxonomy.git
   ```
   
3. To run the Taxonomy Development Tools, navigate to the GitHub project folder you have just cloned:
    ```
    cd nhp_basal_ganglia_taxonomy
   ```
   
4. On the terminal, run Taxonomy Development Tools: 
 
    macOS and Linux:
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