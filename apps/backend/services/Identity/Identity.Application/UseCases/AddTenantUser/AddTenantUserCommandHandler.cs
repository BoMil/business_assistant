using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.Services;
using Identity.Domain.Entities;
using MediatR;

namespace Identity.Application.UseCases.AddTenantUser;

internal sealed class AddTenantUserCommandHandler(
    IUnitOfWorkIdentity unitOfWork,
    IPasswordHasher passwordHasher)
    : IRequestHandler<AddTenantUserCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(AddTenantUserCommand request, CancellationToken cancellationToken)
    {
        var emailTaken = await unitOfWork.Users.ExistsByEmailAsync(request.Email, cancellationToken);
        if (emailTaken)
            return Result.Fail($"Email '{request.Email}' is already registered.");

        var passwordHash = passwordHasher.Hash(request.Password);
        var user = User.Create(request.FirstName, request.LastName, request.Email, request.PhoneNumber, passwordHash, request.TenantId, request.Role);

        await unitOfWork.Users.AddAsync(user, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok(user.Id);
    }
}
