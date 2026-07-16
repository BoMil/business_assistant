using FluentResults;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Shared.Domain.Errors;
using System.Net;

namespace Shared.Presentation.ErrorHandling;

public static class CommonHttpErrorHandlers
{
    public static ProblemHttpResult HandleError(IError error)
    {
        return error switch
        {
            ValidationError validationError => TypedResults.Problem(
                title: error.Message,
                statusCode: (int)HttpStatusCode.BadRequest,
                detail: "One or more validation errors occurred.",
                extensions: new Dictionary<string, object?>
                {
                    { "errors", validationError.ValidationErrors }
                }),
            NotFoundError => TypedResults.Problem(
                title: error.Message,
                statusCode: (int)HttpStatusCode.NotFound),
            ServiceUnavailableError => TypedResults.Problem(
                title: error.Message,
                statusCode: (int)HttpStatusCode.ServiceUnavailable),
            InternalError => TypedResults.Problem(
                title: error.Message,
                statusCode: (int)HttpStatusCode.InternalServerError),
            ForbiddenError => TypedResults.Problem(
                title: error.Message,
                statusCode: (int)HttpStatusCode.Forbidden),
            _ => TypedResults.Problem(
                title: error.Message,
                statusCode: (int)HttpStatusCode.BadRequest)
        };
    }

    public static ProblemHttpResult HandleBadRequest(IError error)
    {
        return TypedResults.Problem(title: error.Message, statusCode: (int)HttpStatusCode.BadRequest);
    }

    public static ValidationProblem HandleValidationProblem(ValidationError error)
    {
        return TypedResults.ValidationProblem(errors: error.ValidationErrors, title: "Request failed validation");
    }

    public static ProblemHttpResult HandleNotFound(NotFoundError error)
    {
        return TypedResults.Problem(title: error.Message, statusCode: (int)HttpStatusCode.NotFound);
    }

    public static ProblemHttpResult HandleInternalServerError(InternalError error)
    {
        return TypedResults.Problem(title: error.Message, statusCode: (int)HttpStatusCode.InternalServerError);
    }

    public static ProblemHttpResult HandleForbiddenError(ForbiddenError error)
    {
        return TypedResults.Problem(title: error.Message, statusCode: (int)HttpStatusCode.Forbidden);
    }
}
