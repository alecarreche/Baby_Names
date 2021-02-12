using SQLite
using DataFrames

db_file = ARGS[1] # "names.db"
name = ARGS[2]
sex = ARGS[3]

db = SQLite.DB(db_file)
qry = DBInterface.prepare(db,
        "SELECT year, num
        FROM names
        WHERE name = ? AND sex = ?
        ORDER BY year")

result = DBInterface.execute(qry, [name, sex]) |> DataFrame
print(result)