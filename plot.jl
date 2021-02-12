using DataFrames
using Gadfly
using SQLite

# params
db_file = ARGS[1] 
name = uppercase(ARGS[2])
sex = uppercase(ARGS[3])

# query 
db = SQLite.DB(db_file)
qry = DBInterface.prepare(db,
        "SELECT year, num
        FROM names
        WHERE UPPER(name) = ? AND UPPER(sex) = ?
        ORDER BY year"
)

result = DBInterface.execute(qry, [name, sex]) |> DataFrame

# plot
sex_color = Dict("M"=>"light blue", "F"=>"pink")

fig = plot(
        result,
        x=:year,
        y=:num,
        Geom.line,
        Theme(default_color=color(sex_color[sex])),
        Guide.xlabel("Year"),
        Guide.ylabel("Babies Born"),
        Guide.title("Popularity of Baby Name $name")
)

display(fig)
