Template.customerBoard.helpers
	publicZones: () ->
		CollaborationZones.find($or:[{openToAll:true},{consumers:{$elemMatch:{_id:Meteor.userId()}}}])
	myZones:()->
		CollaborationZones.find($or:[{contributors:{$elemMatch:{_id:Meteor.userId()}}},{coordinators:{$elemMatch:{_id:Meteor.userId()}}}])
	notifymsg:()->
		# Notifications.find({},{limit:5})
		# console.log 'observer the running status'
		# Notifications.find({},{sort:{createdAt:-1},limit:5})
		Notifications.find({},{sort:{createdAt:-1}})

Template.customerBoard.events
	'click .panel-collapse-clickable': (ev,template) ->
		clickable=$(ev.currentTarget)
		if not clickable.hasClass('panel-collapsed')
			clickable.parents('.panel').find('.panel-body').slideUp()
			clickable.addClass 'panel-collapsed'
			clickable.find('i').removeClass('entypo-down-open').addClass('entypo-up-open')
		else
			clickable.parents('.panel').find('.panel-body').slideDown()
			clickable.removeClass 'panel-collapsed'
			clickable.find('i').removeClass('entypo-up-open').addClass('entypo-down-open')
	'click .msg-file-link':(ev,template)->
		ev.preventDefault()
		ev.stopPropagation()
		# if this.isDir
		# 	atFolder={
		# 		_id:this._id
		# 		name:this.name
		# 	}
		# 	czone=CollaborationZones.findOne this.czone_id

		# 	coordinators=czone.coordinators
		# 	contributors=czone.contributors

		# 	isCoordinator=false
		# 	isContributor=false

		# 	if coordinators
		# 		isCoordinator=_.find coordinators,(coordinator)->
		# 			return coordinator._id==Meteor.userId()
		# 	if contributors
		# 		isContributor=_.find contributors, (contributor)->
		# 			return contributor._id==Meteor.userId()

		# 	if isCoordinator or isContributor
		# 		Router.go 'privateczone',{zoneid:czone._id,folder_id:this._id,folder_name:this.name}
		# 	else
		# 		Router.go 'publicczone',{zoneid:czone._id,folder_id:this._id,folder_name:this.name}
		# else
		# 	myfile=KimaFiles.findOne this._id
		# 	window.open(Attachments.findOne({_id:myfile.file_id}).url())
		folder_id=this.parent._id
		folder_name=this.parent.name
		if this.isDir
			folder_id=this._id
			folder_name=this.name
		czone=CollaborationZones.findOne this.czone_id

		coordinators=czone.coordinators
		contributors=czone.contributors

		isCoordinator=false
		isContributor=false

		if coordinators
			isCoordinator=_.find coordinators,(coordinator)->
				return coordinator._id==Meteor.userId()
		if contributors
			isContributor=_.find contributors, (contributor)->
				return contributor._id==Meteor.userId()

		if isCoordinator or isContributor
			Router.go 'privateczone',{zoneid:czone._id,folder_id:folder_id,folder_name:folder_name}
		else
			Router.go 'publicczone',{zoneid:czone._id,folder_id:folder_id,folder_name:folder_name}


