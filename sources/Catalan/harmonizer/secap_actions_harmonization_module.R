# setwd("C:/Users/glagu/Nextcloud/L-Gerard/ePLANET local/Girona - Lectura dades")
setwd("E:/Nextcloud/L-Gerard/ePLANET local/Girona - Lectura dades")
library("readxl")
library("writexl")



########################## FUNCTIONS ##########################

read_mit <- function(path_file) {
  files <- list.files(path = path_file, pattern = ".xlsx")
  files <- files[grepl(pattern = "^Lagu", x = files)]
  
  accio_mit <- {}
  for (x in files) {
    # x <- files[1]
    sheets <- excel_sheets(paste0(path_file, x))
    sheets_mit <- sheets[grepl(pattern = "_mitigació", x = sheets) & !grepl(pattern = "_NO", x = sheets)]
    sheets_mit <- sheets_mit[!grepl(pattern = "Template_", x = sheets_mit)]
    for (s in sheets_mit) {
      # s <- sheets_mit[1]
      sheet <- read_excel(path = paste0(path_file, x), sheet = s)
      accio_mit <- rbind(accio_mit, data.frame(
        #Obligatori
        "ID Proyecto" = sheet$`ID Projecte`,
        "Tipologia" = sheet$`Típologia pla`,
        "Nom del pla" = sheet$`Nom del pla`,
        "ID mesura" = sheet$`ID mesura`,
        "Titol de la mesura" = sheet$`Títol de la mesura`,
        "Sector" = sheet$Sector,
        "Area d'intervencio" = sheet$`Área d'intervenció`,
        "Categoria de l'ambit" = sheet$`Categoria de l'àmbit`,
        "Descripcio" = sheet$Descripció,
        "Responsable" = sheet$Responsable,#"Irresponsable_1",
        #Info adicional
        "Estalvi energètic total [MWh]" = sheet$`Estalvi energètic total [MWh]`,
        "Producció d'energia renovable [MWh]" = sheet$`Producció d'energia renovable [MWh]`,
        "Emissions evitades [tCO2]" = sheet$`Emissions evitades [tCO2]`,
        "Cost [€]" = sheet$`Cost [€]`,
        "Estalvi anual [€]" = sheet$`Estalvi anual [€]`,
        "Any inici" = sheet$`Any inici`,
        "Any fi" = sheet$`Any fi`,
        "Instrument" = sheet$Instrument,
        "Origen de l'accio" = sheet$`Origen de l'acció`,
        "Estat d'execucio" = sheet$`Estat ejecució (%)`
      ))
      
      
    }
    # read_excel(path = paste0("SECAPS/ARDA/", x), sheet = )
    # sheets_ada <- sheets[grepl(pattern = "_adaptació", x = sheets)]
  }
  return(accio_mit)
}


read_adap <- function(path_file) {
  files <- list.files(path = path_file, pattern = ".xlsx")
  files <- files[grepl(pattern = "^Lagu", x = files)]
  
  accio_ada <- {}
  for (x in files) {
    # x <- files[1]
    sheets <- excel_sheets(paste0(path_file, x))
    sheets_ada <- sheets[grepl(pattern = "_adaptació", x = sheets) & !grepl(pattern = "_NO", x = sheets)]
    sheets_ada <- sheets_ada[!grepl(pattern = "Template_", x = sheets_ada)]
    for (s in sheets_ada) {
      # s <- sheets_ada[1]
      sheet <- read_excel(path = paste0(path_file, x), sheet = s)
      accio_ada <- rbind(accio_ada, data.frame(
        #Obligatori
        "ID Proyecto" = sheet$`ID Projecte`,
        "Tipologia" = sheet$`Típologia pla`,
        "Nom del pla" = sheet$`Nom del pla`,
        "ID mesura" = sheet$`ID mesura`,
        "Titol de la mesura" = sheet$`Títol de la mesura`,
        "Sector" = sheet$Sector,
        "Registre climatic" = sheet$`Registre climàtic`,
        "Descripcio" = sheet$Descripció,
        "Responsable" = sheet$Responsable,#"Irresponsable_1",
        #Info adicional
        "Estalvi energètic total [kWh]" = sheet$`Estalvi energètic total [kWh]`,
        "Producció d'energia renovable [kWh]" = sheet$`Producció d'energia renovable [kWh]`,
        "Emissions evitades [tCO2]" = sheet$`Emissions evitades [tCO2]`,
        "Cost [€]" = sheet$`Cost [€]`,
        "Estalvi anual [€]" = sheet$`Estalvi anual [€]`,
        "Any inici" = sheet$`Any inici`,
        "Any fi" = sheet$`Any fi`,
        "Afecta la mitigació (Si/No)" = sheet$`Afecta la mitigació (Si/No)`,
        "Estat d'execucio" = sheet$`Estat ejecució (%)`
      ))
    }
  }
  return(accio_ada)
}

mit_harm_Sector <- function(accions) {
  accions$Sector[accions$Sector == "10. Producció local de calor/fred"] <- "772 - Producció local de Calefacció/refrigeració"
  accions$Sector[accions$Sector == "03. Edificis  residencials"] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  accions$Sector[accions$Sector == "02. Edificis del sector terciari"] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  accions$Sector[accions$Sector == "09. Producció local d'energia"] <- "773 - Producció local d’electricitat"
  accions$Sector[accions$Sector == "07. Transport públic"] <- "774 - Transport"
  accions$Sector[accions$Sector == "08. Transport privat"] <- "774 - Transport"
  accions$Sector[accions$Sector == "11. Altres"] <- "771 - Altres"
  accions$Sector[accions$Sector == "01. Edificis municipals"] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  accions$Sector[accions$Sector == "04. Enllumenat públic"] <- "776 - Enllumenat públic"
  accions$Sector[accions$Sector == "09. Producció local d’energia"] <- "773 - Producció local d’electricitat"
  accions$Sector[accions$Sector == "09. Producció local d'electricitat"] <- "773 - Producció local d’electricitat"
  accions$Sector[accions$Sector == "06. Flota municipal"] <- "774 - Transport"
  accions$Sector[accions$Sector == "Producció local d’energia"] <- "773 - Producció local d’electricitat"
  accions$Sector[accions$Sector == "05. Indústria"] <- "775 - Industria"
  accions$Sector[accions$Sector == "Edificis municipals residencials i terciaris"] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  accions$Sector[accions$Sector == "Indústria"] <- "775 - Industria"
  accions$Sector[accions$Sector == "Transport"] <- "774 - Transport"
  accions$Sector[accions$Sector == "Producció local d'energia"] <- "773 - Producció local d’electricitat"
  accions$Sector[accions$Sector == "Residus"] <- "771 - Altres"
  accions$Sector[accions$Sector == "Enllumenat públic"] <- "776 - Enllumenat públic"
  accions$Sector[accions$Sector == "Calefacció i refrigeració locals"] <- "772 - Producció local de Calefacció/refrigeració"
  accions$Sector[accions$Sector == "Altres"] <- "771 - Altres"
  accions$Sector[accions$Sector == "Pobresa energètica"] <- "771 - Altres"
  accions$Sector[accions$Sector == "Edificis: municipals, residencials i terciaris"] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  accions$Sector[accions$Sector == "Transport municipal, públic i privat"] <- "774 - Transport"
  accions$Sector[accions$Sector == "A7_Altres"] <- "771 - Altres"
  accions$Sector[accions$Sector == "Pobresa_energètica"] <- "771 - Altres"
  accions$Sector[accions$Sector == "Edificis municipals, residencials i terciaris"] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  accions$Sector[accions$Sector == "A1 Edificis municipals, residencials i terciari"] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  accions$Sector[accions$Sector == "A4 Transport"] <- "774 - Transport"
  accions$Sector[accions$Sector == "A5 Producció local d'energia"] <- "773 - Producció local d’electricitat"
  accions$Sector[accions$Sector == "A7 Altres"] <- "771 - Altres"
  accions$Sector[accions$Sector == "A2 Enllumenat públic"] <- "776 - Enllumenat públic"
  accions$Sector[accions$Sector == "A6 Producció local de calor i fred"] <- "772 - Producció local de Calefacció/refrigeració"
  accions$Sector[accions$Sector == "A6 Calefacció/ Refrigeració generades localment"] <- "772 - Producció local de Calefacció/refrigeració"
  accions$Sector[accions$Sector == "A6 Calefacció/Refrigeració generades localment"] <- "772 - Producció local de Calefacció/refrigeració"
  accions$Sector[accions$Sector == "A6 Producció local de calor"] <- "772 - Producció local de Calefacció/refrigeració"
  accions$Sector[accions$Sector == "A6 Producció local de calor o fred"] <- "772 - Producció local de Calefacció/refrigeració"
  accions$Sector[accions$Sector == "A6 producció local de calor i fred"] <- "772 - Producció local de Calefacció/refrigeració"
  
  return(accions)
}

mit_harm_A.Intervencio <- function(accions) {
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "Gestió de residus i cicle de l'aigua"] <- "833 - Gestió de residus i aigües residuals"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "Altres"] <- "830 - Altres"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "Regeneració Urbana"] <- "834 - Regeneració urbana"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "Regeneració urbana"] <- "834 - Regeneració urbana"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "Agricultura i gestió forestal"] <- "831 - Relacionat amb l’agricultura i la silvicultura"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "Gestió de residus i aigües residual"] <- "833 - Gestió de residus i aigües residuals"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "A72 Gestió de residus i aigües residuals"] <- "833 - Gestió de residus i aigües residuals"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "Gestió de residus i aigües residuals"] <- "833 - Gestió de residus i aigües residuals"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "A16 Acció integrada (tot l'anterior)"] <- "830 - Altres"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "A75 Altres"] <- "830 - Altres"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "A75"] <- "830 - Altres"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "A72"] <- "833 - Gestió de residus i aigües residuals"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "A57 Altres"] <- "830 - Altres"
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" & accions$Area.d.intervencio == "A18 Modificació d'hàbits"] <- "830 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "Altres"] <- "826 - Altres"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "Xarxes de calor/fred (noves, reurbanitzacions, expansions)"] <- "827 - Xarxa de calefacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "Renovables per a climatització i aigua calenta"] <- "828 - Planta de calefacció/refrigeració urbana"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "Plantes per a xarxes de calor/fred"] <- "828 - Planta de calefacció/refrigeració urbana"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A63 Xarxa de calegacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"] <- "827 - Xarxa de calefacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A13 Eficiència energètica en calefacció d'espais i subministrament d'aigua calenta"] <- "828 - Planta de calefacció/refrigeració urbana"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A63 Xarxa de calefacció/refrigeració urbana"] <- "827 - Xarxa de calefacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A63 Xarxa de calefacció/refrigeració"] <- "827 - Xarxa de calefacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A54 Planta de biomassa"] <- "828 - Planta de calefacció/refrigeració urbana"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A54 Energia biomassa"] <- "828 - Planta de calefacció/refrigeració urbana"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A63 Xarxa de calegacció/ refrigeració urbana (nova instal·lació, ampliació, reforma)"] <- "827 - Xarxa de calefacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Area.d.intervencio == "A57 Altres"] <- "826 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "Energia fotovoltaica"] <- "823 - Energia fotovoltaica"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "Energia hidoelèctrica"] <- "825 - Energia hidroelèctrica"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "Altres"] <- "819 - Altres"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "Acció integrada (totes les anteriors)"] <- "819 - Altres"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "Biogàs"] <- "822 - Planta de biomassa"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "Biogàs\r\nFotovoltaica\r\n"] <- "822 - Planta de biomassa"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A55 Cogeneració"] <- "821 - Cogeneració"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A53 Energia fotovoltaica"] <- "823 - Energia fotovoltaica"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A54 Planta de biomassa"] <- "822 - Planta de biomassa"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A16 Acció integrada (tot l'anterior)"] <- "819 - Altres"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A57 Altres"] <- "819 - Altres"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A51 Energia hidroelèctrica"] <- "825 - Energia hidroelèctrica"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A57"] <- "819 - Altres"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A53"] <- "823 - Energia fotovoltaica"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A75 Altres"] <- "819 - Altres"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A52 Energia eòlica"] <- "824 - Energia eòlica"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A54 Energia biomassa"] <- "822 - Planta de biomassa"
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" & accions$Area.d.intervencio == "A55 Solar tèrmica"] <- "819 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "Canvi modal cap al transport públic"] <- "816 - Transferència modal cap al transport públic"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "Altres"] <- "808 - Altres"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "Canvi modal a bicicleta i anar a peu"] <- "815 - Transferència modal cap als trajectes a peu i en bicicleta"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "Vehicles elèctrics (inclòs infraestructures)"] <- "817 - Vehicles elèctrics (inc. infraestructures)"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "Vehicles nets/eficients"] <- "818 - Vehicles més nets/eficients"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "Compartir cotxe (\"sharing/pooling\")"] <- "814 - Ús compartit d’automòbils"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A42 Vehicles elèctrics (incl. Infrastructura)"] <- "817 - Vehicles elèctrics (inc. infraestructures)"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A43 Transferència modal cap al transport públic"] <- "816 - Transferència modal cap al transport públic"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A411 Altres"] <- "808 - Altres"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A45 Ús compartit d'automòbils"] <- "814 - Ús compartit d’automòbils"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A44 Transferència modal cap als trajectes a peu i en bicicleta"] <- "815 - Transferència modal cap als trajectes a peu i en bicicleta"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A41 Vehicles més nets/eficients"] <- "818 - Vehicles més nets/eficients"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A411 Altres / Acció integrada"] <- "808 - Altres"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A49 Tecnologies de la informació i la comunicació"] <- "810 - Tecnologies de la informació i les comunicacions"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A46 Millora de les operacions de logística i del transport urbà de mercaderies"] <- "813 - Millora de les operacions de logística i del transport urbà de mercaderies"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A41"] <- "818 - Vehicles més nets/eficients"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A75"] <- "808 - Altres"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A17 Tecnologies de la informació i les comunicacions"] <- "810 - Tecnologies de la informació i les comunicacions"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A47 Optimització de la xarxa de carreteres\r\n"] <- "812 - Optimització de la xarxa de carreteres"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A45 Ús compartit de vehicles"] <- "814 - Ús compartit d’automòbils"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A41 Vehicles més nets/ eficients"] <- "818 - Vehicles més nets/eficients"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A42 Vehicles elèctrics (incl. Infraestructura)"] <- "817 - Vehicles elèctrics (inc. infraestructures)"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A48 Urbanització d'ús mixte i contenció de l'expansió"] <- "811 - Urbanització d’ús mixta i contenció de l’expansió"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A41 Vehicles més nets i eficients"] <- "818 - Vehicles més nets/eficients"
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" & accions$Area.d.intervencio == "A45 ús compartit de vehicles"] <- "814 - Ús compartit d’automòbils"
  
  accions$Area.d.intervencio[accions$Sector == "775 - Industria" & accions$Area.d.intervencio == "Renovables per a climatització i aigua calenta"] <- "805 - Energia renovable"
  accions$Area.d.intervencio[accions$Sector == "775 - Industria" & accions$Area.d.intervencio == "A75 Altres"] <- "803 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" & accions$Area.d.intervencio == "Eficiència energètica"] <- "802 - Eficiència energètica"
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" & accions$Area.d.intervencio == "Gestió energètica"] <- "799 - Altres"
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" & accions$Area.d.intervencio == "A21 Eficiència energètica"] <- "802 - Eficiència energètica"
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" & accions$Area.d.intervencio == "A21"] <- "802 - Eficiència energètica"
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" & accions$Area.d.intervencio == "A24"] <- "799 - Altres"
  
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Envolvent edifici"] <- "798 - Envolupant d’edificis"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Acció integrada (totes les anteriors)"] <- "793 - Acció integrada (tot l’anterior)"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Altres"] <- "790 - Altres"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Tecnologies de la informació i comunicació (TIC)"] <- "792 - Tecnologies de la informació i les comunicacions"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Renovables per a climatització i aigua calenta"] <- "797 - Energia renovable per a calefacció d’espais i subministres d’aigua calenta"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Eficiència energètica en il·luminació"] <- "795 - Sistemes d’enllumenat eficient"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Eficiència energètica en calefacció d'espais i subministrament d'aigua calenta sanitària"] <- "796 - Eficiència energètica en calefacció d’espais i subministres d’aigua calenta"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Eficiència energètica"] <- "796 - Eficiència energètica en calefacció d’espais i subministres d’aigua calenta"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Tecnologies de la informació i comunicacions"] <- "792 - Tecnologies de la informació i les comunicacions"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "Energies renovables"] <- "797 - Energia renovable per a calefacció d’espais i subministres d’aigua calenta"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A16 Acció integrada (tot l'anterior)"] <- "793 - Acció integrada (tot l’anterior)"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A18 Modificació d'hàbits"] <- "791 - Modificacions d’hàbits"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A17 Tecnologies de la informació i les comunicacions"] <- "792 - Tecnologies de la informació i les comunicacions"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A16"] <- "793 - Acció integrada (tot l’anterior)"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A18"] <- "791 - Modificacions d’hàbits"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A19"] <- "790 - Altres"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A35"] <- "790 - Altres"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A 17 Tecnologies de la informació i les comunicacions"] <- "792 - Tecnologies de la informació i les comunicacions"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A13 Eficiència energètica en calefacció d'espais i subministrament d'aigua calenta"] <- "796 - Eficiència energètica en calefacció d’espais i subministres d’aigua calenta"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A12 Energia renovable per calefacció d'espais i subministrament d'aigua calenta"] <- "797 - Energia renovable per a calefacció d’espais i subministres d’aigua calenta"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A19 Altres"] <- "790 - Altres"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A17 Tecnologies de la informació i les comunicacions\r\n"] <- "792 - Tecnologies de la informació i les comunicacions"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A18 Modificació dels hàbits de consum"] <- "791 - Modificacions d’hàbits"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A12 Energia renovable per calefacció d'espais i subministament d'aigua calenta"] <- "797 - Energia renovable per a calefacció d’espais i subministres d’aigua calenta"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A54 Planta de biomassa"] <- "790 - Altres"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A16 Acció integrada"] <- "793 - Acció integrada (tot l’anterior)"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A18 Modificació dels hàbits de consum\r\n"] <- "791 - Modificacions d’hàbits"
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Area.d.intervencio == "A11 Envolupant d'edificis"] <- "798 - Envolupant d’edificis"
  
  return(accions)
}

