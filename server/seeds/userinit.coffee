if Meteor.users.find().count()==0
	new_user={
		username:"demo"
		email:"demo@kimatech.com"
		password:"demo"
		roles:["systemadmin"]
		profile:{fullname:"Demo"}
	}
	admin_id=Accounts.createUser(new_user)
	Roles.addUsersToRoles(admin_id,['systemadmin'])

