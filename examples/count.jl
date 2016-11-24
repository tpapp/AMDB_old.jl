######################################################################
# counting various spell types
######################################################################
using AMDB 
using DataStructures

@time rc = open(deserialize, "/tmp/test.serialized", "r")

c = counter(Int)
for (id,record) in records
    push!(c, length(record.AMP_spells))
end
counts = sort(collect(c), by=first)
