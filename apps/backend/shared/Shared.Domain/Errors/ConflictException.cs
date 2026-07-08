namespace Shared.Domain.Errors;

public class ConflictException(ConflictError error) : Exception(error.Message)
{
    public ConflictError Error { get; } = error;
}

public class NotFoundException(NotFoundError error) : Exception(error.Message)
{
    public NotFoundError Error { get; } = error;
}

public class ValidationException(ValidationError error) : Exception(error.Message)
{
    public ValidationError Error { get; } = error;
}
