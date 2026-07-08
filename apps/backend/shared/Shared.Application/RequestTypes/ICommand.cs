using MediatR;

namespace Shared.Application.RequestTypes;

public interface ICommand<out TResponse> : IRequest<TResponse>;
