
#notice that the logged on user must have permissions on the database you query.

#example connectionstring - server is(surprisingly) the server you connect to, database is(even more surprisingly) the database you query, don't touch the rest?
$connectionstring = "Server=my-sql; Database=NSRL; integrated security=true;Trusted_connection=True;"

function query-sql
    {
    param (        
        [string] $query,
        [string] $connectionString
        )

    $connection = New-Object -TypeName system.data.sqlclient.sqlconnection
    $connection.connectionString = $connectionString
    $command = $connection.createCommand()
    $command.commandText = $query
    $adapter = New-Object -TypeName system.data.sqlclient.sqldataadapter $command
    $dataset = New-Object -TypeName system.data.dataset
    $adapter.fill($dataset)
    return $dataset.tables[0]
    }

function execute-sql 
    {
    param (
    [string] $statement,
    [string] $connectionString
    )

    $connection = New-Object -TypeName system.data.sqlclient.sqlconnection
    $connection.connectionString = $connectionString
    $command = $connection.createCommand()
    $command.commandText = $statement
    $connection.open()
    $command.executeNonQuery()
    $connection.close()

    }
    
#usage:   
#query-sql -connectionstring $connectionstring -query "select * from information_schema.tables"
#execute-sql -connectionstring $connectionstring -statement "drop table importantstuff"