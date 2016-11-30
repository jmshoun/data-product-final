### Given a number of successes, number of failres, prior (to be applied to both
### successes and failures), width of uncertainty width alpha, and name of an
### estimand, constrcut an alpha% uncertainty interval on the posterior 
### distribution along with a couple other summary metrics and return the
### result as a single-row data.frame.
beta_uncertainty <- function(num.successes, num.failures, prior, alpha,
                             estimand) {
    ## Convert alpha to lower and upper quantiles.
    alpha.lower <- (1 - as.numeric(alpha)) / 2
    alpha.upper <- (1 + as.numeric(alpha)) / 2
    ## Algebraic expression for the mode of the distribution.
    uncapped.mode <- (num.successes + prior - 1) /
        (num.successes + num.failures + 2  * prior - 2)
    
    data.frame(Estimand = estimand,
               Mean = (num.successes + prior) / 
                   (num.successes + num.failures + 2 * prior),
               ## The expression for the mode isn't guaranteed to fall between
               ## 0 and 1, so we force it so.
               Mode = min(max(uncapped.mode, 0), 1),
               `Lower Bound`=qbeta(alpha.lower, num.successes + prior, 
                                   num.failures + prior),
               `Upper Bound`=qbeta(alpha.upper, num.successes + prior,
                                   num.failures + prior),
               check.names=FALSE)
}

### This function is the analogue to beta_uncertainty for the difference
### estimand. There's no easy closed-form solution for the uncertainty interval
### here, so we estimate it numerically from the approximated distribution
### function.
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
