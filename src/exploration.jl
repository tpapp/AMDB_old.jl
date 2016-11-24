# utilities not used in the final version, just for exploration

"""
Read the given columns from `io`, and return them in a vector of
`AutoEnum` structures.
"""
function read_categories(io::IO, columns::Vector{Int},
                         autoenums=[AutoEnum{AbstractString}() for c in columns])
    while !eof(io)
        fields = split(chomp(readline(io)), ";")
        for (column, autoenum) in zip(columns, autoenums)
            tryparse(autoenum, fields[column])
        end
    end
    autoenums
end
