######################################################################
# field types and parsers
######################################################################

"""
Parsers of type `T` return `Nullable{parsedtype(T)}`.
"""
parsedtype{T}(::Type{T}) = T    # fallback

"Representing gender."
@enum Gender male female

function Base.tryparse(::Type{Gender}, string)
    string == "M" ? Nullable(male) :
        string == "F" ? Nullable(female) : Nullable{Gender}()
end

"Some dates end with 00, recode as to 1st day of the month.

Dates coded as 00000000 are considered unparsed."
abstract AMDB_Date

parsedtype(::Type{AMDB_Date}) = Date

function Base.tryparse(::Type{AMDB_Date}, string)
    if !isascii(string) || (string == "00000000")
        Nullable{Date}()
    elseif endswith(string, "00")  # day is corrected to 1
        @catch_as_Nullable Date(string[1:end-2], "yyyymm")::Date
    else
        @catch_as_Nullable Date(string, "yyyymmdd")::Date
    end
end

"Fields which are possibly an empty string. Parsed as `Nullable{T}`."
abstract MaybeEmpty{T}

parsedtype{T}(::Type{MaybeEmpty{T}}) = Nullable{parsedtype(T)}

function Base.tryparse{T}(::Type{MaybeEmpty{T}}, string)
    S = parsedtype(T)
    if string == ""
        Nullable(Nullable{S}())
    else
        v = tryparse(T, string)
        isnull(v) ? Nullable{Nullable{S}}() : Nullable(v)
    end
end

"""
Automatically insert new items into a dictionary with `get!`,
assigning a number in the order of insertion. `keys` will retrieve a
vector of the items. Can also be used as a parser with `tryparse`.
"""
immutable AutoEnum{T}
    dict::Dict{T,Int}
    AutoEnum() = new(Dict{T,Int}())
end

parsedtype(::Type{AutoEnum}) = Int

function Base.get!{T}(ae::AutoEnum{T}, key::T)
    if haskey(ae.dict, key)
        ae.dict[key]
    else
        ae.dict[key] = length(ae.dict) + 1
    end
end

Base.length(ae::AutoEnum) = length(ae.dict)

function Base.keys(ae::AutoEnum)
    map(x->x[1], sort(collect(ae.dict), by = x->x[2]))
end

Base.tryparse(ae::AutoEnum, string) = Nullable(get!(ae, string))

parsedtype{T,S}(::Type{Dict{T,S}}) = S

function Base.tryparse{T,S}(dict::Dict{T,S}, string)
    haskey(dict, string) ? Nullable(dict[string]) : Nullable{S}()
end

"""
Parse a line to type R, calling tryparse with the given `types` on the
`positions`.
"""
immutable LineParser{R}
    positions::Vector{Int}
    types::Vector
    function LineParser(positions, types)
        @assert length(positions) == length(types)
        new(positions, types)
    end
end

parsedtype{R}(::Type{LineParser{R}}) = R

function LineParser{R}(::Type{R}, pairs...)
    LineParser{R}([pair[1] for pair in pairs],
                  [pair[2] for pair in pairs])
end

"""
Parse a spell with the given line parser.
"""
function Base.tryparse{R}(parser::LineParser{R}, line::AbstractString)
    raw_fields = split(line, ';')
    @assert raw_fields[end] == "" # check terminating
    raw_fields = raw_fields[parser.positions]
    parsed_fields = tryparse.(parser.types, raw_fields)
    unparsed = find(isnull, parsed_fields)
    if isempty(unparsed)
        Nullable(R(map(get, parsed_fields)...))
    else
        println("unparsed fields $(unparsed) = $(raw_fields[unparsed])")
        Nullable{R}()
    end
end
