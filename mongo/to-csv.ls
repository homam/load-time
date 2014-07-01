
db = require("mongojs").connect \172.30.0.160:27017/MobiWeb-events, [\events]

(err, res) <- db.eval "function(x) { return x*x; }", 3
console.log err, res


(err, res) <- db.eval 'loadTime_595(new Date(2014,5,10), new Date(2014,5,26))'
console.log <| JSON.stringify res._firstBatch, null, 4

db.close!