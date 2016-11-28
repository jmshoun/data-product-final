beta_uncertainty <- function(num.successes, num.failures, prior, alpha,
                             estimand) {
    alpha.lower <- (1 - as.numeric(alpha)) / 2
    alpha.upper <- (1 + as.numeric(alpha)) / 2
    uncapped.mode <- (num.successes + prior - 1) /
        (num.successes + num.failures + 2  * prior - 2)
    data.frame(Estimand = estimand,
               Mean = (num.successes + prior) / 
                   (num.successes + num.failures + 2 * prior),
               Mode = min(max(uncapped.mode, 0), 1),
               `Lower Bound`=qbeta(alpha.lower, num.successes + prior, 
                                   num.failures + prior),
               `Upper Bound`=qbeta(alpha.upper, num.successes + prior,
                                   num.failures + prior),
               check.names=FALSE)
}

difference_uncertainty <- function(difference.density, alpha, estimand) {
    alpha.lower <- (1 - as.numeric(alpha)) / 2
    alpha.upper <- (1 + as.numeric(alpha)) / 2
    
    mean.difference <- weighted.mean(difference.density$probability,
                                     difference.density$density)
    mode.index <- which.max(difference.density$density)
    mode.difference <- difference.density$probability[mode.index]
    
    data.frame(Estimand = estimand,
               Mean = mean.difference,
               Mode = mode.difference,
               `Lower Bound`= wtd.quantile(difference.density$probability,
                                           difference.density$density,
                                           alpha.lower),
               `Upper Bound`= wtd.quantile(difference.density$probability,
                                           difference.density$density,
                                           alpha.upper),
               check.names=FALSE)
}
