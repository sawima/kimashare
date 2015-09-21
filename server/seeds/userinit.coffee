if Meteor.users.find().count()==0
	new_user={
		username:"james"
		email:"james@kimatech.com"
		password:"ima123"
		roles:["internal","useradmin","systemadmin"]
		profile:{fullname:"James"}
	}
	admin_id=Accounts.createUser(new_user)
	Roles.addUsersToRoles(admin_id,['internal','useradmin','systemadmin'])

	new_user={
		username:"demo"
		email:"demo@kimatech.com"
		password:"demo"
		roles:["internal","useradmin","systemadmin"]
		profile:{fullname:"Demo"}
	}
	admin_id=Accounts.createUser(new_user)
	Roles.addUsersToRoles(admin_id,['internal','useradmin','systemadmin'])

