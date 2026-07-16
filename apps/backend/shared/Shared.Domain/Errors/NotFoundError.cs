using FluentResults;

namespace Shared.Domain.Errors;

public class NotFoundError : IError
{
    public List<IError> Reasons => [];

    public string Message { get; init; }

    public Dictionary<string, object> Metadata => [];

    public NotFoundError(string message)
    {
        Message = message;
    }
}
