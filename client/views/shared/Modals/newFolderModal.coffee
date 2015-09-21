Template.newFolderModal.events
	'keydown #newfoldername': (ev) ->
		if ev.keyCode==13
			if ev.currentTarget.value
				$('#btn_save_new_folder').trigger 'click'
	'show.bs.modal #newFolderModal':(ev)->
		callback=->
			$('#newfoldername').focus()
		setTimeout callback,500
