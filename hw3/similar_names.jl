using DataFrames
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