mit_harm_Categoria_us <- function(accions) {
  accions$Categoria_us <- NA
  
  accions$Categoria_us[accions$Sector == "771 - Altres"] <- "70 - Serveis"
  accions$Categoria_us[accions$Sector == "772 - Producció local de Calefacció/refrigeració"] <- "10 - Edificis"
  accions$Categoria_us[accions$Sector == "773 - Producció local d’electricitat"] <- "10 - Edificis"
  accions$Categoria_us[accions$Sector == "774 - Transport"] <- "50 - Mobilitat"
  accions$Categoria_us[accions$Sector == "775 - Industria"] <- "70 - Serveis"
  accions$Categoria_us[accions$Sector == "776 - Enllumenat públic"] <- "80 - Enllumenat"
  accions$Categoria_us[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"] <- "10 - Edificis"
  
  return(accions)
}

mit_harm_Categoria_ambit <- function(accions) {
  accions$Categoria.de.l.ambit <- NA
  
  #In "categoria d'ús" 10 - EDIFICIS
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" & 
                                 (grepl(pattern = "calor", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "geotèrmica", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Geotèrmia", x = accions$Titol.de.la.mesura))] <- "11 - Calefacción"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" & 
                                 grepl(pattern = "llum", x = accions$Titol.de.la.mesura)] <- "14 - Iluminación"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" & 
                                 (grepl(pattern = "fotovoltai", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "autoconsum", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "FV", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "solar", x = accions$Titol.de.la.mesura)|
                                    grepl(pattern = "renovabl", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "biomassa", x = accions$Titol.de.la.mesura)|
                                    grepl(pattern = "comunitat ", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "comunitats locals ", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "sòl", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Generació", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "biogàs", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "energia tèrmica", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "tèrmic", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "hidràuli", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "hidroel", x = accions$Titol.de.la.mesura) )] <- "18 - Generación renovable"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" & 
                                 (grepl(pattern = "rehabilitació", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Rehabilitació", x = accions$Titol.de.la.mesura)  |
                                    grepl(pattern = "Rehabilització", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "eficiència energètica", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "teletreball", x = accions$Titol.de.la.mesura) )] <- "109 - Cambios en el edficio"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" & 
                                 (grepl(pattern = "comptabilitat energètica", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "gestor energètic", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "estalvi energètic", x = accions$Titol.de.la.mesura)|
                                    grepl(pattern = "informació energètica", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Estudi", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "energia verda", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Monitoritzar ", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "telecontrol", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "certificació", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "assessorament", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "ficiència", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "accés", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "pobresa", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "procés de creació", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "telegestió", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "autosuf", x = accions$Titol.de.la.mesura) ) ] <- "17 - Gestión energética"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) & accions$Categoria_us == "10 - Edificis"] <- "17 - Gestión energética"
  
  
  
  
  #In "categoria d'ús" 40 - FLOTA MUNICIPAL
  #no matches
  
  
  
  
  #In "categoria d'ús" 50 - MOBILITAT
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" & 
                                 (grepl(pattern = "sensibilització", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "teletreball", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "comparti", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Carsharing", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Foment", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Bonificació", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Promoure", x = accions$Titol.de.la.mesura))] <- "506 - Sensibilización y comunicación"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" & 
                                 (grepl(pattern = "flota municipal", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "elèctric", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Renovació", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "recàrrega", x = accions$Titol.de.la.mesura))] <- "51 - Flota vehiculos"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" & 
                                 (grepl(pattern = "mobilitat sostenible", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Aparcaments", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Estudi", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "eficiència", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "eficència", x = accions$Titol.de.la.mesura)  |
                                    grepl(pattern = "Redacció", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "verd", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "senyalització", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "pla de mobilitat", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Pla de Mobilitat", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "punts de recollida", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Plans de Desplaçament", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "dades mobilitat", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Regulació", x = accions$Titol.de.la.mesura))] <- "52 - Gestión"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" & 
                                 (grepl(pattern = "Transport a demanda", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "públic", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "demanda", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "bus", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Bus", x = accions$Titol.de.la.mesura))] <- "503 - Transporte público"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" & 
                                 (grepl(pattern = "bici", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "ciclables", x = accions$Titol.de.la.mesura))] <- "505 - Bicicletas"
  
  
  
  
  #In "categoria d'ús" 60 - RESIDENCIAL
  #no matches
  
  
  
  
  #In "categoria d'ús" 70 - SERVEIS
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "70 - Serveis" & 
                                 (grepl(pattern = "residus", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "selectiva", x = accions$Titol.de.la.mesura)|
                                    grepl(pattern = "recollida", x = accions$Titol.de.la.mesura)|
                                    grepl(pattern = "reisdus", x = accions$Titol.de.la.mesura)|
                                    grepl(pattern = "cobertes verdes", x = accions$Titol.de.la.mesura)|
                                    grepl(pattern = "recollida", x = accions$Titol.de.la.mesura))] <- "71 - Urbanismo y edificación"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "70 - Serveis" & 
                                 (grepl(pattern = "Campanya", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "campanyes", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "mobilitat", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "sensibilització", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "pobresa", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "energèti", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "comunitat", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "comunicació", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Fomentar", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "taules comarcals", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "suport", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Difusió", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "sostenibilitat", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Fomentar", x = accions$Titol.de.la.mesura))] <- "72 - Comunicación y sensibilización"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "70 - Serveis" & 
                                 (grepl(pattern = "FV", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "biomassa", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "autoconsum", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "equipaments", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "compres agrupades", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "energies renovables", x = accions$Titol.de.la.mesura))] <- "703 - Autoconsumo y renovables"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) & accions$Categoria_us == "70 - Serveis"] <- "72 - Comunicación y sensibilización"
  
  
  
  
  #In "categoria d'ús" 80 - ENLLUMENAT
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "80 - Enllumenat" &
                                 (grepl(pattern = "eficiència", x = accions$Titol.de.la.mesura) |
                                    grepl(pattern = "Canvi", x = accions$Titol.de.la.mesura))] <- "81 - Luminarias"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "80 - Enllumenat" &
                                 (grepl(pattern = "Ajustar", x = accions$Titol.de.la.mesura))] <- "82 - Regulación y gestión"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "80 - Enllumenat" &
                                 (grepl(pattern = "pla d'enllumenat", x = accions$Titol.de.la.mesura))] <- "803 - Planificación"
  
  return(accions)
}


mit_harm_Instrument <- function(accions) {
  
  #Instruments lligats al sector 771 - ALTRES
  
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Administració local (Aj.)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Estàndards en edificació"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Taxes sobre energia/emissions"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Obligacions a subministradors d'energia"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Ajuts i subvencions"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B74 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B74"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B53 Ajudes i subvencions"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "A72 Gestió de residus i aigües residuals"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "A16 Acció integrada (tot l'anterior)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "A75 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B15 Impostos sobre l'energia/les emissions de carboni"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B16 Ajudes i subvencions"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B43 Ajudes i subvencions"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B112 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B112  Altres"] <- "130 - Otros"
  
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Sensibilització/Formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B71 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B11 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B71"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B71 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B71 Sensibilització /formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B71"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B71"] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == ""] <- "140 - No se aplica"
  
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "Planificació urbanística"] <- "190 - Planificació territorial"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B72 Planificació territorial"] <- "190 - Planificació territorial"
  accions$Instrument[accions$Sector == "771 - Altres" & accions$Instrument == "B56 Normativa sobre planificació territorial"] <- "190 - Planificació territorial"
  
  #Instruments lligats al sector 772 - PRODUCCIÓ LOCAL DE CALEFACCIÓ/REGRIGERACIÓ
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "Administració local (Aj.)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "B58 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "A63 Xarxa de calegacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "B74 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "Compra pública"] <- "130 - Otros"
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "Sensibilització/Formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "B71 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "B61 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "B41 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == ""] <- "134 - Obligaciones de los proveedores de energía"
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "B16 Ajudes i subvencions"] <- "136 - Subvenciones y ayudas"
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == ""] <- "137 - Financiación por terceros. Asociaciones público-privadas"
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "Planificació urbanística"] <- "139 - Normativa sobre planificación territorial"
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == "B56 Normativa sobre planificació territorial"] <- "139 - Normativa sobre planificación territorial"
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == ""] <- "140 - No se aplica"
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" & accions$Instrument == ""] <- "150 - Requisits de construcció"
  
  #Instruments lligats al sector 773 - PRODUCCIÓ LOCAL DE D'ELECTRICITAT
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Compra pública"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Administració local (Aj.)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Gestió energètica"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B58 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "A54 Planta de biomassa"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "A16 Acció integrada (tot l'anterior)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "A57 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "A51 Energia hidroelèctrica"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "A53 Energia fotovoltaica"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B15 Impostos sobre l'energia/les emissions de carboni"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B51 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B59"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B57"] <- "130 - Otros"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Sensibilitació / Formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Sensibilització/Formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B51 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B11 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B51 Sensibilització"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B51 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B11 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B51"] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B52 Obligacions dels proveidors d'energia"] <- "134 - Obligaciones de los proveedores de energía"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B53 Ajudes i subvencions"] <- "136 - Subvenciones y ayudas"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B53"] <- "136 - Subvenciones y ayudas"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B16 Ajudes i subvencions"] <- "136 - Subvenciones y ayudas"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B54 Finançament per tercers. Asociacions público-privades"] <- "137 - Financiación por terceros. Asociaciones público-privadas"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == ""] <- "140 - No se aplica"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Estàndards en edificació"] <- "150 - Requisits de construcció"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B55 Requeriments de construcció"] <- "150 - Requisits de construcció"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "Planificació urbanística"] <- "190 - Planificació territorial"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B56 Normativa sobre planificació territorial"] <- "190 - Planificació territorial"
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" & accions$Instrument == "B56"] <- "190 - Planificació territorial"
  
  #Instruments lligats al sector 774 - TRANSPORT
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Administració local (Aj.)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "A411 Altres / Acció integrada"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B410 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B112 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B15 Impostos sobre l'energia/les emissions de carboni"] <- "130 - Otros"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Sensibilització/Formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Sensibilització / Formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B41 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B71"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B11 Sensibilització"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B41 Sensibilització"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B51 Sensibilització"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B41 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B71 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B11 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Ajuts i subvencions"] <- "136 - Subvenciones y ayudas"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B43 Ajudes i subvencions"] <- "136 - Subvenciones y ayudas"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Compra pública"] <- "138 - Contratación pública"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B47 Contractació pública"] <- "138 - Contratación pública"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B47 Contratació pública"] <- "138 - Contratación pública"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Planificació urbanística"] <- "139 - Normativa sobre planificación territorial"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B45 Normativa sobre planificació territorial"] <- "139 - Normativa sobre planificación territorial"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B45"] <- "139 - Normativa sobre planificación territorial"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == ""] <- "140 - No se aplica"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == ""] <- "180 - Integració de sistemes d'expedició i pagament de bitllets"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Tarificació viària"] <- "181 - Peatges"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Regulació/planificació de transport/mobilitat"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Ús compratit de vehicle"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B46 Regulació plans de mobilitat i transport"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "A45 Ús compartit d'automòbils"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "A42 Vehicles elèctrics (incl. Infrastructura)"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "A41 Vehicles més nets/eficients"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "A44 Transferència modal cap als trajectes a peu i en bicicleta"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "A43 Transferència modal cap al transport públic"] <- "182 - Reglament sobre planificació del transport/la mobilitat"
  
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "Acords voluntaris amb agents implicats"] <- "183 - Acords voluntaris amb les parts implicades"
  accions$Instrument[accions$Sector == "774 - Transport" & accions$Instrument == "B48 Acords voluntaris amb les parts implicades"] <- "183 - Acords voluntaris amb les parts implicades"
  
  #Instruments lligats al sector 775 - TRANSPORT
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == "B74 Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == "A75 Altres"] <- "130 - Otros"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == "Sensibilització/Formació"] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == ""] <- "132 - Gestión de energía"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == ""] <- "133 - Certificación energética/etiquetado"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == ""] <- "135 - Impuestos sobre la energía/las emisiones de carbono"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == ""] <- "136 - Subvenciones y ayudas"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == ""] <- "137 - Financiación por terceros. Asociaciones público-privadas"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == ""] <- "140 - No se aplica"
  
  accions$Instrument[accions$Sector == "775 - Industria" & accions$Instrument == ""] <- "170 - Normes de rendiment energètic"
  
  #Instruments lligats al sector 776 - ENLLUMENAT PÚBLIC
  
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == "Altres"] <- "130 - Otros"
  
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == "Gestió energètica"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == "B21 Gestió d'energia"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == "B21"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == "A21 Eficiència energètica"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == "B21 Gestió de l'energia"] <- "132 - Gestión de energía"
  
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == ""] <- "134 - Obligaciones de los proveedores de energía"
  
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == ""] <- "137 - Financiación por terceros. Asociaciones público-privadas"
  
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == "Compra pública"] <- "138 - Contratación pública"
  
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" & accions$Instrument == ""] <- "140 - No se aplica"
  
  #Instruments lligats al sector 777 - EDIFICIS, EQUIPAMENT/INSTAL·LACIONS MUNICIPALS, RESIDENCIALS I TERCIARIS
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Altres"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Administració local (Aj.)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Altres (Administracions Nacional, Regional)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B112"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "A16 Acció integrada (tot l'anterior)"] <- "130 - Otros"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B112 Altres"] <- "130 - Otros"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Sensibilització/Formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B11 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B11"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B31"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "A18 Modificació d'hàbits"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "A17 Tecnologies de la informació i les comunicacions"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B51 Sensibilització"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B71 Sensibilització/formació"] <- "131 - Sensibilización/formación"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B11 Sensibilització/ formació"] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Gestió energètica"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B12 Gestió d'energia"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B21 Gestió d'energia"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B12"] <- "132 - Gestión de energía"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B12 Gestió de l'energia"] <- "132 - Gestión de energía"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B13 Certificació energètica"] <- "133 - Certificación energética/etiquetado"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Obligacions a subministradors d'energia"] <- "134 - Obligaciones de los proveedores de energía"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Taxes sobre energia/emissions"] <- "135 - Impuestos sobre la energía/las emisiones de carbono"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Ajuts i subvencions"] <- "136 - Subvenciones y ayudas"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B16 Ajudes i subvencions"] <- "136 - Subvenciones y ayudas"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Finançament per   tercers. PPP"] <- "137 - Financiación por terceros. Asociaciones público-privadas"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Compra pública"] <- "138 - Contratación pública"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B18"] <- "138 - Contratación pública"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B18 Contractació pública"] <- "138 - Contratación pública"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "Planificació urbanística"] <- "139 - Normativa sobre planificación territorial"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B110 Normativa sobre planificació territorial"] <- "139 - Normativa sobre planificación territorial"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == ""] <- "140 - No se aplica"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B39"] <- "150 - Requisits de construcció"
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" & accions$Instrument == "B19 Requeriments de construcció"] <- "150 - Requisits de construcció"
  
  
  return(accions)
}



