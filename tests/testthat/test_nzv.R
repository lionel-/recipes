library(testthat)
library(magrittr)
library(recipes)

n <- 50
set.seed(424)
dat <- data.frame(x1 = rnorm(n),
                  x2 = rep(1:5, each = 10),
                  x3 = factor(rep(letters[1:3], c(2, 2, 46))),
                  x4 = 1,
                  y = runif(n))


ratios <- function(x) {
  tab <- sort(table(x), decreasing = TRUE)
  if(length(tab) > 1) 
    tab[1]/tab[2] else Inf
}

pct_uni <- vapply(dat[, -5], function(x) length(unique(x)), c(val = 0))/nrow(dat)*100
f_ratio <- vapply(dat[, -5], ratios, c(val = 0))
vars <- names(pct_uni)

test_that('nzv filtering', {
  rec <- recipe(y ~ ., data = dat)
  filtering <- rec %>% 
    step_nzv(x1, x2, x3, x4)
  
  filtering_trained <- prepare(filtering, training = dat, verbose = FALSE)
  
  removed <- vars[
    pct_uni <= filtering_trained$steps[[1]]$options$unique_cut & 
      f_ratio >= filtering_trained$steps[[1]]$options$freq_cut]
  
  expect_equal(filtering_trained$steps[[1]]$removals, removed)
})

test_that('altered options', {
  rec <- recipe(y ~ ., data = dat)
  filtering <- rec %>% 
    step_nzv(x1, x2, x3, x4, 
             options = list(freq_cut = 50, unique_cut = 10))
  
  filtering_trained <- prepare(filtering, training = dat, verbose = FALSE)
  
  removed <- vars[
    pct_uni <= filtering_trained$steps[[1]]$options$unique_cut & 
      f_ratio >= filtering_trained$steps[[1]]$options$freq_cut]
  
  expect_equal(filtering_trained$steps[[1]]$removals, removed)
})


test_that('printing', {
  rec <- recipe(y ~ ., data = dat) %>%
    step_nzv(x1, x2, x3, x4)
  expect_output(print(rec))
  expect_output(prepare(rec, training = dat))
})
