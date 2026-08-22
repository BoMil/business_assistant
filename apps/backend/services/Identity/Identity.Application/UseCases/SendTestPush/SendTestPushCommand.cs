using FluentResults;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.SendTestPush;

public record SendTestPushCommand(Guid UserId) : ICommand<Result<SendTestPushResult>>;

public record SendTestPushResult(int RegisteredTokenCount, int SentCount, int FailedCount);
