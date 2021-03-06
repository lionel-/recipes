% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sqrt.R
\name{step_sqrt}
\alias{step_sqrt}
\title{Square Root Transformation}
\usage{
step_sqrt(recipe, ..., role = NA, trained = FALSE, vars = NULL)
}
\arguments{
\item{recipe}{A recipe object. The step will be added to the sequence of 
operations for this recipe.}

\item{...}{One or more selector functions to choose which variables will be
transformed. See \code{\link{selections}} for more details.}

\item{role}{Not used by this step since no new variables are created.}

\item{trained}{A logical to indicate if the quantities for preprocessing 
have been estimated.}

\item{vars}{A character string of variable names that will be (eventually)
populated by the \code{terms} argument.}
}
\value{
\code{step_sqrt}  returns an object of class \code{step_sqrt}.
}
\description{
\code{step_sqrt} creates a \emph{specification} of a recipe step that will
  square root transform the data.
}
\examples{
set.seed(313)
examples <- matrix(rnorm(40)^2, ncol = 2)
examples <- as.data.frame(examples)

rec <- recipe(~ V1 + V2, data = examples)

sqrt_trans <- rec  \%>\%
  step_sqrt(all_predictors())

sqrt_obj <- prepare(sqrt_trans, training = examples)

transformed_te <- bake(sqrt_obj, examples)
plot(examples$V1, transformed_te$V1)
}
\seealso{
\code{\link{step_logit}} \code{\link{step_invlogit}}
  \code{\link{step_log}}  \code{\link{step_hyperbolic}} \code{\link{recipe}}
  \code{\link{prepare.recipe}} \code{\link{bake.recipe}}
}
\concept{
preprocessing transformation_methods
}
\keyword{datagen}
