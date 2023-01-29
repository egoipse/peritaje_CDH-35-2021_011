# Conversión de los DOT y DOCS a PDF

pacman::p_load(doconv, here, tidyverse)

ruta <- paste0(here("docs", "Causas"), "/")

file.rename(paste0(here("docs", "Causas", "dots"), "/" , list.files(here("docs", "Causas", "dots"), "dot")), 
            paste0(here("docs", "Causas", "dots"), "/" , str_replace_all(archivos, "\\.dot", "\\.doc")))

archivos <- list.files(here("docs", "Causas"), "doc")

for(archivo in archivos) to_pdf(paste0(ruta, archivo), output = paste0(ruta, str_extract(archivo, ".*(?=\\.doc+x?)"), ".pdf")) 

