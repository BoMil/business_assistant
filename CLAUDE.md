# Business Assistant — Project Guide

Multi-tenant business operations platform. .NET 8 microservices backend (Clean Architecture + CQRS, following the pattern in `/Users/boki/Zepp/Zepp.WebApp`), Flutter mobile app (white-label, feature-based), Angular web app (not yet built out).

This file is the durable reference for how this repo is built. Read it before adding a new microservice, endpoint, or mobile feature — the goal is to extend existing patterns, not invent new ones. See `README.md` for local run instructions (Docker, database, secrets) — this file focuses on *how code here is structured and why*.

---

## Backend — Clean Architecture microservices

Two services exist today: `apps/backend/services/Identity/` and `apps/backend/services/Business/`. Both follow an identical shape, itself copied from `/Users/boki/Zepp/Zepp.WebApp`. **When adding a third microservice, copy this shape exactly** — don't improvise a new layout.

### API Gateway

`apps/backend/gateway/Gateway.API` is a YARP reverse proxy — the single entrypoint mobile/web talk to. It is **not** a Clean Architecture microservice (no Domain/Application/Persistence/Infrastructure/Presentation layers) — just one project, since it has no business logic of its own, only routing config in `appsettings.json`'s `ReverseProxy` section.

Routing is by path prefix: `/identity/**` → Identity, `/business/**` → Business (prefix stripped before forwarding via a `PathRemovePrefix` transform). Adding a new endpoint inside an existing service needs **zero** Gateway changes — only a brand new microservice needs a new Route+Cluster pair added here. Auth is untouched by the gateway: the `Authorization` header passes through as-is, each backend service still validates the JWT itself exactly as before.

Same environment-layering convention as the other services: `appsettings.json` has placeholder destination addresses, `appsettings.Development.json` overrides them for the "everything runs via `dotnet run` on host" flow (`http://localhost:5100`/`5101`), and `docker-compose.override.yml` overrides them again for the containerized flow (`http://identity.api:8080`/`http://business.api:8080`, Docker's internal DNS). Locally the Gateway itself is reachable at `http://localhost:5099` (5000 is usually taken by macOS AirPlay Receiver).

### Layer structure

Each service `X` is six projects under `apps/backend/services/X/`:

| Project | Responsibility |
|---|---|
| `X.Domain` | Entities (`Entity<TKey>` subclasses with private setters + static `Create(...)` factories), value objects, enums. No dependency on other layers. |
| `X.Application` | CQRS use cases (Commands/Queries + handlers), repository/service **interfaces**, DTOs. Depends only on `X.Domain` + `Shared.Application`/`Shared.Domain`. |
| `X.Persistence` | EF Core `DbContext`, `IEntityTypeConfiguration<T>` per entity, repository **implementations**, the Unit of Work, migrations. |
| `X.Infrastructure` | External/technical concerns: JWT issuing/validation, password hashing, blob storage clients, (future: message bus, gRPC clients). |
| `X.Presentation` | Minimal-API endpoints (`IEndpoint` classes), request DTOs, `ClaimsPrincipalExtensions`. |
| `X.API` | Composition root: `Program.cs`, `appsettings*.json`, Swagger, Dockerfile. |

Shared cross-service code lives in `apps/backend/shared/`: `Shared.Domain` (error types, `Entity`/`EntityBase`), `Shared.Application` (`ICommand`/`IQuery`, pipeline behaviors), `Shared.Presentation` (`CommonHttpErrorHandlers`).

`X.Application/UseCases/` has **one folder per use case** (e.g. `CreateAsset/`, `GetAssetById/`, `UploadImage/`), each containing a `XCommand.cs`/`XQuery.cs` (with its validator co-located in the same file) and a `XCommandHandler.cs`/`XQueryHandler.cs`. `X.Application/UseCases/Common/` holds shared DTOs used across multiple use cases. `X.Application/Repositories/` holds repository interfaces + the UoW interface. `X.Application/Services/` holds other interfaces (e.g. `IBlobStorageService`).

`X.Presentation/Endpoints/` has one folder per resource (`Assets/`, `Clients/`, `Transactions/`, `Images/`), plus `Endpoints/Common/` for `IEndpoint`, `EndpointExtensions`, `EndpointGroups`/`EndpointTags`, `ClaimsPrincipalExtensions`.

### Composition root — `Program.cs`

Identical shape in both services. **Order matters**:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.ConfigureHttpJsonOptions(o =>
    o.SerializerOptions.Converters.Add(new JsonStringEnumConverter())); // enums serialize as names

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c => { /* SwaggerDoc + Bearer scheme */ }); // Swagger config lives HERE, not in X.Presentation (deliberate divergence from Zepp — see "Known divergences")

