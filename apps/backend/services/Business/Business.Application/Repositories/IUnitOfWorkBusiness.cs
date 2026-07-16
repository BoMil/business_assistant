namespace Business.Application.Repositories;

/// <summary>
/// Mirrors Zepp.WebApp's fat aggregate UnitOfWork shape (e.g. IUnitOfWorkCustomers) — one
/// UoW per service exposing every repository as a property, instead of injecting each
/// repository separately into handlers.
///
/// Not ported: Zepp's <c>CreateResilientTransaction()</c>/<c>ClearChanges()</c> members —
/// those back onto an <c>IResilientTransaction</c>/saga-retry infrastructure that doesn't
/// exist in this repo and has no caller yet. Add them if/when Business actually needs
/// cross-transaction retry logic.
/// </summary>
public interface IUnitOfWorkBusiness
{
    IAssetRepository Assets { get; }
    IClientRepository Clients { get; }
    ITransactionRepository Transactions { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
