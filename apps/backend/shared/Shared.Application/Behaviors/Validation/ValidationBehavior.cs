using FluentResults;
using FluentValidation;
using MediatR;
using Shared.Domain.Errors;

namespace Shared.Application.Behaviors.Validation;

public sealed class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
    where TResponse : ResultBase, new()
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        if (!_validators.Any())
            return await next();

        var context = new ValidationContext<TRequest>(request);

        Dictionary<string, string[]> validatorResult = _validators
            .Select(x => x.Validate(context))
            .SelectMany(x => x.Errors)
            .Where(x => x != null)
            .GroupBy(
                x => x.PropertyName,
                x => x.ErrorMessage,
                (propertyName, errorMessages) => new { Key = propertyName, Values = errorMessages.Distinct().ToArray() })
            .ToDictionary(x => x.Key, x => x.Values);

        if (!validatorResult.Any())
            return await next();

        return SetupErrorResponse(request, validatorResult);
    }

    private static TResponse SetupErrorResponse(TRequest request, Dictionary<string, string[]> validatorResult)
    {
        var result = new TResponse();

        List<IError> reasons = validatorResult
            .Select(x =>
            {
                Error reason = new(x.Key);
                reason.CausedBy(x.Value.Select(y => new Error(y)));
                return (IError)reason;
            })
            .ToList();

        result.Reasons.Add(new ValidationError($"{request.GetType().Name} failed validation", reasons));

        return result;
    }
}
