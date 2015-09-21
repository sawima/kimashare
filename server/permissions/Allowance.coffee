# useradmin 
Meteor.users.allow
	insert: (userId, doc) ->
		# Roles.userIsInRole userId,'useradmin'
		false
	update: (userId, doc, fields, modifier) ->
		# Roles.userIsInRole userId,'useradmin'
		false
	remove: (userId, doc) ->
		false
Meteor.users.deny
	update: (userId, doc, fields, modifier) ->
		true
	remove: (userId, doc) ->
		true
	
@KimaFiles.allow
	insert: (userId, doc) ->
		false
	update: (userId, doc, fields, modifier) ->
		userId
	remove: (userId, doc) ->
		false