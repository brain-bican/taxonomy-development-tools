# https://github.com/AllenInstitute/CCN/
# if(!require(renv)){
#     install.packages("renv")
#     renv::init()
# }

# see Dockerfile binary package installations
# install.packages("remotes", dependencies = TRUE)
# install.packages("jsonlite", dependencies = TRUE)
# install.packages("data.table", dependencies = TRUE)
# install.packages("ggplot2", dependencies = TRUE)
# install.packages("dendextend", dependencies = TRUE)
# install.packages("dplyr", dependencies = TRUE)
# install.packages("BiocManager", dependencies = TRUE)
# # install.packages("devtools", dependencies = TRUE)
# install.packages("knitr", dependencies = TRUE)
# install.packages("httr", dependencies = TRUE)
BiocManager::install("rols", update=FALSE)
remotes::install_github("AllenInstitute/CCN", build_vignettes = TRUE)

print("install_packages.R completed...")