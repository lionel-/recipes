library(testthat)
library(magrittr)
library(gower)
library(recipes)
library(dplyr)
data("biomass")

rec <- recipe(HHV ~ carbon + hydrogen + oxygen + nitrogen + sulfur,
              data = biomass)

biomass_tr <- biomass[biomass$dataset == "Training", ]
biomass_te <- biomass[biomass$dataset == "Testing", ]

# induce some missing data at random
set.seed(9039)
carb_missing <- sample(1:nrow(biomass_te), 3)
nitro_missing <- sample(1:nrow(biomass_te), 3)

biomass_te$carbon[carb_missing] <- NA
biomass_te$nitrogen[nitro_missing] <- NA

test_that('imputation values', {
  discr_rec <- rec %>%
    step_discretize(nitrogen, options = list(keep_na = FALSE))
  impute_rec <- discr_rec %>%
    step_knnimpute(carbon,
                   nitrogen,
                   impute_with = imp_vars(hydrogen, oxygen, nitrogen),
                   K = 3)

  discr_rec <- prepare(discr_rec, training = biomass_tr, verbose = FALSE)
  tr_data <- bake(discr_rec, newdata = biomass_tr)
  te_data <- bake(discr_rec, newdata = biomass_te) %>%
    dplyr::select(hydrogen, oxygen, nitrogen, carbon)
  
  nn <- gower_topn(te_data[, c("hydrogen", "oxygen", "nitrogen")],
                   tr_data[, c("hydrogen", "oxygen", "nitrogen")],
                   n = 3)$index
  
  impute_rec <- prepare(impute_rec, training = biomass_tr, verbose = FALSE)
  imputed_te <- bake(impute_rec, newdata = biomass_te)
  
  for(i in carb_missing) {
    nn_tr_ind <- nn[, i]
    nn_tr_data <- tr_data$carbon[nn_tr_ind]
    expect_equal(imputed_te$carbon[i], mean(nn_tr_data))
  }
  
  for(i in nitro_missing) {
    nn_tr_ind <- nn[, i]
    nn_tr_data <- tr_data$nitrogen[nn_tr_ind]
    expect_equal(as.character(imputed_te$nitrogen[i]), 
                 recipes:::mode_est(nn_tr_data))
  }  
})


test_that('printing', {
  discr_rec <- rec %>%
    step_discretize(nitrogen, options = list(keep_na = FALSE))
  expect_output(print(discr_rec))
  expect_output(prepare(discr_rec, training = biomass_tr))
})

