
WORKSPACE=/tools

build_nomenclature_tables:
	Rscript $(WORKSPACE)/dendR/nomenclature_builder.R

runR:
	Rscript dendR/nomenclature_builder.R


include ontodev.Makefile