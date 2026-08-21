using Identity.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Identity.Application.UseCases.UpdateUserImage;

internal sealed class UpdateUserImageCommandHandler(IUnitOfWorkIdentity unitOfWork) : IRequestHandler<UpdateUserImageCommand, Result>
{
    public async Task<Result> Handle(UpdateUserImageCommand request, CancellationToken cancellationToken)
    {
        var user = await unitOfWork.Users.GetByIdAsync(request.UserId, cancellationToken);
        if (user is null)
            return Result.Fail(new NotFoundError($"User '{request.UserId}' not found."));

        user.UpdateImage(request.ImgUrl);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
