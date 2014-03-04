{id, Obj,map, concat, mean, filter, head, each, take, find, fold, foldr, fold1, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

data = require './data/allrecords.json'
#console.log data.length
visits = data |> (group-by (.visitId)) >> obj-to-pairs
visits = take 10000, visits
records = map ([visitId,[r0,...]:records]) ->
	earliestRecord = (records |> (filter (-> !!it.eventArgs)) >> (sort-by (.eventId)) >> head)?.eventArgs
	visitId: visitId
	country: r0.country
	page: r0.pageName
	referrer: r0.referrer
	webBrowser: r0.webBrowser
	submissions: records |> (map (.submissionId)) >> (filter (-> !!it)) >> unique >> (.length) 
	subscribers: records |> (map (.subscriberId)) >> (filter (-> !!it)) >> unique >> (.length) 
	records: records |> (map (.eventId)) >> (filter (-> !!it)) >> unique >> (.length) 
	navigationTime: earliestRecord?.navigationTime or null

, visits
#console.log (JSON.stringify visits, null, 4)
#console.log (JSON.stringify records, null, 4)

console.log <| records |> (map (.navigationTime)) >> (filter (-> !!it and 500 < it < 120000)) >> mean

#console.log <| (filter (-> it.submissions > 0)) >> (.length) <| records