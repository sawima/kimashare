if(Meteor.roles.find().count()==0)
	roles=[
		{name:'external'}
		{name:'internal'}
		# {name:'useradmin'}
		# {name:'fileadmin'}
		{name:'systemadmin'}
	]

	roles.forEach (role) ->
		Meteor.roles.insert(role)