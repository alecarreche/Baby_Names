using CSV
using SQLite
using ZipFile

function csv_to_db(file_name, db)
    CSV.File(file_name, header=["name", "sex", "num"]) |> SQLite.load!(db, "names")
end


input_file = ARGS[1]
output_file = ARGS[2]

db = SQLite.DB(output_file)
DBInterface.execute(db, 
    "CREATE TABLE names (
        name TEXT,
        sex TEXT,
        num INTEGER
    )")

r = ZipFile.Reader(input_file)

for file in r.files
    if occursin(r"yob.*.txt", file.name)
        csv_to_db(file, db) 
    end
end

