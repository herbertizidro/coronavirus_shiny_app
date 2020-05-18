library(DT)
library(curl)
library(Rcpp)
library(xlsx)
library(dplyr)
library(rvest)
library(shiny)
library(rgdal)
library(plotly)
library(ggplot2)
library(stringr)
library(leaflet)
library(jsonlite)
library(devtools)
library(lubridate)
library(fuzzyjoin)
library(shinythemes)
library(formattable)
library(RColorBrewer)
library(shinydashboard)
library(leaflet.extras)
library(shinycustomloader)


#coordenadas de cada estado
#informação necessária para addLabelOnlyMarkers em output$mapa_br
#FONTE: https://gist.github.com/ricardobeat/674646

lat_long_UFs = fromJSON("coordenadas.json", flatten=TRUE)
lat_long_UFs = lat_long_UFs[, c(1,3,4)]
names(lat_long_UFs)[1] = "uid"
names(lat_long_UFs)[2] = "lat"
names(lat_long_UFs)[3] = "long"

estados_uid = read.xlsx("estados_uid_template.xlsx", 1, encoding="UTF-8")

#fonte de dados covid19
covid_csv = read.csv("https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-total.csv")
covid_csv = covid_csv[, c(2,3,6,12)]
#covid_csv = covid_csv[-1,]
covid_csv = subset(covid_csv, state != "TOTAL") #linha desnecessária
covid_csv$state = as.character(covid_csv$state)
corona_brazil = estados_uid %>% regex_inner_join(covid_csv, by = c(state = "state"))
corona_brazil$state.x = as.character(corona_brazil$state.x)
corona_brazil$state.y = NULL
names(corona_brazil)[2] = "estado"
names(corona_brazil)[3] = "casos"
names(corona_brazil)[4] = "mortes"
names(corona_brazil)[5] = "recuperados"

corona_brazil[is.na(corona_brazil)] = 0
total_confirmados = sum(corona_brazil$casos)
total_recuperados = sum(corona_brazil$recuperados)
total_obitos = sum(corona_brazil$mortes)
taxa_letalidade = (total_obitos * 100) / total_confirmados

total_confirmados = accounting(total_confirmados, format="d")
total_recuperados = accounting(total_recuperados, format="d")
total_obitos = accounting(total_obitos, format="d")
taxa_letalidade = paste0(format(taxa_letalidade, digits=2, decimal.mark=","), "%")

corona_brazil = left_join(corona_brazil, lat_long_UFs, by="uid")

shp = readOGR("www", "BRUFE250GC_SIR", stringsAsFactors=FALSE, encoding="UTF-8") # shp disponibilizado pelo IBGE
mapa_corona = merge(shp, corona_brazil, by.x = "CD_GEOCUF", by.y = "uid") # merge dos dados da API com o shp

df_aux = as.data.frame(cbind(mapa_corona$NM_REGIAO, mapa_corona$casos))
names(df_aux)[1] = "Região"
names(df_aux)[2] = "Total de casos confirmados"

#avanço dos casos(acumulado)
covid_total_dia = read.csv("https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv")
covid_total_dia = subset(covid_total_dia, state != "TOTAL") #linha desnecessária
covid_total_dia = covid_total_dia[, c(1,6,8,14)]
covid_total_dia[,1] = as.Date(covid_total_dia[,1])

names(covid_total_dia)[1] = "data"
names(covid_total_dia)[2] = "mortes"
names(covid_total_dia)[3] = "casos"
names(covid_total_dia)[4] = "recuperados"
covid_total_dia[is.na(covid_total_dia)] = 0

mortes_aux = covid_total_dia %>% group_by(data) %>% summarise(mortes = sum(mortes))
casos_aux = covid_total_dia %>% group_by(data) %>% summarise(casos = sum(casos))
casos_aux = casos_aux[,2]
recuperados_aux = covid_total_dia %>% group_by(data) %>% summarise(recuperados = sum(recuperados))
recuperados_aux = recuperados_aux[,2]
covid_total_dia = cbind(mortes_aux, casos_aux, recuperados_aux)


