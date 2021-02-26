

ui = dashboardPage(
    dashboardHeader(title = "Brasil Covid-19"),
    
    dashboardSidebar(disable = TRUE, 
                     tags$head(tags$style(HTML('#mapa_br { height: 500px !important; } *{font-family: "Quicksand", sans-serif;} .table{width: 100%;} .testes-milhao, #covid-testes-br{text-align: center;}')))),              
    dashboardBody(
        
        fluidRow(

            valueBoxOutput("confirmados"),
            valueBoxOutput("obitos"),
            valueBoxOutput("recuperados")

        ),

        fluidRow(
            
            column(width = 8,
                   
                   box(title = paste0("Brasil - % de óbitos por uf ", "| Letalidade: ", taxa_letalidade), width = NULL,
                       withLoader(leafletOutput("mapa_br"), type = "html", loader = "loader6"),
                       tags$i(paste("Fonte: Ministério da Saúde e secretarias de saúde de cada estado -"), downloadLink("dados_corona", "Download CSV"), style = "font-size: 12px;")),
            ),
            
            column(width = 4,
                   box(title = "Brasil - testes de covid-19", id = "covid-testes-br", width = NULL, solidHeader = TRUE, status = "success",
                       tags$b(testes_br), "testes realizados. Obs: o somatório pode estar desatualizado, por falta de divulgação pelas secretarias de saúde."),
                   box(title = "Casos confirmados por região", width = NULL, withLoader(plotlyOutput("casos_regiao"), type = "html", loader = "loader6"))
            )
            
        ),

        fluidRow(

            box(title = "Acumulado - confirmados, recuperados e óbitos", width = 12, withLoader(plotlyOutput("acumulado"), type = "html", loader = "loader6"),
                tags$li("Casos confirmados", style = "color: blue; font-size: 12px; margin-left: 15px;"),
                tags$li("Recuperados", style = "color: #008000; font-size: 12px; margin-left: 15px;"),
                tags$li("Óbitos", style = "color: red; font-size: 12px; margin-left: 15px;"))

        ),
        
        fluidRow(
            box(title = "Casos novos por data de notificação", width = 6, withLoader(plotlyOutput("casos_novos_dia"), type = "html", loader = "loader6")),
            box(title = "Óbitos por data de notificação", width = 6, withLoader(plotlyOutput("obitos_dia"), type = "html", loader = "loader6"))
        ),

        fluidRow(
            box(title = "Notícias", width = 12, withLoader(DTOutput("noticias_br"), type = "html", loader = "loader6"))
        ),

        fluidRow(
            p("Desenvolvido por Herbert Souza", style = "font-size: 12px; text-align: center;")
        )
        
    )
)

