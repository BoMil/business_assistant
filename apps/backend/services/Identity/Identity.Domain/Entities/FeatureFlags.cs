namespace Identity.Domain.Entities;

public class FeatureFlags
{
    public bool Rental { get; set; } = true;
    public bool Inventory { get; set; } = true;
    public bool Reporting { get; set; } = true;
    public bool Poultry { get; set; } = false;
}