mit_harm_Origen <- function(accions) {
  accions$Origen.de.l.accio[grepl("S", accions$ID.mesura)] <- "142 - Coordinador regional del Pacto"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "SUPRA"] <- "142 - Coordinador regional del Pacto"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Supramunicipal"] <- "142 - Coordinador regional del Pacto"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Supramunicipal (Procés de participació)"] <- "142 - Coordinador regional del Pacto"
  
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Administració local (Aj.)"] <- "141 - Autoridad local"
  accions$Origen.de.l.accio[grepl("Ajuntament", accions$Origen.de.l.accio)] <- "141 - Autoridad local"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Autoritat local"] <- "141 - Autoridad local"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Municipal"] <- "141 - Autoridad local"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "MUNICIPAL"] <- "141 - Autoridad local"
  
  
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Altres (Administracions Nacional, Regional)"] <- "143 - Otros (nacional, regional)"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Consell Comarcal"] <- "143 - Otros (nacional, regional)"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Agència comarcal de l'energia"] <- "143 - Otros (nacional, regional)"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Agència comarcal de l'energia \r\n"] <- "143 - Otros (nacional, regional)"
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "Consell comarcal d'Osona"] <- "143 - Otros (nacional, regional)"
  
  accions$Origen.de.l.accio[accions$Origen.de.l.accio == "-"] <- "144 - No es posible decirlo"
  
  return(accions)
}



mit_format_Inergy <- function(accions) {
  
  Inergy <- data.frame(
    "ID_Proyecto" = accions$ID.Proyecto,
    "Nombre_del_plan" = accions$Nom.del.pla,
    "Título_de_la_medida" = accions$Titol.de.la.mesura,
    "Sector" = accions$Sector,
    "Área_de_Intervención" = accions$Area.d.intervencio,
    "Categoría_de_uso" = accions$Categoria_us,
    "Categoría_de_ámbito" = accions$Categoria.de.l.ambit,
    "Descripción" = accions$Descripcio,
    "Responsable" = accions$Responsable,
    "Ahorro_energético_total_kWh" = 1000*as.numeric(accions$Estalvi.energètic.total..MWh.),
    "Producción_energía_renovable_kWh" = 1000*as.numeric(accions$Producció.d.energia.renovable..MWh.),
    "Emisiones_evitadas_tCO2" = accions$Emissions.evitades..tCO2.,
    "Coste_Eur" = accions$Cost....,
    "Ahorro_anual_Eur" = accions$Estalvi.anual....,
    "Año_de_inicio" = accions$Any.inici,
    "Año_de_fin" = accions$Any.fi,
    "Instrumento" = accions$Instrument,
    "Origen_de_la_acción" = accions$Origen.de.l.accio,
    "Estado_de_ejecución" = accions$Estat.d.execucio)
  
  return(Inergy)
}



ada_harm_Sector <- function(accions) {
  
  accions$Sector[accions$Sector == "PARTICIPACIÓ CIUTADANA"] <- "778 - Altres"
  accions$Sector[accions$Sector == "VERD URBÀ"] <- "778 - Altres"
  accions$Sector[accions$Sector == "\r\n\r\nParticipació ciutadana\r\n"] <- "778 - Altres"
  accions$Sector[accions$Sector == "Participació ciutadana"] <- "778 - Altres"
  
  accions$Sector[accions$Sector == "Turisme"] <- "779 - Turisme"
  accions$Sector[accions$Sector == "TURISME"] <- "779 - Turisme"
  accions$Sector[accions$Sector == "Turime"] <- "779 - Turisme"
  
  accions$Sector[accions$Sector == "PROTECCIÓ CIVIL I EMERGÈNCIES"] <- "780 - Protecció civil i emergències"
  accions$Sector[accions$Sector == "Protecció civil i emergències"] <- "780 - Protecció civil i emergències"
  accions$Sector[accions$Sector == "Protecció civil"] <- "780 - Protecció civil i emergències"
  accions$Sector[accions$Sector == "PORTECCIÓ CIVIL I EMERGÈNCIES"] <- "780 - Protecció civil i emergències"
  accions$Sector[accions$Sector == "PROTECCIÓ CIVIL"] <- "780 - Protecció civil i emergències"
  accions$Sector[accions$Sector == "\r\n\r\nProtecció civil i emergències\r\n"] <- "780 - Protecció civil i emergències"
  accions$Sector[accions$Sector == "Protecció civil i casos d'emergència"] <- "780 - Protecció civil i emergències"
  
  accions$Sector[accions$Sector == "SALUT"] <- "781 - Salut"
  accions$Sector[accions$Sector == "Salut"] <- "781 - Salut"
  accions$Sector[accions$Sector == "SALUT/ SERVEIS SOCIALS"] <- "781 - Salut"
  
  accions$Sector[accions$Sector == "MEDI AMBIENT I BIODIVERSITAT"] <- "782 - Medi Ambient i biodiversitat"
  accions$Sector[accions$Sector == "Medi ambient i biodiversitat"] <- "782 - Medi Ambient i biodiversitat"
  
  accions$Sector[accions$Sector == "Agricultura i sector forestal"] <- "783 - Agricultura i silvicultura"
  accions$Sector[accions$Sector == "AGRICULTURA I SECTOR FORESTAL"] <- "783 - Agricultura i silvicultura"
  
  accions$Sector[accions$Sector == "PLANIFICACIÓ URBANÍSTICA"] <- "784 - Planificació Territorial"
  accions$Sector[accions$Sector == "Planificació urbanística"] <- "784 - Planificació Territorial"
  accions$Sector[accions$Sector == "Planificació urabnística"] <- "784 - Planificació Territorial"
  accions$Sector[accions$Sector == "Litoral i sistemes costaners"] <- "784 - Planificació Territorial"
  accions$Sector[accions$Sector == "LITORAL I SISTEMES COSTANERS"] <- "784 - Planificació Territorial"
  
  accions$Sector[accions$Sector == "RESIDUS"] <- "785 - Residus"
  accions$Sector[accions$Sector == "Residus"] <- "785 - Residus"
  
  accions$Sector[accions$Sector == "AIGUA"] <- "786 - Aigua"
  accions$Sector[accions$Sector == "Aigua"] <- "786 - Aigua"
  accions$Sector[accions$Sector == "CICLE DE L’AIGUA"] <- "786 - Aigua"
  
  accions$Sector[accions$Sector == "ENERGIA"] <- "787 - Energia"
  
  accions$Sector[accions$Sector == "Transport"] <- "788 - Transport"
  
  accions$Sector[accions$Sector == "Edificis"] <- "789 - Edificis"
  accions$Sector[accions$Sector == "EDIFICIS"] <- "789 - Edificis"
  
  return(accions)
}



ada_harm_Registre <- function(accions) {
  
  # unique(accions$Registre.climatic[accions$Sector == "778 - Altres"])
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "956 - Altres"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "Onades de calor (calor extrema) Onades de fred (fred extrem) Sequeres i escassetat d'aigua Risc d’incendi Precipitació extrema Inundacions Increment del nivell del mar Esllavissades Tempestes i ventades"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "Risc d’incendi/Precipitació extrema/Inundacions"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "Risc d’incendi/Sequeres i escassetat d'aigua/Onades de calor (calor extrema)"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "Sequeres i escassetat d'aigua/Onades de calor (calor extrema)/Risc d’incendi"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "VERD URB \r\nS. HUMIDES \r\nSP. URBANES"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "ESTIATGE \r\nZ.HUMIDES \r\nSEQUERA \r\nTEMPESTA"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "ESTIATGE \r\nZ.HUMIDES \r\nSEQUERA"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "Onades de calor (calor extrema); Onades de fred (fred extrem); Sequeres i escassetat d'aigua"] <- "957 - Transversal"
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "Onades de calor (calor extrema); Sequeres i escassetat d'aigua"] <- "957 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == "INCENDI SP. FORESTALS"] <- "958 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "959 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "960 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "961 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "962 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "963 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "964 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "965 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "778 - Altres" & accions$Registre.climatic == ""] <- "966 - Calor extrema"
  
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "779 - Turisme"])
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "945 - Altres"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Onades de calor (calor extrema) Onades de fred (fred extrem) Sequeres i escassetat d'aigua Risc d’incendi Precipitació extrema Inundacions Increment del nivell del mar"] <- "946 - Transversal"
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Onades de calor (calor extrema) Sequeres i escassetat d'aigua"] <- "946 - Transversal"
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Onades de calor (calor extrema) Onades de fred (fred extrem) Sequeres i escassetat d'aigua Risc d’incendi Precipitació extrema Inundacions"] <- "946 - Transversal"
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Precipitació extrema/Inundacions/Risc d’incendi"] <- "946 - Transversal"
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Risc d’incendi/Sequeres i escassetat d'aigua/Onades de calor (calor extrema)"] <- "946 - Transversal"
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Onades de calor (calor extrema)Onades de fred (fred extrem)Sequeres i escassetat d'aigua"] <- "946 - Transversal"
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Onades de calor (calor extrema)/Onades de fred (fred extrem)/Sequeres i escassetat d'aigua"] <- "946 - Transversal"
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Onades de calor (calor extrema); Onades de fred (fred extrem); Sequeres i escassetat d'aigua; Risc d'incendi; Precipitació extrema; Inundacions; Increment del nivell del mar"] <- "946 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == "Risc d’incendi//"] <- "947 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "948 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "949 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "950 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "951 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "952 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "953 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "954 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "779 - Turisme" & accions$Registre.climatic == ""] <- "955 - Calor extrema"
  
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències"])
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "RIUADA"] <- "934 - Altres"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == ""] <- "935 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "Risc d’incendi"] <- "936 - Incendis  forestals"
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "Risc d'incendi"] <- "936 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == ""] <- "937 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == ""] <- "938 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "939 - Sequeres"
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "Sequeres i escassetat d'aigua"] <- "939 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "Increment del nivell del mar"] <- "940 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == ""] <- "941 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "Precipitació extrema"] <- "942 - Precipitació extrema"
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == ""] <- "942 - Precipitació extrema"
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == ""] <- "942 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == ""] <- "943 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & accions$Registre.climatic == "Onades de calor (calor extrema)//"] <- "944 - Calor extrema"
  
  accions$Registre.climatic[accions$Sector == "780 - Protecció civil i emergències" & 
                              !accions$Registre.climatic == "934 - Altres" &
                              !accions$Registre.climatic == "935 - Transversal" &
                              !accions$Registre.climatic == "936 - Incendis  forestals" &
                              !accions$Registre.climatic == "937 - Allaus" &
                              !accions$Registre.climatic == "938 - Tempestes" &
                              !accions$Registre.climatic == "939 - Sequeres" &
                              !accions$Registre.climatic == "940 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "941 - Inundacions" &
                              !accions$Registre.climatic == "942 - Precipitació extrema" &
                              !accions$Registre.climatic == "943 - Fred extrem" &
                              !accions$Registre.climatic == "944 - Calor extrema"] <- "935 - Transversal"
  
  
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "781 - Salut"])
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == "CALOR \r\nENERGIA \r\nINFRAESTRUCTURES"] <- "923 - Altres"
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == "POL·LEN AL·LÈRGIA"] <- "923 - Altres"
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "923 - Altres"
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "923 - Altres"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "924 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "925 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "926 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "927 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "928 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "929 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "930 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == ""] <- "931 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == "Onades de fred (fred extrem)"] <- "932 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == "Onades de calor (calor extrema)//"] <- "933 - Calor extrema"
  accions$Registre.climatic[accions$Sector == "781 - Salut" & accions$Registre.climatic == "Onades de calor (calor extrema)"] <- "933 - Calor extrema"
  
  
  accions$Registre.climatic[accions$Sector == "781 - Salut" & 
                              !accions$Registre.climatic == "923 - Altres" &
                              !accions$Registre.climatic == "924 - Transversal" &
                              !accions$Registre.climatic == "925 - Incendis  forestals" &
                              !accions$Registre.climatic == "926 - Allaus" &
                              !accions$Registre.climatic == "927 - Tempestes" &
                              !accions$Registre.climatic == "928 - Sequeres" &
                              !accions$Registre.climatic == "929 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "930 - Inundacions" &
                              !accions$Registre.climatic == "931 - Precipitació extrema" &
                              !accions$Registre.climatic == "932 - Fred extrem" &
                              !accions$Registre.climatic == "933 - Calor extrema"] <- "924 - Transversal"
  
  
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat"])
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "912 - Altres"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "913 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "914 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "915 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "916 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "917 - Sequeres"
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == "Sequeres i escassetat d'aigua"] <- "917 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "918 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "919 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "920 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == ""] <- "921 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & accions$Registre.climatic == "Onades de calor (calor extrema)//"] <- "922 - Calor extrema"
  
  accions$Registre.climatic[accions$Sector == "782 - Medi Ambient i biodiversitat" & 
                              !accions$Registre.climatic == "912 - Altres" &
                              !accions$Registre.climatic == "913 - Transversal" &
                              !accions$Registre.climatic == "914 - Incendis  forestals" &
                              !accions$Registre.climatic == "915 - Allaus" &
                              !accions$Registre.climatic == "916 - Tempestes" &
                              !accions$Registre.climatic == "917 - Sequeres" &
                              !accions$Registre.climatic == "918 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "919 - Inundacions" &
                              !accions$Registre.climatic == "920 - Precipitació extrema" &
                              !accions$Registre.climatic == "921 - Fred extrem" &
                              !accions$Registre.climatic == "922 - Calor extrema"] <- "913 - Transversal"
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura"])
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "901 - Altres"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "902 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == "Risc d’incendi"] <- "903 - Incendis  forestals"
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == "Risc d’incendi//"] <- "903 - Incendis  forestals"
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == "Risc d'incendi"] <- "903 - Incendis  forestals"
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == "\r\nRisc d'incendi\r\n"] <- "903 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "904 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "905 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "906 - Sequeres"
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == "Sequeres i escassetat d'aigua"] <- "906 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "907 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "908 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "909 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == ""] <- "910 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & accions$Registre.climatic == "Onades de calor (calor extrema)//"] <- "911 - Calor extrema"
  
  
  accions$Registre.climatic[accions$Sector == "783 - Agricultura i silvicultura" & 
                              !accions$Registre.climatic == "901 - Altres" &
                              !accions$Registre.climatic == "902 - Transversal" &
                              !accions$Registre.climatic == "903 - Incendis  forestals" &
                              !accions$Registre.climatic == "904 - Allaus" &
                              !accions$Registre.climatic == "905 - Tempestes" &
                              !accions$Registre.climatic == "906 - Sequeres" &
                              !accions$Registre.climatic == "907 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "908 - Inundacions" &
                              !accions$Registre.climatic == "909 - Precipitació extrema" &
                              !accions$Registre.climatic == "910 - Fred extrem" &
                              !accions$Registre.climatic == "911 - Calor extrema"] <- "902 - Transversal"
  
  
  # unique(accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial"])
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "890 - Altres"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "891 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "892 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "893 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "894 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "895 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "896 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "897 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "898 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == ""] <- "899 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == "Onades de calor (calor extrema)"] <- "900 - Calor extrema"
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & accions$Registre.climatic == "Onades de calor (calor extrema)//"] <- "900 - Calor extrema"
  
  
  
  accions$Registre.climatic[accions$Sector == "784 - Planificació Territorial" & 
                              !accions$Registre.climatic == "890 - Altres" &
                              !accions$Registre.climatic == "891 - Transversal" &
                              !accions$Registre.climatic == "892 - Incendis  forestals" &
                              !accions$Registre.climatic == "893 - Allaus" &
                              !accions$Registre.climatic == "894 - Tempestes" &
                              !accions$Registre.climatic == "895 - Sequeres" &
                              !accions$Registre.climatic == "896 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "897 - Inundacions" &
                              !accions$Registre.climatic == "898 - Precipitació extrema" &
                              !accions$Registre.climatic == "899 - Fred extrem" &
                              !accions$Registre.climatic == "900 - Calor extrema"] <- "891 - Transversal"
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "785 - Residus"])
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "879 - Altres"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "880 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "881 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "882 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "883 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "884 - Sequeres"
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == "Sequeres i escassetat d'aigua"] <- "884 - Sequeres"
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "884 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "885 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "886 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "887 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == ""] <- "888 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == "Onades de calor (calor extrema)"] <- "889 - Calor extrema"
  accions$Registre.climatic[accions$Sector == "785 - Residus" & accions$Registre.climatic == "Onades de calor (calor extrema)//"] <- "889 - Calor extrema"
  
  
  accions$Registre.climatic[accions$Sector == "785 - Residus" & 
                              !accions$Registre.climatic == "879 - Altres" &
                              !accions$Registre.climatic == "880 - Transversal" &
                              !accions$Registre.climatic == "881 - Incendis  forestals" &
                              !accions$Registre.climatic == "882 - Allaus" &
                              !accions$Registre.climatic == "883 - Tempestes" &
                              !accions$Registre.climatic == "884 - Sequeres" &
                              !accions$Registre.climatic == "885 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "886 - Inundacions" &
                              !accions$Registre.climatic == "887 - Precipitació extrema" &
                              !accions$Registre.climatic == "888 - Fred extrem" &
                              !accions$Registre.climatic == "889 - Calor extrema"] <- "880 - Transversal"
  
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "786 - Aigua"])
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "Z. HUMIDES MALALTIES"] <- "868 - Altres"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == ""] <- "869 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "Risc d’incendi//"] <- "870 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == ""] <- "871 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == ""] <- "872 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "Sequeres i escassetat d'aigua"] <- "873 - Sequeres"
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "Sequeres i escassetat d’aigua"] <- "873 - Sequeres"
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "Sequeres I escassetat d'aigua"] <- "873 - Sequeres"
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "873 - Sequeres"
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "SEQUERA ARIDESA"] <- "873 - Sequeres"
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "SEQUERA"] <- "873 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == ""] <- "874 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "RIUADA"] <- "875 - Inundacions"
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == "Inundacions"] <- "875 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == ""] <- "876 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == ""] <- "877 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & accions$Registre.climatic == ""] <- "878 - Calor extrema"
  
  
  accions$Registre.climatic[accions$Sector == "786 - Aigua" & 
                              !accions$Registre.climatic == "868 - Altres" &
                              !accions$Registre.climatic == "869 - Transversal" &
                              !accions$Registre.climatic == "870 - Incendis  forestals" &
                              !accions$Registre.climatic == "871 - Allaus" &
                              !accions$Registre.climatic == "872 - Tempestes" &
                              !accions$Registre.climatic == "873 - Sequeres" &
                              !accions$Registre.climatic == "874 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "875 - Inundacions" &
                              !accions$Registre.climatic == "876 - Precipitació extrema" &
                              !accions$Registre.climatic == "877 - Fred extrem" &
                              !accions$Registre.climatic == "878 - Calor extrema"] <- "869 - Transversal"
  
  
  # unique(accions$Registre.climatic[accions$Sector == "787 - Energia"])
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "857 - Altres"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "858 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "859 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "860 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "861 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "862 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "863 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "864 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "865 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == ""] <- "866 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & accions$Registre.climatic == "Onades de calor (calor extrema)"] <- "867 - Calor extrema"
  
  accions$Registre.climatic[accions$Sector == "787 - Energia" & 
                              !accions$Registre.climatic == "857 - Altres" &
                              !accions$Registre.climatic == "858 - Transversal" &
                              !accions$Registre.climatic == "859 - Incendis  forestals" &
                              !accions$Registre.climatic == "860 - Allaus" &
                              !accions$Registre.climatic == "861 - Tempestes" &
                              !accions$Registre.climatic == "862 - Sequeres" &
                              !accions$Registre.climatic == "863 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "864 - Inundacions" &
                              !accions$Registre.climatic == "865 - Precipitació extrema" &
                              !accions$Registre.climatic == "866 - Fred extrem" &
                              !accions$Registre.climatic == "867 - Calor extrema"] <- "858 - Transversal"
  
  
  
  
  # unique(accions$Registre.climatic[accions$Sector == "788 - Transport"])
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "846 - Altres"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "847 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "848 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "849 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "850 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "851 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "852 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "853 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "854 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "855 - Fred extrem"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & accions$Registre.climatic == ""] <- "856 - Calor extrema"
  
  accions$Registre.climatic[accions$Sector == "788 - Transport" & 
                              !accions$Registre.climatic == "846 - Altres" &
                              !accions$Registre.climatic == "847 - Transversal" &
                              !accions$Registre.climatic == "848 - Incendis  forestals" &
                              !accions$Registre.climatic == "849 - Allaus" &
                              !accions$Registre.climatic == "850 - Tempestes" &
                              !accions$Registre.climatic == "851 - Sequeres" &
                              !accions$Registre.climatic == "852 - Elevació del nivell del mar" &
                              !accions$Registre.climatic == "853 - Inundacions" &
                              !accions$Registre.climatic == "854 - Precipitació extrema" &
                              !accions$Registre.climatic == "855 - Fred extrem" &
                              !accions$Registre.climatic == "856 - Calor extrema"] <- "847 - Transversal"
  
  
  # unique(accions$Registre.climatic[accions$Sector == "789 - Edificis"])
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == "Onades de calor (calor extrema)"] <- "835 - Altres" 
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == "Onades de calor (calor extrema) Onades de fred (fred extrem) Sequeres i escassetat d'aigua"] <- "836 - Transversal"
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == "Onades de calor (calor extrema) Onades de fred (fred extrem)"] <- "836 - Transversal"
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == "Onades de calor (calor extrema); Onades de fred (fred extrem); Sequeres i escassetat d'aigua"] <- "836 - Transversal"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == ""] <- "837 - Incendis  forestals"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == ""] <- "838 - Allaus"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == ""] <- "839 - Tempestes"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == "Sequeres i escassetat d'aigua//"] <- "840 - Sequeres"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == ""] <- "841 - Elevació del nivell del mar"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == "Inundacions/Precipitació extrema/"] <- "842 - Inundacions"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == ""] <- "843 - Precipitació extrema"
  
  accions$Registre.climatic[accions$Sector == "789 - Edificis" & accions$Registre.climatic == ""] <- "844 - Fred extrem"
  
  return(accions)
}



