

shinyServer(function(input, output, session) {
    
    output$confirmados <- renderInfoBox({
        valueBox(
            total_confirmados, "Total de casos confirmados", icon = icon("chart-line"),
            color = "aqua"
        )
    })
    
    output$obitos <- renderInfoBox({
        valueBox(
            total_obitos, "Total de óbitos", icon = icon("chart-line"),
            color = "red"
        )
    })
    
    output$letalidade <- renderInfoBox({
        valueBox(
            taxa_letalidade, "Letalidade", icon = icon("percent"),
            color = "yellow"
        )
    })
    
    output$mapa_br = renderLeaflet({
        
        cores_mapa = colorQuantile(c("#FFF5F0", "#FEE0D2", "#FCBBA1", "#FC9272", "#FB6A4A", "#EF3B2C"), #paleta Reds sem os tons "#CB181D" "#99000D"
                                   domain = unique(as.numeric(mapa_corona$mortes)), n=5)
        
        legenda = paste0("<strong>Estado: </strong>", 
                         mapa_corona$estado, 
                         "<br><strong>Confirmados: </strong>", 
                         mapa_corona$casos,
                         "<br><strong>Mortes: </strong>",
                         mapa_corona$mortes)
        
        mapa = leaflet(mapa_corona, options = leafletOptions(zoomControl = TRUE, minZoom = 4, maxZoom = 4.5, dragging = TRUE)) %>%
            addPolygons(fillColor = ~cores_mapa(as.numeric(mapa_corona$mortes)), 
                        fillOpacity = 0.9, 
                        color = "#4F4F4F", #contornos
                        weight = 1, 
                        popup = legenda) %>%
            addTiles("http://tile.stamen.com/terrain-background/{z}/{x}/{y}.jpg") %>% 
            addLabelOnlyMarkers(~long, ~lat, label =  ~mortes, 
                                labelOptions = labelOptions(noHide = T, direction = 'center', textOnly = T,
                                                            style = list("font-size" = "13px"))) %>% suspendScroll()
        
        mapa
        
    })
    
    output$dados_corona = downloadHandler(
        filename = function() {
            paste("covid19-UFs", Sys.Date(), ".csv", sep="")
        },
        content = function(file) {
            write.csv(corona_brazil[, c(1:4)], file)
        }
    )
    
    
    output$acumulado = renderPlotly({
        g1 = ggplot(evolucao_json) +
            geom_line(aes(x = data, y = `mortes(acumulado)`), color='red') +
            geom_point(aes(x = data, y = `mortes(acumulado)`), color='red', size = 1) +
            geom_line(aes(x = data, y = `confirmados(acumulado)`), color='blue') + 
            geom_point(aes(x = data, y = `confirmados(acumulado)`), color='blue', size = 1) + 
            labs(x = "Dias do mês", y = "Casos confirmados e mortes") +
            scale_x_date(date_labels = '%d/%m', breaks = "months") +
            ggtitle("") +
            theme_minimal()
        ggplotly(g1)
    })
    
    
    output$total_dia = renderPlotly({
        g2 = ggplot(evolucao_json) +
            geom_line(aes(x = data, y = `mortes(dia)`), color='red') +
            geom_point(aes(x = data, y = `mortes(dia)`), color='red', size = 1) +
            geom_line(aes(x = data, y = `confirmados(dia)`), color='blue') + 
            geom_point(aes(x = data, y = `confirmados(dia)`), color='blue', size = 1) + 
            labs(x = "Dias do mês", y = "Casos confirmados e mortes") +
            scale_x_date(date_labels = '%d/%m', breaks = "months") +
            ggtitle("") +
            theme_minimal()
        ggplotly(g2)
    })
    
    output$casos_regiao = renderPlotly({
        plot_ly(df_aux, labels = ~`Região`, values = ~`Total de casos confirmados`, type = 'pie',
                textposition = 'inside',
                textinfo = 'label+percent+value',
                insidetextfont = list(color = '#FFFFFF'),
                hoverinfo = 'text',
                showlegend = FALSE) %>%
            layout(title = '',
                   xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    })
    
    output$noticias_br =  renderDataTable({NOTICIAS}, escape = FALSE)
    
})
