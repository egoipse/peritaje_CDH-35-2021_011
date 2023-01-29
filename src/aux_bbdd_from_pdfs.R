# BBDD a partir de pdfs

pacman::p_load(openxlsx, stopwords, pdftools, here, tidyverse)

original <- read.xlsx(here("data", "Resoluciones DDHH CS S. Interamericano KA+CC.xlsx"),
                      sep.names = "_", detectDates = T) |> 
  rename_with(~tolower(.x)) |> 
  rename_with(~gsub("/", "_", .x)) |> 
  rename(caso = 1) |> 
  filter(!is.na(caso)) |> 
  mutate(caso = as.character(caso))

ruta <- paste0(here("docs", "Causas"), "/")

archivos <- list.files(ruta, "\\.pdf")

datos <- data.frame(archivo = archivos,
                    caso = str_extract_all(archivos, "^\\d+(?=(\\.)?(\\s)?)", simplify = T),
                    descripcion = str_remove_all(str_remove_all(archivos, "^\\d+(\\.)?(\\s)?"), "\\.pdf")
                    ) |> 
  mutate(caso = case_when(grepl("^[[:alpha:]]\\.", descripcion) ~ paste0(caso, ".", str_extract(descripcion, "^[[:alpha:]]\\.")),
                          TRUE ~ caso),
         descripcion = str_remove_all(str_remove_all(descripcion, "^[[:alpha:]]\\."), "\\."),
         rol = str_replace_all(as.character(str_extract_all(descripcion, "\\d+\\s?(-|_)\\s?\\d+", simplify = T )), "_", "-"),
         descripcion = tolower(str_trim(
           str_replace_all(str_remove_all(descripcion, "^\\_?\\s?\\-?\\d+\\s?(-|_)\\s?\\d+\\_?\\s?"), "(-|_)", " "),
           "both")),
         across(c(descripcion, rol), ~case_when(.x == "" ~ NA_character_, TRUE ~ .x)),
         texto = str_replace_all(I(map(archivos, function(x) {
           unlist(map(paste0(ruta, x), pdf_text)) |> 
             str_squish()  |> 
             str_c(collapse = " ")
         })) |> 
           unlist(), "(VISTO+S?)|(V I S T O S)", "Vistos"),
         agno = as.character(str_extract_all(str_extract_all(texto, "(?<=Santiago, )(.*)", simplify = T), "(?<=dos mil )(.*)(?=(\\. )+(Vistos|En cumplimiento|Conforme)+)")),
         agno = case_when(agno == "character(0)" ~ as.character(str_extract_all(str_extract_all(texto, "(?<=En Santiago, )(.*)", simplify = T), "(?<=dos mil )(.*)(?=, notifiqué)")),
                          TRUE ~ agno),
         agno = case_when(grepl("^cuatro", agno, ignore.case = T) ~ "2004",
                          grepl("^cinco", agno, ignore.case = T) ~ "2005",
                          grepl("^seis", agno, ignore.case = T) ~ "2006",
                          grepl("^siete", agno, ignore.case = T) ~ "2007",
                          grepl("^ocho", agno, ignore.case = T) ~ "2008",
                          grepl("^nueve", agno, ignore.case = T) ~ "2009",
                          grepl("^diez", agno, ignore.case = T) ~ "2010",
                          grepl("^once", agno, ignore.case = T) ~ "2011",
                          grepl("^doce", agno, ignore.case = T) ~ "2012",
                          grepl("^trece", agno, ignore.case = T) ~ "2013",
                          grepl("^catorce", agno, ignore.case = T) ~ "2014",
                          grepl("^quince", agno, ignore.case = T) ~ "2015",
                          grepl("^diecis(é|e)is", agno, ignore.case = T) ~ "2016",
                          grepl("^diecisiete", agno, ignore.case = T) ~ "2017",
                          grepl("^dieciocho", agno, ignore.case = T) ~ "2018",
                          grepl("^diecinueve", agno, ignore.case = T) ~ "2019",
                          agno == "character(0)" ~ NA_character_,
                          TRUE ~ as.character(agno)),
         texto = str_remove_all(texto,"(^([\\S\\s]+)?(?=((Visto+s?)|(VISTO+S?)|(V I S T O S))+(:| )+))|(^Versión(.*)Chile)|(\\d+ (Ene|Feb|Mar|Abr|May|Jun|Jul|Ago|Sep|Oct|Nov|Dic) \\d{4} \\d{1,2}:\\d{2}:\\d{2})|(\\d{1,2}\\/\\d{1,2})|(© Copyright \\d{4}, vLex\\. )"), 
         rol = case_when(is.na(rol) ~
                           as.character(str_extract_all(texto, "(?<=Redacción)(\\d+\\s?(-|_)\\s?\\d+)(?=Pronunciado)")),
                         TRUE ~ as.character(rol)),
         antecedentes = str_trim(as.character(str_extract_all(texto, "(?<=Vistos(:| ))(.*)(?=(CONSIDERANDO|Considerando|C O N S I D E R A N D O)+:+)", simplify = T)), "both"),
         motivo = case_when(grepl("casaci(ó|o)|reemplazo|invalida|anula|rectifica", descripcion, ignore.case = T) ~ descripcion),
         motivo = as.character(str_extract_all(motivo,
                                  "casación|rectificación|invalidación|anulación|(fallo|sentencia) (de )?reemplazo|invalida de oficio",
                                  simplify = T)),
         motivo = case_when(motivo %in% c("sentencia reemplazo", "fallo reemplazo", "fallo de reemplazo" )~ "sentencia de reemplazo" ,
                            motivo %in% c("", "character(0)") ~ NA_character_,
                            TRUE ~ motivo),
         rol_jerarquia_anterior = str_trim(as.character(str_extract_all(antecedentes, "\\d+\\.?\\d*\\s?(-|_)\\s?\\d+")), "both"),
         across(contains("rol"), ~case_when(.x == "character(0)" ~ NA_character_, TRUE ~ .x)),
         media_prescripcion = case_when(grepl("((M|m)edia (P|p)rescripci(o|ó)n)|((P|p)rescripci(o|ó)n (G|g)radual)|((P|p)rescripci(o|ó)n (I|i)mcompleta)|(art+\\.?(í|i)culo?\\s+103+)", texto) ~ "1", TRUE ~ "0"),
         aplica_media_prescr = NA,
         resultado = NA,
         impunidad = NA,
         # tokens = str_squish(str_remove_all(str_trim(str_replace_all(tolower(str_remove_all(texto, "(?!\\s)\\W|\\d")), "\\n", " "), "both"),
         #                     str_c("\\b", str_c(stops, collapse ="\\b|\\b"), "\\b")))
         # rol = case_when(is.na(rol) ~ str_extract(texto, "(?<=(R|r)(OL|ol))(.*)(?=\\n|\\.)"),
           #              TRUE ~ rol),
         ) |> 
  select(archivo, caso, descripcion, rol_jerarquia_anterior, rol, motivo, media_prescripcion, aplica_media_prescr, resultado, impunidad, agno, texto) |> 
  group_by(caso) |> 
  nest() |> 
  full_join(original, by = "caso") |>
  mutate(data = map(data, function(x) {
    if(any(is.na(x$rol)) & any(!is.na(x$rol)))
      x$rol <- x$rol[which(!is.na(x$rol))[1]]
    if(any(is.na(x$rol_jerarquia_anterior)) & any(!is.na(x$rol_jerarquia_anterior)))
      x$rol_jerarquia_anterior <- x$rol_jerarquia_anterior[which(!is.na(x$rol_jerarquia_anterior))[1]]
    return(x)
  })) |> 
  unnest(c(data)) |> 
  ungroup() |> 
  mutate(rol = case_when(is.na(rol) ~ rol_cs, TRUE ~ rol))

for(i in 2:(NROW(datos)-1)) {
  
  if(is.na(datos$agno[i]) & datos$agno[i-1] == datos$agno[i+1]) {
    datos$agno[i] <- datos$agno[i-1]
  }
  
}

datos$agno[which(is.na(datos$agno))] <- "2007"

save(datos, file = here("data", "x_escrito.RData"))

write.xlsx(datos |> select(-c(texto)), here("data", "x_escrito.xlsx"))

