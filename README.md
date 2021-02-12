# Baby Name Frequency Over Time

The purpose of this tool is to load data from the Baby Names from Social 
Security Card Applications [dataset](https://catalog.data.gov/dataset/baby-names-from-social-security-card-applications-national-data) from data.gov into a SQLite database and 
then plot the popularity of a given baby name over time. 

## prepare.jl

`julia prepare.jl [INPUT_FILE] [OUTPUT_FILE]`

This script prepares the dataset from the `.zip` file in `INPUT_FILE` into a SQLite `.db` file named `OUTPUT_FILE`. Once opening the compressed `INPUT_FILE`, files following the format `yob*.txt` are parsed and inserted into the directory using prepared SQLite statements. 

## plot.jl

`julia plot.jl [DATABASE_FILE] [NAME] [SEX]`

This script opens the SQLite database in `DATABASE_FILE` and makes a query for year and number of babies born with the given `NAME` and `SEX`. Both of these parametsrs are case insensitive, but `SEX` must take the values of `m` or `f`. After quierying the database, a resultant plot is displayed showing the name populatirty over time, with plot colored determed by sex. 
