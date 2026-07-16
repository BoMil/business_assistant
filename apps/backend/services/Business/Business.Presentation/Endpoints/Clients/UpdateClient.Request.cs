namespace Business.Presentation.Endpoints.Clients;

/// <summary>JSON body for PUT /clients/{id}.</summary>
public record UpdateClientRequest(
    string Name,
    string PhoneNumber,
    string Email,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    string? Description);
