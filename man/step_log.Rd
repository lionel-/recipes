% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/log.R
\name{step_log}
\alias{step_log}
\title{Logarithmic Transformation}
\usage{
step_log(recipe, ..., role = NA, trained = FALSE, base = exp(1),
  vars = NULL)
}
\arguments{
\item{recipe}{A recipe object. The step will be added to the sequence of 
operations for this recipe.}

\item{...}{One or more selector functions to choose which variables are 
affected by the step. See \code{\link{selections}} for more details.}

\item{role}{Not used by this step since no new variables are created.}

\item{trained}{A logical to indicate if the quantities for preprocessing 
have been estimated.}

\item{base}{A numeric value for the base.}

\item{vars}{A character string of variable names that will be (eventually)
populated by the \code{terms} argument.}
}
\value{
\code{step_log} returns an object of class \code{step_log}.
}
\description{
\code{step_log} creates a \emph{specification} of a recipe step that will
  log transform data.
}
\examples{
set.seed(313)
examples <- matrix(exp(rnorm(40)), ncol = 2)
examples <- as.data.frame(examples)

rec <- recipe(~ V1 + V2, data = examples)

log_trans <- rec  \%>\%
  step_log(all_predictors())

log_obj <- prepare(log_trans, training = examples)

transformed_te <- bake(log_obj, examples)
plot(examples$V1, transformed_te$V1)
}
\seealso{
\code{\link{step_logit}} \code{\link{step_invlogit}}
  \code{\link{step_hyperbolic}}  \code{\link{step_sqrt}}
  \code{\link{recipe}} \code{\link{prepare.recipe}}
  \code{\link{bake.recipe}}
}
\concept{
preprocessing transformation_methods
}
\keyword{datagen}
