namespace Business.Domain.ValueObjects;

/// <summary>
/// A named place with coordinates. Populated client-side by a geocoding/autocomplete
/// search (e.g. Google Places) — the backend only stores the chosen result, it never
/// searches or validates addresses itself.
/// </summary>
public class Location
{
    public string Address { get; private set; } = string.Empty;
    public double Latitude { get; private set; }
    public double Longitude { get; private set; }

    private Location() { }

    public static Location Create(string address, double latitude, double longitude) =>
        new() { Address = address, Latitude = latitude, Longitude = longitude };
}
