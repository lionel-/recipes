library(testthat)
library(magrittr)
library(recipes)

n <- 50
set.seed(424)
dat <- data.frame(
  x1 = sort(rnorm(n)),
  x2 = sort(rep(1:5, each = 10)),
  x3 = sort(factor(rep(letters[1:3], c(2, 2, 46)))),
  x4 = 1,
  y = sort(runif(n))
  )

test_that('numeric data', {
  rec1 <- recipe(y ~ ., data = dat) %>%
    step_shuffle(all_numeric())
  
  rec1 <- prepare(rec1, training = dat, verbose = FALSE)
  set.seed(7046)
  dat1 <- bake(rec1, dat)
  exp1 <- c(FALSE, FALSE, TRUE, TRUE)
  obs1 <- rep(NA, 4)
  for (i in 1:ncol(dat1))
    obs1[i] <-
    isTRUE(all.equal(dat[, i], getElement(dat1, names(dat)[i])))
  expect_equal(exp1, obs1)
})

test_that('nominal data', {
  rec2 <- recipe(y ~ ., data = dat) %>%
    step_shuffle(all_nominal())
  
  rec2 <- prepare(rec2, training = dat, verbose = FALSE)
  set.seed(804)
  dat2 <- bake(rec2, dat)
  exp2 <- c(TRUE, TRUE, FALSE, TRUE)
  obs2 <- rep(NA, 4)
  for (i in 1:ncol(dat2))
    obs2[i] <-
    isTRUE(all.equal(dat[, i], getElement(dat2, names(dat)[i])))
  expect_equal(exp2, obs2)
})

test_that('all data', {
  rec3 <- recipe(y ~ ., data = dat) %>%
    step_shuffle(everything())
  
  rec3 <- prepare(rec3, training = dat, verbose = FALSE)
  set.seed(2516)
  dat3 <- bake(rec3, dat)
  exp3 <- c(FALSE, FALSE, FALSE, TRUE)
  obs3 <- rep(NA, 4)
  for (i in 1:ncol(dat3))
    obs3[i] <-
    isTRUE(all.equal(dat[, i], getElement(dat3, names(dat)[i])))
  expect_equal(exp3, obs3)
})


test_that('printing', {
  rec3 <- recipe(y ~ ., data = dat) %>%
    step_shuffle(everything())
  expect_output(print(rec3))
  expect_output(prepare(rec3, training = dat))
})

