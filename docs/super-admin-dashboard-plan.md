# Super Admin Dashboard — plan i status

Status na dan 2026-10-12. Cilj: dashboard (Angular) preko kog vlasnik platforme kreira/update-uje tenante, dodaje im korisnike i ima pregled osnovnih info. Drugi, odvojen zadatak (posle ovog) je `client_admin_dashboard` — dashboard koji sami tenanti koriste za interni menadžment.

## Arhitektonske odluke (potvrđeno sa korisnikom)

1. **Workspace struktura**: jedan Angular CLI multi-project workspace u `apps/web/`, sa oba dashboarda kao odvojeni projekti (`projects/<app>`), ne jedna app sa 2 modula, ne 2 odvojena repo-a. Deljeni kod (auth, HTTP interceptor, UI komponente) ide kroz zajedničke lib-ove u istom workspace-u kad do toga dođe.
2. **Domen/tenant resolution strategija (client_admin_dashboard)**: ODLOŽENO — nije blokirajuće za super admin dashboard, rešava se kad se krene na zadatak #2. Preporuka data korisniku: subdomene po tenantu (`{slug}.businessassistant.rs`) + `admin.businessassistant.rs` za super admin, umesto path-based (`/ime-klijenta`) zbog izolacije (cookies/localStorage/CSP na istom origin-u) i lakšeg puta ka custom domenima po klijentu kasnije.
3. **Super-admin identitet**: NE proširujemo `User`/`Tenant` model (koji pretpostavlja da svaki user pripada tačno jednom tenantu — `User.TenantId` je non-nullable). Umesto toga: jedan super-admin nalog čiji kredencijali (email + password hash) sede u konfiguraciji, isti obrazac kao `Jwt:Secret` danas (placeholder u `appsettings.json`, throwaway dev vrednost u `appsettings.Development.json`, pravi secret preko `dotnet user-secrets`/env var u produkciji). Nema refresh token za super-admina u v1 (nema `User` reda za koji bi se vezao u bazi) — samo access token, ponovni login kad istekne.

## Šta je urađeno

- `apps/web/.nvmrc` → `24.15.0` (jedina instalirana verzija koja zadovoljava Angular CLI 22 zahtev `^24.15.0`).
- Angular workspace inicijalizovan u `apps/web/` (`angular.json`, `tsconfig.json`, `.prettierrc`, itd.) — bez default app-a (`--no-create-application`).
- `projects/super_admin_dashboard/` generisan (Angular 22, standalone, routing, SCSS, bez SSR).
- `@angular-eslint/schematics` dodat, `eslint.config.js` na workspace i app nivou.
- Build i lint provereni, prolaze čisto (`npx ng build super_admin_dashboard`, `npx ng lint super_admin_dashboard`).
- `projects/client_admin_dashboard/` NAMERNO nije kreiran — pravi se istom komandom (`npx ng generate application client_admin_dashboard ...`) kad se krene na zadatak #2.
- Ništa od ovoga nije komitovano (korisnik nije tražio commit).
- Angular strana (login stranica, guard, HTTP klijent) čeka da backend deo (ispod) prvo bude готов, jer diktira oblik auth flow-a.

## Backend plan (NIJE JOŠ IMPLEMENTIRANO)

Sve u postojećem `Identity` servisu (`apps/backend/services/Identity/`), ne novi mikroservis. Prati postojeći Clean Architecture + CQRS obrazac iz CLAUDE.md.

**Application** (novi use case folderi pod `Identity.Application/UseCases/`):
- `SuperAdminLogin` — command + handler. Čita `SuperAdmin:Email`/`SuperAdmin:PasswordHash` iz `IConfiguration`, poredi preko postojećeg `IPasswordHasher.Verify(...)`. Vraća samo access token (bez refresh tokena, vidi odluku #3 iznad).
- `GetTenants` — query + handler, vraća listu (`TenantSummaryDto`: id, ime, slug, tip, aktivan, datum kreiranja). Bez paginacije/pretrage za v1 (OTVORENO PITANJE ispod).
- `GetTenantById` — query + handler, pun detalj tenanta (branding, moduli, feature flags, broj usera).
- `UpdateTenant` — command + handler. Tačan obim OTVORENO PITANJE ispod.
- Super-admin varijanta `AddTenantUser` endpointa — ista `AddTenantUserCommand` (već prima `TenantId` eksplicitno), samo nova Presentation ruta koja `TenantId` uzima iz route parametra umesto iz `user.GetTenantId()` (JWT claim pozivaoca).

**Infrastructure**:
- `IJwtProvider` dobija novu metodu (npr. `GenerateSuperAdminAccessToken(string email)`) — postojeća `GenerateAccessToken(User user)` zahteva pravi `User` domain objekat koji super-admin nema. Claims: `role=SuperAdmin`, BEZ `tenantId` claim-a.
- `ITenantRepository` dobija `GetAllAsync(...)`.
- DI: `AddAuthorizationBuilder().AddPolicy("SuperAdmin", policy => policy.RequireClaim("role", "SuperAdmin"))` — prva named authorization policy u servisu (danas je sve binarno + ručne role provere u handler-ima, npr. `AddTenantUser` proverava `user.GetRole()` ručno).

**Presentation** (nove rute + jedna izmena postojeće):
- `POST /auth/super-admin/login` — `AllowAnonymous`.
- `GET /tenants` — `RequireAuthorization("SuperAdmin")`.
- `GET /tenants/{id}` — isto.
- `PUT /tenants/{id}` — isto.
- `POST /tenants/{id}/users` — isto (super-admin varijanta AddTenantUser).
- **`POST /tenants/register`: menja se `.AllowAnonymous()` → `.RequireAuthorization("SuperAdmin")`** — zatvara postojeću rupu (trenutno bilo ko može da kreira tenant).

**Konfiguracija**: `SuperAdmin:Email` / `SuperAdmin:PasswordHash` — placeholder u `appsettings.json`, throwaway dev vrednost u `appsettings.Development.json`, pravi secret preko `dotnet user-secrets` lokalno i `SuperAdmin__Email`/`SuperAdmin__PasswordHash` env var u produkciji.

## Otvorena pitanja (čekaju odgovor korisnika pre implementacije)

1. **Šta tačno sme da menja "update tenant"?** Branding (već postoji `Tenant.UpdateBranding`) sigurno, ali da li i moduli/feature flags, i da li treba aktivacija/deaktivacija iz dashboarda (trenutno postoji samo `Deactivate()`, nema `Activate()`)?
2. **Da li je lista tenanata bez paginacije/pretrage dovoljna za v1** (verovatno da, dok ih ima malo), ili odmah uvesti filter/paginaciju?

## Sledeći korak

Kad korisnik odgovori na oba otvorena pitanja: implementirati backend deo po planu iznad (Application → Infrastructure → Presentation, redom kao i uvek u ovom projektu), zatim Angular login stranica + auth guard + HTTP klijent u `super_admin_dashboard` koji se kači na nove endpoint-e.
