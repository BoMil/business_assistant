using FluentResults;

namespace Shared.Domain.Errors;

public class ForbiddenError : IError
{
    public List<IError> Reasons => [];
    public string Message { get; init; }
    public Dictionary<string, object> Metadata { get; init; } = [];

    public ForbiddenError(string message)
    {
        Message = message;
    }

    public ForbiddenError(string message, Dictionary<string, object> metadata)
    {
        Message = message;
        Metadata = metadata;
    }
}
