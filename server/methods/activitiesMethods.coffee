Meteor.methods
	'insertNewActivity':(act)->
		act=_.extend(act,{happendAt:new Date()})
		FileActivities.insert(act)


		
