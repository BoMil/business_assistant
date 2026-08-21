namespace Identity.Presentation.Endpoints.Users;

/// <summary>JSON body for PUT /users/me/image.</summary>
public record UpdateUserImageRequest(string? ImgUrl);
