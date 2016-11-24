# Spell and einstellgrund encodings in the `vmz_v2_int` file.
#
# Available as a submodule, use as eg `VMZ.sickness`.

module VMZ

import ..@enum_and_Dict

@enum_and_Dict(Einstellgrund,
               einstellgrund_dict,
               "A" => employment_Austria,
               "K" => sickness,
               "M" => nonreporting,
               "P" => retirement,
               "R" => rehab, # NOTE: avoid clash with rehabilitation::Spell
               "S" => other,
               "W" => maternity,
               "X" => precautionary_discontinuation,
               "B" => employment_abroad,
               "V" => forderung_job_search,
               "Z" => forderung_job_offer,
               "F" => forderung_start,
               "-" => unknown,
               "" => unknown, # FIXME should we handle the two types differently?
               "T" => permanent_discontinuation)

@enum_and_Dict(Spell,
               spell_dict,
               "AL" => unemployed,
               "SC" => training,
               "LS" => search_apprentice,
               "SF" => stipend,
               "SR" => rehabilitation,
               "SO" => employment_subsidized,
               "AG" => working_ability_examination,
               "AS" => search_job,
               "AM" => foreign_insurance,
               "AF" => search_early_job,
               "LF" => search_early_training,
               "TA" => partial_foreigner,
               "VM" => preregistered,
               "10" => inability,
               "RE" => rest)

end # module