ada_harm_Mitigacio <- function(accions) {
  
  accions$Afecta.la.mitigació..Si.No.[accions$Afecta.la.mitigació..Si.No. == "Si" |
                                        accions$Afecta.la.mitigació..Si.No. == "Sí" |
                                        accions$Afecta.la.mitigació..Si.No. == "X" |
                                        accions$Afecta.la.mitigació..Si.No. == "x"] <- "290 - Sí"
  
  accions$Afecta.la.mitigació..Si.No.[accions$Afecta.la.mitigació..Si.No. == "-" |
                                        accions$Afecta.la.mitigació..Si.No. == "NO" |
                                        accions$Afecta.la.mitigació..Si.No. == "No" |
                                        is.na(accions$Afecta.la.mitigació..Si.No.)] <- "291 - No"
  
  return(accions)
}



ada_format_Inergy <- function(accions) {
  
  Inergy <- data.frame(
    "ID_Proyecto" = accions$ID.Proyecto,
    "Nombre_del_plan" = accions$Nom.del.pla,
    "Título_de_la_medida" = accions$Titol.de.la.mesura,
    "Sector" = accions$Sector,
    "Riesgo_climático" = accions$Registre.climatic,
    "Descripción" = accions$Descripcio,
    "Responsable" = accions$Responsable,
    "Ahorro_energético_total_kWh" = as.numeric(accions$Estalvi.energètic.total..kWh.),
    "Producción_energía_renovable_kWh" = as.numeric(accions$Producció.d.energia.renovable..kWh.),
    "Emisiones_evitadas_tCO2" = accions$Emissions.evitades..tCO2.,
    "Coste_Eur" = accions$Cost....,
    "Ahorro_anual_Eur" = accions$Estalvi.anual....,
    "Año_de_inicio" = accions$Any.inici,
    "Año_de_fin" = accions$Any.fi,
    "Afecta_a_mitigación" = accions$Afecta.la.mitigació..Si.No.,
    "Estado_de_ejecución" = accions$Estat.d.execucio)
  
  return(Inergy)
}


########################## DATA IMPORT ##########################

# accio_mit <- data.frame(
#                     #Obligatori
#                     "ID Proyecto" = {},
#                     "Tipologia" = {},
#                     "Nom del pla" = {},
#                     "ID mesura" = {},
#                     "Titol de la mesura" = {},
#                     "Sector" = {},
#                     "Area d'intervencio" = {},
#                     "Categoria de l'ambit" = {},
#                     "Descripcio" = {},
#                     "Responsable" = {},#"Irresponsable_1",
#                     #Info adicional
#                     "Estalvi energètic total [MWh]" = {},
#                     "Producció d'energia renovable [MWh]" = {},
#                     "Emissions evitades [tCO2]" = {},
#                     "Cost [€]" = {},
#                     "Estalvi anual [€]" = {},
#                     "Any inici" = {},
#                     "Any fi" = {},
#                     "Instrument" = {},
#                     "Origen de l'accio" = {},
#                     "Estat d'execucio" = {}
#                     )
# 
# accio_ada <- data.frame(
#                     #Obligatori
#                     "ID Proyecto" = {},
#                     "Tipologia" = {},
#                     "Nom del pla" = {},
#                     "ID mesura" = {},
#                     "Titol de la mesura" = {},
#                     "Sector" = {},
#                     "Registre climatic" = {},
#                     "Descripcio" = {},
#                     "Responsable" = {},#"Irresponsable_1",
#                     #Info adicional
#                     "Estalvi energètic total [kWh]" = {},
#                     "Producció d'energia renovable [kWh]" = {},
#                     "Emissions evitades [tCO2]" = {},
#                     "Cost [€]" = {},
#                     "Estalvi anual [€]" = {},
#                     "Any inici" = {},
#                     "Any fi" = {},
#                     "Afecta la mitigació (Si/No)" = {},
#                     "Estat d'execucio" = {}
# )


# files <- list.files(path = "SECAPS/ARDA", pattern = ".xlsx")
# ARUM_files <- list.files(path = "SECAPS/ARUM", pattern = ".xlsx")
# # ECO_files <- list.files(path = "SECAPS/ECOSERVEIS", pattern = ".xlsx")
# OICOS_files <- list.files(path = "SECAPS/OICOS", pattern = ".xlsx")


# path_file <- "SECAPS/ARDA/"

accio_mit_ARDA <- read_mit("SECAPS/ARDA/")
accio_ada_ARDA <- read_adap("SECAPS/ARDA/")

length(unique(accio_mit_ARDA$ID.Proyecto))-1
length(unique(accio_ada_ARDA$ID.Proyecto))-1

unique(accio_mit_ARDA$ID.Proyecto)
unique(accio_ada_ARDA$ID.Proyecto)


# path_file <- "SECAPS/ARUM/"

accio_mit_ARUM <- read_mit("SECAPS/ARUM/")
accio_ada_ARUM <- read_adap("SECAPS/ARUM/")

length(unique(accio_mit_ARUM$ID.Proyecto))-1
length(unique(accio_ada_ARUM$ID.Proyecto))-1

unique(accio_mit_ARUM$ID.Proyecto)
unique(accio_ada_ARUM$ID.Proyecto)

# path_file <- "SECAPS/OICOS/"

accio_mit_OICOS <- read_mit("SECAPS/OICOS/")
accio_ada_OICOS <- read_adap("SECAPS/OICOS/")

length(unique(accio_mit_OICOS$ID.Proyecto))-1
length(unique(accio_ada_OICOS$ID.Proyecto))-1

unique(accio_mit_OICOS$ID.Proyecto)
unique(accio_ada_OICOS$ID.Proyecto)



# accio_mit_OICOS[is.na(accio_mit_OICOS$ID.Proyecto),]


########################## MITIGATION - HARMONIZATION TO EPLANET MODEL ##########################

totes_accions_mit <- rbind(accio_mit_ARDA, accio_mit_ARUM, accio_mit_OICOS)
# totes_accions_mit <- accio_mit_ECO

unique(totes_accions_mit$Sector)
totes_accions_mit <- mit_harm_Sector(totes_accions_mit)
unique(totes_accions_mit$Sector)

# unique(totes_accions_mit$Area.d.intervencio[totes_accions_mit$Sector == "771 - Altres"])
# unique(totes_accions_mit$Area.d.intervencio[totes_accions_mit$Sector == "772 - Producció local de Calefacció/refrigeració"])
# unique(totes_accions_mit$Area.d.intervencio[totes_accions_mit$Sector == "773 - Producció local d’electricitat"])
# unique(totes_accions_mit$Area.d.intervencio[totes_accions_mit$Sector == "774 - Transport"])
# unique(totes_accions_mit$Area.d.intervencio[totes_accions_mit$Sector == "775 - Industria"])
# unique(totes_accions_mit$Area.d.intervencio[totes_accions_mit$Sector == "776 - Enllumenat públic"])
# unique(totes_accions_mit$Area.d.intervencio[totes_accions_mit$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"])

# "771 - Altres"
# "772 - Producció local de Calefacció/refrigeració"
# "773 - Producció local d’electricitat"
# "774 - Transport"
# "775 - Industria"
# "776 - Enllumenat públic"
# "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"

unique(totes_accions_mit$Area.d.intervencio)
totes_accions_mit <- mit_harm_A.Intervencio(totes_accions_mit)
unique(totes_accions_mit$Area.d.intervencio)

# accions <- totes_accions_mit

unique(totes_accions_mit$Categoria_us)
totes_accions_mit <- mit_harm_Categoria_us(totes_accions_mit)
unique(totes_accions_mit$Categoria_us)

unique(totes_accions_mit$Categoria.de.l.ambit)
totes_accions_mit <- mit_harm_Categoria_ambit(totes_accions_mit)
unique(totes_accions_mit$Categoria.de.l.ambit)

unique(totes_accions_mit$Instrument)
totes_accions_mit <- mit_harm_Instrument(totes_accions_mit)
unique(totes_accions_mit$Instrument)

# backup <- totes_accions_mit
# totes_accions_mit <- backup

unique(totes_accions_mit$Origen.de.l.accio)
totes_accions_mit <- mit_harm_Origen(totes_accions_mit)
unique(totes_accions_mit$Origen.de.l.accio)


unique(totes_accions_mit$Estat.d.execucio)

#
mit_export <- mit_format_Inergy(totes_accions_mit)

unique(mit_export$ID_Proyecto)
length(unique(mit_export$ID_Proyecto))-1

# mit_export$Nombre_del_plan <- paste0("PAESC_Mitigació_", gsub(pattern = "_Mitigació", replacement = "", x = mit_export$Nombre_del_plan))

#Take the ETP names from the ePLANET platform to identify the actions with the already existing plans
mit_export$Nombre_del_plan <- gsub(pattern = "_Mitigació", replacement = "", x = mit_export$Nombre_del_plan)
mit_export$Nombre_del_plan <- gsub(pattern = "_", replacement = " ", x = mit_export$Nombre_del_plan)
mit_export$Nombre_del_plan <- paste0("SECAP_Mitigation_",mit_export$Nombre_del_plan)

