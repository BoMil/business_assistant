namespace Business.Presentation.Endpoints.Clients;

/// <summary>JSON body for POST /clients.</summary>
public record CreateClientRequest(
    string Name,
    string PhoneNumber,
    string Email,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    string? Description);
