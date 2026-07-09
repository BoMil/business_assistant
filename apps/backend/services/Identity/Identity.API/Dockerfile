# ─────────────────────────────────────────────────────────────────────────────
# Zepp pattern: multi-stage Dockerfile
#
# Stage 1 (base)    — minimalni runtime image koji ce se koristiti u produkciji.
# Stage 2 (build)   — SDK image za kompajliranje koda.
# Stage 3 (publish) — release build + publish optimizovanog outputa.
# Stage 4 (final)   — kopira publish output u base (runtime), bez SDK.
#
# VAZNO: docker-compose build context mora biti ROOT repozitorijuma (ne ovaj folder),
# jer Dockerfile kopira fajlove iz apps/backend/services/Identity/ I apps/backend/shared/.
# U docker-compose.yml: build.context: .
# ─────────────────────────────────────────────────────────────────────────────

# Stage 1: base — lightweight ASP.NET runtime (nema SDK, nema kompilatora)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

# Stage 2: build — full SDK za restore i kompajliranje
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Kopiramo SAMO .csproj fajlove pre source koda.
# Docker cache: ako se .csproj fajlovi nisu promenili, dotnet restore se preskace.
# Ovo drasticno ubrzava rebuild kada menjamo samo source fajlove (bez novih paketa).
COPY ["apps/backend/services/Identity/Identity.API/Identity.API.csproj", "apps/backend/services/Identity/Identity.API/"]
COPY ["apps/backend/services/Identity/Identity.Application/Identity.Application.csproj", "apps/backend/services/Identity/Identity.Application/"]
COPY ["apps/backend/services/Identity/Identity.Domain/Identity.Domain.csproj", "apps/backend/services/Identity/Identity.Domain/"]
COPY ["apps/backend/services/Identity/Identity.Infrastructure/Identity.Infrastructure.csproj", "apps/backend/services/Identity/Identity.Infrastructure/"]
COPY ["apps/backend/services/Identity/Identity.Persistence/Identity.Persistence.csproj", "apps/backend/services/Identity/Identity.Persistence/"]
COPY ["apps/backend/services/Identity/Identity.Presentation/Identity.Presentation.csproj", "apps/backend/services/Identity/Identity.Presentation/"]
COPY ["apps/backend/shared/Shared.Application/Shared.Application.csproj", "apps/backend/shared/Shared.Application/"]
COPY ["apps/backend/shared/Shared.Domain/Shared.Domain.csproj", "apps/backend/shared/Shared.Domain/"]

RUN dotnet restore "apps/backend/services/Identity/Identity.API/Identity.API.csproj"

# Sada kopiramo kompletan source kod i buildujemo
COPY . .
WORKDIR "/src/apps/backend/services/Identity/Identity.API"
RUN dotnet build "Identity.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Stage 3: publish — optimizovani release output (bez debug simbola, trimovan)
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Identity.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Stage 4: final — kopira samo publish output u runtime image (ne SDK!)
# Rezultat: mali image (~200MB vs ~800MB sa SDK)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Identity.API.dll"]
