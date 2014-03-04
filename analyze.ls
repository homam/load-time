{id, Obj,map, concat, mean, filter, head, each, take, find, fold, foldr, fold1, tail, any, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

existential-filter = filter (-> !!it)
time-sanity-filter = (-> 500 < it < 120000)
time-is-sane-or-nill = (-> if time-sanity-filter(it) then it else null)

data = require './data/allrecords.json'
visits = data |> (group-by (.visitId)) >> obj-to-pairs
#visits = take 100, visits
records = map ([visitId,[r0,...]:records]) ->
	earliestRecord = (records |> (filter (-> !!it.eventArgs)) >> (sort-by (.eventId)) >> head)?.eventArgs
	visitId: visitId
	country: r0.country
	page: r0.pageName
	referrer: r0.referrer
	webBrowser: r0.webBrowser
	submissions: records |> (map (.submissionId)) >> existential-filter >> unique >> (.length) 
	subscribers: records |> (map (.subscriberId)) >> existential-filter >> unique >> (.length) 
	loads: records |> (map (.eventId)) >> (filter (-> !!it)) >> unique >> (.length) 
	loaded: records |> any (-> !!it.eventId)
	navigationTime: earliestRecord?.navigationTime or null
	fetchTime: earliestRecord?.fetchTime or null
	loadTime: earliestRecord?.loadTime or null

, visits
#console.log (JSON.stringify visits, null, 4)
#console.log (JSON.stringify records, null, 4)
#console.log <| (filter (-> it.submissions > 0)) >> (.length) <| records

#console.log <| records |> (map (.loadTime)) >> (filter (-> !!it and 500 < it < 120000)) >> mean

# unpivoted-data =
# 	records |> (group-by (-> [it.country, it.page, it.referrer])) >> obj-to-pairs 
# 		|> map ([_, [r0,...]:records]) -> 
# 				country: r0.country
# 				page: r0.page
# 				referrer: r0.referrer
# 				visits: records.length
# 				loads: records |> (filter (-> it.loads > 0)) >> (.length)
# 				submissions: records |> (filter (-> it.submissions > 0)) >> (.length)
# 				subscribers: records |> (filter (-> it.subscribers > 0)) >> (.length)
# 				navigationTime: records |> (map (.navigationTime)) >> existential-filter >> time-sanity-filter >> mean
# 				fetchTime: records |> (map (.fetchTime)) >> existential-filter >> time-sanity-filter >> mean
# 				loadTime: records |> (map (.loadTime)) >> existential-filter >> time-sanity-filter >> mean

		




all-keys = (Obj.keys records[0])
csv =  records |> map (-> it <<< {navigationTime: time-is-sane-or-nill(it.navigationTime), fetchTime: time-is-sane-or-nill(it.fetchTime), loadTime: time-is-sane-or-nill(it.loadTime)}) |> map ((r) ->
		fold ((acc,k)-> acc += (if !!acc then ', ' else '') + r[k]), '', all-keys ) 

csv = [(fold ((acc, k) -> acc += (if !!acc then ', ' else '') + k), '', all-keys)] ++ csv

csv = csv |> (fold ((acc,a) -> acc + '\n' + a), '')

fs = require \fs
fs.writeFileSync 'data/allrecords.csv', csv