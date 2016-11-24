using AMDB
using Base.Test
using IntervalSets

≅(a,b) = isequal(a,b)

# parsing

@test parsedtype(AMDB_Date) ≅ Date
@test tryparse(AMDB_Date, "00000000") ≅ Nullable{Date}()
@test tryparse(AMDB_Date, "19800101") ≅ Nullable(Date(1980, 1, 1))
@test tryparse(AMDB_Date, "19800100") ≅ Nullable(Date(1980, 1, 1))
@test tryparse(AMDB_Date, "") ≅ Nullable{Date}()
@test tryparse(AMDB_Date, "nonsense") ≅ Nullable{Date}()

@test parsedtype(Gender) ≅ Gender
@test tryparse(Gender, "M") ≅ Nullable(male)
@test tryparse(Gender, "F") ≅ Nullable(female)
@test tryparse(Gender, "") ≅ Nullable{Gender}()
@test tryparse(Gender, "nonsense") ≅ Nullable{Gender}()

@test parsedtype(MaybeEmpty{Int}) ≅ Nullable{Int}
@test tryparse(MaybeEmpty{Int}, "") ≅ Nullable(Nullable{Int}())
@test tryparse(MaybeEmpty{Int}, "42") ≅ Nullable(Nullable(42))
@test tryparse(MaybeEmpty{Int}, "42.2") ≅ Nullable{Nullable{Int}}()
@test tryparse(MaybeEmpty{Int}, "nonsense") ≅ Nullable{Nullable{Int}}()

@test parsedtype(MaybeEmpty{AMDB_Date}) ≅ Nullable{Date}
@test tryparse(MaybeEmpty{AMDB_Date}, "") ≅ Nullable(Nullable{Date}())
@test tryparse(MaybeEmpty{AMDB_Date}, "19700907") ≅
    Nullable{Nullable{Date}}(Date(1970,9,7))
@test tryparse(MaybeEmpty{AMDB_Date}, "42.2") ≅ Nullable{Nullable{Date}}()
@test tryparse(MaybeEmpty{AMDB_Date}, "nonsense") ≅ Nullable{Nullable{Date}}()

let ae = AutoEnum{Char}()
    v = map(x->get!(ae, x), ['a', 'b', 'a', 'a', 'c', 'b'])
    @test v == [1, 2, 1, 1, 3, 2]
    @test keys(ae) == ['a', 'b', 'c']
end

date_interval = ClosedInterval(Date(1980, 1, 1), Date(1980, 3, 1))
@test tryparse(PersonSpellParser, "1900;M;0;;0;;19800101;19800301;20010101;") ≅
    Nullable(PersonSpell(1900, male, 0, Nullable{Date}(), date_interval))
@test tryparse(AMPSpellParser, "1400;RE;19800101;19800301;T;") ≅
    Nullable(AMPSpell(1400, AMP.retired, date_interval))
@test tryparse(VMZSpellParser, "19800101;19800301;AL;A;20010101;") ≅
    Nullable(VMZSpell(VMZ.unemployed, VMZ.employment_Austria, date_interval))
