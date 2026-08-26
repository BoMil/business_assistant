using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace Shared.Presentation.Extensions;

public static class SentryExtensions
{
    // ServerName razlikuje Identity/Business gresku u zajednickom backend Sentry projektu.
    // DSN se ne cita ovde eksplicitno — UseSentry() ga sam bind-uje iz "Sentry:Dsn" config
    // sekcije (Sentry__Dsn env var), isti pattern kao Zepp.
    public static WebApplicationBuilder UseSentryIfEnabled(this WebApplicationBuilder builder, string serviceName)
    {
        if (!builder.Environment.IsDevelopment())
        {
            builder.WebHost.UseSentry(options =>
            {
                options.Environment = builder.Environment.EnvironmentName;
                options.ServerName = serviceName;
            });
        }

        return builder;
    }
}