noms_plans_INERGY <- read_excel(path = "Plantilles INERGY/Revisió Pau/Noms plans Mesures Gironaxlsx.xlsx", col_names = T)
# mit_export$Nombre_del_plan <- NA
for (ID in unique(mit_export$ID_Proyecto[!mit_export$ID_Proyecto == "NA"])) {
  if (length(noms_plans_INERGY$`Nombre del plan_MITIGATION`[which(noms_plans_INERGY$`ID Proyecto`==ID)])>0) {
    mit_export$Nombre_del_plan[mit_export$ID_Proyecto == ID] <- noms_plans_INERGY$`Nombre del plan_MITIGATION`[which(noms_plans_INERGY$`ID Proyecto`==ID)]
  }
}

unique(mit_export$Nombre_del_plan[mit_export$Nombre_del_plan %in% noms_plans_INERGY$`Nombre del plan_MITIGATION`])
unique(mit_export$ID_Proyecto)


# All the actions responsible entity to be listed in the same string with coma separated by comas
# Moreover the ones that have "-" or NA are completed with "Altrs"

# unique(mit_export$Responsable)

mit_export$Responsable <- gsub(pattern = " \r", replacement = "\r", x = mit_export$Responsable)
mit_export$Responsable <- gsub(pattern = "\r\n", replacement = ", ", x = mit_export$Responsable)
mit_export$Responsable <- gsub(pattern = " \t", replacement = "", x = mit_export$Responsable)
mit_export$Responsable <- gsub(pattern = "\\, $", replacement = "", x = mit_export$Responsable)

mit_export$Responsable[mit_export$Responsable %in% c("-", NA)] <- "Altres"

unique(mit_export$Responsable)

#Delate number in front of measure names. it have no sense when they are going to be sorted differently

unique(mit_export$Título_de_la_medida)
mit_export$Título_de_la_medida[startsWith(mit_export$Título_de_la_medida,"*")] <- gsub(pattern = "^.", replacement = "", x = mit_export$Título_de_la_medida[startsWith(mit_export$Título_de_la_medida,"*")])

mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))] <- 
  substring(text = mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))], first = 2)

mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))] <- 
  substring(text = mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))], first = 2)

mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == "."] <- 
  substring(text = mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == "."], first = 2)

mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))] <- 
  substring(text = mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))], first = 2)

mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))] <- 
  substring(text = mit_export$Título_de_la_medida[!is.na(as.numeric(substring(text = mit_export$Título_de_la_medida, first = 1, last = 1)))], first = 2)

mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == "."] <- 
  substring(text = mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == "."], first = 2)

mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == " "] <- 
  substring(text = mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == " "], first = 2)

mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == " "] <- 
  substring(text = mit_export$Título_de_la_medida[substring(text = mit_export$Título_de_la_medida, first = 1, last = 1) == " "], first = 2)

unique(mit_export$Título_de_la_medida)
sum(is.na(mit_export$Título_de_la_medida))

#Ahorro energético total [kWh]: without decimals, with dot separating thousands.
mit_export$Ahorro_energético_total_kWh
mit_export$Ahorro_energético_total_kWh <- round(x = mit_export$Ahorro_energético_total_kWh, digits = 0)

#Producción energía renovable [kWh]: without decimals, with dot separating thousands.
mit_export$Producción_energía_renovable_kWh
mit_export$Producción_energía_renovable_kWh <- round(x = mit_export$Producción_energía_renovable_kWh, digits = 0)

#Emisiones evitadas [tCO2]:
# 1) NQ, SD, - (non numeric values): assigned to value = 0.
# 2) change dot by coma.
# 3) with one decimal, with dot separating thousands.
mit_export$Emisiones_evitadas_tCO2
mit_export$Emisiones_evitadas_tCO2 <- round(x = as.numeric(mit_export$Emisiones_evitadas_tCO2), digits = 1)
sum(is.na(mit_export$Emisiones_evitadas_tCO2))
mit_export$Emisiones_evitadas_tCO2[is.na(mit_export$Emisiones_evitadas_tCO2)] <- 0

# Coste [€]:
#   1) non numeric value = 0.
# 2) change dots by comas.
# 3) with 2 decimals, dot separating thousands.
mit_export$Coste_Eur
mit_export$Coste_Eur <- round(x = as.numeric(mit_export$Coste_Eur), digits = 2)
sum(is.na(mit_export$Coste_Eur))
mit_export$Coste_Eur[is.na(mit_export$Coste_Eur)] <- 0

# Año de inicio: if there is no initial date indicate 2023.
mit_export$Año_de_inicio <- as.numeric(mit_export$Año_de_inicio)
sum(is.na(mit_export$Año_de_inicio))
mit_export$Año_de_inicio[is.na(mit_export$Año_de_inicio)] <- 2023
unique(mit_export$Año_de_inicio)

# Año de fin: if there is no end date indicate 2030.
mit_export$Año_de_fin <- as.numeric(mit_export$Año_de_fin)
sum(is.na(mit_export$Año_de_fin))
mit_export$Año_de_fin[is.na(mit_export$Año_de_fin)] <- 2030
unique(mit_export$Año_de_fin)



unique(mit_export$Nombre_del_plan)
mit_export$Nombre_del_plan[mit_export$Nombre_del_plan == "SECAP_Mitigation_Darnius,"] <- "SECAP_Mitigation_Darnius"

mit_export$Responsable <- gsub(pattern = "Consell comarcal", x = mit_export$Responsable, replacement = "Consell Comarcal")

mit_export$Responsable[mit_export$Responsable == "Agència d’Energia del Ripollès"] <- "Agència de l’Energia del Ripollès"
mit_export$Responsable[mit_export$Responsable == "Agència d'Energia del Ripollès"] <- "Agència de l’Energia del Ripollès"
mit_export$Responsable[mit_export$Responsable == "l’Agència d’Energia del Ripollès"] <- "Agència de l’Energia del Ripollès"


sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Campdevànol"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Campdevànol" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Gombrèn"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Gombrèn" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Les Llosses"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Les Llosses" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Les Llosses" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntament"] <- "Ajuntament, Consell Comarcal"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Ogassa"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Ogassa" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Ripoll"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Ripoll" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Ripoll" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntament"] <- "Ajuntament, Consell Comarcal"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Joan de les Abadesses"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Pau de Segúries"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Pau de Segúries" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vallfogona de Ripollès"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vallfogona de Ripollès" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vidrà"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vidrà" &
                         mit_export$Responsable == "Consell Comarcal"] <- "Consell Comarcal del Ripollès"
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vidrà" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntament"] <- "Ajuntament, Consell Comarcal"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Cadaqués"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Colera"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Port de la Selva"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Port de la Selva" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Llançà"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Llançà" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Ajuntament, Consell Comarcal"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Palau-saverdera"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Palau-saverdera" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Ajuntament, Consell Comarcal"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Pau"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Pau" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Ajuntament, Consell Comarcal"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Portbou"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Portbou" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Ajuntament, Consell Comarcal"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Roses"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vilajuïga"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Begur"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Begur" &
                         mit_export$Responsable == "Ajuntament, Oficina comarcal de transició energètica"] <- "Ajuntament, Oficina comarcal de Transició Energètica"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Calonge i Sant Antoni"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Castell-Platja d'Aro"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Mont-ras"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Palafrugell"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Palafrugell" &
                         mit_export$Responsable == "Ajuntament: Àrea d’Urbanisme, Àrea de Medi Ambient"] <- "Ajuntament: Àrea d'Urbanisme, Àrea de Medi Ambient"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Palamós"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Regencós"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Santa Cristina d'Aro"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Santa Cristina d'Aro" &
                         mit_export$Responsable == "Ajuntment, Oficina comarcal de Transició Energètica"] <- "Ajuntament, Oficina Comarcal de Transició Energètica"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Feliu de Guíxols"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Feliu de Guíxols" &
                         mit_export$Responsable == "Ajuntament: Àrea sostenibilitat, manteniment i serveis."] <- "Ajuntament: Àrea sostenibilitat, manteniment i serveis"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vall-llobrega"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Alp"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Alp" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Bolvir"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Bolvir" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Das"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Das" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Fontanals de Cerdanya"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Fontanals de Cerdanya" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Ger"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Ger" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Guils de Cerdanya"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Guils de Cerdanya" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Isòvol"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Isòvol" &
                         mit_export$Responsable == "Consell Comarcal, Ajuntaments"] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Llívia"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Llívia" &
                         (mit_export$Responsable == "Consell Comarcal, Ajuntaments" |
                            mit_export$Responsable == "Ajuntament, Consell Comarcal" )] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Meranges"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Meranges" &
                         (mit_export$Responsable == "Consell Comarcal, Ajuntaments" |
                            mit_export$Responsable == "Ajuntament, Consell Comarcal" )] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Puigcerdà"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Puigcerdà" &
                         (mit_export$Responsable == "Consell Comarcal, Ajuntaments" |
                            mit_export$Responsable == "Ajuntament, Consell Comarcal" )] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Urús"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Urús" &
                         (mit_export$Responsable == "Consell Comarcal, Ajuntaments" |
                            mit_export$Responsable == "Ajuntament, Consell Comarcal" )] <- "Consell Comarcal, Ajuntament"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Banyoles"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Banyoles" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Camós"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Camós" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Cornellà del Terri"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Cornellà del Terri" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Fontcoberta"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Fontcoberta" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Maià de Montcal"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Maià de Montcal" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Palol de Revardit"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Palol de Revardit" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Porqueres"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Porqueres" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Serinyà"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Serinyà" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Aiguaviva"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Aiguaviva" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Fornells de la Selva"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Fornells de la Selva" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Girona"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Girona" &
                         mit_export$Responsable == "Serveis urbans"] <- "Serveis Urbans"
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Girona" &
                         mit_export$Responsable == "Serveis urbansi gestió econòmica"] <- "Serveis urbans i gestió econòmicas"
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Girona" &
                         mit_export$Responsable == "Serveis Urbansi Gestió Econòmica o Tresoreria"] <- "Serveis Urbans i Gestió Econòmica o Tresoreria"
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Girona" &
                         mit_export$Responsable == "Urbanisme(Oficinatècnica d’enginyeria)"] <- "Urbanisme (Oficina tècnica d’enginyeria)"
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Girona" &
                         mit_export$Responsable == "Llicències (Urbanisme)"] <- "Urbanisme (departament d’obres i llicències)"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Riudellots de la Selva"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Riudellots de la Selva" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Julià de Ramis"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Julià de Ramis" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sarrià de Ter"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sarrià de Ter" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vilablareix"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vilablareix" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Amer"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Amer" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Canet d'Adri"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Canet d'Adri" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Aniol de Finestres"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Aniol de Finestres" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Gregori"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Gregori" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Julià del Llor i Bonmatí"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Julià del Llor i Bonmatí" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Martí de Llémena"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Martí de Llémena" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Miquel de Campmajor"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Miquel de Campmajor" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Agullana"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Agullana" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Cantallops"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Cantallops" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Capmany"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Capmany" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Darnius"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Darnius" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Espolla"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Espolla" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_La Jonquera"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_La Jonquera" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_La Vajol"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_La Vajol" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Maçanet de Cabrenys"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Maçanet de Cabrenys" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Masarac"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Masarac" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Rabos"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Rabos" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Climent Sescebes"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sant Climent Sescebes" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vilamaniscle"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vilamaniscle" &
                         mit_export$Responsable == "Ajuntaments i administracions públiques supramunicipals"] <- "Ajuntament i administracions públiques supramunicipals"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Albanyà"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Beuda"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Montagut i Oix"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Sales de Llierca"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Tortellà"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Camprodon"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Llanars"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Molló"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Setcases"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Setcases" &
                         mit_export$Responsable == "Ajuntament de Camprodon"] <- "Ajuntament de Setcases"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Vilalloga de Ter"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Arbúcies"]))

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Breda"]))
mit_export$Responsable[mit_export$Nombre_del_plan == "SECAP_Mitigation_Breda" &
                         mit_export$Responsable == "Ajuntament d'Arbúcies"] <- "Ajuntament de Breda"

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""

sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""



sort(unique(mit_export$Responsable[mit_export$Nombre_del_plan == ""]))
mit_export$Responsable[mit_export$Nombre_del_plan == "" &
                         mit_export$Responsable == ""] <- ""




# ########################## FILTER TO EXPORT MITIGATION FORMAT TO EPLANET PLATFORM ##########################
# 
# mit_export <- mit_export[!mit_export$ID_Proyecto == "NA",]
# 
# 
# 
# ID_responsable <- unique(mit_export[c("ID_Proyecto", "Responsable")])
# names(ID_responsable) <- c("ID", "Responsable")
# 
# plans_mitigacio <- unique(mit_export[c("ID_Proyecto", "Nombre_del_plan")])
# 
# # #Identificació dels plans
# # write_xlsx(
# #   plans_mitigacio,
# #   path = "Plans_mitigació.xlsx",#tempfile(fileext = "ID_responsable.xlsx"),
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )
# # 
# # # Full responsables
# # write_xlsx(
# #   ID_responsable,
# #   path = "ID_responsable_mit.xlsx",#tempfile(fileext = "ID_responsable.xlsx"),
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )
# # 
# # # 
# # write_xlsx(
# #   mit_export,
# #   path = "Mesures_mit.xlsx",#tempfile(fileext = "ID_responsable.xlsx"),
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )

########################## ADAPTATION - HARMONIZATION TO EPLANET MODEL ##########################

totes_accions_ada <- rbind(accio_ada_ARDA, accio_ada_ARUM, accio_ada_OICOS)

unique(totes_accions_ada$Sector)
totes_accions_ada <- ada_harm_Sector(totes_accions_ada)
unique(totes_accions_ada$Sector)


unique(totes_accions_ada$Registre.climatic)
totes_accions_ada <- ada_harm_Registre(totes_accions_ada)
unique(totes_accions_ada$Registre.climatic)


unique(totes_accions_ada$Afecta.la.mitigació..Si.No.)
totes_accions_ada <- ada_harm_Mitigacio(totes_accions_ada)
unique(totes_accions_ada$Afecta.la.mitigació..Si.No.)

unique(totes_accions_ada$Estat.d.execucio)


accions <- totes_accions_ada
unique(accions$Afecta.la.mitigació..Si.No.)


ada_export <- ada_format_Inergy(totes_accions_ada)

unique(ada_export$ID_Proyecto)
length(unique(ada_export$ID_Proyecto))-1

# ada_export$Nombre_del_plan <- paste0("PAESC_Adptació_", gsub(pattern = "_Adaptació", replacement = "", x = ada_export$Nombre_del_plan))

#Agafar noms dels plans existents a INERGY
ada_export$Nombre_del_plan <- gsub(pattern = "_Adaptació", replacement = "", x = ada_export$Nombre_del_plan)
ada_export$Nombre_del_plan <- gsub(pattern = "_", replacement = " ", x = ada_export$Nombre_del_plan)
ada_export$Nombre_del_plan <- paste0("SECAP_Adaptation_",ada_export$Nombre_del_plan)

# ada_export$Nombre_del_plan <- NA
for (ID in unique(ada_export$ID_Proyecto[!ada_export$ID_Proyecto == "NA"])) {
  if (length(noms_plans_INERGY$`Nombre del plan_ADAPTATION`[which(noms_plans_INERGY$`ID Proyecto`==ID)])>0) {
    ada_export$Nombre_del_plan[ada_export$ID_Proyecto == ID] <- noms_plans_INERGY$`Nombre del plan_ADAPTATION`[which(noms_plans_INERGY$`ID Proyecto`==ID)]
  }
}

unique(ada_export$Nombre_del_plan[ada_export$Nombre_del_plan %in% noms_plans_INERGY$`Nombre del plan_ADAPTATION`])
unique(ada_export$ID_Proyecto)
length(unique(ada_export$ID_Proyecto))

# All action responsible to be in a string without intros and separated by coma
# Moreover, the ones that are "-" or NA are completed with "Altres"

# unique(ada_export$Responsable)

ada_export$Responsable <- gsub(pattern = " \r", replacement = "\r", x = ada_export$Responsable)
ada_export$Responsable <- gsub(pattern = "\r\n", replacement = ", ", x = ada_export$Responsable)
ada_export$Responsable <- gsub(pattern = " \t", replacement = "", x = ada_export$Responsable)
ada_export$Responsable <- gsub(pattern = "\\, $", replacement = "", x = ada_export$Responsable)

