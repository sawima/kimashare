Template.newCollaborationZone.helpers
	selectUserSettings: () ->
		return {
			position:"bottom"
			limit:10
			matchAll: true
			rules:[
				{
					token:""
					collection:Meteor.users
					field:"emails.0.address"
					matchAll:true
					filter:{'profile.active':true}
					template: Template.customerPopup
				}
			]
		}
	current_edit_id:()->
		Template.instance().edit_czone_id.get()

Template.newCollaborationZone.events
	'autocompleteselect #newCustomerTxtForZone': (ev,template,doc) ->
		fullname=doc.profile.fullname
		email=doc.emails[0].address
		u_id=doc._id
		exist_ids=[]
		$('.zone-customers').each (index,el)->
			exist_ids.push($(el).data('id'))

		if _.indexOf(exist_ids,u_id)==-1
			$('#customersOfCZone').append("<li><a href='#' data-id="+u_id+" data-fullname='"+fullname+"' data-email='"+email+"' class='zone-customers zone-user-remove'><i class='entypo-cancel'></i></a>"+fullname+"</li>")
			$(ev.currentTarget).val("")
		else
			$(ev.currentTarget).val("")
	'autocompleteselect #newInternalTxtForZone': (ev,template,doc) ->
		fullname=doc.profile.fullname
		email=doc.emails[0].address
		u_id=doc._id
		exist_ids=[]
		$('.zone-internals').each (index,el)->
			exist_ids.push($(el).data('id'))

		if _.indexOf(exist_ids,u_id)==-1
			$('#internalsOfCZone').append("<li><a href='#' data-id="+u_id+" data-fullname='"+fullname+"' data-email='"+email+"' class='zone-internals zone-user-remove'><i class='entypo-cancel'></i></a>"+fullname+"</li>")
			$(ev.currentTarget).val("")
		else
			$(ev.currentTarget).val("")
	'autocompleteselect #newAdminTxtForZone': (ev,template,doc) ->
		fullname=doc.profile.fullname
		email=doc.emails[0].address
		u_id=doc._id
		exist_ids=[]
		$('.zone-keyusers').each (index,el)->
			exist_ids.push($(el).data('id'))

		if _.indexOf(exist_ids,u_id)==-1
			$('#keyuserOfCZone').append("<li><a href='#' data-id="+u_id+" data-fullname='"+fullname+"' data-email='"+email+"' class='zone-keyusers zone-user-remove'><i class='entypo-cancel'></i></a>"+fullname+"</li>")
			$(ev.currentTarget).val("")
		else
			$(ev.currentTarget).val("")
	'click .zone-user-remove':(ev,template)->
		u_id=$(ev.currentTarget).data 'id'
		$(ev.currentTarget).parent().remove()
	'click #saveNewCZone':(ev,template)->
		zone_customers=[]
		zone_internals=[]
		zone_keyusers=[]

		$('.zone-customers').each (index,el)->
			customer=
				_id:$(el).data 'id'
				fullname:$(el).data 'fullname'
				email: $(el).data 'email'
			zone_customers.push customer

		$('.zone-internals').each (index,el)->
			internal=
				_id:$(el).data 'id'
				fullname:$(el).data 'fullname'
				email: $(el).data 'email'
			zone_internals.push internal

		$('.zone-keyusers').each (index,el)->
			keyuser=
				_id:$(el).data 'id'
				fullname:$(el).data 'fullname'
				email: $(el).data 'email'
			zone_keyusers.push keyuser

		czone_name=$('#czone_name').val()

		czone_name.replace('\/',"_")

		new_czone=
			name:czone_name
			description:$('#czone_description').val()
			consumers:zone_customers
			contributors:zone_internals
			coordinators:zone_keyusers
			# isPublic:$('#isPublic').is(":checked")
			isPublic:false
			openToAll:$('#openToAll').is(":checked")
			isRemoved:false

		Meteor.call 'add_new_czone',new_czone,template.edit_czone_id.get(),(err,result)->
			if !err 
				$('#czone_name').val ""
				$('#czone_description').val ""
				$('.zone-user-remove').parent().remove()
				template.edit_czone_id.set(result)
				Meteor.call 'createNewPhysicalFolder',new_czone.name
				Router.go 'viewCZone',{czone_id:template.edit_czone_id.get()}
	'click #back_to_view_czone':(ev,template)->
		if template.edit_czone_id.get()
			Router.go 'viewCZone',{czone_id:template.edit_czone_id.get()}
		else
			Router.go 'CZoneAdmin'

Template.newCollaborationZone.rendered = () ->
	if @data
		Template.instance().edit_czone_id.set(@data._id)
		$('#czone_name').val(@data.name)
		$('#czone_description').val @data.description
		$('#isPublic').prop('checked',@data.isPublic)
		$('#openToAll').prop('checked',@data.openToAll)

		if @data.consumers
			for customer in @data.consumers 
				$('#customersOfCZone').append("<li><a href='#' data-id="+customer._id+" data-fullname='"+customer.fullname+"' data-email='"+customer.email+"' class='zone-customers zone-user-remove'><i class='entypo-cancel'></i></a>"+customer.fullname+"</li>")
		if @data.contributors
			for interal in @data.contributors 
				$('#internalsOfCZone').append("<li><a href='#' data-id="+interal._id+" data-fullname='"+interal.fullname+"' data-email='"+interal.email+"' class='zone-internals zone-user-remove'><i class='entypo-cancel'></i></a>"+interal.fullname+"</li>")
		if @data.coordinators
			for keyuser in @data.coordinators 
				$('#keyuserOfCZone').append("<li><a href='#' data-id="+keyuser._id+" data-fullname='"+keyuser.fullname+"' data-email='"+keyuser.email+"' class='zone-keyusers zone-user-remove'><i class='entypo-cancel'></i></a>"+keyuser.fullname+"</li>")

Template.newCollaborationZone.created = () ->
	@edit_czone_id=new ReactiveVar()