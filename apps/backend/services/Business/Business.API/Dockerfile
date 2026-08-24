# ─────────────────────────────────────────────────────────────────────────────
# Zepp pattern: multi-stage Dockerfile (mirrors Identity.API/Dockerfile)
#
# VAZNO: docker-compose build context mora biti ROOT repozitorijuma (ne ovaj folder),
# jer Dockerfile kopira fajlove iz apps/backend/services/Business/ I apps/backend/shared/.
# U docker-compose.yml: build.context: .
# ─────────────────────────────────────────────────────────────────────────────

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["apps/backend/services/Business/Business.API/Business.API.csproj", "apps/backend/services/Business/Business.API/"]
COPY ["apps/backend/services/Business/Business.Application/Business.Application.csproj", "apps/backend/services/Business/Business.Application/"]
COPY ["apps/backend/services/Business/Business.Domain/Business.Domain.csproj", "apps/backend/services/Business/Business.Domain/"]
COPY ["apps/backend/services/Business/Business.Infrastructure/Business.Infrastructure.csproj", "apps/backend/services/Business/Business.Infrastructure/"]
COPY ["apps/backend/services/Business/Business.Persistence/Business.Persistence.csproj", "apps/backend/services/Business/Business.Persistence/"]
COPY ["apps/backend/services/Business/Business.Presentation/Business.Presentation.csproj", "apps/backend/services/Business/Business.Presentation/"]
COPY ["apps/backend/shared/Shared.Application/Shared.Application.csproj", "apps/backend/shared/Shared.Application/"]
COPY ["apps/backend/shared/Shared.Domain/Shared.Domain.csproj", "apps/backend/shared/Shared.Domain/"]
COPY ["apps/backend/shared/Shared.Queues/Shared.Queues.csproj", "apps/backend/shared/Shared.Queues/"]

RUN dotnet restore "apps/backend/services/Business/Business.API/Business.API.csproj"

COPY . .
WORKDIR "/src/apps/backend/services/Business/Business.API"
RUN dotnet build "Business.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Business.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Business.API.dll"]
