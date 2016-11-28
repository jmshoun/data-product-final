library(shiny)

inlineNumericInput <- function(inputId, label, value, min=NA, max=NA, step=NA) {
    value <- restoreInput(id=inputId, default=value)
    inputTag <- tags$input(id=inputId, type="number", class="form-control",
                           value=shiny:::formatNoSci(value))
    if (!is.na(min)) inputTag$attribs$min <- min
    if (!is.na(max)) inputTag$attribs$max <- max
    if (!is.na(step)) inputTag$attribs$step <- step
    div(style="display:inline-block; width:45%",
        class="input-small",
        tags$label(label, `for`=inputId),
        inputTag)
}

shinyUI(pageWithSidebar(
    headerPanel("Hello"),
    sidebarPanel(
        selectInput("data_type", "Data Type", c("One-Sample", "Two-Sample")),
        selectInput("prior_type", "Prior Distribution",
                    c("Uniform (log-odds)", "Jeffreys", "Uniform (probability)",
                      "Agresti-Coull"),
                    selected="Agresti-Coull"),
        inlineNumericInput("sample_1_successes", "Sample 1 Successes", 
                           value=5, min=0),
        inlineNumericInput("sample_1_failures", "Sample 1 Failures",
                           value=5, min=0),
        conditionalPanel(
            "input.data_type == 'Two-Sample'",
            inlineNumericInput("sample_2_successes", "Sample 2 Successes", 
                               value=5, min=0),
            inlineNumericInput("sample_2_failures", "Sample 2 Failures",
                               value=5, min=0)
        ),
        selectInput("alpha", "Uncertainty Interval Size",
                    c(0.5, 0.8, 0.9, 0.95, 0.99), selected=0.9)
    ),
    mainPanel(
        plotOutput("sample_distribution_plot"),
        h3(textOutput("uncertainty_interval_header")),
        tableOutput("uncertainty_intervals")
    )
))
