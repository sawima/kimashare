Template.collaborationZoneDetail.rendered = () ->
	$('.chosen-select').chosen({
		no_results_text:'Oops, nothing found!'
		width:'100%'
		})
	# $('#testSelector').val(@data._id)

	# $('#CZoneSelector option[value='+@data_id+']').attr('selected',true)
	# console.log @data
	# console.log @data._id


Template.collaborationZoneDetail.helpers
	czones: () ->
		# CollaborationZones.find({},{sort:{name:1}}).fetch().map (czone)->
		# 	czone.name
		CollaborationZones.find()

Template.collaborationZoneDetail.events
	'change #CZoneSelector':(ev,template)->
		Router.go 'viewCZone',{czone_id:ev.currentTarget.value}
	'click #remove_this_czone':(ev,template)->
		Meteor.call 'remove_czone_byid',this._id,()->
			$('#removeCZoneModal').modal('hide')
			$('body').removeClass('modal-open')
			$('.modal-backdrop').remove()
			Router.go 'CZoneAdmin'
		