builder.Services.SetupPresentationLayer()
                .SetupPersistenceLayer(builder.Configuration)
                .SetupInfrastructureLayer(builder.Configuration)
                .SetupApplicationLayer();

var app = builder.Build();

await using (var scope = app.Services.CreateAsyncScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<XDbContext>();
    await dbContext.Database.MigrateAsync();   // auto-migrate on every startup, dev convenience
}

app.UseSwagger();
app.UseSwaggerUI();
app.UseExceptionHandler(...);   // BadHttpRequestException -> 400, else -> 500
app.UseAuthentication();
app.UseAuthorization();
app.SetupEndpoints();           // reflection-discovered IEndpoint classes get mapped here
app.Run();
```

What each `SetupXLayer` extension method does:
- **`X.Application.SetupApplicationLayer()`**: `AddMediatR` (scoped lifetime, registers `LoggingBehavior<,>` then `ValidationBehavior<,>` as open pipeline behaviors) + `AddValidatorsFromAssembly` (singleton).
- **`X.Persistence.SetupPersistenceLayer(configuration)`**: `AddDbContext<XDbContext>(UseSqlServer(...))` + `AddScoped<IUnitOfWorkX, UnitOfWorkX>()`. Individual repositories are **never** registered in DI — only the UoW.
- **`X.Infrastructure.SetupInfrastructureLayer(configuration)`**: JWT Bearer auth + authorization, plus service-specific infra (Identity: `IPasswordHasher`, `IJwtProvider`; Business: `BlobServiceClient` + `IBlobStorageService`).
- **`X.Presentation.SetupPresentationLayer()`**: `services.AddEndpoints(assembly)` only (reflection scan for `IEndpoint` implementers). The `app.SetupEndpoints()` call post-`Build()` is a separate extension that does `app.MapEndpoints()`.

### CQRS pattern

`ICommand<TResponse>`/`IQuery<TResponse>` (`Shared.Application/RequestTypes/`) just extend `IRequest<TResponse>` — always return `Result` or `Result<T>` (FluentResults), never a bare DTO (the `ValidationBehavior` pipeline requires `TResponse : ResultBase, new()`).

Command + validator co-located in one file:

```csharp
public record CreateClientCommand(Guid TenantId, string Name, string PhoneNumber, string Email, ...) : ICommand<Result<Guid>>;

