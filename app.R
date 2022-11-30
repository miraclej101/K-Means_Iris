library(FactoMineR)
library(factoextra)
library(shiny)

data(iris)
#dataframe normé et enlevé la colonne 5 qui est qualitative
df <- scale(iris[,-5])

#Définir UI pour l'app
ui <- fluidPage(
  #appliquer (style) css dans l'application
  includeCSS("www/style.css"),
  #Titre de l'application
  titlePanel("Iris K-Means"),
  #Sidebar layout avec les définitions des inputs et outputs 
  sidebarLayout(
    #Sidebar panel pour input
    sidebarPanel(
      sliderInput(inputId = "clusts",
                  label = "Nombre de clusters",
                  min = 1,
                  max = 10,
                  value = 3,
                  step = 1),
      sliderInput(inputId = "nstart",
                  label = "Nombre d'ensembles aléatoires au départ",
                  min = 1,
                  max = 30,
                  value= 25),
      selectInput(inputId = "algo",
                  label = "Selectionner un algorithme pour K-Means",
                  choices = list("Hartigan-Wong"= "Hartigan-Wong"
                                 ,"Lloyd" = "Lloyd",
                                 "Forgy"= "Forgy",
                                 "MacQueen" = "MacQueen" ),
                  selected = "Hartigan-Wong"),
      h4("Déterminer un nombre optimal de clusters",class="input_text"),
      selectInput(inputId = "methode",
                label = "Selectionner une méthode",
                choices = list("silhouette"= "silhouette",
                               "within sum of squares" = "wss",
                               "gap statistique" ="gap_stat"),
                selected = "wss"),
    ), 
    mainPanel(
      #output cluster plot
      plotOutput(outputId = "clusterPlot"),
      br(), #sortie une ligne
      plotOutput(outputId = "nbClust")
    )
  ),
)
#Définir une logique de server pour calculer les résultats
server <- function(input,output){
  
  dataInput <- reactive({
    #calculer K-means pour la dataframe iris, centers = nombre de groupes
    #initialiser nstart affectations de départ aléatoires différentes, 
    #puis sélectionnera les meilleurs résultats
    res.km <- kmeans(df,centers = input$clusts, nstart = input$nstart,algorithm = input$algo)
  })
  
  output$clusterPlot <- renderPlot({
    #plot cluster
    fviz_cluster(dataInput(),data = df,geom = c("point","text"),
                labelsize=8,ellipse.type = "convex",
                 ggtheme = theme_gray())
  })
  
  output$nbClust <- renderPlot({
    #plot nombre de clusters optimal
    fviz_nbclust(df,kmeans,method = input$methode)
  })
}

# Créer Shiny app ----
shinyApp(ui = ui, server = server)
