# Spell and einstellgrund encodings in the AMP data, eg the `hv_epi_uni_roh` file.
#
# Available as a submodule, use as eg `AMP.employee`.

module AMP

import ..@enum_and_Dict

@enum_and_Dict(Spell,
               spell_dict,
               "D2" => DLU,
               "BE" => civil_servant,
               "LE" => apprenticeship,
               "AA" => employee,
               "FU" => FUB,
               "FD" => service_contract,
               "SO" => other_employment,
               "LW" => farmer,
               "S1" => self_employed,
               "AL" => unemployed_mixed, # with and without benefits
               "AO" => unemployed_nobenefits,
               "W1" => maternity_active,
               "W2" => maternity_inactive,
               "EO" => parental_leave_inactive,
               "ED" => parental_leave_active,
               "KO" => child_care_allowance_inactive,
               "KG" => child_care_allowance_active,
               "PZ" => military,
               "RE" => retired,
               "AU" => education,
               "SG" => other_insured_nonemployment,
               "G1" => minor_employment,
               "SV" => other_insured_time,
               "LL" => data_gap,
               "GT" => birth,
               "TO" => death,
               "KD" => no_data,
               "66" => transition_allowance,
               "68" => rehabilitation)

end # module
