### Required libraries
library(shiny)

### External files with support functions
source("support/sample_input.R")

### Global constants
PRIOR.CHOICES <- c("Uniform (log-odds)", "Jeffreys", "Uniform (probability)",
                   "Agresti-Coull")
ALPHA.CHOICES <- c(0.5, 0.8, 0.9, 0.95, 0.99)

### Control Sidebar Definition
control.sidebar <- sidebarPanel(
    selectInput("data_type", "Data Type", c("One-Sample", "Two-Sample")),
    selectInput("prior_type", "Prior Distribution", PRIOR.CHOICES,
                selected="Uniform (probability)"),
    
    ## Sample Data
    sample_input(1),
    conditionalPanel(
        "input.data_type == 'Two-Sample'",
        sample_input(2)
    ),
    
    selectInput("alpha", "Uncertainty Interval Size", ALPHA.CHOICES, 
                selected=0.8)
)

### Main Panel Definition
main.panel <- mainPanel(
    tabsetPanel(
        tabPanel(
            "Output",
            plotOutput("sample_distribution_plot"),
            h3(textOutput("uncertainty_interval_header")),
            tableOutput("uncertainty_intervals")
        ),
        tabPanel(
            "Documentation",
            p("stub")
        )
    )
)

### UI definition
shinyUI(pageWithSidebar(
    headerPanel("Bayesian Estimation with Binomial Data"),
    control.sidebar,
    main.panel
))
