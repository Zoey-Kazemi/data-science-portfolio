# 🦠 Global Tuberculosis Burden Analysis

This project analyzes global tuberculosis (TB) burden using data from the World Health Organization (WHO) covering the period 2000–2023.

## Overview

Tuberculosis remains a major global health issue, especially in low- and middle-income countries. This analysis explores how TB incidence and mortality have changed over time, compares trends across regions, and identifies countries with relatively high or low TB burden.

## Key Questions

- How has the global TB burden changed over time?
- How do TB trends differ across regions?
- Which countries currently have high or low TB burden?

## Methods

- Trend visualization using `ggplot2` (`geom_smooth`)
- Regional comparison using faceting
- K-means clustering to classify countries into TB burden levels
- Spatial visualization using `sf` and `rnaturalearth`
- Interactive mapping using `ggiraph`

## Results

- TB incidence and mortality generally decreased globally over time
- Africa and South-East Asia continue to show the highest TB burden
- Most countries fall into low or moderate burden categories, but some remain in high-burden clusters

## Visualization

### Global and Regional Trends
![Trend Plot](figures/fig1.png)

### Country-Level TB Burden (2023)
![Map](figures/fig2.png)

👉 **Interactive version:**  
[Open the full HTML report](analysis.html)
## Tools

R, tidyverse, ggplot2, patchwork, broom, sf, rnaturalearth, ggiraph

## Data Source

World Health Organization (WHO) TB Burden dataset  
https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-11-11/readme.md
