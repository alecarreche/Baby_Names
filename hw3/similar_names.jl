using DataFrames
using Distributed
using LinearAlgebra
using SharedArrays
using SQLite

# Task 1 - load data 
db = SQLite.DB("names.db")
qry = DBInterface.prepare(db,
    "SELECT * 
    FROM names"
)

df = DBInterface.execute(qry) |> DataFrame

# Task 2 - distinct boy and girls
unique_b = unique(df[df.sex .== "M", :"name"])
unique_g = unique(df[df.sex .== "F", :"name"])
unique_y = unique(df[:, :"year"])


Nb = size(unique_b, 1)
Ng = size(unique_g, 1)
Ny = size(unique_y, 1)

# Task 3 - dictionaries 

# dictionaries without using find()
boy_name = Dict(enumerate(unique_b))
boy_idx = Dict(value => key for (key, value) in boy_name)

girl_name = Dict(enumerate(unique_g))
girl_idx = Dict(value => key for (key, value) in girl_name)

year_name = Dict(enumerate(unique_y))
year_idx = Dict(value => key for (key, value) in year_name)

# Task 4-5 - Frequency Matrices
Fb = zeros((Nb, Ny))
Fg = zeros((Ng, Ny))

boy_groups = groupby(df[df.sex .== "M", :], [:"year", :"name"])
girl_groups = groupby(df[df.sex .=="F", :], [:"year", "name"])

for (i, group) in enumerate(boy_groups)
    cur_name = keys(boy_groups)[i][:"name"]
    cur_year = keys(boy_groups)[i][:"year"]

    cur_name_idx = boy_idx[cur_name]
    cur_year_idx = year_idx[cur_year]

    Fb[cur_name_idx, cur_year_idx] = group[1, :"num"]
end

for (i, group) in enumerate(girl_groups)
    cur_name = keys(girl_groups)[i][:"name"]
    cur_year = keys(girl_groups)[i][:"year"]

    cur_name_idx = girl_idx[cur_name]
    cur_year_idx = year_idx[cur_year]

    Fg[cur_name_idx, cur_year_idx] = group[1, :"num"]
end

# Task 6 - Yearly totals 

yearly_sum = reshape(sum(eachrow(Fb)) + sum(eachrow(Fg)), (1, Ny))

# Task 7 - probabilities 

Pb = Fb ./ yearly_sum
Pg = Fg ./ yearly_sum

# Task 8 - L2 Norm accross years

Qb = deepcopy(Pb)
Qg = deepcopy(Pg)

for i in 1:Nb
    Qb[i,:] = normalize(Qb[i,:])
end

for i in 1:Ng
    Qg[i,:] = normalize(Qg[i,:])
end

# Task 9 and 10 - Find cosine distances 
b_size = div(Nb, 10)
g_size = div(Ng, 10)

# create sections

# first 9
Qb_sections = [Qb[b_size*(i-1)+1:b_size*i, :] for i in 1:9]
Qg_sections = [Qg[g_size*(i-1)+1:g_size*i, :] for i in 1:9]

# last section (includes remainder)
push!(Qb_sections, Qb[b_size*9+1:Nb, :])
push!(Qg_sections, Qg[b_size*9+1:Ng, :])

glob_max = 0
max_coord = CartesianIndex(0,0)
a = zeros(10)
# multiply
BLAS.set_num_threads(8) # ensure multithreading
@time begin
    for i in 1:10
        for j in 1:10
            result = Array{Float64}(undef, size(Qb_sections[i])[1], size(Qg_sections[j])[1])

            # no need to use threads here because BLAS already uses multithreading for matmult
            mul!(result, Qb_sections[i], transpose(Qg_sections[j]))
            loc_max = maximum(result)
            
            if loc_max > glob_max
                m = argmax(result)
                global max_coord = CartesianIndex(m[1] + (i-1)*b_size, m[2] + (i-1)*g_size)
                global glob_max = loc_max
            end
        end
    end
end

max_boy = boy_name[max_coord[1]]
max_girl = girl_name[max_coord[2]]
println("Max Cosine Distance: ")
println("Boy: $max_boy")
println("Girl: $max_girl")
