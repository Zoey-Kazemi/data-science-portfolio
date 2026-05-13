library(shiny)
library(tidyverse)
library(sf)
library(rnaturalearth)
library(ggplot2)
library(broom)

#---------------------------------------------------------

who_tb_data <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-11-11/who_tb_data.csv', show_col_types = FALSE)

# Create a vector of variable of interest
vars_of_interest <- c(
  "country", "g_whoregion", "iso_numeric", "iso2", "iso3", "year", "c_cdr", "c_newinc_100k", "cfr", "e_inc_100k", "e_inc_num", "e_mort_100k", "e_mort_exc_tbhiv_100k", "e_mort_exc_tbhiv_num",
  "e_mort_num", "e_mort_tbhiv_100k", "e_mort_tbhiv_num", "e_pop_num"
)

# Subset the dataset 
who_tb_data <- who_tb_data |>
  select(all_of(vars_of_interest))

who_tb_data <- who_tb_data |>
  select(country, g_whoregion, year, e_inc_100k, e_mort_100k, iso3)

who_tb_data <- filter(who_tb_data, country != "Democratic People's Republic of Korea")

#-----------------------------------------------------------
# Natural earth: Country level
sf_world <- ne_countries(returnclass='sf')

ui <- fluidPage(
  titlePanel("Global TB Burden Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "year",
        "Select year:",
        choices = rev(2000:2023),
        selected = 2023
      )
    ),
    
    mainPanel(
      plotOutput("tb_map")
    )
  )
)

server <- function(input, output) {
  
  output$tb_map <- renderPlot({
    
    data_year <- who_tb_data |>
      filter(year == as.numeric(input$year))
    
    km_fit <- data_year |>
      select(e_inc_100k, e_mort_100k) |>
      scale() |>
      kmeans(centers = 5, nstart = 50)
    
    cluster_labels <- tidy(km_fit) |>
      mutate(distance = e_inc_100k + e_mort_100k) |>
      arrange(distance) |>
      mutate(
        cluster_order = c(
          "Lowest TB Burden",
          "Low TB Burden",
          "Moderate TB Burden",
          "High TB Burden",
          "Highest TB Burden"
        ),
      cluster_order = fct_relevel(cluster_order, "Lowest TB Burden", "Low TB Burden", "Moderate TB Burden", "High TB Burden", "Highest TB Burden")
      ) 
    
    # Prepare the data to join sf_world: first cluster labels
    cluster_labels_tojoin_map <- cluster_labels |>
      mutate(cluster = as.integer(cluster)) |>
      select(cluster, cluster_order)
    
    # Label countries by cluster labels
    map_tb <- data_year |>
      mutate(.cluster = km_fit$cluster) |> # Add cluster numbers as .cluster
      left_join(cluster_labels_tojoin_map, by = c(".cluster" = "cluster"))
    
    # join our data set to sf_world by ISO country codes
    map_data <- sf_world |>
      left_join (map_tb, by = c("iso_a3" = "iso3"))
    
    # NA appears in cluster_order because there is no information about some countries
    map_data <- map_data |>
      mutate(cluster_order = if_else(is.na(cluster_order), "No Information", cluster_order))|>
      mutate(cluster_order = fct_relevel (cluster_order, 
                                          "Lowest TB Burden"  , 
                                          "Low TB Burden"     , 
                                          "Moderate TB Burden", 
                                          "High TB Burden"    , 
                                          "Highest TB Burden",
                                          "No Information" ))
    
    ggplot(map_data) + geom_sf(aes(fill = cluster_order), color = "black", linewidth = 0.1) + coord_sf(crs = "ESRI:54030")+  # Robinson projection
      
      scale_fill_manual(name = NULL, values = c(
        "Lowest TB Burden"  = "#FFFFCC", 
        "Low TB Burden"     = "#F0E442", 
        "Moderate TB Burden"= "#E3A136", 
        "High TB Burden"    = "#EB6A10", 
        "Highest TB Burden" = "#C30625",
        "No Information" = "#4A443199") # Color palette checked for accessibility (deutan, protan, tritan) using the colorspace package
      )+
      
      theme_bw() +
      theme(
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "#FCF9F3"),
        panel.background = element_rect(fill = "#F1EBDA"),
        legend.background = element_rect(fill = "#FCF9F3"),
        text = element_text(color = "black", face = "bold", size = 16),
        legend.position = "bottom",
        legend.key.spacing.x = unit(0.4, "cm"),
        legend.text = element_text(size = 13)
      )+
      guides(fill = guide_legend(nrow = 2))
  })
}

shinyApp(ui, server)