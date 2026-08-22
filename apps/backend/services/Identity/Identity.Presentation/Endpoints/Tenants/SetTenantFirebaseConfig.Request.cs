namespace Identity.Presentation.Endpoints.Tenants;

/// <summary>JSON body for PUT /tenants/{slug}/firebase-config.</summary>
public record SetTenantFirebaseConfigRequest(
    string AndroidApiKey,
    string AndroidAppId,
    string ProjectId,
    string MessagingSenderId,
    string StorageBucket,
    string ServiceAccountJson);
