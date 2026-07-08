namespace Shared.Domain.Common;

public abstract class Entity<TKey> : EntityBase where TKey : notnull
{
    public TKey Id { get; set; } = default!;

    protected Entity() { }

    public override bool Equals(object? obj)
    {
        if (obj is null || GetType() != obj.GetType())
            return false;

        return Id.Equals(((Entity<TKey>)obj).Id);
    }

    public override int GetHashCode() => Id.GetHashCode();

    public static bool operator ==(Entity<TKey>? a, Entity<TKey>? b)
    {
        if (a is null && b is null) return true;
        if (a is null || b is null) return false;
        return a.Equals(b);
    }

    public static bool operator !=(Entity<TKey>? a, Entity<TKey>? b) => !(a == b);
}