ada_export$Responsable[ada_export$Responsable %in% c("-", NA)] <- "Altres"

unique(ada_export$Responsable)


# Coste [€]:
#   1) non numeric values: set to 0.
# 2) change dot by coma.
# 3) with two decimals, dot separating thousands.
ada_export$Coste_Eur
ada_export$Coste_Eur <- gsub(pattern = "\\-$", replacement = "", x = ada_export$Coste_Eur) #eliminate the dashes at the end

ada_export$Coste_Eur[grepl(pattern = "-", x = ada_export$Coste_Eur)] <- #if there is a range keep the highest value
  substr(x = ada_export$Coste_Eur[grepl(pattern = "-", x = ada_export$Coste_Eur)], 
       start = unlist(gregexpr("-", ada_export$Coste_Eur[grepl(pattern = "-", x = ada_export$Coste_Eur)]))+1, 
       stop = nchar(ada_export$Coste_Eur[grepl(pattern = "-", x = ada_export$Coste_Eur)]))

ada_export$Coste_Eur <- round(x = as.numeric(ada_export$Coste_Eur), digits = 2)
sum(is.na(ada_export$Coste_Eur))
ada_export$Coste_Eur[is.na(ada_export$Coste_Eur)] <- 0

# Ahorro anual [€]: set to 0.
unique(ada_export$Ahorro_anual_Eur)
ada_export$Ahorro_anual_Eur <- 0
unique(ada_export$Ahorro_anual_Eur)
ada_export[ada_export$Ahorro_anual_Eur == 2023,]


# Año de inicio: if empty, set to 2023.
ada_export$Año_de_inicio <- as.numeric(ada_export$Año_de_inicio)
sum(is.na(ada_export$Año_de_inicio))
ada_export$Año_de_inicio[is.na(ada_export$Año_de_inicio)] <- 2023
ada_export$Año_de_inicio[ada_export$Año_de_inicio==0] <- 2023
unique(ada_export$Año_de_inicio)

# Año de fin: if empty, set to 2030.
unique(ada_export$Año_de_fin)
ada_export$Año_de_fin <- as.numeric(ada_export$Año_de_fin)
sum(is.na(ada_export$Año_de_fin))
ada_export$Año_de_fin[is.na(ada_export$Año_de_fin)] <- 2030
ada_export$Año_de_fin[ada_export$Año_de_fin==0] <- 2023
unique(ada_export$Año_de_fin)

# ########################## FILTER TO EXPORT ADAPTATION FORMAT TO EPLANET PLATFORM ##########################
# 
# ada_export <- ada_export[!ada_export$ID_Proyecto == "NA",]
# 
# ID_responsable_ada <- unique(ada_export[c("ID_Proyecto", "Responsable")])
# names(ID_responsable) <- c("ID", "Responsable")
# 
# plans_adaptacio <- unique(ada_export[c("ID_Proyecto", "Nombre_del_plan")])
# 
# # #Identificació dels plans
# # write_xlsx(
# #   plans_adaptacio,
# #   path = "Plans_adaptació.xlsx",
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )
# #
# # # Full responsables
# # write_xlsx(
# #   ID_responsable_ada,
# #   path = "ID_responsable_ada.xlsx",
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )
# #
# # #Mesures adaptació
# # write_xlsx(
# #   ada_export,
# #   path = "Mesures_ada.xlsx",
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )




# UP Salines does not have adaptation measures, delate actions entreies that appears as NA




########################## ECOSERVEIS FUNCIONS ##########################


ECO_mit_harm_Sector <- function(accions) {
  # accions <- accio_mit_ECO
  accions$Sector[grepl(pattern = "Calefacció i refrigeració local", x = accio_mit_ECO$Sector) |
                   grepl(pattern = "Calefacció i refrigeració local", x = accio_mit_ECO$Sector) |
                   accions$Sector == "Producció local d’electricitat i Producció local de calor/fred" |
                   accions$Sector == "Biomassa"
  ] <- "772 - Producció local de Calefacció/refrigeració"
  
  accions$Sector[accions$Sector == "Producció local d’electricitat" |
                   accions$Sector == "Producció local d’energia renovable"
  ] <- "773 - Producció local d’electricitat"
  
  accions$Sector[accions$Sector == "Transport"] <- "774 - Transport"
  
  accions$Sector[accions$Sector == "Industrial"] <- "775 - Industria"
  
  accions$Sector[accions$Sector == "Enllumenat públic"] <- "776 - Enllumenat públic"
  
  accions$Sector[grepl(pattern = "Edificis", x = accio_mit_ECO$Sector)|
                   accions$Sector == "Residencial"
  ] <- "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  
  accions$Sector[accions$Sector == "Altres" |
                   accions$Sector == "Residus"|
                   accions$Sector == "Municipal"] <- "771 - Altres"
  
  # unique(accions$Sector)
  return(accions)
}




ECO_mit_harm_A.Intervencio <- function(accions) {
  # accions <- accio_mit_ECO
  accions$Area.d.intervencio <- gsub("\r", "", accions$Area.d.intervencio)
  accions$Area.d.intervencio <- gsub("\n", "", accions$Area.d.intervencio)
  
  ###Sector == "771 - Altres"
  # sort(unique(accions$Area.d.intervencio[accions$Sector == "771 - Altres"]))
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" &
                               (accions$Area.d.intervencio == "Altres" |
                                  accions$Area.d.intervencio == "Acció integral" |
                                  accions$Area.d.intervencio == "Canvi de comportament" |
                                  accions$Area.d.intervencio == "Acció integrada"
                               )] <- "830 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" &
                               (accions$Area.d.intervencio == "")
  ] <- "831 - Relacionat amb l’agricultura i la silvicultura"
  
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" &
                               (accions$Area.d.intervencio == "")
  ] <- "832 - Plantació d’arbres en zones urbanes"
  
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" &
                               (grepl(pattern = "Gestió", x = accions$Area.d.intervencio) &
                                  grepl(pattern = "residus", x = accions$Area.d.intervencio) |
                                  accions$Area.d.intervencio == "Residus"
                               )] <- "833 - Gestió de residus i aigües residuals"
  
  accions$Area.d.intervencio[accions$Sector == "771 - Altres" &
                               (accions$Area.d.intervencio == "")] <- "834 - Regeneració urbana"
  
  
  
  
  ###Sector == "772 - Producció local de Calefacció/refrigeració"
  # sort(unique(accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració"]))
  
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" &
                               (grepl(pattern = "Biomassa", x = accions$Area.d.intervencio) |
                                  accions$Area.d.intervencio == "Calefacció/refrigeració"
                               )] <- "826 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" &
                               (accions$Area.d.intervencio == ""
                               )] <- "827 - Xarxa de calefacció/refrigeració urbana (nova instal·lació, ampliació, reforma)"
  
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" &
                               (accions$Area.d.intervencio == ""
                               )] <- "828 - Planta de calefacció/refrigeració urbana"
  
  accions$Area.d.intervencio[accions$Sector == "772 - Producció local de Calefacció/refrigeració" &
                               (grepl(pattern = "cogeneració", x = accions$Area.d.intervencio)
                               )] <- "829 - Cogeneració"
  
  
  
  
  ###Sector == "773 - Producció local d’electricitat"
  # sort(unique(accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat"]))
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" &
                               (accions$Area.d.intervencio == "Altres" |
                                  accions$Area.d.intervencio == "Canvis en el comportament" |
                                  accions$Area.d.intervencio == "Canvis de comportaments" |
                                  accions$Area.d.intervencio == "Acció integrada"
                               )] <- "819 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" &
                               (accions$Area.d.intervencio == ""
                               )] <- "820 - Xarxes intel·ligents"
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" &
                               (accions$Area.d.intervencio == ""
                               )] <- "821 - Cogeneració"
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" &
                               (accions$Area.d.intervencio == ""
                               )] <- "822 - Planta de biomassa"
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" &
                               (accions$Area.d.intervencio == ""
                               )] <- "823 - Energia fotovoltaica"
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" &
                               (accions$Area.d.intervencio == "Fotovoltaica"
                               )] <- "824 - Energia eòlica"
  
  accions$Area.d.intervencio[accions$Sector == "773 - Producció local d’electricitat" &
                               (accions$Area.d.intervencio == ""
                               )] <- "825 - Energia hidroelèctrica"
  
  
  
  
  ###Sector == "774 - Transport"
  # sort(unique(accions$Area.d.intervencio[accions$Sector == "774 - Transport"]))
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == "Acció integrada"
                               )] <- "808 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == "Conducció eficient i sostenible" |
                                  accions$Area.d.intervencio == "Conducció eficient isostenible" |
                                  accions$Area.d.intervencio == "Conducció eficienti sostenible"
                               )] <- "809 - Conducció ecològica"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "810 - Tecnologies de la informació i les comunicacions"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "811 - Urbanització d’ús mixta i contenció de l’expansió"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "812 - Optimització de la xarxa de carreteres"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "813 - Millora de les operacions de logística i del transport urbà de mercaderies"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "814 - Ús compartit d’automòbils"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "815 - Transferència modal cap als trajectes a peu i en bicicleta"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "816 - Transferència modal cap al transport públic"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == ""
                               )] <- "817 - Vehicles elèctrics (inc. infraestructures)"
  
  accions$Area.d.intervencio[accions$Sector == "774 - Transport" &
                               (accions$Area.d.intervencio == "Vehicle elèctric"
                               )] <- "818 - Vehicles més nets/eficients"
  
  
  
  ###Sector == "775 - Industria"
  # sort(unique(accions$Area.d.intervencio[accions$Sector == "775 - Industria"]))
  accions$Area.d.intervencio[accions$Sector == "775 - Industria" &
                               (accions$Area.d.intervencio == "Gestió integral" |
                                  accions$Area.d.intervencio == "Industrial"
                               )] <- "803 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "775 - Industria" &
                               (accions$Area.d.intervencio == ""
                               )] <- "804 - Tecnologies de la informació i les comunicacions"
  
  accions$Area.d.intervencio[accions$Sector == "775 - Industria" &
                               (accions$Area.d.intervencio == ""
                               )] <- "805 - Energia renovable"
  
  accions$Area.d.intervencio[accions$Sector == "775 - Industria" &
                               (accions$Area.d.intervencio == ""
                               )] <- "806 - Eficiència energètica en edificis"
  
  accions$Area.d.intervencio[accions$Sector == "775 - Industria" &
                               (accions$Area.d.intervencio == ""
                               )] <- "807 - Eficiència energètica en processos industrials"
  
  
  
  ###Sector == "776 - Enllumenat públic"
  # sort(unique(accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic"]))
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" &
                               (accions$Area.d.intervencio == "Altres"
                               )] <- "799 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" &
                               (accions$Area.d.intervencio == ""
                               )] <- "800 - Tecnologies de la informació i les comunicacions"
  
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" &
                               (accions$Area.d.intervencio == ""
                               )] <- "801 - Energia renovable integrada"
  
  accions$Area.d.intervencio[accions$Sector == "776 - Enllumenat públic" &
                               (accions$Area.d.intervencio == ""
                               )] <- "802 - Eficiència energètica"
  
  
  
  
  ###Sector == "776 - Enllumenat públic"
  # sort(unique(accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"]))
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (accions$Area.d.intervencio == "Altres" |
                                  grepl("Sensibilització", accions$Area.d.intervencio)
                               )] <- "790 - Altres"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (accions$Area.d.intervencio == ""
                               )] <- "791 - Modificacions d’hàbits"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (grepl("Tecnologies de la informació", accions$Area.d.intervencio)
                               )] <- "792 - Tecnologies de la informació i les comunicacions"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (accions$Area.d.intervencio == "Acció integrada" |
                                  accions$Area.d.intervencio == "Acció integral"
                               )] <- "793 - Acció integrada (tot l’anterior)"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (grepl("Electrodomèstics", accions$Area.d.intervencio)
                               )] <- "794 - Electrodomèstics eficients"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (accions$Area.d.intervencio == ""
                               )] <- "795 - Sistemes d’enllumenat eficient"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (accions$Area.d.intervencio == "Energia renovable per calefacció d’espais i subministrament d’aigua calenta"
                               )] <- "796 - Eficiència energètica en calefacció d’espais i subministres d’aigua calenta"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (accions$Area.d.intervencio == "Fotovoltaica" |
                                  accions$Area.d.intervencio == "Geotèrmia" |
                                  accions$Area.d.intervencio == "Integració d’energies renovables"
                               )] <- "797 - Energia renovable per a calefacció d’espais i subministres d’aigua calenta"
  
  accions$Area.d.intervencio[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                               (accions$Area.d.intervencio == "Envolupant d’edificis" |
                                  accions$Area.d.intervencio == "Envolupantd’edificis"
                               )] <- "798 - Envolupant d’edificis"
  
  # sort(unique(accions$Area.d.intervencio))
  return(accions)
}




ECO_mit_harm_Categoria_us <- function(accions) {
  accions$Categoria_us <- NA
  
  accions$Categoria_us[is.na(accions$Categoria_us) &
                         grepl("enllumenat públic", accions$Titol.de.la.mesura)
  ] <- "80 - Enllumenat"
  
  accions$Categoria_us[is.na(accions$Categoria_us) &
                         grepl("flota municipal", accions$Titol.de.la.mesura)
  ] <- "40 - Flota municipal"
  
  accions$Categoria_us[is.na(accions$Categoria_us) & (
    grepl("mobilitat", accions$Titol.de.la.mesura) |
      grepl("vehicle", accions$Titol.de.la.mesura) |
      grepl("(fibra)", accions$Titol.de.la.mesura)
  )] <- "50 - Mobilitat"
  
  accions$Categoria_us[is.na(accions$Categoria_us) & (
    grepl("edificis", accions$Titol.de.la.mesura) |
      grepl("habitatges", accions$Titol.de.la.mesura)|
      grepl("autoconsum", accions$Titol.de.la.mesura)|
      grepl("equipaments públics", accions$Titol.de.la.mesura)
  )] <- "10 - Edificis"
  
  accions$Categoria_us[is.na(accions$Categoria_us) & (
    grepl("llar", accions$Titol.de.la.mesura) |
      grepl("residencial", accions$Titol.de.la.mesura) |
      grepl("(PaP)", accions$Titol.de.la.mesura) |
      grepl("electrodomèstics", accions$Titol.de.la.mesura)
  )] <- "60 - Residencial"
  
  accions$Categoria_us[is.na(accions$Categoria_us) & (
    grepl("Crear un punt d’informació", accions$Titol.de.la.mesura) |
      grepl("(ACE)", accions$Titol.de.la.mesura)
  )] <- "70 - Serveis"
  
  accions$Categoria_us[is.na(accions$Categoria_us) & (
    grepl("energi", accions$Titol.de.la.mesura)|
      grepl("biomass", accions$Titol.de.la.mesura)
  )] <- "10 - Edificis"
  
  accions$Categoria_us[is.na(accions$Categoria_us) & (
    grepl("auditor", accions$Titol.de.la.mesura) |
      grepl("taxes", accions$Titol.de.la.mesura) |
      grepl("geot", accions$Titol.de.la.mesura) |
      grepl("industri", accions$Titol.de.la.mesura) |
      grepl("Maximit", accions$Titol.de.la.mesura) |
      grepl("Maximit", accions$Titol.de.la.mesura) |
      grepl("Maximit", accions$Titol.de.la.mesura) |
      grepl("Maximit", accions$Titol.de.la.mesura) |
      grepl("Maximit", accions$Titol.de.la.mesura)
  )] <- "10 - Edificis"
  
  accions$Categoria_us[is.na(accions$Categoria_us)] <- "10 - Edificis"
  
  return(accions)
}


