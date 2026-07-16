using FluentResults;

namespace Shared.Domain.Errors;

public class InternalError : IError
{
    public List<IError> Reasons => new();

    public string Message { get; init; }

    public Dictionary<string, object> Metadata => new();

    public InternalError(string message)
    {
        Message = message;
    }
}
