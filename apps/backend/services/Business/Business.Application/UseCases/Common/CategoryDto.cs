using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Business.Application.UseCases.Common;

public record CategoryDto(Guid Id, string Name, string? ImgUrl);