ECO_mit_harm_Categoria_ambit <- function(accions){
  # accions <- accio_mit_ECO
  accions$Categoria.de.l.ambit <- NA
  
  ### Categoria_us == "10 - Edificis"
  sort(unique(accions$Titol.de.la.mesura[accions$Categoria_us == "10 - Edificis" &
                                           is.na(accions$Categoria.de.l.ambit)]))
  
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" &
                                 (grepl("biomassa", accions$Titol.de.la.mesura) |
                                    grepl("calderes", accions$Titol.de.la.mesura)
                                 )
  ] <- "11 - Calefacción"
  
  # accions$Categoria.de.l.ambit[accions$Categoria_us == "10 - Edificis" &
  #                              (
  #                               )] <- "12 - Refrigeración"
  # 
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" &
                                 (grepl("ACS", accions$Titol.de.la.mesura)
                                 )] <- "13 - Agua caliente sanitaria ACS"
  # 
  # accions$Categoria.de.l.ambit[accions$Categoria_us == "10 - Edificis" &
  #                              (
  #                               )] <- "14 - Iluminación"
  # 
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "10 - Edificis" &
  #                                (grepl("electrodomèstics", accions$Titol.de.la.mesura)
  #                                )] <- "15 - Equipos eléctricos"
  
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" &
                                 (grepl("rehabilitació", accions$Titol.de.la.mesura)
                                 )] <- "16 - Envolvente"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" &
                                 (grepl("energia renovable", accions$Titol.de.la.mesura) |
                                    grepl("Comptabilitat energètica", accions$Titol.de.la.mesura) |
                                    grepl("energia verda", accions$Titol.de.la.mesura) |
                                    grepl("fotovoltai", accions$Titol.de.la.mesura) |
                                    grepl("geotèrm", accions$Titol.de.la.mesura) |
                                    grepl("Geotèrm", accions$Titol.de.la.mesura) |
                                    grepl("renovable", accions$Titol.de.la.mesura) |
                                    grepl("Cessió d’espais de propietat municipal per a projectes privats", accions$Titol.de.la.mesura)|
                                    grepl("biogàs", accions$Titol.de.la.mesura) |
                                    grepl("instal·lació d’energia solar tèrmica", accions$Titol.de.la.mesura) |
                                    grepl("campanya d’estalvi energètic", accions$Titol.de.la.mesura) |
                                    grepl("infraestructures necessàries per realitzar la transició energètica", accions$Titol.de.la.mesura) |
                                    grepl("Estudi del potencial eòlic de", accions$Titol.de.la.mesura)
                                 )] <- "18 - Generación renovable"
  
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" &
                                 (grepl("informació energética", accions$Titol.de.la.mesura) |
                                    grepl("aïllaments", accions$Titol.de.la.mesura) |
                                    grepl("assessora", accions$Titol.de.la.mesura) |
                                    grepl("informació", accions$Titol.de.la.mesura) |
                                    grepl("planificació", accions$Titol.de.la.mesura) |
                                    grepl("autoconsum", accions$Titol.de.la.mesura) |
                                    grepl("Promoure el debat", accions$Titol.de.la.mesura) |
                                    grepl("Promoure l'adhesió de les empreses al Programa d'acords", accions$Titol.de.la.mesura) |
                                    grepl("Bonificació en taxes municipals per incentivar la transició energètica", accions$Titol.de.la.mesura) |
                                    grepl("bonificar i agilitzar els tràmits d’implementació", accions$Titol.de.la.mesura) |
                                    grepl("participació del sector empresarial", accions$Titol.de.la.mesura) |
                                    grepl("Crear la figura del gestor energètic supramunicipal", accions$Titol.de.la.mesura) |
                                    grepl("Gestor energètic", accions$Titol.de.la.mesura) |
                                    grepl("Impulsar una taula de coordinació", accions$Titol.de.la.mesura) |
                                    grepl("Informació, sensibilització, difusió", accions$Titol.de.la.mesura) |
                                    grepl("Crear recursos per sensibilitzar i promoure la participació ciutadana", accions$Titol.de.la.mesura) |
                                    grepl("Planificació de comunitats energètiques tèrmiques", accions$Titol.de.la.mesura) |
                                    grepl("Planificació urbanística", accions$Titol.de.la.mesura) |
                                    grepl("Sensibilització i participació ciutadana", accions$Titol.de.la.mesura) |
                                    grepl("Taula de coordinació", accions$Titol.de.la.mesura)
                                 )] <- "17 - Gestión energética"
  
  
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "10 - Edificis" &
                                 (grepl("Maximitzar l’eficiència", accions$Titol.de.la.mesura) |
                                    grepl("industrial", accions$Titol.de.la.mesura)
                                 )] <- "109 - Cambios en el edficio"
  
  accions$Categoria_us[
    accions$Titol.de.la.mesura == "Organitzar cursos de conducció eficient a la ciutadania" |
      accions$Titol.de.la.mesura == "Organitzar cursos de conducció eficient a la ciutadania"|
      accions$Titol.de.la.mesura == "Mobilitat sostenible"|
      accions$Titol.de.la.mesura == "Impulsar la Mobilitat sostenible a l’Empordanet"
  ] <- "50 - Mobilitat"
  
  accions$Categoria.de.l.ambit[
    accions$Titol.de.la.mesura == "Impulsar una campanya de prevenció de residus"
  ] <- "17 - Gestión energética"
  
  accions$Categoria.de.l.ambit[
    accions$Titol.de.la.mesura == "Realitzar accions divulgatives sobre la cultura energètica a través dels centres educatius, l'associacionisme, els mitjans de comunicació, entre altres"
  ] <- "17 - Gestión energética"
  
  
  
  ### Categoria_us == "40 - Flota municipal"
  # sort(unique(accions$Titol.de.la.mesura[accions$Categoria_us == "40 - Flota municipal" &
  #                                          is.na(accions$Categoria.de.l.ambit)]))
  # sort(unique(accions$Titol.de.la.mesura[accions$Categoria_us == "40 - Flota municipal"]))
  # sort(unique(accions$Categoria_us[accions$Categoria_us == "40 - Flota municipal"]))
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "40 - Flota municipal" &
                                 (grepl("Adquisició de vehicles", accions$Titol.de.la.mesura)
                                 )] <- "401 - Flota vehículos"
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "40 - Flota municipal" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "402 - Gestión"
  
  
  ### Categoria_us == "50 - Mobilitat"
  # sort(unique(accions$Titol.de.la.mesura[accions$Categoria_us == "50 - Mobilitat" &
  #                                          is.na(accions$Categoria.de.l.ambit)]))
  # (unique(accions$Categoria.de.l.ambit[accions$Categoria_us == "50 - Mobilitat"]))
  
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" &
                                 (grepl("Impulsar els sistemes de mobilitat sostenible", accions$Titol.de.la.mesura) |
                                    grepl("cursos", accions$Titol.de.la.mesura) |
                                    grepl("Promoure", accions$Titol.de.la.mesura) |
                                    grepl("Promoció", accions$Titol.de.la.mesura) |
                                    grepl("Impulsar la Mobilitat", accions$Titol.de.la.mesura) |
                                    grepl("Impulsar la mobilitat", accions$Titol.de.la.mesura) |
                                    grepl("Impulsar una taula", accions$Titol.de.la.mesura) |
                                    grepl("Mobilitat sostenible", accions$Titol.de.la.mesura)
                                 )] <- "506 - Sensibilización y comunicación"
  
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" &
                                 (grepl("Bonificació de l’impost", accions$Titol.de.la.mesura) |
                                    grepl("Creació d’estructura de recàrrega", accions$Titol.de.la.mesura)
                                 )] <- "51 - Flota vehiculos"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "50 - Mobilitat" &
                                 (grepl("Impuls de les plataformes", accions$Titol.de.la.mesura) |
                                    grepl("Facilitar l’accés a les IT", accions$Titol.de.la.mesura) |
                                    grepl("plataformes d’ús compartit", accions$Titol.de.la.mesura)
                                 )] <- "52 - Gestión"
  
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "50 - Mobilitat" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "503 - Transporte público"
  # 
  # 
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "50 - Mobilitat" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "504 - Peatones"
  # 
  # 
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "50 - Mobilitat" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "505 - Bicicletas"
  
  # sort(unique(accions$Categoria.de.l.ambit[accions$Categoria_us == "50 - Mobilitat"]))
  # sum(is.na(accions$Categoria.de.l.ambit[accions$Categoria_us == "50 - Mobilitat"]))
  
  
  ### Categoria_us == "60 - Residencial"
  # sort(unique(accions$Titol.de.la.mesura[accions$Categoria_us == "60 - Residencial" &
  #                                          is.na(accions$Categoria.de.l.ambit)]))
  # unique(accions$Categoria.de.l.ambit[accions$Categoria_us == "60 - Residencial"])
  
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "60 - Residencial" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "61 - Urbanismo y edificación"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "60 - Residencial" &
                                 (grepl("(PaP)", accions$Titol.de.la.mesura) |
                                    grepl("electrodomèstics", accions$Titol.de.la.mesura) |
                                    grepl("estalvi energètic", accions$Titol.de.la.mesura)
                                 )] <- "62 - Comunicación y sensibilización"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "60 - Residencial" &
                                 (grepl("biomassa", accions$Titol.de.la.mesura)
                                 )] <- "603 - Renovables y autoconsumo"
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "60 - Residencial" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "604 - Pobreza energética"
  
  
  ### Categoria_us == "70 - Serveis"
  # sort(unique(accions$Titol.de.la.mesura[accions$Categoria_us == "70 - Serveis" &
  #                                          is.na(accions$Categoria.de.l.ambit)]))
  # unique(accions$Categoria.de.l.ambit[accions$Categoria_us == "70 - Serveis"])
  
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "70 - Serveis" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "71 - Urbanismo y edificación"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "70 - Serveis" &
                                 (grepl("punt d’informació", accions$Titol.de.la.mesura) |
                                    grepl("web de l’Agència", accions$Titol.de.la.mesura)
                                 )] <- "72 - Comunicación y sensibilización"
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "70 - Serveis" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "703 - Autoconsumo y renovables"
  
  
  ### Categoria_us == "80 - Enllumenat"
  # sort(unique(accions$Titol.de.la.mesura[accions$Categoria_us == "80 - Enllumenat" &
  #                                          is.na(accions$Categoria.de.l.ambit)]))
  # unique(accions$Categoria.de.l.ambit[accions$Categoria_us == "80 - Enllumenat"])
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "80 - Enllumenat" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "81 - Luminarias"
  
  accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
                                 accions$Categoria_us == "80 - Enllumenat" &
                                 (grepl("eficiència energètica de l’enllumenat", accions$Titol.de.la.mesura)
                                 )] <- "82 - Regulación y gestión"
  
  # accions$Categoria.de.l.ambit[is.na(accions$Categoria.de.l.ambit) &
  #                                accions$Categoria_us == "80 - Enllumenat" &
  #                                (grepl("", accions$Titol.de.la.mesura) |
  #                                   grepl("", accions$Titol.de.la.mesura)
  #                                )] <- "803 - Planificación"
  
  return(accions)
  
}


ECO_mit_harm_Instrument <- function(accions){
  # accions <- accio_mit_ECO
  
  ###Sector == "771 - Altres"
  # sort(unique(accions$Instrument[accio_mit_ECO$Sector == "771 - Altres"]))
  
  accions$Instrument[accions$Sector == "771 - Altres" &
                       (grepl("Sensibilització/formació", accions$Instrument)
                       )] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "771 - Altres" &
                       (grepl("Altres", accions$Instrument) |
                          grepl("Contractació pública", accions$Instrument) |
                          grepl("Gestió d’energia", accions$Instrument)
                       )] <- "130 - Otros"
  
  
  ###Sector == "772 - Producció local de Calefacció/refrigeració"
  # sort(unique(accions$Instrument[accio_mit_ECO$Sector == "772 - Producció local de Calefacció/refrigeració"]))
  
  accions$Instrument[accions$Sector == "772 - Producció local de Calefacció/refrigeració" &
                       (grepl("Altres", accions$Instrument)
                       )] <- "130 - Otros"
  
  
  ###Sector == "773 - Producció local d’electricitat"
  # sort(unique(accions$Instrument[accio_mit_ECO$Sector == "773 - Producció local d’electricitat"]))
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" &
                       (grepl("Ajudes i subvencions", accions$Instrument)
                       )] <- "136 - Subvenciones y ayudas"
  
  accions$Instrument[accions$Sector == "773 - Producció local d’electricitat" &
                       (grepl("Altres", accions$Instrument)
                       )] <- "130 - Otros"
  
  ###Sector == "774 - Transport"
  # sort(unique(accions$Instrument[accio_mit_ECO$Sector == "774 - Transport"]))
  
  accions$Instrument[accions$Sector == "774 - Transport" &
                       (grepl("Sensibilització/ formació", accions$Instrument)
                       )] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "774 - Transport" &
                       (grepl("Altres", accions$Instrument)
                       )] <- "130 - Otros"
  
  
  ###Sector == "775 - Industria"
  # sort(unique(accions$Instrument[accio_mit_ECO$Sector == "775 - Industria"]))
  
  accions$Instrument[accions$Sector == "775 - Industria" &
                       (grepl("Gestió integral", accions$Instrument)
                       )] <- "132 - Gestión de energía"
  
  accions$Instrument[accions$Sector == "775 - Industria" &
                       (grepl("Sensibilització/formació", accions$Instrument)
                       )] <- "131 - Sensibilización/formación"
  
  accions$Instrument[accions$Sector == "775 - Industria" &
                       (grepl("Altres", accions$Instrument)
                       )] <- "130 - Otros"
  
  
  ###Sector == "776 - Enllumenat públic"
  # sort(unique(accions$Instrument[accio_mit_ECO$Sector == "776 - Enllumenat públic"]))
  
  accions$Instrument[accions$Sector == "776 - Enllumenat públic" &
                       (grepl("Contractació pública", accions$Instrument)
                       )] <- "138 - Contratación pública"
  
  
  ###Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"
  sort(unique(accions$Instrument[accio_mit_ECO$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris"]))
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                       (grepl("Ajudes i subvencions", accions$Instrument)
                       )] <- "136 - Subvenciones y ayudas"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                       (grepl("Contractació pública", accions$Instrument)
                       )] <- "138 - Contratación pública"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                       (grepl("Finançament per tercers", accions$Instrument)
                       )] <- "137 - Financiación por terceros. Asociaciones público-privadas"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                       (grepl("Gestió d’energia", accions$Instrument) |
                          grepl("Gestió de l’energia", accions$Instrument)
                       )] <- "132 - Gestión de energía"
  
  accions$Instrument[accions$Sector == "777 - Edificis, equipament/instal·lacions municipals, residencials i terciaris" &
                       (grepl("Altres", accions$Instrument)
                       )] <- "130 - Otros"
  
  return(accions)
}

ECO_mit_harm_Origen <- function(accions) {
  
  # sort(unique(accions$Origen.de.l.accio))
  # sum(is.na(accions$Origen.de.l.accio))
  accions$Origen.de.l.accio <- "141 - Autoridad local"
  
  return(accions)
}


ECO_mit_harm_Nom_Pla <- function(accions) {
  taula_noms_plans <- read_excel(path = "Plantilles INERGY/Revisió Pau/Noms plans Mesures Gironaxlsx.xlsx")
  
  plans_id <-sort(unique(accions$ID.Proyecto))
  plans_id <- plans_id[!plans_id == "NA"]
  plans_id
  
  for (i in plans_id) {
    # i <- plans_id[1]
    
    accions$Nom.del.pla[accions$ID.Proyecto==i] <-
      taula_noms_plans$`Nombre del plan_MITIGATION`[which(taula_noms_plans$`ID Proyecto` == i)]
  }
  
  return(accions)
}


ECO_mit_harm_estalvi_ener <- function(accions) {
  # accions <- accio_mit_ECO
  accions$Estalvi.energètic.total..MWh. <- gsub(pattern = "\\.", replacement = '',
                                                x = accions$Estalvi.energètic.total..MWh.)
  
  accions$Estalvi.energètic.total..MWh. <- gsub(pattern = ",", replacement = '.',
                                                x = accions$Estalvi.energètic.total..MWh.)
  
  accions$Estalvi.energètic.total..MWh. <- as.numeric(accions$Estalvi.energètic.total..MWh.)
  
  accions$Estalvi.energètic.total..MWh. <- accions$Estalvi.energètic.total..MWh.*1000
  names(accions)[names(accions) == "Estalvi.energètic.total..MWh."] <- "Estalvi.energètic.total.kWh"
  
  accions$Estalvi.energètic.total.kWh <- as.integer(accions$Estalvi.energètic.total.kWh)
  accions$Estalvi.energètic.total.kWh <- format(round(as.numeric(accions$Estalvi.energètic.total.kWh), digits = 0), nsmall=0, big.mark=".", decimal.mark=",")
  accions$Estalvi.energètic.total.kWh <- gsub(pattern = " ", replacement = '',
                                                x = accions$Estalvi.energètic.total.kWh)
  accions$Estalvi.energètic.total.kWh <- gsub(pattern = "NA", replacement = '0,0',
                                              x = accions$Estalvi.energètic.total.kWh)
  # unique(accions$Estalvi.energètic.total.kWh)
  
  return(accions)
}


