#' Near-Zero Variance Filter
#'
#' \code{step_nzv} creates a \emph{specification} of a recipe step that will
#'   potentially remove variables that are highly sparse and unbalanced.
#'
#' @inheritParams step_center
#' @param ... One or more selector functions to choose which variables that
#'   will evaluated by the filtering bake. See \code{\link{selections}} for
#'   more details.
#' @param role Not used by this step since no new variables are created.
#' @param options A list of options for the filter (see Details below).
#' @param removals A character string that contains the names of columns that
#'   should be removed. These values are not determined until
#'   \code{\link{prepare.recipe}} is called.
#' @return \code{step_nzv}  returns an object of class \code{step_nzv}.
#' @keywords datagen
#' @concept preprocessing variable_filters
#' @export
#'
#' @details This step diagnoses predictors that have one unique value (i.e.
#'   are zero variance predictors) or predictors that are have both of the
#'   following characteristics:
#' \enumerate{
#'   \item they have very few unique values relative to the number of samples
#'     and
#'   \item the ratio of the frequency of the most common value to the
#'     frequency of the second most common value is large.
#' }
#'
#' For example, an example of near zero variance predictor is one that, for
#'   1000 samples, has two distinct values and 999 of them are a single value.
#'
#' To be flagged, first the frequency of the most prevalent value over the
#'   second most frequent value (called the "frequency ratio") must be above
#'   \code{freq_cut}. Secondly, the "percent of unique values," the number of
#'   unique values divided by the total number of samples (times 100), must
#'   also be below \code{unique_cut}.
#'
#' In the above example, the frequency ratio is 999 and the unique value
#'   percentage is 0.0001.
#' @examples
#' data(biomass)
#'
#' biomass$sparse <- c(1, rep(0, nrow(biomass) - 1))
#'
#' biomass_tr <- biomass[biomass$dataset == "Training",]
#' biomass_te <- biomass[biomass$dataset == "Testing",]
#'
#' rec <- recipe(HHV ~ carbon + hydrogen + oxygen + nitrogen + sulfur + sparse,
#'               data = biomass_tr)
#'
#' nzv_filter <- rec %>%
#'   step_nzv(all_predictors())
#'
#' filter_obj <- prepare(nzv_filter, training = biomass_tr)
#'
#' filtered_te <- bake(filter_obj, biomass_te)
#' any(names(filtered_te) == "sparse")
#' @seealso \code{\link{step_corr}} \code{\link{recipe}}
#'   \code{\link{prepare.recipe}} \code{\link{bake.recipe}}

step_nzv <-
  function(recipe,
           ...,
           role = NA,
           trained = FALSE,
           options = list(freq_cut = 95 / 5, unique_cut = 10),
           removals = NULL) {
    terms <- quos(...)
    if (is_empty(terms))
      stop("Please supply at least one variable specification.",
           "See ?selections.",
           call. = FALSE)
    add_step(
      recipe,
      step_nzv_new(
        terms = terms,
        role = role,
        trained = trained,
        options = options,
        removals = removals
      )
    )
  }

step_nzv_new <-
  function(terms = NULL,
           role = NA,
           trained = FALSE,
           options = NULL,
           removals = NULL) {
    step(
      subclass = "nzv",
      terms = terms,
      role = role,
      trained = trained,
      options = options,
      removals = removals
    )
  }

#' @export
prepare.step_nzv <- function(x, training, info = NULL, ...) {
  col_names <- select_terms(x$terms, info = info)
  filter <- nzv(
    x = training[, col_names],
    freq_cut = x$options$freq_cut,
    unique_cut = x$options$unique_cut
  )
  
  step_nzv_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    options = x$options,
    removals = filter
  )
}

#' @export
bake.step_nzv <- function(object, newdata, ...) {
  if (length(object$removals) > 0)
    newdata <- newdata[, !(colnames(newdata) %in% object$removals)]
  as_tibble(newdata)
}

print.step_nzv <-
  function(x, width = max(20, options()$width - 38), ...) {
    if (x$trained) {
      if (length(x$removals) > 0) {
        cat("Sparse, unbalanced variable filter removed ")
        cat(format_ch_vec(x$removals, width = width))
      } else
        cat("Sparse, unbalanced variable filter removed no terms")
    } else {
      cat("Correlation filter on ", sep = "")
      cat(format_selectors(x$terms, wdth = width))
    }
    if (x$trained)
      cat(" [trained]\n")
    else
      cat("\n")
    invisible(x)
  }

nzv <- function(x,
                freq_cut = 95 / 5,
                unique_cut = 10) {
  if (is.null(dim(x)))
    x <- matrix(x, ncol = 1)
  
  fr_foo <- function(data) {
    t <- table(data[!is.na(data)])
    if (length(t) <= 1) {
      return(0)
    }
    w <- which.max(t)
    
    return(max(t, na.rm = TRUE) / max(t[-w], na.rm = TRUE))
  }
  
  freq_ratio <- vapply(x, fr_foo, c(ratio = 0))
  uni_foo <- function(data)
    length(unique(data[!is.na(data)]))
  lunique <- vapply(x, uni_foo, c(num = 0))
  pct_unique <- 100 * lunique / vapply(x, length, c(num = 0))
  
  zero_func <- function(data)
    all(is.na(data))
  zero_var <- (lunique == 1) | vapply(x, zero_func, c(zv = TRUE))
  
  out <-
    which( (freq_ratio > freq_cut &
             pct_unique <= unique_cut) | zero_var)
  names(out) <- NULL
  colnames(x)[out]
}
