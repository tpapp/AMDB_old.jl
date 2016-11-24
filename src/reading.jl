typealias SpellRecords Dict{Int, IndividualData}

"""
Read spells from `hv_pn`. New indexes are kept with probability
`keep_probability`. Records are inserted into `records` (empty by
default), which is returned.
"""
function read_person_spells!(io::IO, keep_probability::Real;
                             maxiter = Nullable{Int}(),
                             records = SpellRecords())
    readlines(io, maxiter) do line
        (id_field, other_fields) = split(line, ';'; limit=2)
        record = random_push!(records, parse(Int, id_field), keep_probability,
                              () -> IndividualData())
        if !isnull(record)
            spell = tryparse(PersonSpellParser, other_fields)
            if isnull(spell)
                warn("Could not parse line:\n$line\n")
            else
                push!(get(record).person_spells, get(spell))
            end
        end
    end
    records
end

"""
Read AMP spells (eg from `hv_epi_uni_roh`). When the person ID is in
`records`, insert the spell there, otherwise don't parse.
"""
function read_AMP_spells!(io::IO, records::SpellRecords;
                          maxiter = Nullable{Int}())
    readlines(io, maxiter) do line
        (id_field, other_fields) = split(line, ';'; limit = 2)
        person_id = parse(Int, id_field)
        if haskey(records, person_id)
            spell = tryparse(AMPSpellParser, other_fields)
            if !isnull(spell)
                push!(records[person_id].AMP_spells, get(spell))
            end
        end
    end
    records
end

"""
Read VMZ spells (eg from `vmz_v2_int`). When the person ID is in
`records`, insert the spell there, otherwise don't parse.  Will ignore
lines with missing person ID.
"""
function read_VMZ_spells!(io::IO, records::SpellRecords;
                         maxiter = Nullable{Int}())
    readlines(io, maxiter) do line
        (_, id_field, other_fields) = split(line, ';'; limit = 3)
        person_id = tryparse(Int, id_field)
        if !isnull(person_id) && haskey(records, get(person_id))
            # println("parsing line: $(line)")
            # println("other_fields: $(other_fields)")
            # println("id: $(get(person_id))")
            spell = tryparse(VMZSpellParser, other_fields)
            if !isnull(spell)
                push!(records[get(person_id)].VMZ_spells, get(spell))
            end
        end
    end
    records
end
