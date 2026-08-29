using Business.Application;
using Business.Infrastructure;
using Business.Persistence;
using Business.Presentation;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Shared.Presentation.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Sentry — samo Error/Critical + unhandled exceptions, iskljuceno u Development.
builder.UseSentryIfEnabled("Business");

// Serialize enums as their name (e.g. "Rental", "InProgress") instead of the
// underlying int — TransactionDto.Type/Status are consumed by the mobile client.
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Business API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Description = "Unesi JWT access token koji si dobio od Identity servisa (/auth/login)."
    });

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

builder.Services.SetupPresentationLayer()
                .SetupPersistenceLayer(builder.Configuration)
                .SetupInfrastructureLayer(builder.Configuration)
                .SetupApplicationLayer();

var app = builder.Build();

await using (var scope = app.Services.CreateAsyncScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<BusinessDbContext>();
    await dbContext.Database.MigrateAsync();
}

// Kad se pristupa kroz Gateway, YARP skida "/business" prefiks pre prosledjivanja —
// vidi identican komentar u Identity.API/Program.cs za puno objasnjenje.
app.UseSwagger(c =>
{
    c.PreSerializeFilters.Add((swaggerDoc, httpReq) =>
    {
        var prefix = httpReq.Headers["X-Gateway-Prefix"].FirstOrDefault();
        if (!string.IsNullOrEmpty(prefix))
            swaggerDoc.Servers = [new() { Url = prefix }];
    });
});
app.UseSwaggerUI();

app.UseExceptionHandler(exceptionHandlerApp =>
{
    exceptionHandlerApp.Run(async (HttpContext context) =>
    {
        var exceptionHandlerFeature = context.Features.Get<IExceptionHandlerFeature>();
        var exception = exceptionHandlerFeature?.Error;

        var logger = context.RequestServices.GetRequiredService<ILogger<WebApplication>>();

        if (exception is BadHttpRequestException)
        {
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
            logger.LogError(exception, "An unhandled exception has occurred while processing the request.");
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await Results.Problem(
                title: "Something went wrong! Please try again later.",
                statusCode: StatusCodes.Status500InternalServerError
            ).ExecuteAsync(context);
        }
    });
});

app.UseAuthentication();
app.UseAuthorization();

app.SetupEndpoints();

app.Run();
