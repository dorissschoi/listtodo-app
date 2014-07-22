model = require '../../model.coffee'
controller = require '../controller/todo.coffee'
vent = require '../../vent.coffee'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

class Router extends Backbone.Router
	routes:
		'todo/list':		'list'
		'todo/agendalist':	'agendalist'
		'todo/create':		'create'
		'todo/read/:id':	'read'
		'todo/update/:id':	'update'
		'todo/hour':		'hour'
		
	constructor: (opts = {}) ->
		@collection = new model.Todos()
		#@listView = new controller.TodoSearchView {el: 'div', collection: new model.Todos(), router: @}
		@agendalistView = new controller.AgendaListView {el: 'body', collection: @collection, router: @}
		@createView = new controller.TodoCreateView {el: 'body', router: @}
		@readView = new controller.TodoReadView {el: 'body', model: new model.Todo({}, {collection: @collection}), router: @}
		@updateView = new controller.TodoUpdateView {el: 'body', model: new model.Todo({}, {collection: @collection}), router: @}
		@hourView = new controller.TodoHourView {el: 'body', collection: new model.Todos(), router: @}
	
		vent.on 'todo:selected', (todo) =>
			@read todo.id
			
		super(opts)
			
	list: ->
		@listView.render()
		@listView.collection.getFirstPage(reset: true)
		
	agendalist: ->
		@agendalistView.render()
		@agendalistView.collection.getFirstPage(reset: true)
			
	create: ->
		@createView.model = new model.Todo({}, collection: @collection)
		@createView.render()
		
	read: (id) ->
		@readView.model.set {_id: id}, {silent: true}
		@readView.model.fetch()
				
	update: (id) ->
		@updateView.model.set {_id: id}, {silent: true}
		@updateView.model.fetch()
			
	hour: ->
		@hourView.render()
		
		
module.exports =
	Router:		Router