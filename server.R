library(shiny)
library(DT)
library(plotly)
library(dplyr)

# Define the UI
shinyUI(fluidPage(
  titlePanel("Data Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose CSV File", 
                accept = c("text/csv", 
                           "text/comma-separated-values,text/plain", 
                           ".csv")),
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
))

# Define the server logic
shinyServer(function(input, output, session) {
  
  # Reactive expression to read and store the uploaded CSV file
  data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  # UI for selecting a variable from the data
  output$var_select <- renderUI({
    req(data())
    selectInput("var", "Select Variable", names(data()))
  })
  
  # UI for the filter slider based on the selected variable
  output$filter_slider <- renderUI({
    req(data(), input$var)
    var <- data()[[input$var]]
    sliderInput("filter", "Filter Data", 
                min = min(var, na.rm = TRUE), 
                max = max(var, na.rm = TRUE), 
                value = c(min(var, na.rm = TRUE), max(var, na.rm = TRUE)))
  })
  
  # Reactive expression to filter data based on slider input
  filtered_data <- reactive({
    req(data(), input$var, input$filter)
    data() %>% filter(between(data()[[input$var]], input$filter[1], input$filter[2]))
  })
  
  # Reactive values to store working data frame
  values <- reactiveValues(dfWorking = NULL)
  
  # Observe the filtered data to update the working data frame
  observe({
    req(filtered_data())
    values$dfWorking <- filtered_data()
  })
  
  # Render the data table with the filtered data
  output$data_table <- renderDT({
    req(values$dfWorking)
    datatable(values$dfWorking, selection = 'single')
  })
  
  # Proxy for DataTable to allow updates without re-rendering
  proxy <- dataTableProxy('data_table')
  
  # Render the scatter plot with Plotly
  output$scatter_plot <- renderPlotly({
    req(values$dfWorking, input$var)
    plot_ly(values$dfWorking, x = ~get(input$var), y = ~get(input$var), type = 'scatter', mode = 'markers') %>%
      event_register('plotly_click')
  })
  
  # Render summary of the selected variable
  output$summary <- renderText({
    req(values$dfWorking, input$var)
    summary(values$dfWorking[[input$var]])
  })
  
  # Handle row deletion from the data table
  observeEvent(input$data_table_rows_selected, {
    selected_row <- input$data_table_rows_selected
    if (!is.null(selected_row)) {
      values$dfWorking <- values$dfWorking[-selected_row, ]
      replaceData(proxy, values$dfWorking, resetPaging = FALSE)
    }
  })
  
  # Handle point deletion from the scatter plot
  observeEvent(event_data("plotly_click"), {
    click_data <- event_data("plotly_click")
    if (!is.null(click_data)) {
      x_val <- click_data$x
      y_val <- click_data$y
      selected_row <- which(values$dfWorking[[input$var]] == x_val & values$dfWorking[[input$var]] == y_val)
      if (length(selected_row) > 0) {
        values$dfWorking <- values$dfWorking[-selected_row, ]
        replaceData(proxy, values$dfWorking, resetPaging = FALSE)
      }
    }
  })
})

