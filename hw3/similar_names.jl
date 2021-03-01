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
boy_idx = Dict(key => findall(x -> x == key, unique_b) for key in unique_b)
boy_name = Dict(value => key for (key, value) in boy_idx)

girl_idx = Dict(key => findall(x -> x == key, unique_g) for key in unique_g)
girl_name = Dict(value => key for (key, value) in girl_idx)

year_idx = Dict(key => findall(x -> x == key, unique_y) for key in unique_y)
year_name = Dict(value => key for (key, value) in year_idx)

# Task 4 - Frequency Matrices
Fb = zeros((Nb, Ny))
Fg = zeros((Ng, Ny))

