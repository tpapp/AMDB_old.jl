######################################################################
# counting various spell types
######################################################################
using AMDB
# you may need to Pkg.add these...
using DataStructures            
using GZip
using UnicodePlots

# you only need to read the data once per session
records = GZip.open(deserialize, "/Data/AMDB/subsample/AMDB_subsample.jls.gz", "r")

"""
Demo for counting the distribution of the number of person spells.
"""
function count_person_lengths(records)
    c = counter(Int)
    for (id,record) in records
        push!(c, length(record.person_spells))
    end
    sort(collect(c), by=first)
end

count_person_lengths(records)   # looks sensible

# a plot for the number of AMP spells
UnicodePlots.histogram(filter(l->l ≤ 100,
                              [length(r.AMP_spells) for (_,r) in records]))

# which individuals have above 1000 spells?
filter((_,r) -> length(r.AMP_spells) > 1000, records)
