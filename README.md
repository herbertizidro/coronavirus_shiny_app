# shiny-app-covid-19

 Painel criado com ShinyDashboard(R) que exibe informações sobre a covid-19 no Brasil
 
 Acesse em: https://herbertsouza.shinyapps.io/corona/

Obs: os números de confirmados, mortes e recuperados do mapa estavam sem vírgula, foi corrigido.

<img src="https://github.com/herbertizidro/coronavirus_shiny_app/blob/master/numeros_mapa.jpg">

Obs²: demora alguns segundos para carregar o conteúdo. caso fique fora do ar, baixe os arquivos e execute em seu RStudio. descomente as linhas 1, 2 e 3("#instala automaticamente as dependências...")
e comente todos os "library(blábláblá)" no global.R(se não me engano, basta selecionar o código e pressionar as teclas Ctrl + Shift + C para comentar). assim quando você executar o app, ele vai instalar e carregar as dependências. fique à vontade para contribuir
com melhorias no código!

Obs³: por se tratar de um mapa coroplético, substitui os dados absolutos(total de óbitos) por dados relativos(percentual).

<img src="https://github.com/herbertizidro/coronavirus_shiny_app/blob/master/percent.jpg">


<img src="https://github.com/herbertizidro/coronavirus_shiny_app/blob/master/screenshot01.10.2020.png">

Fonte:

 - https://labs.wesleycota.com/sarscov2/br/

