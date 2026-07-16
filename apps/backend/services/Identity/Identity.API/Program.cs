using Identity.Application;
using Identity.Infrastructure;
using Identity.Persistence;
using Identity.Presentation;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

// ─────────────────────────────────────────────────────────────────────────────
// BUILDER — sve sto treba da se registruje PRE app.Build()
// ─────────────────────────────────────────────────────────────────────────────
var builder = WebApplication.CreateBuilder(args);

// Serialize enums as their name (e.g. "Rental") instead of the underlying int —
// TenantConfigDto.Type is the first enum exposed in a response DTO, and mobile's
// CI config-fetch step (mobile-android.yml) reads it as a string.
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
});

// Swagger/OpenAPI
// AddEndpointsApiExplorer() generise opise za Minimal API rute (bez njega Swagger ne vidi rute).
// AddSwaggerGen() kreira swagger.json fajl koji SwaggerUI koristi da prikaze dokumentaciju.
//
// Swagger zivi ovde (u Identity.API) a ne u Identity.Presentation jer samo API projekat
// zna koji security scheme, naslov i verzija dokumentacije mu trebaju.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Identity API", Version = "v1" });

    // Dodajemo "Bearer" security scheme — omogucava testiranje zasticenih endpointa
    // direktno kroz Swagger UI (dugme "Authorize" u gornjem desnom uglu).
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Description = "Unesi JWT access token koji si dobio od /auth/login."
    });

    // Govori Swagger-u da SVAKI endpoint podrazumevano zahteva Bearer token,
    // osim onih sa .AllowAnonymous() — oni ce biti oznaceni kao otvoreni.
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Zepp pattern: SetupXxxLayer() metode se chainuju — svaki sloj registruje
// sopstvene servise i nikad ne zna za slojeve iznad njega.
//
// Redosled je bitan:
//   SetupPresentationLayer — registruje sve IEndpoint implementacije
//   SetupPersistenceLayer  — DbContext, Repositories, UnitOfWork
//   SetupInfrastructureLayer — PasswordHasher, JwtProvider, JWT Bearer autentikacija
//   SetupApplicationLayer  — MediatR handlers, FluentValidation validators
builder.Services.SetupPresentationLayer()
                .SetupPersistenceLayer(builder.Configuration)
                .SetupInfrastructureLayer(builder.Configuration)
                .SetupApplicationLayer();

// ─────────────────────────────────────────────────────────────────────────────
// APP — sve sto se konfigurise POSLE app.Build()
// ─────────────────────────────────────────────────────────────────────────────
var app = builder.Build();

// Auto-migracija — na svakom pokretanju aplikacija proverava da li postoje
// neprimenjene EF Core migracije i primenjuje ih automatski.
//
// Ovo je pogodno za development i Docker deploy.
// U produkciji se cesto radi odvojeno (dotnet ef database update u CI/CD pipeline-u).
await using (var scope = app.Services.CreateAsyncScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
    await dbContext.Database.MigrateAsync();
}

// Swagger je vidljiv u svim environmentima — za production deployment
// ogranici ga sa: if (app.Environment.IsDevelopment())
app.UseSwagger();
app.UseSwaggerUI();

// Global exception handler — Zepp pattern: jedan centralizovani middleware
// prevodi exception-e iz Application sloja u odgovarajuce HTTP status kodove.
//
// Redosled provera je bitan — specificniji tipovi idu pre generickijeg Exception.
app.UseExceptionHandler(exceptionHandlerApp =>
{
    exceptionHandlerApp.Run(async (HttpContext context) =>
    {
        var exceptionHandlerFeature = context.Features.Get<IExceptionHandlerFeature>();
        var exception = exceptionHandlerFeature?.Error;

        var logger = context.RequestServices.GetRequiredService<ILogger<WebApplication>>();

        if (exception is BadHttpRequestException)
        {
            // Automatski bacen od strane ASP.NET Core kada JSON body ne moze
            // da se deserijalizuje u ocekivani tip (npr. pogresno formatiran JSON).
            logger.LogWarning(exception, "A bad request has been received.");

            context.Response.StatusCode = StatusCodes.Status400BadRequest;
            await Results.Problem(
                title: "Bad Request",
                detail: "The request was invalid. Please check your input and try again.",
                statusCode: StatusCodes.Status400BadRequest
            ).ExecuteAsync(context);
        }
        else
        {
            // Svaki neocekivani exception — ne otkrivamo interne detalje klijentu.
            logger.LogError(exception, "An unhandled exception has occurred while processing the request.");

            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await Results.Problem(
                title: "Something went wrong! Please try again later.",
                statusCode: StatusCodes.Status500InternalServerError
            ).ExecuteAsync(context);
        }
    });
});

// JWT autentikacija i autorizacija moraju biti POSLE UseExceptionHandler
// i PRE SetupEndpoints() — redosled middleware-a je bitan u ASP.NET Core.
app.UseAuthentication();
app.UseAuthorization();

// Registruje sve rute (mapira IEndpoint implementacije koje su pronadjene refleksijom).
app.SetupEndpoints();

app.Run();
