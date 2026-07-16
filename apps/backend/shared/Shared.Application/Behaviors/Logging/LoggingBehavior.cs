using System.Text.Json;
using FluentResults;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared.Domain.Errors;

namespace Shared.Application.Behaviors.Logging;

public class LoggingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
    where TResponse : ResultBase, new()
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;
    private readonly JsonSerializerOptions _jsonSerializeOptions = new() { WriteIndented = true };

    public LoggingBehavior(ILogger<LoggingBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        string requestName = request.GetType().Name;

        _logger.LogInformation("Handling {Request} with data {@Data}", requestName, request);

        var response = await next();

        if (response.IsFailed)
            response.Errors.ForEach(error => LogExpectedErrors(requestName, error));

        _logger.LogInformation("Finish handling {Request}", requestName);

        return response;
    }

    private void LogExpectedErrors(string requestName, IError error)
    {
        if (error is ValidationError validationError)
        {
            _logger.LogWarning("{Request} failed with validation errors {Errors}", requestName,
                JsonSerializer.Serialize(validationError.ValidationErrors, _jsonSerializeOptions));
        }
        else
        {
            _logger.LogWarning("{Request} failed with error {Error}", requestName,
                JsonSerializer.Serialize(error, _jsonSerializeOptions));
        }
    }
}
