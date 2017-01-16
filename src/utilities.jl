"""
Given a form `value::type`, return `value` wrapped in a
`Nullable`. Errors of type `catch_errors` are caught and returned
as a `Nullable{type}()`, other errors are rethrown.

Example: @catch_as_Nullable Date(string)::Date
"""
macro catch_as_Nullable(expr, catch_errors=:ArgumentError)
    @assert expr.head ≡ :(::) "Use this macro with value::type."
    (expr_value, expr_type) = map(esc, expr.args)
    quote
        try
            Nullable{$expr_type}($expr_value)
        catch e
            if isa(e, $(esc(catch_errors)))
                Nullable{$expr_type}()
            else
                rethrow()
            end
        end
    end
end

"Test if `i` is below maximum number of iterations (when given)."
below_maxiter(i, maxiter::Nullable{Int}) = isnull(maxiter) || (i ≤ get(maxiter))
below_maxiter(i, maxiter::Int) = i ≤ maxiter

"""
When `key ∈ dict`, return the corresponding value as a `Nullable`.

Otherwise, with `probability`, add `key` with the value `default`, and
return that as a `Nullable`, or with `1-probability`, return a
`Nullable` without value.

Useful for keeping a random subsample of `key`s, with the given default.
"""
function random_push!{T,S}(dict::Dict{T,S}, key::T, probability::Real,
                           default::Function)
    if haskey(dict, key)
        Nullable(dict[key])
    elseif rand() ≤ probability
        value = default()
        dict[key] = value
        Nullable(value)
    else
        Nullable{S}()
    end
end

"""
Define using `key => value` pairs, define a dictionary in `dictvar`,
and an `enum` names `enumname` using `value`s.

Useful because one does not need to enumerate the values twice.
"""
macro enum_and_Dict(enumname, dictvar, pairs...)
    function expr_second(expr)
        @assert expr.head ≡ :(=>) "$expr is not a Pair."
        esc(expr.args[2])
    end
    quote
        @enum($(esc(enumname)), $(unique(map(expr_second, pairs))...))
        $(esc(dictvar)) = Dict($(map(esc, pairs)...))
    end
end

"""Open a zip compressed file, read (and discard) the first line when
`skip_first`, then call `f` with the stream, finally close it."""
function process_compressed_database(f, path; skip_first = true)
    io = open(path) |> Libz.ZlibInflateInputStream
    try
        skip_first && readline(io)  # skip header
        f(io)
    finally
        close(io)
    end
end

"""
Read lines and call function on the result.
"""
function Base.readlines(f::Function, io::IO, maxiter = Nullable{Int}())
    i = 1
    while !eof(io) && below_maxiter(i, maxiter)
        line = chomp(readline(io))
        f(line)
        i += 1
    end
end


"""
Read from the gzip-compressed `path`, and return the deserialied contents.
"""
deserialize_gz(path::String) = GZip.open(deserialize, path, "r")
