######################################################################
# reading the data, matching up people, writing out serialized data
#
# NOTE: You don't need to rerun this for exploratory work.
# It will be rerun when Julia is updated.
#
# NOTE: compressing via GZip gives ≈1/6 file size and +20% read time.
######################################################################
using AMDB
using GZip

data_dir = "/Data/AMDB/RawTables/"

srand(5447225802448749441)      # random seed for reproducible data

# read person spells
records = process_compressed_database(joinpath(data_dir, "hv_pn.csv.gz")) do io
    read_person_spells!(io, 0.01)
end

# remove records with no person spells
records = filter((id,record) -> !isempty(record.person_spells), records)

# read AMP data
process_compressed_database(joinpath(data_dir, "hv_epi_uni_roh.csv.gz")) do io
    read_AMP_spells!(io, records)
end

# read VMZ v2 data
process_compressed_database(joinpath(data_dir, "vmz_v2_int.csv.gz")) do io
    read_VMZ_spells!(io, records)
end

# write out data
GZip.open(normpath(joinpath(data_dir,
                            "../subsample/AMDB_subsample.jls.gz")), "w") do io
    serialize(io, records)
end
