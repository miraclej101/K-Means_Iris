library(FactoMineR)
library(factoextra)
library(shiny)

data(iris)
#dataframe normé et enlevé la collone 5 qui est qualitative
df <- scale(iris[,-5])

#Définir UI pour l'app
ui <- fluidPage(
  includeCSS("www/style.css"),
  #Titre de l'app
  titlePanel("Iris K-Means"),
  #Sidebar layout avec les définitions des input et ouput 
  sidebarLayout(
    #Sidebar panel pour input
    sidebarPanel(
      sliderInput(inputId = "clusts",
                  label = "Nombre de clusters",
                  min = 1,
                  max = 10,
                  value = 3,
                  step = 1),
      h4("Déterminer un nombre optimal de clusters",class="input_text"),
      selectInput(inputId = "methode",
                  label = "Selectionner une méthode",
                  choices = list("silhouette"= "silhouette",
                                 "within sum of squares" = "wss",
                                 "gap_stat" ="gap_stat"),
                                 selected = "wss")
      
    ),
    mainPanel(
      #output cluster plot
      plotOutput(outputId = "clusterPlot"),
      br(),
      plotOutput(outputId = "nbClust")
    )
  )
)
#Définir une logique de server pour calculer les résultats
server <- function(input,output){
  
  dataInput <- reactive({
    #calculer K-means pour la dataframe iris, centers = nombre de groupes
    #initialiser 25 affectations de départ aléatoires différentes, 
    #puis sélectionnera les meilleurs résultats
    res.km <- kmeans(df,centers = input$clusts, nstart = 25 )
  })
  
  output$clusterPlot <- renderPlot({
    #plot cluster ,non labelé (geom option)
    fviz_cluster(dataInput(),data = df,geom = "point",ellipse.type = "convex",ggtheme = theme_minimal())
  })
  
  output$nbClust <- renderPlot({
    #plot nombre de clusters optimal
    fviz_nbclust(df,kmeans,method = input$methode)
  })
}

# Créer Shiny app ----
shinyApp(ui = ui, server = server)
