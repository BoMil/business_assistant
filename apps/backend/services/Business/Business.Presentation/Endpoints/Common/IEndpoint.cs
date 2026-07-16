using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Common;

public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}
