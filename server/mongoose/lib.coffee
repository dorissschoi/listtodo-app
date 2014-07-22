model = require '../../model.coffee'

field = (name) ->
	if name.charAt(0) == '-'
		return name.substring(1)
	return name
	
order = (name) ->
	if name.charAt(0) == '-'
		return -1
	return 1
	
order_by = (name) ->
	ret = {}
	ret[field(name)] = order(name)
	return ret
		
ensurePermission = (p) ->
	(req, res, next) ->
		user = req.user
		
		# if file/dir creation, check parent folder ownership and permission
		if p == 'todo:create' or p == 'todo:list'
			return next()
			
		#todo read, update, delete	
		model.Todo.findOne {id: req.param.id}, (err, todo) ->
			if err or todo == null
				return res.json 501, error: err
			if todo.createdBy.id == user._id.id
				return next()
			else res.json 401, error: 'Unauthorzied access'
		
class Period
	constructor: (start, end) ->
		@start = start
		@end = end
		
	contain: (strdate) ->
		cond1 = {}
		cond2 = {}
		cond1[strdate] = $gte: @start
		cond2[strdate] = $lte: @end
		
		$or: [cond1, cond2]
		
	ncontain: (strdate) ->
		cond1 = {}
		cond2 = {}	
		cond1[strdate] = $lt: @start
		cond2[strdate] = $gt: @end
		
		$or: [cond1, cond2]
						
	intersect: (strstart, strend) ->
		cond1 = {}
		cond1[strend] = $lt: @start
		cond2 = {}
		cond2[strstart] = $gt: @end
		
		$nor: [cond1, cond2]
				
								
	isGT: (period) ->
		@start.getTime() > period.end.getTime()
			
	isLT: (period) ->
		@end.getTime() < period.start.getTime()
			
	isContain: (date) ->
		@start.getTime() <= date.getTime() and date.getTime() <= @end.getTime()
		
	isIntersect: (period)->	
		not (@isGT(period) or @isLT(period) )
		
module.exports =
	field:		field
	order:		order
	order_by:	order_by
	ensurePermission:	ensurePermission
	Period:		Period