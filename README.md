# AMDB

[![Build Status](https://travis-ci.org/tpapp/AMDB.jl.svg?branch=master)](https://travis-ci.org/tpapp/AMDB.jl)

[![Coverage Status](https://coveralls.io/repos/tpapp/AMDB.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tpapp/AMDB.jl?branch=master)

[![codecov.io](http://codecov.io/github/tpapp/AMDB.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/AMDB.jl?branch=master)

Preliminary code for working with the AMDB data using a compact binary dump (instead of SQL or similar).

To use on `marvin`, please add the following line to your `.juliarc.jl`:

```julia
push!(LOAD_PATH, "/Data/AMDB/AMDB.jl")
```
