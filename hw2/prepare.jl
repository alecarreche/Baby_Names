using CSV
using SQLite
using ZipFile

function csv_to_db(file, db, ins)
    # start transaction 
    SQLite.transaction(db)
    # extract year from filename
    year = replace(file.name, r"\D+" => "")
    # open file to iterate through rows
    f = CSV.Rows(file, header=["name", "sex", "num"])

    for row in f
        # execute prepared statement 
        DBInterface.execute(ins, [year, row.name, row.sex, row.num])
    end

    # finish transaction 
    SQLite.commit(db)
end

input_file = ARGS[1]
output_file = ARGS[2]

# create database
db = SQLite.DB(output_file)

# create names table in db 
DBInterface.execute(db, 
    "CREATE TABLE names (
        year INTEGER,
        name TEXT,
        sex TEXT,
        num INTEGER
    )")

# open the zip file 
r = ZipFile.Reader(input_file)

# create prepared statement
ins = DBInterface.prepare(db,
    "INSERT INTO names (year, name, sex, num)
    VALUES
        (?, ?, ?, ?)")

for file in r.files
    # check for 'yob[YEAR].txt' 
    if occursin(r"yob.*.txt", file.name)
        csv_to_db(file, db, ins) 
    end
end

close(db)
close(r)
