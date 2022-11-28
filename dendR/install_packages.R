# https://github.com/AllenInstitute/CCN/
if(!require(renv)){
    install.packages("renv")
    renv::init()
}

install.packages("remotes")
install.packages("jsonlite")
install.packages("data.table")
install.packages("ggplot2")
install.packages("dendextend")
install.packages("dplyr")
install.packages("BiocManager")
install.packages("BiocManager")
BiocManager::install("rols", update=FALSE)
remotes::install_github("AllenInstitute/CCN", build_vignettes = TRUE)