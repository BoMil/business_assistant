/// <summary>JSON body for POST /categories.</summary>
public record UpdateCategoryRequest(string Name, string? ImgUrl);