#avanço dos novos casos(por dia de notificação)
covid_novos_dia = read.csv("https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv")
covid_novos_dia = subset(covid_novos_dia, state != "TOTAL") #linha desnecessária
covid_novos_dia = covid_novos_dia[, c(1,5,7)]
covid_novos_dia[,1] = as.Date(covid_novos_dia[,1])

names(covid_novos_dia)[1] = "data"
names(covid_novos_dia)[2] = "novas mortes"
names(covid_novos_dia)[3] = "novos casos"

nvs_mortes_aux = covid_novos_dia %>% group_by(data) %>% summarise(`novas mortes` = sum(`novas mortes`))
nvs_casos_aux = covid_novos_dia %>% group_by(data) %>% summarise(`novos casos` = sum(`novos casos`))
nvs_casos_aux = nvs_casos_aux[,2]
covid_novos_dia = cbind(nvs_mortes_aux, nvs_casos_aux)


#total de testes pra covid19 feitos no Brasil
worldometers = read_html("https://www.worldometers.info/coronavirus/")
tabela = worldometers %>% html_nodes("tr") %>% html_text()
testes_por_milhao = "---"
testes_total = "---"
for (i in tabela) {
  if(grepl("Brazil", i)){
    tabela = c(str_split(i, "\\n")[[1]][12], str_split(i, "\\n")[[1]][13])
    testes_total = tabela[1]
    testes_por_milhao = tabela[2]
  }
}

# notícias sobre o corona - BBC
noticias_bbc = read_html("https://www.bbc.com/portuguese/search?q=coronav%C3%ADrus")
bbc_principais_titulo = noticias_bbc %>% html_nodes(".hard-news-unit__headline-link") %>% html_text()
bbc_principais_link = noticias_bbc %>% html_nodes(".hard-news-unit__headline a") %>% html_attr("href")
bbc_principais_hora = noticias_bbc %>% html_nodes(".date") %>% html_text()
for (i in 1:length(bbc_principais_link)) {
  bbc_principais_link[i] = paste0("<a href='", bbc_principais_link[i], "'>Acessar Notícia</a>")
}
BBC = paste(bbc_principais_titulo, "  |  ", bbc_principais_hora,
            "  |  ", bbc_principais_link, sep="")

# notícias sobre o corona - O Globo
noticias_oglobo = read_html("https://oglobo.globo.com/sociedade/coronavirus/")
oglobo_principais_titulo = noticias_oglobo %>% html_nodes(".teaser__title a") %>% html_text()
oglobo_principais_link = noticias_oglobo %>% html_nodes(".teaser__title a") %>% html_attr("href")
for (i in 1:length(oglobo_principais_link)) {
  oglobo_principais_link[i] = paste0("<a href='", oglobo_principais_link[i], "'>Acessar Notícia</a>")
}
OGLOBO = paste(oglobo_principais_titulo, "  |  ", oglobo_principais_link, sep="")

# notícias sobre o corona - UOL
noticias_uol = read_html("https://noticias.uol.com.br/coronavirus") #/ultimas
uol_principais_titulo = noticias_uol %>% html_nodes(".thumb-title") %>% html_text()
uol_principais_hora = noticias_uol %>% html_nodes(".thumb-time") %>% html_text()
uol_principais_link = noticias_uol %>% html_nodes(".thumbnail-standard-wrapper a") %>% html_attr("href")
for (i in 1:length(uol_principais_link)) {
  uol_principais_link[i] = paste0("<a href='", uol_principais_link[i], "'>Acessar Notícia</a>")
}
UOL = paste(uol_principais_titulo, "  |  ", uol_principais_hora,
            "  |  ", uol_principais_link, sep="")

NOTICIAS = c()
NOTICIAS = as.data.frame(c(NOTICIAS, BBC, OGLOBO, UOL))
names(NOTICIAS)[1] = "<span class='fontes-noticias'>Fontes: BBC Brasil, O Globo e UOL</div>"

#limpar memória
rm(list = subset(ls(), !(ls() %in% c("corona_brazil", "covid_total_dia", "covid_novos_dia", "df_aux", "evolucao_json", "mapa_corona",
                                     "NOTICIAS", "taxa_letalidade", "testes_por_milhao", "testes_total", "total_confirmados", "total_recuperados", "total_obitos"))))
