#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(leaflet)
library(htmlwidgets)
library(BAMMtools)
library(htmltools)
library(scales)
library(rsconnect)

# read in data
df_map <- readRDS("./df_merged.Rds")
df_char <- readRDS("./df_merged_2.Rds")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel(
      h1("Disease mortality rates across the United States", align="center")
      ),
    mainPanel(
      tags$head(
        tags$style(type='text/css', 
                   ".nav-tabs {font-size: 16px} ")), 
      tabsetPanel(
          tabPanel("Disease Rates by State (2010)",
                   fluidRow(
                     column(4,
                            radioButtons(
                              inputId = "icd_chapter",
                              label = "Select Disease Type",
                              choices = c(
                                "Parasitic" = "Certain infectious and parasitic diseases",                                                          
                                "Neoplasms" = "Neoplasms",                                                                                          
                                "Blood" = "Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism",
                                "Enodcrine" = "Endocrine, nutritional and metabolic diseases",                                                      
                                "Mental" = "Mental and behavioural disorders",                                                                   
                                "Nervous system" = "Diseases of the nervous system",                                                                     
                                "Circulatory system" = "Diseases of the circulatory system",                                                                 
                                "Respiratory system" = "Diseases of the respiratory system",                                                                 
                                "Digestive system" = "Diseases of the digestive system",                                                                   
                                "Skin and Subcutaneous tissue" = "Diseases of the skin and subcutaneous tissue",                                                       
                                "Muculoskeletal" = "Diseases of the musculoskeletal system and connective tissue",                                       
                                "Genitourinary system" = "Diseases of the genitourinary system",                                                               
                                "Pregnancy and Childbirth" = "Pregnancy, childbirth and the puerperium",                                                           
                                "Preinatal conditions" = "Certain conditions originating in the perinatal period",                                             
                                "Deformations" = "Congenital malformations, deformations and chromosomal abnormalities",                               
                                "Other" = "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified",            
                                "External cause" = "External causes of morbidity and mortality"),
                            ),
                            span(tags$i(h5("Data sourced from the Center for Disease Control (CDC)",
                                           a(href="https://wonder.cdc.gov/ucd-icd10.html",
                                             "data repository.", target="_blank"))))
                          ),
                     column(8,leafletOutput(outputId = "disease_rate_2010",
                                            height = "80vh",
                                            width = "60vw")
                            )
                     )
                   ),
          tabPanel("Disease Rate by State over Time vs. National Avg (1999-2010)",
                   column(4,
                   radioButtons(
                     inputId = "disease",
                     label = "Select Disease Type",
                     choices =
                       c(
                         "Parasitic" = "Certain infectious and parasitic diseases",                                                          
                         "Neoplasms" = "Neoplasms",                                                                                          
                         "Blood" = "Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism",
                         "Enodcrine" = "Endocrine, nutritional and metabolic diseases",                                                      
                         "Mental" = "Mental and behavioural disorders",                                                                   
                         "Nervous system" = "Diseases of the nervous system",                                                                     
                         "Circulatory system" = "Diseases of the circulatory system",                                                                 
                         "Respiratory system" = "Diseases of the respiratory system",                                                                 
                         "Digestive system" = "Diseases of the digestive system",                                                                   
                         "Skin and Subcutaneous tissue" = "Diseases of the skin and subcutaneous tissue",                                                       
                         "Muculoskeletal" = "Diseases of the musculoskeletal system and connective tissue",                                       
                         "Genitourinary system" = "Diseases of the genitourinary system",                                                               
                         "Pregnancy and Childbirth" = "Pregnancy, childbirth and the puerperium",                                                           
                         "Preinatal conditions" = "Certain conditions originating in the perinatal period",                                             
                         "Deformations" = "Congenital malformations, deformations and chromosomal abnormalities",                               
                         "Other" = "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified",            
                         "External cause" = "External causes of morbidity and mortality")
                     ),
                   selectInput(
                     inputId = "state",
                     label = "Select State",
                     choices = c("Alabama" = "AL",
                                 "Alaska" = "AK",
                                 "Arizona" ="AZ",
                                 "Arkansas"="AR",
                                 "California"="CA",
                                 "Colorado"="CO",
                                 "Connecticut"="CT",
                                 "Delaware"="DE",
                                 "District of Columbia"="DC",
                                 "Florida"="FL",
                                 "Georgia"="GA",
                                 "Hawaii"="HI",
                                 "Idaho"="ID",
                                 "Illinois"="IL",
                                 "Indiana"="IN",
                                 "Iowa"="IA",
                                 "Kansas"="KS",
                                 "Kentucky"="KY",
                                 "Louisiana"="LA",
                                 "Maine"="ME",
                                 "Montana"="MT",
                                 "Nebraska"="NE",
                                 "Nevada"="NV",
                                 "New Hampshire"="NH",
                                 "New Jersey"="NJ",
                                 "New Mexico"="NM",
                                 "New York"="NY",
                                 "North Carolina"="NC",
                                 "North Dakota"="ND",
                                 "Ohio"="OH",
                                 "Oklahoma"="OK",
                                 "Oregon"="OR",
                                 "Maryland"="MD",
                                 "Massachusetts"="MA",
                                 "Michigan"="MI",
                                 "Minnesota"="MN",
                                 "Mississippi"="MS",
                                 "Missouri"="MO",
                                 "Pennsylvania"="PA",
                                 "Rhode Island"="RI",
                                 "South Carolina"="SC",
                                 "South Dakota"="SD",
                                 "Tennessee"="TN",
                                 "Texas"="TX",
                                 "Utah"="UT",
                                 "Vermont"="VT",
                                 "Virginia"="VA",
                                 "Washington"="WA",
                                 "West Virginia"="WV",
                                 "Wisconsin"="WI",
                                 "Wyoming"="WY"),
                     multiple = FALSE),
                   span(tags$i(h5("Data sourced from the Center for Disease Control (CDC)",
                                  a(href="https://wonder.cdc.gov/ucd-icd10.html",
                                    "data repository.", target="_blank"))))
                   ),
                   column(8,plotlyOutput(outputId = "disease_rate_time",
                                           height = "80vh",
                                           width = "60vw")
                          )
          )
      )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  # define reactive content for first tab
  disease_type <- reactive({
    d <- df_map %>% filter(icd_chapter == input$icd_chapter)
    return(d)
  })
  
  # define reactive content for 2nd tab
  disease_type_state <- reactive({
    d2 <- df_char %>% filter(disease == input$disease,
                             state == input$state)
    return(d2)
  })
  
  

    output$disease_rate_2010 <- renderLeaflet({
      # set labels
      labels <- sprintf(
        "<h3>%s</h3><br><br/>
  <strong>Disease Type: </strong>%s<br/>
  <strong>Population: </strong>%s<br/>
  <strong>Crude Motality Rate: </strong>%g ",
        disease_type()$name,
        disease_type()$icd_chapter,
        disease_type()$population,
        disease_type()$crude_rate) %>% 
        lapply(htmltools::HTML)
      
      # set bins
      bins <- getJenksBreaks(disease_type()$crude_rate, 6) # get natural breaks
      # if bins not unique
      if (length(bins) > length(unique(bins))) {
        bins <- getJenksBreaks(disease_type()$crude_rate,5)
      }
      # set color palette
      pal <- colorBin(palette = "PuBu",
                      bins = bins, 
                      domain = disease_type()$crude_rate)
      
      # plot map
        disease_type() %>% 
        st_transform(4326) %>% 
        leaflet() %>%
        setView(lng = -95.7129,lat = 37.0902,zoom = 4.25) %>%
        addProviderTiles(providers$CartoDB.Positron) %>% 
        addPolygons(label = labels,
                    weight = 0.25,
                    color = "white",
                    smoothFactor = 0.5,
                    opacity = 1,
                    fillOpacity = 0.7,
                    fillColor = pal(disease_type()$crude_rate),
                    highlightOptions = highlightOptions(weight = 1,
                                                        color = "#666",
                                                        fillOpacity = 0.7,
                                                        bringToFront = T)) %>% 
        addLegend("bottomright",
                  pal = pal,
                  values = ~crude_rate,
                  title = "Mortality Rate",
                  opacity = 0.7)
        })

    output$disease_rate_time <- renderPlotly({
      # set var
      state <-  disease_type_state()$name
      disease <-  disease_type_state()$disease
      colors <-  c("#0C6291","#A63446")
      
      # create plot and define xaxis
      plot_ly(data = disease_type_state(), x = ~year) %>% # add state
      add_trace(y = ~crude_rate, 
                     type = "scatter",
                     mode = "line",
                     line = list(width=4,
                                 color = colors[2]),
                     name = state) %>%  # add national average
      add_trace(y = ~avg_crude_rate_all, 
                     type = "scatter",
                     mode = "line",
                     line = list(width=2, 
                                 color = colors[1]),
                     name = "National Avg") %>%  # add title and axis titles
      layout(title = list(text =paste0("Crude Rate in ",state," vs. National Average \n",disease), y=0.96),
                      xaxis = list(title = "Year"),
                      yaxis = list (title = "Crude Morality Rate"),
                      legend = list(x = 0.80, y = 0.9))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