public sealed class CreateClientCommandValidator : AbstractValidator<CreateClientCommand>
{
    public CreateClientCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.Email).NotEmpty().EmailAddress().WithMessage("A valid Email is required");
    }
}
```

Handler, own file, same folder, `internal sealed class`:

```csharp
internal sealed class CreateClientCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<CreateClientCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateClientCommand request, CancellationToken cancellationToken)
    {
        var client = Client.Create(request.TenantId, request.Name, ...);
        await unitOfWork.Clients.AddAsync(client, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Ok(client.Id);
    }
}
```

Not every command needs a validator (e.g. queries usually don't) — only add one when there are real rules to enforce.

### Result / error handling

Handlers return `Result.Ok(value)` / `Result.Fail(new SomeError(...))`. Error types (`Shared.Domain/Errors/`, all `FluentResults.IError`): `NotFoundError`, `ForbiddenError`, `ValidationError` (auto-populated by `ValidationBehavior`), `InternalError`, `ServiceUnavailableError`, `UserError` (defined but **not currently mapped** in the switch below — falls through to generic 400; confirm intent before relying on it).

`Shared.Presentation/ErrorHandling/CommonHttpErrorHandlers.HandleError(IError)` maps error type → HTTP status (`ValidationError`→400 with an `errors` extension, `NotFoundError`→404, `ServiceUnavailableError`→503, `InternalError`→500, `ForbiddenError`→403, else→400). Endpoints call it directly: `return CommonHttpErrorHandlers.HandleError(result.Errors[0]);` — only the first error reaches HTTP.

### Endpoint pattern

`IEndpoint` (currently duplicated verbatim per-service, see "Known divergences"):
```csharp
public interface IEndpoint { void MapEndpoint(IEndpointRouteBuilder app); }
```
`EndpointExtensions.AddEndpoints`/`MapEndpoints` reflection-scan the assembly for `IEndpoint` implementers and auto-register them — **a new endpoint needs zero manual registration**, just implement `IEndpoint`.

`EndpointGroups`/`EndpointTags` are plain `const string` classes (route prefixes / Swagger tags), one pair per service.

Typical endpoint file — static class named after the use case, nested `Endpoint : IEndpoint`, static `Handle`:
```csharp
public static class CreateClient
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app) =>
            app.MapPost(EndpointGroups.Clients, Handle).WithTags(EndpointTags.Clients).RequireAuthorization();
    }

    public static async Task<Results<Created<Guid>, ProblemHttpResult>> Handle(
        CreateClientRequest request, ClaimsPrincipal user, ISender sender, CancellationToken cancellationToken)
    {
        var result = await sender.Send(new CreateClientCommand(user.GetTenantId(), request.Name, ...), cancellationToken);
        return result.IsSuccess
            ? TypedResults.Created($"{EndpointGroups.Clients}/{result.Value}", result.Value)
            : CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
```
Endpoints with a JSON body get a co-located `<Name>.Request.cs` record. Route params with constraints: `$"{EndpointGroups.Assets}/{{id:guid}}"`. File uploads bind `IFormFile` directly as a parameter (see `Images/UploadImage.cs`). A non-JWT, shared-secret-guarded pattern exists for CI-only routes: `.AddEndpointFilter<ApiKeyEndpointFilter>().AllowAnonymous()` (see Identity's `GetTenantConfig.cs`).

### Repository / Unit of Work ("fat UoW")

One repository interface per aggregate in `X.Application/Repositories/`. `IUnitOfWorkX` exposes every repository as a lazily-instantiated property + `SaveChangesAsync`:

```csharp
public interface IUnitOfWorkBusiness
{
    IAssetRepository Assets { get; }
    IClientRepository Clients { get; }
    ITransactionRepository Transactions { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}

internal sealed class UnitOfWorkBusiness(BusinessDbContext context) : IUnitOfWorkBusiness
{
    private IAssetRepository? _assetRepository;
    public IAssetRepository Assets => _assetRepository ??= new AssetRepository(context);
    // ... one ??= line per repository
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) => context.SaveChangesAsync(cancellationToken);
}
```

Only `IUnitOfWorkX` is registered in DI — repositories are never resolved from the container directly. Handlers depend only on the UoW. Zepp's `CreateResilientTransaction()`/`ClearChanges()` (retry-on-failure saga support) were deliberately **not** ported — add only if a real cross-repository transactional need appears.

### Multi-tenancy

No global EF query filter, no `ITenantContext` service — tenant scoping is **explicit everywhere**:

1. Identity's `JwtProvider` embeds a custom claim at login: `new Claim("tenantId", user.TenantId.ToString())`.
2. Each service's `ClaimsPrincipalExtensions.GetTenantId(this ClaimsPrincipal user)` reads it back (`Guid.Parse`, throws if missing).
3. Every endpoint `Handle` calls `user.GetTenantId()` and threads it into the Command/Query.
4. Every Command/Query record carries a `Guid TenantId` field; every repository method takes `tenantId` explicitly and filters with it directly in the LINQ query.
5. Every tenant-owned entity has its own `TenantId` property (set via `Create(...)`) with an EF index (`builder.HasIndex(a => a.TenantId)`).

**When adding a new tenant-scoped entity/endpoint, follow this exact chain — don't introduce a shortcut (global filter, ambient context, etc.) without discussing it first**, since it would be inconsistent with everything else in the codebase.

### EF Core conventions

- `DbContext` in `X.Persistence/XDbContext.cs`, primary-constructor style, `OnModelCreating` calls `modelBuilder.ApplyConfigurationsFromAssembly(...)`.
- One `internal sealed class XConfiguration : IEntityTypeConfiguration<X>` per entity in `X.Persistence/Configurations/` — auto-applied, no manual registration.
- New migration:
  ```bash
  cd apps/backend/services/Business   # or Identity
  dotnet ef migrations add MigrationName --project Business.Persistence --startup-project Business.API
  ```
- Migrations auto-apply on every startup via `dbContext.Database.MigrateAsync()` in `Program.cs` — no manual `dotnet ef database update` needed for local dev.

### Secrets & configuration

- `appsettings.json` — **placeholders only**, committed to git (`"CHANGE_ME_IN_PRODUCTION_USE_KEY_VAULT"`).
- `appsettings.Development.json` — real *local* dev values are OK here **only if they're throwaway** (e.g. the shared dev JWT secret, the docker-compose SQL Server SA password) — never a real external/cloud credential.
- `dotnet user-secrets` — required for any genuine external/cloud credential even in dev (e.g. Business's Azure Blob Storage connection string). Not every service needs this — Identity currently has no `UserSecretsId` because it has no such credential yet.
- `docker-compose.override.yml` — env var overrides for the Docker path (`ConnectionStrings__XDb`, `Jwt__Secret`, using ASP.NET Core's `__` nested-config convention). A value that must stay a real secret (not a throwaway dev value) is threaded through the gitignored root `.env` file instead of being inlined here — see `BLOB_STORAGE_CONNECTION_STRING` in `docker-compose.override.yml` / `.env.example`.
- **Never register a client for an external service (Blob, future message bus, etc.) as an *eagerly-constructed* singleton** (`AddSingleton(new XClient(...))`) — an invalid/missing config value then crashes the entire API at startup, even for endpoints unrelated to that service. Use a factory registration (`AddSingleton(_ => new XClient(...))`) so the value is only touched on first actual use.

### Known divergences from the Zepp reference (intentional or open TODOs — don't silently "fix")

- **`IEndpoint`/`EndpointExtensions` are duplicated per-service** instead of living once in `Shared.Presentation`, as they do in Zepp. Identity's copy of `IEndpoint.cs` has a doc-comment flagging this: *"When a second microservice is added, this interface should be moved to Shared.Presentation."* That second service (Business) now exists — this is a live, acknowledged TODO. Ask before extracting it (touches both services).
- **Swagger setup lives in `X.API/Program.cs`**, not in `X.Presentation/DependencyInjection.cs` like Zepp does it. Both services agree on this — a considered choice, not an inconsistency.
- **No message bus, gRPC, OpenTelemetry, Sentry, Key Vault, or health checks yet** — Zepp's `Products.Infrastructure` wires all of these; Identity/Business don't. If a task needs one of these, Zepp's `Products.Infrastructure/DependencyInjection.cs` is the reference to adapt, not something to invent from scratch.
- **`UserError`** is defined in `Shared.Domain/Errors` but not handled in `CommonHttpErrorHandlers.HandleError`'s switch (falls to generic 400).

---

## Mobile — Flutter app (`apps/mobile`)

**Always run Flutter/Dart commands via `fvm`** (`fvm flutter ...`, `fvm dart ...`), never the bare global `flutter` — the global SDK is a different, incompatible version. Confirmed via `.fvmrc`/`.fvm/fvm_config.json` (pinned to 3.41.9).

### Reuse existing widgets — don't recreate them

| Widget | Path | Use for |
|---|---|---|
| `PageFrame` | `lib/core/shared/pages/page_frame/page_frame.dart` | The scaffold for every screen. `headerActionIcon: Icons.close` for modal-like pushed pages; `isHeaderVisible: false` + `pageHeader:` for tab-root pages. |
| `CardFrame` | `lib/core/shared/widgets/cards/card_frame.dart` | White rounded panel, optional `headerSectionTtitle` (typo is existing/intentional). Grouping form sections, stat blocks. |
| `SelectableItem` | `lib/core/shared/widgets/cards/selectable_item.dart` | Tappable list row — bottom-sheet pickers, settings lists. |
| `PrimaryInputField` | `lib/core/shared/widgets/input_fields/primary_input_field.dart` | The standard text/number input. `showValidationError: false` when a `CardFrame` header already labels the field. `minContainerHeight: 0` to collapse reserved error space. `isCurrency: true` restricts to digits/`.`/`,`. |
| `InputLabel` | `lib/core/shared/widgets/input_fields/input_label.dart` | Styled section/field label text. |
| `TextSearch` | `lib/core/shared/widgets/input_fields/text_search.dart` | Debounced (500ms) search box. |
| `NumberStepperInputField` | `lib/core/shared/widgets/input_fields/number_stepper_input_field.dart` | Quantity input with +/− stepper. |
| `LocationInputField` | `lib/core/shared/widgets/input_fields/location_input_field.dart` | Google Places address search (needs `Environment.googlePlacesApiKey`). |
| `DateInputField` / `DateInputTimeSelection` | `lib/core/shared/widgets/input_fields/date_input/` | Themed date/datetime pickers. |
| `LoadedImage` | `lib/core/shared/widgets/images/loaded_image.dart` | Any remote image (product photos, logos, avatars) — never use raw `Image.network`/`CachedNetworkImage` directly. Pass `alternativeWidget` for a no-image placeholder. |
| `ButtonWithLoadingState` | `lib/core/shared/widgets/buttons/button_with_loading_state.dart` | Primary submit/save button tied to a Cubit's async action (`loading: state.isSaving`). |
| `CustomOutlinedButton` | `lib/core/shared/widgets/buttons/custom_outlined_button.dart` | Secondary/outlined/destructive actions, or the base if you don't need the loading wrapper. |
| `SwitchButton` | `lib/core/shared/widgets/buttons/switch_button.dart` | On/off toggles. |
| `CustomCheckbox` | `lib/core/shared/widgets/checkboxes/custom_checkbox.dart` | Multi-select / checkbox lists. |
| `SelectionBottomModal` | `lib/core/shared/widgets/modals/selection_bottom_modal.dart` | "Select client"/"Add product" single-choice bottom sheets, backed by `BaseDropdownItem`. |

### State management — Cubit

- One feature = `<feature>_cubit.dart` (has `part '<feature>_state.dart';`) + `<feature>_state.dart` (starts `part of '<feature>_cubit.dart';`).
- `CubitState` enum (`lib/core/shared/enums/cubit_state.dart`): `{ loading, loaded, error, initial }`.
- State classes: plain immutable class, `currentState` field + `errorMessage` + full `copyWith`. For nullable fields, use the `clearX: bool` idiom to distinguish "leave unchanged" from "explicitly set to null" (see `clearSalePrice`, `clearError`).
- View: outer `StatelessWidget` does `BlocProvider(create: (_) => XCubit()..loadX(), child: _XPageContent())`; inner widget uses `BlocConsumer` (`listenWhen` for toast/navigation side effects via `listener`, `builder` for UI).
- Success/error surfaces via `ToastMessage().showSuccessToast/showErrorToast` (`lib/core/utils/toast_message.dart`) — not inline banners.
- If a cubit does async work that might resolve after the widget is disposed, use the `safeEmit` extension (`lib/core/utils/safe_emit_cubit_extension.dart`) instead of `emit` directly.

### API service pattern

- One Dio singleton via `AppInterceptor()` (`lib/core/utils/api/app_interceptor.dart`): `.dio`, pointed at the API Gateway (`Environment.serverAddress`) — the app never talks to Identity/Business directly. It auto-injects the Bearer token and handles 401-refresh-retry.
- Every service method returns `ApiResponse<T>` (`lib/core/utils/api/api_response.dart`: `loading`/`completed`/`error` factory constructors).
- Service class shape (see `lib/core/features/inventory/api_services/asset_api_service.dart`):
  ```dart
  class AssetApiService {
    final Dio dio;
    AssetApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

    Future<ApiResponse<X>> doThing() async {
      try {
        final response = await dio.get(APIEndpoints.thing);
        return ApiResponse.completed(...);
      } on DioException catch (e) {
        return ApiResponse.error(_messageFor(e));
      } catch (e) {
        return ApiResponse.error('Something went wrong. Please try again.');
      }
    }
  }
  ```
- All relative paths are centralized in `lib/config/constants/api_endpoints.dart` on `APIEndpoints` — never inline a path string in a service. Every path starts with `/identity` or `/business` — that's what the Gateway uses to route the request to the right microservice (see "API Gateway" above). Adding an endpoint to an existing service is just a new `APIEndpoints` entry with the right prefix; nothing else needs to change on the mobile side.
- `AssetApiService.getAssets()`/`getAssetById()` currently have an early mock-data `return` before the real Dio call (explicitly marked `// TODO: temporary mock data`) — this is a known, intentional stopgap while the Business API isn't wired up from the mobile side yet, not a bug to silently remove.

### Translations

- Source: `lib/l10n/app_en.arb` / `app_sr.arb` (ARB, camelCase keys). Add a key to **both** files.
- Codegen via `l10n.yaml` (repo root) + `flutter: generate: true` in `pubspec.yaml` — regenerate with `fvm flutter pub get` or `fvm flutter gen-l10n` after adding a key. Generated `app_localizations*.dart` files are not committed.
- Access anywhere (Cubits, validators, widgets — no `BuildContext` needed): `TranslationStorage.translation.someKey` (`lib/config/translations/translation_storage.dart`). Convention in widgets: `final t = TranslationStorage.translation;` at the top of `build()`. Don't use the generated `AppLocalizations.of(context)` directly — always go through `TranslationStorage`.

### Theming

- `ThemeColor` (`ThemeExtension`, `lib/theme/theme_color.dart`) holds semantic slots (`primaryBackground`, `primaryText`, `brandPrimary`, etc.). Access via `context.colors.x` (extension in `lib/theme/get_theme_color.dart`) — prefer this over hardcoding colors.
- `AppColors` — static, tenant-branded (`String.fromEnvironment('PRIMARY_COLOR', ...)` etc., set via `--dart-define-from-file`), plus fixed neutrals.
- `InputStyles.primaryInputDecoration(...)` (`lib/theme/input_styles.dart`) is the single source of input field decoration (borders, fill, focus color) — any new text-input-like widget should build its decoration through this, not a bespoke `InputDecoration`.

### Routing

- `lib/config/routes/route_names.dart` — path constants + parameterized-route builders.
- `lib/config/routes/routes.dart` — singleton `GoRouter` (don't rebuild it, resets nav history). Full-screen pushed pages (create/edit forms) are top-level `GoRoute`s outside the bottom-nav shell, using a consistent `CustomTransitionPage` left-slide transition — copy that block for new pushed pages.
- `StatefulShellRoute.indexedStack` wraps bottom-nav tabs — **it keeps every tab's widget tree alive simultaneously**. Tab switches always go through `BottomNavigationCubit.changeScreen()`, never `navigationShell.goBranch()` directly.
- **Hero-tag gotcha**: because all tabs stay alive, two tabs each having a `FloatingActionButton` with Flutter's default hero tag causes a "multiple heroes share the same tag" crash. Every per-tab FAB must set an explicit unique `heroTag` (e.g. `'inventoryFab'`, `'eventsFab'`). Any new tab-root page with a FAB needs its own unique tag.
- **PageProps navigation convention**: every pushed create/edit/detail page (Events, Inventory, Clients) takes its data via a `<Page>PageProps` object passed through GoRouter's `extra`, not a path (`/:id`) or query parameter — mirrors `/Users/boki/Zepp/ZEPP.FluterMobileAppNew`'s `models/page_props/*PageProps` pattern. Define a plain props class per page (in `<feature>/models/page_props/`), e.g. `CreateEditEventPageProps({eventId, initialClientId})`, `CreateEditAssetPageProps({assetId})`, `CreateEditClientPageProps({clientId})`, `ClientEventsPageProps({clientId, clientName})` — `null`/absent fields mean create mode or "no value passed". Navigate with `context.push(RouteNames.x, extra: XPageProps(...))`; the page widget takes a single nullable `pageProps` constructor field and reads its way through (`pageProps?.assetId`, etc.). In `routes.dart`, every such route reads it back with the try/catch cast below — never a bare `state.extra as X` (an uncaught type mismatch there crashes navigation):
  ```dart
  GoRoute(
    path: RouteNames.editClientPage,
    pageBuilder: (context, state) {
      CreateEditClientPageProps? pageProps;
      try {
        pageProps = state.extra as CreateEditClientPageProps?;
      } catch (e) {
        debugPrint('No data in the route extra params');
      }
      return CustomTransitionPage<void>(key: state.pageKey, child: CreateEditClientPage(pageProps: pageProps), ...);
    },
  ),
  ```
  `RouteNames` only holds plain static path strings for these routes (no `.../:id` segments, no path-builder helper functions) — copy this shape for any new pushed page.

### Multi-tenant / white-label

- `TenantConfig` (`lib/config/tenant/tenant_config.dart`) — build-time tenant identity (`tenantId`, `appName`, `currency`, `logoPath`, `tenantType`).
- `TenantType` (`rental`/`farming`) only seeds which modules a tenant gets **by default at creation time on the backend** — it does not gate anything at runtime in the app.
- `TenantModules` (`bool.fromEnvironment('MODULE_EVENTS'|'MODULE_INVENTORY'|'MODULE_CLIENTS')`) is what actually drives which bottom-nav tabs/features exist, independent of `TenantType`. **Gate new tenant-aware features through a new `TenantModules`/`FeatureFlags` boolean, not by branching on `tenantType` directly.**
- All of the above are compile-time constants from `--dart-define-from-file=.env/<tenant>.<environment>.json` — one JSON file per tenant × environment.
- Tenant-branded assets live at `assets/tenants/<tenantId>/{logo.svg, app_icon.png, splash_logo.png}` — reference them the way `TenantConfig.logoPath` does, never hardcode a path.

---

## Cross-cutting notes

- Backend and mobile both isolate Azure Blob Storage per tenant (one container per tenant, `tenant-{tenantId}`) — see `README.md`'s "Blob Storage & Secrets" section for the full local setup.
- When either layer's established pattern doesn't fit a new requirement (e.g. needing a shared `Shared.Presentation.IEndpoint`, needing a message bus, needing a new tenant isolation mechanism), **surface the tradeoff and ask before deciding unilaterally** — these are exactly the kind of cross-cutting architectural choices that should stay a joint decision, not something silently changed mid-task.
