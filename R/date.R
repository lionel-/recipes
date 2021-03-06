#' Date Feature Generator
#'
#' \code{step_date} creates a a \emph{specification} of a recipe step that will
#'   convert date data into one or more factor or numeric variables.
#'
#' @inheritParams step_center
#' @param ... One or more selector functions to choose which variables that
#'   will be used to create the new variables. The selected variables should
#'   have class \code{Date} or \code{POSIXct}. See \code{\link{selections}} for
#'   more details.
#' @param role For model terms created by this step, what analysis role should
#'   they be assigned?. By default, the function assumes that the new variable
#'   columns created by the original variables will be used as predictors in a
#'   model.
#' @param features A character string that includes at least one of the
#'   following values: \code{month}, \code{dow} (day of week), \code{doy}
#'   (day of year), \code{week}, \code{month}, \code{decimal} (decimal date,
#'   e.g. 2002.197), \code{quarter}, \code{semester}, \code{year}.
#' @param label A logical. Only available for features \code{month} or
#'   \code{dow}. \code{TRUE} will display the day of the week as an ordered
#'   factor of character strings, such as "Sunday." \code{FALSE} will display
#'   the day of the week as a number.
#' @param abbr A logical. Only available for features \code{month} or
#'   \code{dow}. \code{FALSE} will display the day of the week as an ordered
#'   factor of character strings, such as "Sunday". \code{TRUE} will display
#'   an abbreviated version of the label, such as "Sun". \code{abbr} is
#'   disregarded if \code{label = FALSE}.
#' @param ordinal A logical: should factors be ordered? Only available for
#'   features \code{month} or \code{dow}.
#' @param variables A character string of variables that will be used as
#'   inputs. This field is a placeholder and will be populated once
#'    \code{\link{prepare.recipe}} is used.
#' @return \code{step_date} returns an object of class \code{step_date}.
#' @keywords datagen
#' @concept preprocessing model_specification variable_encodings dates
#' @export
#' @details Unlike other steps, \code{step_date} does \emph{not} remove the
#'   original date variables. \code{\link{step_rm}} can be used for this
#'   purpose.
#' @examples
#' library(lubridate)
#'
#' examples <- data.frame(Dan = ymd("2002-03-04") + days(1:10),
#'                        Stefan = ymd("2006-01-13") + days(1:10))
#' date_rec <- recipe(~ Dan + Stefan, examples) %>%
#'    step_date(all_predictors())
#'
#' date_rec <- prepare(date_rec, training = examples)
#' date_values <- bake(date_rec, newdata = examples)
#' date_values
#' @seealso \code{\link{step_holiday}} \code{\link{step_rm}} 
#'   \code{\link{recipe}} \code{\link{prepare.recipe}} \code{\link{bake.recipe}}
step_date <-
  function(recipe,
           ...,
           role = "predictor",
           trained = FALSE,
           features = c("dow", "month", "year"),
           abbr = TRUE,
           label = TRUE,
           ordinal = FALSE,
           variables = NULL
  ) {
  feat <-
    c("year",
      "doy",
      "week",
      "decimal",
      "semester",
      "quarter",
      "dow",
      "month")
  if (!all(features %in% feat))
    stop("Possible values of `features` should include: ",
         paste0("'", feat, "'", collapse = ", "))
  
  terms <- quos(...)
  if (is_empty(terms))
    stop("Please supply at least one variable specification.", 
         "See ?selections.", call. = FALSE)
  add_step(
    recipe,
    step_date_new(
      terms = terms,
      role = role,
      trained = trained,
      features = features,
      abbr = abbr,
      label = label,
      ordinal = ordinal,
      variables = variables
    )
  )
}

step_date_new <- 
  function(
    terms = NULL,
    role = "predictor",
    trained = FALSE,
    features = features,
    abbr = abbr,
    label = label,
    ordinal = ordinal,
    variables = variables
  ) {
  step(
    subclass = "date",
    terms = terms,
    role = role,
    trained = trained,
    features = features,
    abbr = abbr,
    label = label,
    ordinal = ordinal,
    variables = variables
  )
}

