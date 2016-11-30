### Given a number of successes, number of failures, and a prior (to be applied)
### to both successes and failures), return a data.frame of 
### (probability, density) pairs that represents the corresponding posterior
### beta distribution. ... args are additional static attributes of the
### data frame (for example, labeling which sample the distribution is for).
beta_density <- function(num.successes, num.failures, prior, 
                                probability=seq(0, 1, by=0.002), ...) {
    data.frame(probability=probability) %>%
        mutate(density = dbeta(probability, num.successes + prior, 
                               num.failures + prior),
               density = ifelse(density == Inf, 10, density),
               ...)
}

### Given a pair of density data.frames created by beta_density, calculate the
### density of p1 - p2 by brute-force integration of the joint density.
difference_density <- function(density.1, density.2, ...) {
    ## Number of decimal places of precision to expect in the probability
    ## differences.
    precision <- floor(-log10(sqrt(.Machine$double.eps)))
    ## %o% is the outer product operator.
    joint.density <- density.1$density %o% density.2$density
    
    joint.df <- expand.grid(p.1=density.1$probability, 
                            p.2=density.2$probability) %>%
        mutate(density = as.vector(joint.density),
               ## Without the rounding, there would be probabilities that only
               ## differed in the least significant bit.
               probability = round(p.1 - p.2, precision)) %>%
        group_by(probability) %>%
        summarize(density = sum(density)) %>%
        ## Normalize the density.
        mutate(density = density / mean(density)) %>%
        mutate(...)
}
