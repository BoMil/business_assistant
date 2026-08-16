/// <summary>JSON body for POST /categories.</summary>
public record CreateCategoryRequest(string Name, string? ImgUrl);