#' @importFrom stats as.formula model.frame
#' @export
prepare.step_date <- function(x, training, info = NULL, ...) {
  col_names <- select_terms(x$terms, info = info)
  
  date_data <- info[info$variable %in% col_names, ]
  if (any(date_data$type != "date"))
    stop("All variables for `step_date` should be either `Date` or", 
         "`POSIXct` classes.", call. = FALSE)
  
  step_date_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    features = x$features,
    abbr = x$abbr,
    label = x$label,
    ordinal = x$ordinal,
    variables = col_names
  )
}


ord2fac <- function(x, what) {
  x <- getElement(x, what)
  factor(as.character(x), levels = levels(x), ordered = FALSE)
}


#' @importFrom lubridate year yday week decimal_date quarter semester wday month
get_date_features <-
  function(dt,
           feats,
           abbr = TRUE,
           label = TRUE,
           ord = FALSE) {
    ## pre-allocate values
    res <- matrix(NA, nrow = length(dt), ncol = length(feats))
    res <- as_tibble(res)
    colnames(res) <- feats
    
    if ("year" %in% feats)
      res[, grepl("year$", names(res))] <- year(dt)
    if ("doy" %in% feats)
      res[, grepl("doy$", names(res))] <- yday(dt)
    if ("week" %in% feats)
      res[, grepl("week$", names(res))] <- week(dt)
    if ("decimal" %in% feats)
      res[, grepl("decimal$", names(res))] <- decimal_date(dt)
    if ("quarter" %in% feats)
      res[, grepl("quarter$", names(res))] <- quarter(dt)
    if ("semester" %in% feats)
      res[, grepl("semester$", names(res))] <- semester(dt)
    if ("dow" %in% feats) {
      res[, grepl("dow$", names(res))] <-
        wday(dt, abbr = abbr, label = label)
      if (!ord & label == TRUE)
        res[, grepl("dow$", names(res))]  <-
          ord2fac(res, grep("dow$", names(res), value = TRUE))
    }
    if ("month" %in% feats) {
      res[, grepl("month$", names(res))] <-
        month(dt, abbr = abbr, label = label)
      if (!ord & label == TRUE)
        res[, grepl("month$", names(res))]  <-
          ord2fac(res, grep("month$", names(res), value = TRUE))
    }
    res
  }

#' @importFrom tibble as_tibble is_tibble
#' @export
bake.step_date <- function(object, newdata, ...) {
  new_cols <-
    rep(length(object$features), each = length(object$variables))
  date_values <-
    matrix(NA, nrow = nrow(newdata), ncol = sum(new_cols))
  colnames(date_values) <- rep("", sum(new_cols))
  date_values <- as_tibble(date_values)
  
  strt <- 1
  for (i in seq_along(object$variables)) {
    cols <- (strt):(strt + new_cols[i] - 1)
    
    tmp <- get_date_features(
      dt = getElement(newdata, object$variables[i]),
      feats = object$features,
      abbr = object$abbr,
      label = object$label,
      ord = object$ordinal
    )
    
    date_values[, cols] <- tmp
    
    names(date_values)[cols] <-
      paste(object$variables[i],
            names(tmp),
            sep = "_")
    
    strt <- max(cols) + 1
  }
  newdata <- cbind(newdata, date_values)
  if (!is_tibble(newdata))
    newdata <- as_tibble(newdata)
  newdata
}


print.step_date <-
  function(x, width = max(20, options()$width - 29), ...) {
    cat("Date features from ")
    if (x$trained) {
      cat(format_ch_vec(x$variables, width = width))
    } else
      cat(format_selectors(x$terms, wdth = width))
    if (x$trained)
      cat(" [trained]\n")
    else
      cat("\n")
    invisible(x)
  }
