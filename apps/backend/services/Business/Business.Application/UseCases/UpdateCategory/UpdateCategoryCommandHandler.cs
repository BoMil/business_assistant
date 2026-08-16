using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.UpdateCategory;

internal sealed class UpdateCategoryCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<UpdateCategoryCommand, Result>
{
    public async Task<Result> Handle(UpdateCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await unitOfWork.Categories.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (category is null)
            return Result.Fail(new NotFoundError($"Category '{request.Id}' not found."));

        // Napomena: ovo je "izuzimajući sebe" deo iz plana — ako korisnik update-uje kategoriju ali joj ne menja ime, 
        // nema smisla da ExistsByNameAsync javi "zauzeto" jer je zauzeto od strane iste kategorije. Samo kad se ime stvarno menja, proveravamo da li je novo ime već zauzeto od strane neke druge kategorije.
        if (!string.Equals(category.Name, request.Name, StringComparison.Ordinal))
        {
            var nameTaken = await unitOfWork.Categories.ExistsByNameAsync(request.TenantId, request.Name, cancellationToken);
            if (nameTaken)
                return Result.Fail($"Category '{request.Name}' already exists.");
        }

        category.Update(request.Name, request.ImgUrl);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
