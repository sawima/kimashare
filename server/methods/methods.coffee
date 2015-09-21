Meteor.methods
	'quickCreateUser':(customer,roles) ->
		u_id=Accounts.createUser customer
		Roles.addUsersToRoles(u_id,roles)
		Accounts.sendEnrollmentEmail(u_id,customer.email)
		u_id
	'setNewPassword':(userId,newpassword)->
		Accounts.setPassword userId,newpassword
	'updateUserInfo':(userId,userinfo)->
		Meteor.users.update({_id:userId},{$set:userinfo})
	'deleteUser':(userId)->
		Meteor.users.remove({_id:userId})
	'add_new_czone':(czone,edit_id)->
		if edit_id
			CollaborationZones.update(edit_id,{$set:czone})
			return edit_id
		else
			return CollaborationZones.insert czone
	'remove_czone_byid':(czone_id)->
		CollaborationZones.update({_id:czone_id},{$set:{isRemoved:true}})

	'createNewNotification':(notification)->
		notification=_.extend(notification,{createdAt:new Date()})
		Notifications.insert notification
