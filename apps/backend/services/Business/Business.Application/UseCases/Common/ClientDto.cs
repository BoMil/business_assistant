namespace Business.Application.UseCases.Common;

public record ClientDto(
    Guid Id,
    string Name,
    string PhoneNumber,
    string Email,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    string? Description);
