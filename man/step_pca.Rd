% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pca.R
\name{step_pca}
\alias{step_pca}
\title{PCA Signal Extraction}
\usage{
step_pca(recipe, ..., role = "predictor", trained = FALSE, num = 5,
  threshold = NA, options = list(), res = NULL, prefix = "PC")
}
\arguments{
\item{recipe}{A recipe object. The step will be added to the sequence of 
operations for this recipe.}

\item{...}{One or more selector functions to choose which variables will be
used to compute the components. See \code{\link{selections}} for more
details.}

\item{role}{For model terms created by this step, what analysis role should
they be assigned?. By default, the function assumes that the new principal
component columns created by the original variables will be used as
predictors in a model.}

\item{trained}{A logical to indicate if the quantities for preprocessing 
have been estimated.}

\item{num}{The number of PCA components to retain as new predictors. If
\code{num} is greater than the number of columns or the number of
possible components, a smaller value will be used.}

\item{threshold}{A fraction of the total variance that should be covered
by the components. For example, \code{threshold = .75} means that
\code{step_pca} should generate enough components to capture 75\% of the
variability in the variables. Note: using this argument will override and
resent any value given to \code{num}.}

\item{options}{A list of options to the default method for
\code{\link[stats]{prcomp}}. Argument defaults are set to
\code{retx = FALSE}, \code{center = FALSE}, \code{scale. = FALSE}, and
\code{tol = NULL}. \bold{Note} that the argument \code{x} should not be
passed here (or at all).}

\item{res}{The \code{\link[stats]{prcomp.default}} object is stored here
once this preprocessing step has be trained by \code{\link{prepare.recipe}}.}

\item{prefix}{A character string that will be the prefix to the resulting
new variables. See notes below}
}
\value{
\code{step_pca}  returns an object of class \code{step_pca}.
}
\description{
\code{step_pca} creates a \emph{specification} of a recipe step that will
  convert numeric data into one or more principal components.
}
\details{
Principal component analysis (PCA) is a transformation of a group of
  variables that produces a new set of artificial features or components.
  These components are designed to capture the maximum amount of information
  (i.e. variance) in the original variables. Also, the components are
  statistically independent from one another. This means that they can be
  used to combat large inter-variables correlations in a data set.

It is advisable to standardized the variables prior to running PCA. Here,
  each variable will be centered and scaled prior to the PCA calculation.
  This can be changed using the \code{options} argument or by using
  \code{\link{step_center}} and \code{\link{step_scale}}.

The argument \code{num} controls the number of components that will be
  retained (the original variables that are used to derive the components
  are removed from the data). The new components will have names that begin
  with \code{prefix} and a sequence of numbers. The variable names are
  padded with zeros. For example, if \code{num < 10}, their names will be
  \code{PC1} - \code{PC9}. If \code{num = 101}, the names would be
  \code{PC001} - \code{PC101}.

Alternatively, \code{threshold} can be used to determine the number of
  components that are required to capture a specified fraction of the total
  variance in the variables.
}
\examples{
rec <- recipe( ~ ., data = USArrests)
pca_trans <- rec \%>\%
  step_center(all_numeric()) \%>\%
  step_scale(all_numeric()) \%>\%
  step_pca(all_numeric(), num = 3)
pca_estimates <- prepare(pca_trans, training = USArrests)
pca_data <- bake(pca_estimates, USArrests)

rng <- extendrange(c(pca_data$PC1, pca_data$PC2))
plot(pca_data$PC1, pca_data$PC2,
     xlim = rng, ylim = rng)

with_thresh <- rec \%>\%
  step_center(all_numeric()) \%>\%
  step_scale(all_numeric()) \%>\%
  step_pca(all_numeric(), threshold = .99)
with_thresh <- prepare(with_thresh, training = USArrests)
bake(with_thresh, USArrests)
}
\references{
Jolliffe, I. T. (2010). \emph{Principal Component Analysis}.
  Springer.
}
\seealso{
\code{\link{step_ica}} \code{\link{step_kpca}}
  \code{\link{step_isomap}} \code{\link{recipe}} \code{\link{prepare.recipe}}
  \code{\link{bake.recipe}}
}
\concept{
preprocessing pca projection_methods
}
\keyword{datagen}
