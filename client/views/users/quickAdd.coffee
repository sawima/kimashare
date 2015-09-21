Template.quickAddUser.events
	'submit #customer_quick_form': (evt) ->
		evt.preventDefault()
		roles=$('#select_roles').val()
		if !roles
			roles=[]
			roles.push('customer')
		customer={
			email:$('#customer_email').val()
			# password:$('#customer_password').val()
			profile:
				fullname:$('#customer_name').val()
				phone:$('#customer_phone').val()
				company:$('#customer_company').val()
		}
		# console.log "new User:",customer
		Meteor.call 'quickCreateUser',customer,roles
		# Meteor.call 'quickCreateUser',customer,(err,u_id)->
		# 	if !err
		# 		console.log u_id
				# Roles.addUsersToRoles(u_id,roles)
		$(evt.currentTarget).trigger('reset')
		# $(evt.currentTarget).trigger 'reset'