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


all-keys = (Obj.keys records[0])
csv =  records |> map (-> it <<< {navigationTime: time-is-sane-or-nill(it.navigationTime), fetchTime: time-is-sane-or-nill(it.fetchTime), loadTime: time-is-sane-or-nill(it.loadTime)}) |> map ((r) ->
		fold ((acc,k)-> acc += (if !!acc then ', ' else '') + r[k]), '', all-keys ) 

csv = [(fold ((acc, k) -> acc += (if !!acc then ', ' else '') + k), '', all-keys)] ++ csv

csv = csv |> (fold ((acc,a) -> acc + '\n' + a), '')

fs = require \fs
fs.writeFileSync 'data/allrecords.csv', csv

console.log "Check: data/allrecords.csv"