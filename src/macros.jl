"""
    @mod(modulus, expression)

Replace all numeric literals with calls to the `Mod{modulus}` constructor.
Variables defined in `expression` are subject to the usual scoping rules,
and can mutate variables outside `expression`.

# Examples
```julia-repl
julia> @mod 2 3
Mod{2}(1)

julia> @mod 2 (1 + 1)
Mod{2}(0)

julia> @mod 5 begin
    a = 3
    b = 4
    a + b
end
Mod{5}(2)

julia> a
Mod{5}(3)

julia> @macroexpand @mod(3, 1 + 2)
:((Mod{3})(1) + (Mod{3})(2))
```
"""
macro mod(modulus::Number, expr)
    _replace_numeric_literals(expr, modulus)
end

# Replace numbers with a `Mod` constructor
_replace_numeric_literals(num::Number, modulus) = :($(Mod{modulus})($num))

# Escape symbols
_replace_numeric_literals(sym::Symbol, _) = :($(esc(sym)))

# Don't do anything to other atoms
_replace_numeric_literals(atom, _) = atom

# Recursively apply to each sub-expression
function _replace_numeric_literals(expr::Expr, constructor)
    Expr(expr.head, _replace_numeric_literals.(expr.args, constructor)...)
end

