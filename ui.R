
ui <- dashboardPage(
    dashboardHeader(title = "Brasil Covid-19"),
    
    dashboardSidebar(disable = TRUE, 
                     tags$head(tags$style(HTML('#mapa_br { height: 500px !important; } *{font-family: "Quicksand", sans-serif;} .table{width: 100%;}')))),              
    dashboardBody(
        
        fluidRow(

            valueBoxOutput("confirmados"),
            valueBoxOutput("obitos"),
            valueBoxOutput("letalidade")

        ),

        fluidRow(
            
            column(width = 8,
                   
                   box(title = "Brasil - óbitos por uf", width = NULL,
                       withLoader(leafletOutput("mapa_br"), type = "html", loader = "loader6"),
                       tags$i(paste("Fonte: Ministério da Saúde e secretarias de saúde de cada estado -"), downloadLink("dados_corona", "Download CSV"), style = "font-size: 12px;")),
            ),
            
            column(width = 4,
                   box(title = "Brasil - testes de covid-19", width = NULL, solidHeader = TRUE, status = "success",
                       tags$b(testes_total), "testes realizados", " | ",  tags$b(testes_por_milhao), "testes por milhão de habitantes"),
                   box(title = "Casos confirmados por região", width = NULL, withLoader(plotlyOutput("casos_regiao"), type = "html", loader = "loader6"))
            )
            
        ),

        fluidRow(

            box(title = "Acumulado", width = 6, withLoader(plotlyOutput("acumulado"), type = "html", loader = "loader6"),
                tags$li("Casos confirmados", style = "color: blue; font-size: 12px; margin-left: 15px;"),
                tags$li("Mortes", style = "color: red; font-size: 12px; margin-left: 15px;")),
            box(title = "Por dia", width = 6, withLoader(plotlyOutput("total_dia"), type = "html", loader = "loader6"),
                tags$li("Casos confirmados por dia", style = "color: blue; font-size: 12px; margin-left: 15px;"),
                tags$li("Mortes por dia", style = "color: red; font-size: 12px; margin-left: 15px;"))

        ),

        fluidRow(
            box(title = "Notícias", width = 12, withLoader(DTOutput("noticias_br"), type = "html", loader = "loader6"))
        ),

        fluidRow(
            p("Desenvolvido por Herbert Souza", style = "font-size: 14px; text-align: center;")
        )
        
    )
)
