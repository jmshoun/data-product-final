library(shiny)
library(Hmisc)
library(dplyr)
library(magrittr)
library(reshape2)
library(ggplot2)

source("support/density.R")
source("support/uncertainty.R")

shinyServer(function(input, output) {
    num_samples <- reactive({
        ifelse(input$data_type == "Two-Sample", 2, 1)
    })
    
    prior <- reactive({
        switch(input$prior_type,
               `Uniform (log-odds)`=0,
               `Jeffreys`=0.5,
               `Uniform (probability)`=1,
               `Agresti-Coull`=2)
    })
    
    prior_distribution_data <- reactive({
        prior.density <- beta_density(0, 0, prior(), distribution="Prior")
        difference.prior <- difference_density(prior.density, prior.density,
                                               distribution="Prior",
                                               estimand="Sample 1 - Sample 2")
        rbind(difference.prior,
              cbind(prior.density, estimand="Sample 1 Probability"),
              cbind(prior.density, estimand="Sample 2 Probability"))
    })
    
    posterior_distribution_data <- reactive({
        sample.1.density <- beta_density(input$sample_1_successes,
                                         input$sample_1_failures, prior(),
                                         distribution="Posterior",
                                         estimand="Sample 1 Probability")
        sample.2.density <- beta_density(input$sample_2_successes,
                                         input$sample_2_failures, prior(),
                                         distribution="Posterior",
                                         estimand="Sample 2 Probability")
        difference.density <- difference_density(sample.1.density,
                                                 sample.2.density,
                                                 distribution="Posterior",
                                                 estimand="Sample 1 - Sample 2")
        rbind(sample.1.density,
              sample.2.density,
              difference.density)
    })
    
    distribution_data <- reactive({
        df <- rbind(prior_distribution_data(),
                    posterior_distribution_data()) %>%
            mutate(distribution = factor(distribution, c("Prior", "Posterior")),
                   estimand = factor(estimand, c("Sample 1 Probability",
                                                 "Sample 2 Probability",
                                                 "Sample 1 - Sample 2")))
        
        if (num_samples() == 1) {
            df <- filter(df, estimand == "Sample 1 Probability")
        }
        df
    })
    
    output$sample_distribution_plot <- renderPlot({
        ggplot(distribution_data()) +
            aes(x=probability, y=density) +
            geom_area(color="black", fill="cornflowerblue") +
            facet_grid(distribution ~ estimand, scales="free") +
            labs(x="Value", 
                 y="Probability Density",
                 title="Prior and Posterior Distributions") +
            theme_bw()
    })
    
    output$uncertainty_interval_header <- renderText({
        alpha.formatted <- sprintf("%d%%", as.numeric(input$alpha) * 100)
        paste(alpha.formatted, "Uncertainty Intervals")
    })
    
    output$uncertainty_intervals <- renderTable({
        sample.1.est <- beta_uncertainty(input$sample_1_successes,
                                         input$sample_1_failures,
                                         prior(), input$alpha, 
                                         "Sample 1 Probability")
        sample.2.est <- beta_uncertainty(input$sample_2_successes,
                                         input$sample_2_failures,
                                         prior(), input$alpha, 
                                         "Sample 2 Probability")
        
        posterior.difference <- filter(posterior_distribution_data(),
                                       estimand == "Sample 1 - Sample 2")
        difference.est <- difference_uncertainty(posterior.difference,
                                                 input$alpha,
                                                 "Sample 1 - Sample 2")
        
        if (num_samples() == 2) {
            rbind(sample.1.est, 
                  sample.2.est,
                  difference.est)
        } else {
            sample.1.est
        }
    })
})