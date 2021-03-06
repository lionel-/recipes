library(testthat)
library(magrittr)
library(recipes)
library(lubridate)

exp_dates <- data.frame(date  = ymd(c("2017-12-25", "2017-05-29", "2017-04-16")),
                        holiday = c("ChristmasDay", "USMemorialDay", "Easter"),
                        stringsAsFactors = FALSE)
test_data <- data.frame(day  = ymd("2017-01-01") + days(0:364))

test_that('Date class', {
  holiday_rec <- recipe(~ day, test_data) %>%
    step_holiday(all_predictors(), holidays = exp_dates$holiday)

  holiday_rec <- prepare(holiday_rec, training = test_data)
  holiday_ind <- bake(holiday_rec, test_data)

  all.equal(holiday_ind$day[holiday_ind$day_USMemorialDay == 1],
            exp_dates$date[exp_dates$holiday == "USMemorialDay"])

  expect_equal(holiday_ind$day[holiday_ind$day_USMemorialDay == 1],
               exp_dates$date[exp_dates$holiday == "USMemorialDay"])
  expect_equal(holiday_ind$day[holiday_ind$day_ChristmasDay == 1],
               exp_dates$date[exp_dates$holiday == "ChristmasDay"])
  expect_equal(holiday_ind$day[holiday_ind$day_Easter == 1],
               exp_dates$date[exp_dates$holiday == "Easter"])
})


test_that('POSIXct class', {
  test_data$day <- as.POSIXct(test_data$day)
  exp_dates$date <- as.POSIXct(exp_dates$date)

  holiday_rec <- recipe(~ day, test_data) %>%
    step_holiday(all_predictors(), holidays = exp_dates$holiday)

  holiday_rec <- prepare(holiday_rec, training = test_data)
  holiday_ind <- bake(holiday_rec, test_data)

  all.equal(holiday_ind$day[holiday_ind$day_USMemorialDay == 1],
            exp_dates$date[exp_dates$holiday == "USMemorialDay"])

  expect_equal(holiday_ind$day[holiday_ind$day_USMemorialDay == 1],
               exp_dates$date[exp_dates$holiday == "USMemorialDay"])
  expect_equal(holiday_ind$day[holiday_ind$day_ChristmasDay == 1],
               exp_dates$date[exp_dates$holiday == "ChristmasDay"])
  expect_equal(holiday_ind$day[holiday_ind$day_Easter == 1],
               exp_dates$date[exp_dates$holiday == "Easter"])
})


test_that('printing', {
  holiday_rec <- recipe(~ day, test_data) %>%
    step_holiday(all_predictors(), holidays = exp_dates$holiday)
  expect_output(print(holiday_rec))
  expect_output(prepare(holiday_rec, training = test_data))
})

