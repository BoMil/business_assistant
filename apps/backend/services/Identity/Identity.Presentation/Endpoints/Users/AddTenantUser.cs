using System.Security.Claims;
using Identity.Application.UseCases.AddTenantUser;
using Identity.Domain.Enums;
using Identity.Presentation.Endpoints.Common;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;
using Shared.Domain.Errors;
using Shared.Presentation.ErrorHandling;

namespace Identity.Presentation.Endpoints.Users;

/// <summary>
/// POST /users
/// Adds a new user to the caller's own tenant (TenantId comes from the caller's JWT).
/// Only callers whose own role is Owner or Admin may call this.
/// </summary>
public static class AddTenantUser
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost(EndpointGroups.Users, Handle)
                .WithTags(EndpointTags.Users)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Created<Guid>, ProblemHttpResult>> Handle(
        AddTenantUserRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        if (user.GetRole() is not (UserRole.Owner or UserRole.Admin))
            return CommonHttpErrorHandlers.HandleError(new ForbiddenError("Only tenant Owners or Admins can add new users."));

        var command = new AddTenantUserCommand(
            user.GetTenantId(),
            request.FirstName,
            request.LastName,
            request.Email,
            request.PhoneNumber,
            request.Password,
            request.Role);

        var result = await sender.Send(command, cancellationToken);

        return result.IsSuccess
            ? TypedResults.Created((string?)null, result.Value)
            : CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
