# ─────────────────────────────────────────────────────────────────────────────
# Zepp pattern: multi-stage Dockerfile (vidi Identity.API/Dockerfile za pun opis stage-ova)
#
# VAZNO: docker-compose build context mora biti ROOT repozitorijuma.
# U docker-compose.yml: build.context: .
# ─────────────────────────────────────────────────────────────────────────────

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["apps/backend/gateway/Gateway.API/Gateway.API.csproj", "apps/backend/gateway/Gateway.API/"]

RUN dotnet restore "apps/backend/gateway/Gateway.API/Gateway.API.csproj"

COPY . .
WORKDIR "/src/apps/backend/gateway/Gateway.API"
RUN dotnet build "Gateway.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Gateway.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Gateway.API.dll"]
