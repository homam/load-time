{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

sql = require \mssql
fs = require \fs

config =
	user: 'homam'
	password: 'gamma123'
	server: '172.30.0.165'
	database: 'Mobitrans'


query = fs.readFileSync 'queries/allrecords.sql', 'utf8'


sql.connect config, (err) ->
	return console.err err if !!err

	request = new sql.Request!

	(err, records) <- request.query query
	return console.err err if !!err

	records = map (->
		it <<<
				eventArgs: if !!it.eventArgs then JSON.parse(it.eventArgs) else null
				webBrowser: 1 == it.webBrowser
	), records

	#console.log (JSON.stringify records, null, 4)

	fs.writeFileSync 'data/allrecords.json', (JSON.stringify records, null, 4)

	console.log 'done!'

	process.exit!



