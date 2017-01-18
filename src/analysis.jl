"""
Call `f` with each AMP spell in `records`. Useful for accumulators.
"""
function traverse_AMP_spells(f, records)
    for data in values(records)
        foreach(f, data.AMP_spells)
    end
end
