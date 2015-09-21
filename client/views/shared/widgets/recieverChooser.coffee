Template.recieverChooser.rendered = () ->
	$('.chosen-select').chosen({
		no_results_text:'Oops, nothing found!'
		width:'100%'
		})

# Template.recieverChooser.helpers
# 	reciever:()->
# 		#todo: mongo sort
# 		Meteor.users.find({},{$sort:{'profile.fullname':1}}).fetch().map (us)->
# 			us.emails[0].address