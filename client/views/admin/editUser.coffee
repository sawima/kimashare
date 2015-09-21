Template.editUser.rendered = () ->
	if @data.roles
		@data.roles.forEach (role) ->
			$('#customer_Role option').map (i,el)->
				if($(el).attr("value")==role)
					$(el).attr("selected",true)

Template.editUser.helpers
	email: () ->
		@emails[0].address

Template.editUser.events
	'click #btn_updatepwd': (event,template) ->
		Meteor.call 'setNewPassword',template.edit_id.get(),$('#newPassword').val(),(err)->
			if !err
				Router.go 'useradmin'
	'click #btn_updateUserInfo':(event,template)->
		new_roles=$('#customer_Role').val()
		update_user_info=
			'emails.0.address':$('#customer_email').val()
			profile:
				company:$('#customer_company').val()
				phone:$('#customer_phone').val()
				fullname:$('#customer_fullname').val()
				active:true
				# active:$('#customer_active').is(":checked")
			roles:new_roles
		Meteor.call 'updateUserInfo',template.edit_id.get(),update_user_info,(err)->
			if !err
				Router.go 'useradmin'
	'click #btn_deleteUser':(event,template)->
		Meteor.call 'deleteUser',template.edit_id.get(),(err)->
			if !err
				Router.go 'useradmin'


Template.editUser.created = () ->
	@edit_id=new ReactiveVar(@data._id)