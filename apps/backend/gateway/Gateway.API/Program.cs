// ─────────────────────────────────────────────────────────────────────────────
// Gateway.API — jedini ulaz za mobilnu/web aplikaciju.
//
// Ovo NIJE Clean Architecture mikroservis (nema Domain/Application/Persistence
// slojeve) — cist YARP reverse proxy, rutira po path prefiksu ka pravim
// mikroservisima. Ruta -> Cluster mapiranje je u appsettings.json ("ReverseProxy").
//
// Autentikacija/autorizacija se NE proverava ovde — Authorization header
// prolazi kroz proxy nepromenjen, svaki backend servis i dalje sam validira JWT.
// ─────────────────────────────────────────────────────────────────────────────

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

app.MapReverseProxy();

app.Run();
