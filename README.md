__*Note:  This is a specialized pre-configured version of the Taxonomy Development Tools (TDT) for testing purposes. For the general-purpose version, please refer to the [original repository](https://github.com/brain-bican/taxonomy-development-tools). *__

# How to Test TDT

1. **Build the Test Docker Image**    
Buils the pre-configured docker image using the following command
```
docker build --no-cache -t "ghcr.io/brain-bican/taxonomy-development-tools:tester" .
```

2. **Clone the Test Taxonomy Repository**   
Download the test taxonomy from GitHub:
```
git clone https://github.com/bicantester/human-brain-cell-atlas_v1_neurons.git
```

3. **Launch TDT**  
Navigate to the repository directory and start TDT:
```
cd human-brain-cell-atlas_v1_neurons
bash ./run.sh make serve
```

4. **Verify Server Execution**   
Upon successful execution, you should observe a log stating `listening on 0.0.0.0:3000` in the terminal and then be able to browse TDT from [http://localhost:3000/table](http://localhost:3000/table)

5. **Learn More About the User Interface**   
For detailed information on the TDT user interface, please see the [User Interface Guide](https://brain-bican.github.io/taxonomy-development-tools/UserInterface/).


# Taxonomy Development Tools

The Taxonomy Development Tools (TDT) is a taxonomy management tool for building, curating and publishing BICAN taxonomies in a collaborative fashion. 
TDT is a graphical editor that converts informal taxonomies used within BICAN into a standardised structure following the [Cell Annotation Schema](https://github.com/cellannotation/cell-annotation-schema) (CAS) with up to date links to the AnnData files associated to the datasets in the taxonomy. TDT gives you the opportunity to customise taxonomies by including both the CAS structure and additional fields defined by the authors of the taxonomy. TDT allows you to work collaboratively  across users to manage taxonomies thanks to the use of the GitHub platform to support concurrent editing and keep the taxonomy synchronised. 

With TDT you can:

- Create a repository to manage your taxonomies.
- Convert your data to Cell Annotation Schema representation.
- Run interactive web editors to curate your data with ontology search and data validation support.

# Where to get help

- To install and launch existing taxonomy use the [Quick Start TDT](https://brain-bican.github.io/taxonomy-development-tools/QuickStart/) 
- To have an overview of Taxonomy Development read the [Intro to TDT](https://brain-bican.github.io/taxonomy-development-tools/Intro_to_TDT/)
- For a more detailed guide to set up have a look at the [Get Your System Ready](https://brain-bican.github.io/taxonomy-development-tools/Build/) documentation.
- To create a repository for a new taxonomy have a look at the [New repository](https://brain-bican.github.io/taxonomy-development-tools/NewRepo/) documentation.
- To review an existing informal taxonomy follow the [Curation](https://brain-bican.github.io/taxonomy-development-tools/Curation/) documentation.
- To learn how to use the user interface follow the [UI guide](https://brain-bican.github.io/taxonomy-development-tools/UserInterface/).
- To use the latest version of TDT read the [Update](https://brain-bican.github.io/taxonomy-development-tools/Update/) documentation. 

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/table_AITT.png" alt="Taxonomy Editor" width="700"/>
</p>
