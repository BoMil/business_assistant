using FluentResults;

namespace Shared.Domain.Errors;

public class UserError : IError
{
    public List<IError> Reasons => [];
    public string Message { get; init; }
    public Dictionary<string, object> Metadata { get; init; } = [];

    public UserError(string message)
    {
        Message = message;
    }

    public UserError(string message, Dictionary<string, object> metadata)
    {
        Message = message;
        Metadata = metadata;
    }
}