ECO_mit_harm_produccio_ren <- function(accions) {
  # accions <- accio_mit_ECO
  accions$Producció.d.energia.renovable..MWh. <- gsub(pattern = "\\.", replacement = '',
                                                x = accions$Producció.d.energia.renovable..MWh.)
  
  accions$Producció.d.energia.renovable..MWh. <- gsub(pattern = ",", replacement = '.',
                                                x = accions$Producció.d.energia.renovable..MWh.)
  
  accions$Producció.d.energia.renovable..MWh. <- as.numeric(accions$Producció.d.energia.renovable..MWh.)
  
  accions$Producció.d.energia.renovable..MWh. <- accions$Producció.d.energia.renovable..MWh.*1000
  names(accions)[names(accions) == "Producció.d.energia.renovable..MWh."] <- "Producció.d.energia.renovable.kWh"
  
  accions$Producció.d.energia.renovable.kWh <- round(x = accions$Producció.d.energia.renovable.kWh, digits = 0)
  accions$Producció.d.energia.renovable.kWh <- as.integer(accions$Producció.d.energia.renovable.kWh)
  
  accions$Producció.d.energia.renovable.kWh[is.na(accions$Producció.d.energia.renovable.kWh)] <- 0
  
  accions$Producció.d.energia.renovable.kWh <- format(round(as.numeric(accions$Producció.d.energia.renovable.kWh), digits = 0), big.mark=".")
  accions$Producció.d.energia.renovable.kWh <- gsub(pattern = " ", replacement = '', x = accions$Producció.d.energia.renovable.kWh)
  # unique(accions$Producció.d.energia.renovable.kWh)
  
  return(accions)
}


ECO_mit_harm_emissions <- function(accions) {
  # accions <- accio_mit_ECO
  accions$Emissions.evitades..tCO2. <- gsub(pattern = "\\.", replacement = '',
                                                      x = accions$Emissions.evitades..tCO2.)
  
  accions$Emissions.evitades..tCO2. <- gsub(pattern = ",", replacement = '.',
                                                      x = accions$Emissions.evitades..tCO2.)
  
  accions$Emissions.evitades..tCO2. <- as.numeric(accions$Emissions.evitades..tCO2.)
  
  names(accions)[names(accions) == "Emissions.evitades..tCO2."] <- "Emissions.evitades.tCO2"
  
  accions$Emissions.evitades.tCO2 <- round(x = accions$Emissions.evitades.tCO2, digits = 0)
  accions$Emissions.evitades.tCO2 <- as.integer(accions$Emissions.evitades.tCO2)
  
  accions$Emissions.evitades.tCO2 <- format(round(as.numeric(accions$Emissions.evitades.tCO2), digits = 1), nsmall=1, big.mark=".", decimal.mark=",")
  accions$Emissions.evitades.tCO2 <- gsub(pattern = " ", replacement = '', x = accions$Emissions.evitades.tCO2)
  accions$Emissions.evitades.tCO2 <- gsub(pattern = "NA", replacement = '0,0', x = accions$Emissions.evitades.tCO2)
  
  # unique(accions$Emissions.evitades.tCO2)
  
  return(accions)
}

ECO_mit_harm_cost <- function(accions) {
  # accions <- accio_mit_ECO
  # accions$Cost.... <- gsub(pattern = "\\.", replacement = '',
  #                                           x = accions$Cost....)
  # 
  # accions$Cost.... <- gsub(pattern = ",", replacement = '.',
  #                                           x = accions$Cost....)
  
  accions$Cost.... <- gsub(pattern = "€/any", replacement = '',
                           x = accions$Cost....)
  
  accions$Cost.... <- gsub(pattern = "€", replacement = '',
                           x = accions$Cost....)
  
  # unique(accions$Cost....)
  
  accions$Cost.... <- as.numeric(accions$Cost....)
  names(accions)[names(accions) == "Cost...."] <- "Cost.euros"
  
  accions$Cost.euros <- format(round(as.numeric(accions$Cost.euros), digits = 2), nsmall=2, big.mark=".", decimal.mark=",")
  
  # unique(accions$Cost.euros)
  
  accions$Cost.euros <- gsub(pattern = " ", replacement = '', x = accions$Cost.euros)
  accions$Cost.euros <- gsub(pattern = "NA", replacement = '0,00', x = accions$Cost.euros)

  return(accions)
}



########################## ECOSERVEIS ##########################

accio_mit_ECO <- read_mit("SECAPS/ECOSERVEIS/")
sort(unique(accio_mit_ECO$ID.Proyecto))

## Harmonization sector
unique(accio_mit_ECO$Sector)
accio_mit_ECO$Sector <- gsub("\r", "", accio_mit_ECO$Sector)
accio_mit_ECO$Sector <- gsub("\n", "", accio_mit_ECO$Sector)
sort(unique(accio_mit_ECO$Sector))
accio_mit_ECO <- ECO_mit_harm_Sector(accio_mit_ECO)
sort(unique(accio_mit_ECO$Sector))
sum(is.na(accio_mit_ECO$Sector))


## harmonization Area d'Intervenció
sort(unique(accio_mit_ECO$Area.d.intervencio))
accio_mit_ECO <- ECO_mit_harm_A.Intervencio(accio_mit_ECO)
sort(unique(accio_mit_ECO$Area.d.intervencio))
sum(is.na(accio_mit_ECO$Area.d.intervencio))


## Fix measure name to remove intros, dobble spaces or similars
sort(unique(accio_mit_ECO$Titol.de.la.mesura))
accio_mit_ECO$Titol.de.la.mesura <- gsub("\r", " ", accio_mit_ECO$Titol.de.la.mesura)
accio_mit_ECO$Titol.de.la.mesura <- gsub("\n", " ", accio_mit_ECO$Titol.de.la.mesura)
accio_mit_ECO$Titol.de.la.mesura <- gsub("   ", " ", accio_mit_ECO$Titol.de.la.mesura)
accio_mit_ECO$Titol.de.la.mesura <- gsub("  ", " ", accio_mit_ECO$Titol.de.la.mesura)
sort(unique(accio_mit_ECO$Titol.de.la.mesura))
sum(is.na(accio_mit_ECO$Titol.de.la.mesura))


## harmonization categoria d'ús
accio_mit_ECO <- ECO_mit_harm_Categoria_us(accio_mit_ECO)
unique(accio_mit_ECO$Categoria_us)
sum(is.na(accio_mit_ECO$Categoria_us))

## harmonization Categoria d'Ambit
accio_mit_ECO <- ECO_mit_harm_Categoria_ambit(accio_mit_ECO)
sort(unique(accio_mit_ECO$Categoria.de.l.ambit))
sum(is.na(accio_mit_ECO$Categoria.de.l.ambit))


## harmonization d'Instrument
sort(unique(accio_mit_ECO$Instrument))
accio_mit_ECO <- ECO_mit_harm_Instrument(accio_mit_ECO)
sort(unique(accio_mit_ECO$Instrument))
sum(is.na(accio_mit_ECO$Instrument))


## Origin of action
sort(unique(accio_mit_ECO$Origen.de.l.accio))
accio_mit_ECO <- ECO_mit_harm_Origen(accio_mit_ECO)
sort(unique(accio_mit_ECO$Origen.de.l.accio))
sum(is.na(accio_mit_ECO$Origen.de.l.accio))


#Modify plan names according to ePLANET taxonomy
accio_mit_ECO <- ECO_mit_harm_Nom_Pla(accio_mit_ECO)

#Check responsible entities names
unique(accio_mit_ECO[c("ID.Proyecto", "Responsable")])
accio_mit_ECO$Responsable <- gsub("\r", " ", accio_mit_ECO$Responsable)
accio_mit_ECO$Responsable <- gsub("\n", " ", accio_mit_ECO$Responsable)
accio_mit_ECO$Responsable <- gsub("   ", " ", accio_mit_ECO$Responsable)
accio_mit_ECO$Responsable <- gsub("  ", " ", accio_mit_ECO$Responsable)
accio_mit_ECO$Responsable[grepl("Alcaldies, Consell Comarcal, Diputació de Girona", accio_mit_ECO$Responsable)] <- "Alcaldies, Consell Comarcal, Diputació de Girona"
accio_mit_ECO$Responsable[grepl("Alcaldies, Consells Comarcals, Diputació de Girona", accio_mit_ECO$Responsable)] <- "Alcaldies, Consell Comarcal, Diputació de Girona"
accio_mit_ECO$Responsable[grepl("Oficines de Transició", accio_mit_ECO$Responsable)] <- "Alcaldies, Consell Comarcal, Diputació de Girona"

unique(accio_mit_ECO[c("ID.Proyecto", "Responsable")])

#Energy savings
unique(accio_mit_ECO$Estalvi.energètic.total..MWh.)
accio_mit_ECO <- ECO_mit_harm_estalvi_ener(accio_mit_ECO)
unique(accio_mit_ECO$Estalvi.energètic.total.kWh)

#Energy production
unique(accio_mit_ECO$Producció.d.energia.renovable..MWh.)
accio_mit_ECO <- ECO_mit_harm_produccio_ren(accio_mit_ECO)
unique(accio_mit_ECO$Producció.d.energia.renovable.kWh)
  
#Emissions avoided
unique(accio_mit_ECO$Emissions.evitades..tCO2.)
accio_mit_ECO <- ECO_mit_harm_emissions(accio_mit_ECO)
unique(accio_mit_ECO$Emissions.evitades.tCO2)

#Cost €
unique(accio_mit_ECO$Cost....)
accio_mit_ECO <- ECO_mit_harm_cost(accio_mit_ECO)
unique(accio_mit_ECO$Cost.euros)

#Anual savings [€]
unique(accio_mit_ECO$Estalvi.anual....)

#Initial date + end date
unique(accio_mit_ECO$Any.inici)
accio_mit_ECO$Any.inici <- as.integer(accio_mit_ECO$Any.inici)
unique(accio_mit_ECO$Any.inici)

unique(accio_mit_ECO$Any.fi)
accio_mit_ECO$Any.fi <- as.integer(accio_mit_ECO$Any.fi)
unique(accio_mit_ECO$Any.fi)

#Execution stage
unique(accio_mit_ECO$Estat.d.execucio)





accio_mit_ECO_export <- data.frame(
  #Mandatory fields for each action
  "ID Proyecto" = accio_mit_ECO$ID.Proyecto,
  "Nom del pla" = accio_mit_ECO$Nom.del.pla,
  "Titol de la mesura" = accio_mit_ECO$Titol.de.la.mesura,
  "Sector" = accio_mit_ECO$Sector,
  "Area d'intervencio" = accio_mit_ECO$Area.d.intervencio,
  "Categoria d'us" = accio_mit_ECO$Categoria_us,
  "Categoria de l'ambit" = accio_mit_ECO$Categoria.de.l.ambit,
  "Descripcio" = accio_mit_ECO$Descripcio,
  "Responsable" = accio_mit_ECO$Responsable,#"Irresponsable_1",
  
  #Additional information
  "Estalvi energètic total [kWh]" = accio_mit_ECO$Estalvi.energètic.total.kWh,
  "Producció d'energia renovable [MWh]" = accio_mit_ECO$Producció.d.energia.renovable.kWh,
  "Emissions evitades [tCO2]" = accio_mit_ECO$Emissions.evitades.tCO2,
  "Cost [€]" = accio_mit_ECO$Cost.euros,
  "Estalvi anual [€]" = accio_mit_ECO$Estalvi.anual....,
  "Any inici" = accio_mit_ECO$Any.inici,
  "Any fi" = accio_mit_ECO$Any.fi,
  "Instrument" = accio_mit_ECO$Instrument,
  "Origen de l'accio" = accio_mit_ECO$Origen.de.l.accio,
  "Estat d'execucio" = accio_mit_ECO$Estat.d.execucio
  )

# 
# ID_responsable_ECO <- unique(accio_mit_ECO_export[c("ID.Proyecto", "Responsable")])
# names(ID_responsable_ECO) <- c("ID", "Responsable")
# 
# 
# accio_mit_ECO_export <- accio_mit_ECO_export[!accio_mit_ECO_export$ID.Proyecto == "NA",]
# ID_responsable_ECO <- ID_responsable_ECO[!ID_responsable_ECO$ID == "NA",]
# 
# nrow(accio_mit_ECO_export[accio_mit_ECO_export$ID.Proyecto=="802",])
# 
# plans_mitigacio_ECO <- unique(accio_mit_ECO_export[c("ID.Proyecto", "Nom.del.pla")])
# 
# # 
# # #
# # write_xlsx(
# #   plans_mitigacio_ECO,
# #   path = "ECO-Plans_mitigació.xlsx",
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )
# # 
# # # Full responsables
# # write_xlsx(
# #   ID_responsable_ECO,
# #   path = "ECO-ID_responsable_mit.xlsx",
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )
# # 
# # #
# # write_xlsx(
# #   accio_mit_ECO_export,
# #   path = "ECO-Mesures_mit.xlsx",
# #   col_names = TRUE,
# #   format_headers = TRUE,
# #   use_zip64 = FALSE
# # )

################# MITIGATION - EXPORT ALL ################

for (x in 1:nrow(df_project_NA)) {
  mit_export$ID_Proyecto[mit_export$Nombre_del_plan == df_project_NA$Nombre_plan_mit[x]] <- df_project_NA$ID_new[x]
}

ID_responsable <- unique(mit_export[c("ID_Proyecto", "Responsable")])
names(ID_responsable) <- c("ID", "Responsable")

plans_mitigacio <- unique(mit_export[c("ID_Proyecto", "Nombre_del_plan")])

#Energy Transition Plan identification
write_xlsx(
  plans_mitigacio,
  path = "Plans_mitigació_all.xlsx",#tempfile(fileext = "ID_responsable.xlsx"),
  col_names = TRUE,
  format_headers = TRUE,
  use_zip64 = FALSE
)

# List of respobsible entities
write_xlsx(
  ID_responsable,
  path = "ID_responsable_mit_all.xlsx",#tempfile(fileext = "ID_responsable.xlsx"),
  col_names = TRUE,
  format_headers = TRUE,
  use_zip64 = FALSE
)

#Mitigation actions
write_xlsx(
  mit_export,
  path = "Mesures_mit_all.xlsx",#tempfile(fileext = "ID_responsable.xlsx"),
  col_names = TRUE,
  format_headers = TRUE,
  use_zip64 = FALSE
)

################# ADAPTATION - EXPORT ALL ################

for (x in 1:nrow(df_project_NA)) {
  ada_export$ID_Proyecto[ada_export$Nombre_del_plan == df_project_NA$Nombre_plan_ada[x]] <- df_project_NA$ID_new[x]
}

ID_responsable_ada <- unique(ada_export[c("ID_Proyecto", "Responsable")])
names(ID_responsable) <- c("ID", "Responsable")

plans_adaptacio <- unique(ada_export[c("ID_Proyecto", "Nombre_del_plan")])

#Energy Transition Plan identification
write_xlsx(
  plans_adaptacio,
  path = "Plans_adaptació_all.xlsx",
  col_names = TRUE,
  format_headers = TRUE,
  use_zip64 = FALSE
)

# List of respobsible entities
write_xlsx(
  ID_responsable_ada,
  path = "ID_responsable_ada_all.xlsx",
  col_names = TRUE,
  format_headers = TRUE,
  use_zip64 = FALSE
)

#Adaptation actions
write_xlsx(
  ada_export,
  path = "Mesures_ada_all.xlsx",
  col_names = TRUE,
  format_headers = TRUE,
  use_zip64 = FALSE
)


