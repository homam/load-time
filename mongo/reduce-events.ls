
db = require("mongojs").connect \172.30.0.160:27017/MobiWAP-events, [\reducedEvents, \events]

exit = (msg) ->
	db.close!
	console.log msg
	process.exit <| if !!msg then 1 else 0

process.on \exit, (code) ->
	db.close!
	console.log "Exiting #code"

query = (fromDate, toDate, viewIds, userIds, minUserId, callback) -->
	query = {}
		
	datequery = {}
	if !!fromDate
		datequery["$gt"] = fromDate
	if !!toDate
		datequery["$lt"] = toDate
	if !!fromDate or !!toDate
		query["creationTime"] = datequery

	if !!viewIds
		query["viewId"] = $in: viewIds

	if !!userIds
		query["userId"] = $in: userIds

	if !!minUserId
		query["userId"] = $lt: 800000000, $gt: minUserId

	(err, res) <- db.events.aggregate([
		{
			$match: query
		},
		{
			$project: {
				"viewId": 1,
				"countryCode": 1,
				"eventArgs.fetchTime": 1,
				"eventArgs.navigationTime": 1,
				"eventArgs.loadTime": 1,
				"eventType": 1,
				"userId": 1
			}
		}, 
		{
			$group: {
				_id: "$userId",
				renders: { $sum: { $cond: [ { $eq: [ "$eventType", "pageRender" ] } , 1, 0 ] } },
				visits: { $sum: { $cond: [ { $eq: [ "$eventType", "pageReady" ] } , 1, 0 ] } },
				clicks: { $sum: { $cond: [ { $eq: [ "$eventType", "click" ] } , 1, 0 ] } },
				fetch: { $max: "$eventArgs.fetchTime" },
				nav: { $max: "$eventArgs.navigationTime"},
				load: { $max: "$eventArgs.loadTime"}
			}
		}], 
		{ 
			allowDiskUse : true
		}
	)
	callback err, res



(err, res) <- db.reducedEvents.findOne({$query: {_id: {$lt: 800000000}}, $orderby: {_id: -1}})
exit err if !!err
minUserId = res._id
console.log "minUserId = #minUserId"

(err, res) <- query null, new Date(new Date().valueOf() - 1*60*60*1000), null, null, minUserId
exit err if !!err

console.log "Results = #{res.length}"

(err, res) <- db.reducedEvents.insert(res)
exit err if !!err

console.log "Done!"

exit null
# var res = db.eval('loadInterPerUser')(null,new Date(new Date().valueOf() - 1*60*60*1000),null,null, minUserId).result
# db.reducedEvents.insert(res)

# (err, res) <- db.eval "db.reducedEvents.findOne({$query: {_id: {$lt: 800000000}}, $orderby: {_id: -1}})._id"
# exit err if !!err
# minUserId = res
# console.log "minUserId = #minUserId"
# (err, res) <- db.eval "var res = loadInterPerUser(null,new Date(new Date().valueOf() - 12*60*60*1000),null,null, #minUserId).result; db.reducedEvents.insert(res)"
# exit err if !!err
# exit "All Done!"

