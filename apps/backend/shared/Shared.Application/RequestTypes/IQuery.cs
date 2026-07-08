using MediatR;

namespace Shared.Application.RequestTypes;

public interface IQuery<out TResponse> : IRequest<TResponse>;
