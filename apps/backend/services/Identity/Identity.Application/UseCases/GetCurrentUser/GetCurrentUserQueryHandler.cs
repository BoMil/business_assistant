using Identity.Application.Repositories;
using Identity.Application.UseCases.Common;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Identity.Application.UseCases.GetCurrentUser;

internal sealed class GetCurrentUserQueryHandler(IUnitOfWorkIdentity unitOfWork) : IRequestHandler<GetCurrentUserQuery, Result<UserDto>>
{
    public async Task<Result<UserDto>> Handle(GetCurrentUserQuery request, CancellationToken cancellationToken)
    {
        var user = await unitOfWork.Users.GetByIdAsync(request.UserId, cancellationToken);
        if (user is null)
            return Result.Fail(new NotFoundError($"User '{request.UserId}' not found."));

        return Result.Ok(new UserDto(user.Id, user.TenantId, user.FirstName, user.LastName, user.Email, user.PhoneNumber, user.Role, user.ImgUrl));
    }
}
