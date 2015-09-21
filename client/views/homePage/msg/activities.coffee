Template.activitiesBoard.helpers
	allMsg: () ->
		Template.instance().allMsg()
	hasMore:()->
		if Template.instance().allMsg()
			return Template.instance().allMsg().count()>=Template.instance().limit.get()
		else
			return false

Template.activitiesBoard.created = () ->
	@limit = new ReactiveVar(20)
	@loaded = new ReactiveVar(0)

	instance = @
	@autorun ()->
		limit = instance.limit.get()
		subscription = instance.subscribe('activities',instance.data.czone_id,limit)
		if subscription.ready()
			instance.loaded.set(limit)

	instance.allMsg = ()->
		FileActivities.find({},{sort:{happendAt:-1},limit:instance.loaded.get()})

Template.activitiesBoard.events
	'click .load-more-msg': (ev,template) ->
		ev.preventDefault()
		limit=template.limit.get()
		limit+=20
		template.limit.set(limit)
	# 'click .msg-file-link':(ev,template)->
	# 	ev.preventDefault()
	# 	ev.stopPropagation()
	# 	if this.isDir
	# 		atFolder={
	# 			_id:this._id
	# 			name:this.name
	# 		}
	# 		czone=CollaborationZones.findOne this.czone_id

	# 		coordinators=czone.coordinators
	# 		contributors=czone.contributors

	# 		isCoordinator=false
	# 		isContributor=false

	# 		if coordinators
	# 			isCoordinator=_.find coordinators,(coordinator)->
	# 				return coordinator._id==Meteor.userId()
	# 		if contributors
	# 			isContributor=_.find contributors, (contributor)->
	# 				return contributor._id==Meteor.userId()

	# 		if isCoordinator or isContributor
	# 			Router.go 'privateczone',{zoneid:czone._id,folder_id:this._id,folder_name:this.name}
	# 		else
	# 			Router.go 'publicczone',{zoneid:czone._id,folder_id:this._id,folder_name:this.name}
	# 	else
	# 		myfile=KimaFiles.findOne this._id
	# 		window.open(Attachments.findOne({_id:myfile.file_id}).url())