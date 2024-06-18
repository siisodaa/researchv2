library(shiny)

ui <- fluidPage(
  titlePanel("Data Explorer"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose CSV File", accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      uiOutput("var_select"),
      uiOutput("filter_slider")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data Table", DTOutput("data_table")),
        tabPanel("Scatter Plot", plotlyOutput("scatter_plot")),
        tabPanel("Summary", textOutput("summary"))
      )
    )
  )
)
