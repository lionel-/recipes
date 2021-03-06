% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/invlogit.R
\name{step_invlogit}
\alias{step_invlogit}
\title{Inverse Logit Transformation}
\usage{
step_invlogit(recipe, ..., role = NA, trained = FALSE, vars = NULL)
}
\arguments{
\item{recipe}{A recipe object. The step will be added to the sequence of 
operations for this recipe.}

\item{...}{One or more selector functions to choose which variables are 
affected by the step. See \code{\link{selections}} for more details.}

\item{role}{Not used by this step since no new variables are created.}

\item{trained}{A logical to indicate if the quantities for preprocessing 
have been estimated.}

\item{vars}{A character string of variable names that will be (eventually)
populated by the \code{terms} argument.}
}
\value{
\code{step_invlogit} returns an object of class \code{step_invlogit}.
}
\description{
\code{step_invlogit} creates a \emph{specification} of a recipe step that
  will transform the data from real values to be between zero and one.
}
\details{
The inverse logit transformation takes values on the real line and
  translates them to be between zero and one using the function
  \code{f(x) = 1/(1+exp(-x))}.
}
\examples{
data(biomass)

biomass_tr <- biomass[biomass$dataset == "Training",]
biomass_te <- biomass[biomass$dataset == "Testing",]

rec <- recipe(HHV ~ carbon + hydrogen + oxygen + nitrogen + sulfur,
              data = biomass_tr)

ilogit_trans <- rec  \%>\%
  step_center(carbon, hydrogen) \%>\%
  step_scale(carbon, hydrogen) \%>\%
  step_invlogit(carbon, hydrogen)

ilogit_obj <- prepare(ilogit_trans, training = biomass_tr)

transformed_te <- bake(ilogit_obj, biomass_te)
plot(biomass_te$carbon, transformed_te$carbon)
}
\seealso{
\code{\link{step_logit}} \code{\link{step_log}}
  \code{\link{step_sqrt}}  \code{\link{step_hyperbolic}}
  \code{\link{recipe}} \code{\link{prepare.recipe}}
  \code{\link{bake.recipe}}
}
\concept{
preprocessing transformation_methods
}
\keyword{datagen}
