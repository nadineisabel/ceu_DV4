

#https://shiny.rstudio.com/articles/layout-guide.html



library(shiny)
library(jsonlite)
library(data.table)
library(httr)
library(rtsdata)
library(DT)
library(TTR)
library(plotly)
library(shinythemes)
library(shinydashboard)


source('000_functions.R')

# base --------------------------------------------------------------------


# ui <- fluidPage(
#   uiOutput('my_ticker'),
#   dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date()),
#   dataTableOutput('my_data'),
#   div(plotlyOutput('data_plot', width = '60%', height='800px'),align="center")
# 
# )



# sidebar -----------------------------------------------------------------

# 
# ui <- fluidPage(
# 
#   sidebarLayout(
#     sidebarPanel(
#       uiOutput('my_ticker'),
#       dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date())
# 
#     ),
#     mainPanel(
#       plotlyOutput('data_plot', width = '60%', height='800px'),
#       dataTableOutput('my_data')
#     )
#   )
# )





# sidebarwithtabset -------------------------------------------------------

# ui <- fluidPage(
# 
#   sidebarLayout(
#     sidebarPanel(
#       uiOutput('my_ticker'),
#       dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date())
# 
#     ),
#     mainPanel(
#       tabsetPanel(
#         tabPanel("Plot", plotlyOutput('data_plot', width = '60%', height='800px')),
#         tabPanel("Table",  dataTableOutput('my_data'))
#       )
#     )
#   )
# )



# justtabsetpanel ---------------------------------------------------------

# ui <- fluidPage(
# 
#   tabsetPanel(
# 
#     tabPanel("control",
#              wellPanel(
#                uiOutput('my_ticker'),
#                dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date())
#                )
#              ),
#     tabPanel("Plot", plotlyOutput('data_plot', width = '60%', height='800px')),
#     tabPanel("Table",  dataTableOutput('my_data'))
#   )
# 
# 
# )
  

# ui <- navbarPage(title = 'Stock browser',theme = shinytheme('flatly'),
#                  tabPanel('control',
#                           uiOutput('my_ticker'),
#                           dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date())
#                           ),
#                  tabPanel('Plot',
#                           plotlyOutput('data_plot', width = '60%', height='800px')
#                           ),
#                  tabPanel('Data',
#                           dataTableOutput('my_data')
#                           )
#                  )




# ui <- navbarPage(title = 'Stock browser',theme = shinytheme('flatly'),
#                  tabPanel('control',
#                           uiOutput('my_ticker'),
#                           dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date())
#                  ),
#                  tabPanel('Plot & data',
#                           fluidRow(
#                             column(9,
#                                    plotlyOutput('data_plot')
#                                    ),
#                             column(3,
#                                    dataTableOutput('my_data')
#                                    )
#                           )
#                  )# ends tabpanel
# )# end navbarpage

# 
# ui <-dashboardPage(
#   dashboardHeader(title = 'Stock browser'),
#   dashboardSidebar(
#     uiOutput('my_ticker'),
#     dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date())
# 
#   ),
#   dashboardBody(
#     plotlyOutput('data_plot'),
#     infoBoxOutput('plus_infobox'),
#     dataTableOutput('my_data')
#   )
# )
# 



# 
# ui <-dashboardPage(
#   dashboardHeader(title = 'Stock browser'),
#   dashboardSidebar(
#     sidebarMenu(
#     menuItem("Plot", tabName = "plot", icon = icon("dashboard")),
#     menuItem("Data", tabName = "data", icon = icon("th"))
#     )
# 
#   ),
#   dashboardBody(
#     tabItems(
#     tabItem(tabName = "plot",
#             uiOutput('my_ticker'),
#             dateRangeInput('my_date',label = 'Date', start = '2018-01-01', end = Sys.Date()),
#       plotlyOutput('data_plot')
#       ),
# 
#     tabItem(tabName = "data",
#             dataTableOutput('my_data')
#     )
#     )
# 
# 
#   )
# )



server <- function(input, output, session) {
  sp500 <-get_sp500()
  
  output$my_ticker <- renderUI({
    selectInput('ticker', label = 'select a ticker', choices = setNames(sp500$name, sp500$description), multiple = FALSE)
  })
  
  
  my_reactive_df <- reactive({
    df<- get_data_by_ticker_and_date(input$ticker, input$my_date[1], input$my_date[2])
    return(df)
  })
  
  
  # # go to https://rstudio.github.io/DT/shiny.html
  output$my_data <- DT::renderDataTable({
    my_reactive_df()
  })

  output$plus_infobox <- renderInfoBox({
    infoBox(title = 'Positive performace', value = sum(sp500$change>0) / nrow(sp500),
        icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  
  output$data_plot <- renderPlotly({
    get_plot_of_data(my_reactive_df())
  })
  
}


shinyApp(ui = ui, server = server)




