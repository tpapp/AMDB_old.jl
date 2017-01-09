using AMDB
using GZip

# data_dir = "/Data/AMDB/RawTables/"
data_dir = expanduser("~/research/AMDB/data/")

"""
Parse lines from `io`, and keep the `id` if the spell status is in
`status_types`. For the AMP database. Returns a `Set` of ids.
"""
function filtered_ids(io::IO, status_types, ids = Set{Int}())
    counter = 0
    readlines(io) do line
        (id_field, empnum, status_field, other_fields) = split(line, ';'; limit=4)
        id = parse(Int, id_field)
        status = tryparse(AMP.spell_dict, status_field)
        if isnull(status)
            warn("Could not parse line:\n$line\n")
        else
            if get(status) ∈ status_types
                push!(ids, id)
            end
        end
        counter += 1
        if mod(counter, 1000000) == 0
            print(".")
        end
    end
    println()
    ids
end

# keep these for people giving birth
keep_status = Set([AMP.maternity_active,     
                   AMP.maternity_inactive,   
                   AMP.parental_leave_inactive,
                   AMP.parental_leave_active])
                  
maternity_ids =
    process_compressed_database(joinpath(data_dir, "hv_epi_uni_roh.csv.gz")) do io
        filtered_ids(io, keep_status)
    end
