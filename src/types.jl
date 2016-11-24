######################################################################
# data structures
######################################################################

"""
Keep track of spell durations using an interval type.
"""
typealias DateInterval ClosedInterval{Date}

"""
Define a constructor for `T`, which accepts DateInterval fields as two
arguments.
"""
macro constructor_DateInterval(t::Symbol)
    T = eval(t)
    @assert isa(T, DataType) "$t needs to be a type."
    outer = []
    inner = []
    for name in fieldnames(T)
        ft = fieldtype(T, name)
        if ft == DateInterval
            arg_start = gensym(name)
            arg_end = gensym(name)
            push!(outer, :($arg_start::Date), :($arg_end::Date))
            push!(inner, :(DateInterval($arg_start, $arg_end)))
        else
            push!(outer, :($name::$ft))
            push!(inner, name)
        end
    end
    @eval $(t)($(outer...))=$(t)($(inner...))
end

"""
Information on (spells of) personal characteristics (nationality and
academic degree may change over time).

- based on HV data
- Smooting: No; Overlap: No
"""
@auto_hash_equals immutable PersonSpell
    birth_year::Int
    gender::Gender
    nationality::Int
    # NOTE ignoring education::String
    death_date::Nullable{Date}
    interval::DateInterval
    # NOTE ignoring timestamp::Date
end

@constructor_DateInterval PersonSpell

"""
Parser for person spells (`hv_pn`). Currently ignore education
(unreliable), infer death date availability from whether death date is
missing, ignore timestamp.
"""
const PersonSpellParser =
    LineParser(PersonSpell,
               1 => Int,        # 1 birth year
               2 => Gender,     # 2 gender
               3 => Int,        # 3 nationality
               # 4 education levels: ignored
               # 5 death date availability: ignored
               6 => MaybeEmpty{AMDB_Date}, # 6 death date
               7 => AMDB_Date,             # 7 spell start
               8 => AMDB_Date)             # 8 spell end

"""
A spell from the AMP datasets, eg `hv_epi_uni_roh`.
"""
@auto_hash_equals immutable AMPSpell
    employer::Int
    status::AMP.Spell
    interval::DateInterval
end

@constructor_DateInterval AMPSpell

"""
Parser for AMP spells (eg `hv_epi_uni_roh`). Ignore timestamp, and
last field (imputation indicator?).
"""
const AMPSpellParser =
    LineParser(AMPSpell,
               1 => Int,            # employed ID
               2 => AMP.spell_dict, # spell status
               3 => AMDB_Date,      # spell start
               4 => AMDB_Date)      # spell end
"""
A spell from the `vmz_v2_int` dataset.
"""
@auto_hash_equals immutable VMZSpell
    status::VMZ.Spell
    discontinuation::VMZ.Einstellgrund
    interval::DateInterval
end

@constructor_DateInterval VMZSpell

"""
Parser for VMZ spells (`vmz_v2_int`). Ignore case id (first field).
"""
const VMZSpellParser =
    LineParser(VMZSpell,
               3 => VMZ.spell_dict,         # spell status
               4 => VMZ.einstellgrund_dict, # einstellgrund
               1 => AMDB_Date,              # spell start
               2 => AMDB_Date)              # spell end

"""
Data matched for an individual, from various data files.
"""
@auto_hash_equals immutable IndividualData
    person_spells::Vector{PersonSpell}
    AMP_spells::Vector{AMPSpell}
    VMZ_spells::Vector{VMZSpell}
end

IndividualData() = IndividualData(Vector{PersonSpell}(),
                                  Vector{AMPSpell}(),
                                  Vector{VMZSpell}())
