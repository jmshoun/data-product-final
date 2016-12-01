# Documentation

### Introduction

This Shiny app is an easy introduction to performing Bayesian inference on on continuous quantities. Here, we demonstrate estimating population probabilities from binomial data.

### Inputs

Each of the inputs in the app are described below.

#### Data Type

Select whether the data you have consists of one or two samples.

#### Prior Distribution

Select the prior distribution you wish to assume. From weakest to strongest, the priors are:

* Uniform (log-odds) assumes an improper uniform prior on the probability when expressed on the log-odds (logit) scale.
* Jeffreys is the [Jeffreys prior](https://en.wikipedia.org/wiki/Jeffreys_prior) for the Bernoulli distribution.
* Uniform (probability) assumes a uniform prior on the probabiltiy when expressed on the probability scale.
* Agresti-Coull assumes the prior implied by the [Agresti-Coull binomial confidence interval](https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Agresti-Coull_Interval).

#### Sample Successes/Failures

Input the data for each sample, expressed as an integer number of successes and failures.

#### Uncertainty Interval Size

Select the probability that the true population probability is within the posterior uncertainty interval. Higher probabilities lead to wider intervals.

### Output

#### Prior and Posterior Plots

The prior and posterior plots on the output panel show the prior and posterior distributions for each of the estimands: the probability of success in the first sample (p1), plus (if Two-Sample mode is selected) the probability of success in the second sample (p1) and the difference p1 - p2. Note that since each of the estimands is continuous, our priors and posteriors are probability distribution functions instead of discrete probabilities.

#### Uncertainty Interval Estimates

The uncertainty estimate table gives a few key summary metrics for each estimand: the mean of the posterior distribution, the mode (the peak of the distribution, or its most likely outcome), and an uncertainty interval for the estimate.

Note that the uncertainty interval in Bayesian statistics is exactly what every beginning statistics student wished frequentist confidence intervals represented! An 80% uncertainty interval means that we believe there's an 80% chance the true probability falls within the interval.

### Example

A brief practical example of estimation using this tool follows.

#### One-Sample Estimation

My aunt Carol is absolutely dominating our family fantasy football league this year, with a record of 10 wins and 2 losses. Assuming constant strength of schedule, what are the chances she wins next week?

If we choose the Agresti-Coull prior (a conservative choice, given the small sample size) and input 10 and 2 for the sample 1 data, we see that the mean probability is 75%, the mode is 79%, and the 90% uncertainty interval is from 56% to 90%. We can therefore conclude that she almost certainly has better-than-even odds of winning next week. (Note however, that the model doesn't completely discount the possibility that she has a below-average team and just got extremely lucky!)

#### Two-Sample Esimation

Continuing this example, my uncle Paul is having a fairly rough season this year, with a record of 5-7. What is the probability that Carol's team really is stronger than Paul's?

If we keep the same priors, switch to two-sample mode, and input Paul's record, we see the mean estimate of Carol's strength is 31% greater than Paul's, the mode is 33% greater than Paul's, and the 90% uncertainty interval is from 4% to 57%. In other words, we're pretty darn sure that Carol really did do better than Paul in the draft this year.

### Suggestions for Further Exploration

* What effect does the choice of prior have on the posterior distributions?
* As the sample size (sum of successes and failures) increases, how does the influence of the choice of prior change?
* Which priors give the most sensible answers for data with all successes or all failures?
* Is it possible to get a posterior 99% uncertainty interval that doesn't include the mode of the distribution?
