#!/usr/bin/env python3
import os

from nanobot import run


if __name__ == '__main__':
    # os.chdir("../..")
    print(os.getcwd())
    run(
        "build/demo.db",
        os.getcwd() + "/curation_tables/table.tsv",
        base_ontology="demo",
        cgi_path="/ODD/branches/fix-1/views/run.py",
        #default_params={"view": "tree"},
        default_table="table",
        hide_index=True,
        import_table="import",
        max_children=100,
        title="OntoDev Demo",
        tree_predicates=[
            "rdfs:label",
            "IAO:0000111",
            "IAO:0000114",
            "IAO:0000118",
            "OBI:0001847",
            "OBI:9991118",
            "IAO:0000115",
            "IAO:0000119",
            "IAO:0000112",
            "IAO:0000117",
            "IAO:0000116",
            "IAO:0000232",
            "IAO:0000234",
            "IAO:0000233",
            "rdf:type",
            "owl:equivalentClass",
            "rdfs:subClassOf",
            "owl:disjointWith",
            "*"
        ],
        flask_host="0.0.0.0",
        flask_port="5555",
    )
