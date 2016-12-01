### Required libraries
library(shiny)
library(Hmisc)
library(dplyr)
library(magrittr)
library(reshape2)
library(ggplot2)

### External files with support functions
source("support/density.R")
source("support/uncertainty.R")

shinyServer(function(input, output) {
    ## Convert the data_type input to a numeric number of samples
    num_samples <- reactive({
        ifelse(input$data_type == "Two-Sample", 2, 1)
    })
    
    ## Convert the prior text input to the corresponding numeric prior
    prior <- reactive({
        switch(input$prior_type,
               `Uniform (log-odds)`=0,
               `Jeffreys`=0.5,
               `Uniform (probability)`=1,
               `Agresti-Coull`=2)
    })
    
    ## Construct a data.frame with the prior distributions.
    prior_distribution_data <- reactive({
        prior.density <- beta_density(0, 0, prior(), distribution="Prior")
        difference.prior <- difference_density(prior.density, prior.density,
                                               distribution="Prior",
                                               estimand="Sample 1 - Sample 2")
        rbind(difference.prior,
              cbind(prior.density, estimand="Sample 1 Probability"),
              cbind(prior.density, estimand="Sample 2 Probability"))
    })
    
    ## Construct a data.frame with the posterior distributions.
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
    
    ## Combine the prior and posterior distribution data.frames.
    distribution_data <- reactive({
        df <- rbind(prior_distribution_data(),
                    posterior_distribution_data()) %>%
            ## Reorder the levels of distribution and estimand so they display
            ## in the proper order in ggplot2.
            mutate(distribution = factor(distribution, c("Prior", "Posterior")),
                   estimand = factor(estimand, c("Sample 1 Probability",
                                                 "Sample 2 Probability",
                                                 "Sample 1 - Sample 2")))
        
        ## Filter the data down to the one-sample distribution if the user has
        ## only selected one sample.
        if (num_samples() == 1) {
            df <- filter(df, estimand == "Sample 1 Probability")
        }
        df
    })
    
    ## Create the plot of the distributions.
    output$sample_distribution_plot <- renderPlot({
        ggplot(distribution_data()) +
            aes(x=probability, y=density) +
            geom_area(color="black", fill="cornflowerblue") +
            facet_grid(distribution ~ estimand, scales="free") +
            labs(x="Value", 
                 y="Probability Density",
                 title="Prior and Posterior Distributions") +
            theme_bw(16)
    })
    
    ## Render the header for the uncertainty interval table.
    output$uncertainty_interval_header <- renderText({
        alpha.formatted <- sprintf("%d%%", as.numeric(input$alpha) * 100)
        paste(alpha.formatted, "Uncertainty Intervals")
    })
    
    ### Render the data.frame for the numeric summaries (including uncertainty
    ### intervals) of the estimands.
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
        
        ## Select the appropriate elements, depending on how many samples the
        ## user has selected.
        if (num_samples() == 2) {
            rbind(sample.1.est, 
                  sample.2.est,
                  difference.est)
        } else {
            sample.1.est
        }
    }, digits=3)
})
