#' ICA Signal Extraction
#'
#' \code{step_ica} creates a \emph{specification} of a recipe step that will
#'   convert numeric data into one or more independent components.
#'
#' @inheritParams step_center
#' @param ... One or more selector functions to choose which variables will be
#'   used to compute the components. See \code{\link{selections}} for more
#'   details.
#' @param role For model terms created by this step, what analysis role should
#'   they be assigned?. By default, the function assumes that the new
#'   independent component columns created by the original variables will be
#'   used as predictors in a model.
#' @param num The number of ICA components to retain as new predictors. If
#'   \code{num} is greater than the number of columns or the number of possible
#'   components, a smaller value will be used.
#' @param options A list of options to \code{\link[fastICA]{fastICA}}. No
#'   defaults are set here. \bold{Note} that the arguments \code{X} and
#'   \code{n.comp} should not be passed here.
#' @param res The \code{\link[fastICA]{fastICA}} object is stored here once
#'   this preprocessing step has be trained by \code{\link{prepare.recipe}}.
#' @param prefix A character string that will be the prefix to the resulting
#'   new variables. See notes below
#' @return \code{step_ica} returns an object of class \code{step_ica}.
#' @keywords datagen
#' @concept preprocessing ica projection_methods
#' @export
#' @details Independent component analysis (ICA) is a transformation of a
#'   group of variables that produces a new set of artificial features or
#'   components. ICA assumes that the variables are mixtures of a set of
#'   distinct, non-Gaussian signals and attempts to transform the data to
#'   isolate these signals. Like PCA, the components are statistically
#'   independent from one another. This means that they can be used to combat
#'   large inter-variables correlations in a data set. Also like PCA, it is
#'   advisable to center and scale the variables prior to running ICA.
#'
#' This package produces components using the "FastICA" methodology (see
#'   reference below).
#'
#' The argument \code{num} controls the number of components that will be
#'   retained (the original variables that are used to derive the components
#'   are removed from the data). The new components will have names that begin
#'   with \code{prefix} and a sequence of numbers. The variable names are
#'   padded with zeros. For example, if \code{num < 10}, their names will be
#'   \code{IC1} - \code{IC9}. If \code{num = 101}, the names would be
#'   \code{IC001} - \code{IC101}.
#'
#' @references Hyvarinen, A., and Oja, E. (2000). Independent component
#'   analysis: algorithms and applications. \emph{Neural Networks}, 13(4-5),
#'   411-430.
#'
#' @examples
#' # from fastICA::fastICA
#' set.seed(131)
#' S <- matrix(runif(400), 200, 2)
#' A <- matrix(c(1, 1, -1, 3), 2, 2, byrow = TRUE)
#' X <- as.data.frame(S %*% A)
#'
#' tr <- X[1:100, ]
#' te <- X[101:200, ]
#'
#' rec <- recipe( ~ ., data = tr)
#'
#' ica_trans <- step_center(rec,  V1, V2)
#' ica_trans <- step_scale(rec, V1, V2)
#' ica_trans <- step_ica(rec, V1, V2, num = 2)
#' ica_estimates <- prepare(ica_trans, training = tr)
#' ica_data <- bake(ica_estimates, te)
#'
#' plot(te$V1, te$V2)
#' plot(ica_data$IC1, ica_data$IC2)
#' @seealso \code{\link{step_pca}} \code{\link{step_kpca}}
#'   \code{\link{step_isomap}} \code{\link{recipe}} \code{\link{prepare.recipe}}
#'   \code{\link{bake.recipe}}
step_ica <-
  function(recipe,
           ...,
           role = "predictor",
           trained = FALSE,
           num  = 5,
           options = list(),
           res = NULL,
           prefix = "IC") {
    terms <- quos(...)
    if (is_empty(terms))
      stop("Please supply at least one variable specification.",
           "See ?selections.", call. = FALSE)
    add_step(
      recipe,
      step_ica_new(
        terms = terms,
        role = role,
        trained = trained,
        num = num,
        options = options,
        res = res,
        prefix = prefix
      )
    )
  }

step_ica_new <-
  function(terms = NULL,
           role = "predictor",
           trained = FALSE,
           num  = NULL,
           options = NULL,
           res = NULL,
           prefix = "IC") {
    step(
      subclass = "ica",
      terms = terms,
      role = role,
      trained = trained,
      num = num,
      options = options,
      res = res,
      prefix = prefix
    )
  }

#' @importFrom dimRed FastICA dimRedData
#' @export
prepare.step_ica <- function(x, training, info = NULL, ...) {
  col_names <- select_terms(x$terms, info = info)
  
  x$num <- min(x$num, length(col_names))
  
  indc <- FastICA(stdpars = x$options)
  indc <-
    indc@fun(dimRedData(as.data.frame(training[, col_names, drop = FALSE])),
             list(ndim = x$num))
  
  step_ica_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    num = x$num,
    options = x$options,
    res = indc,
    prefix = x$prefix
  )
}

#' @export
bake.step_ica <- function(object, newdata, ...) {
  ica_vars <- colnames(environment(object$res@apply)$indata)
  comps <-
    object$res@apply(
      dimRedData(
        as.data.frame(newdata[, ica_vars, drop = FALSE])
        )
      )@data
  comps <- comps[, 1:object$num, drop = FALSE]
  colnames(comps) <- names0(ncol(comps), object$prefix)
  newdata <- cbind(newdata, as_tibble(comps))
  newdata <-
    newdata[, !(colnames(newdata) %in% ica_vars), drop = FALSE]
  as_tibble(newdata)
}


print.step_ica <-
  function(x, width = max(20, options()$width - 29), ...) {
    cat("ICA extraction with ")
    if (x$trained) {
      cat(format_ch_vec(colnames(x$res@org.data), width = width))
    } else
      cat(format_selectors(x$terms, wdth = width))
    if (x$trained)
      cat(" [trained]\n")
    else
      cat("\n")
    invisible(x)
  }
