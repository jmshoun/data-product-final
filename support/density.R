beta_density <- function(num.successes, num.failures, prior, 
                                probability=seq(0, 1, by=0.002), ...) {
    data.frame(probability=probability) %>%
        mutate(density = dbeta(probability, num.successes + prior, 
                               num.failures + prior),
               density = ifelse(density == Inf, 10, density),
               ...)
}

difference_density <- function(density.1, density.2, ...) {
    precision <- floor(-log10(sqrt(.Machine$double.eps)))
    joint.density <- outer(density.1$density, density.2$density)
    joint.df <- expand.grid(p.1=density.1$probability, 
                            p.2=density.2$probability) %>%
        mutate(density = as.vector(joint.density),
               probability = round(p.1 - p.2, precision)) %>%
        group_by(probability) %>%
        summarize(density = sum(density)) %>%
        mutate(density = density / mean(density)) %>%
        mutate(...)
}
