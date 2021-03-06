#' Logit Transformation
#'
#' \code{step_logit} creates a \emph{specification} of a recipe step that will
#'   logit transform the data.
#'
#' @inheritParams step_center
#' @param role Not used by this step since no new variables are created.
#' @param vars A character string of variable names that will be (eventually)
#'   populated by the \code{terms} argument.
#' @return \code{step_logit} returns an object of class \code{step_logit}.
#' @keywords datagen
#' @concept preprocessing transformation_methods
#' @export
#' @details The inverse logit transformation takes values between zero and one
#'   and translates them to be on the real line using the function
#'   \code{f(p) = log(p/(1-p))}.
#' @examples
#' set.seed(313)
#' examples <- matrix(runif(40), ncol = 2)
#' examples <- data.frame(examples)
#'
#' rec <- recipe(~ X1 + X2, data = examples)
#'
#' logit_trans <- rec  %>%
#'   step_logit(all_predictors())
#'
#' logit_obj <- prepare(logit_trans, training = examples)
#'
#' transformed_te <- bake(logit_obj, examples)
#' plot(examples$X1, transformed_te$X1)
#' @seealso \code{\link{step_invlogit}} \code{\link{step_log}}
#' \code{\link{step_sqrt}}  \code{\link{step_hyperbolic}} \code{\link{recipe}}
#' \code{\link{prepare.recipe}} \code{\link{bake.recipe}}

step_logit <-
  function(recipe,
           ...,
           role = NA,
           trained = FALSE,
           vars = NULL) {
    terms <- quos(...)
    if (is_empty(terms))
      stop("Please supply at least one variable specification.",
           "See ?selections.", call. = FALSE)
    add_step(recipe,
             step_logit_new(
               terms = terms,
               role = role,
               trained = trained,
               vars = vars
             ))
  }

step_logit_new <-
  function(terms = NULL,
           role = NA,
           trained = FALSE,
           vars = NULL) {
    step(
      subclass = "logit",
      terms = terms,
      role = role,
      trained = trained,
      vars = vars
    )
  }

#' @export
prepare.step_logit <- function(x, training, info = NULL, ...) {
  col_names <- select_terms(x$terms, info = info)
  step_logit_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    vars = col_names
  )
}

#' @importFrom tibble as_tibble
#' @importFrom stats binomial
#' @export
bake.step_logit <- function(object, newdata, ...) {
  for (i in seq_along(object$vars))
    newdata[, object$vars[i]] <-
      binomial()$linkfun(getElement(newdata, object$vars[i]))
  as_tibble(newdata)
}


print.step_logit <-
  function(x, width = max(20, options()$width - 33), ...) {
    cat("Logit transformation on ", sep = "")
    if (x$trained) {
      cat(format_ch_vec(x$vars, width = width))
    } else
      cat(format_selectors(x$terms, wdth = width))
    if (x$trained)
      cat(" [trained]\n")
    else
      cat("\n")
    invisible(x)
  }
