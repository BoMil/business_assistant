using FluentResults;

namespace Shared.Domain.Errors;

public class ServiceUnavailableError : IError
{
    public List<IError> Reasons => new();

    public string Message { get; init; }

    public Dictionary<string, object> Metadata => new();

    public ServiceUnavailableError(string message)
    {
        Message = message;
    }
}
