Template.searchResult.events
	'click #btn_files_search':(ev,template)->
		search_text=$('#txt_search_box').val()
		if search_text
			Router.go('searchResult',{searchtext:search_text,zoneid:template.data.czone_id})
	'keydown #txt_search_box':(ev,template)->
		if ev.keyCode==13
			if ev.currentTarget.value
				$('#btn_files_search').trigger 'click'
	'click .search_result_file':(ev,template)->
		ev.preventDefault()
		zoneid=template.data.czone_id
		zonetype=template.data.zonetype
		parent=this.parent
		folder_id=parent._id
		folder_name=parent.name

		if this.isDir
			folder_id=this._id
			folder_name=this.name

		#wild=private square=public
		if zonetype=='wild'
			Router.go('privateczone',{zoneid:zoneid,folder_id:folder_id,folder_name:folder_name})
		else if zonetype=='square'
			Router.go('publicczone',{zoneid:zoneid,folder_id:folder_id,folder_name:folder_name})
		else
			Router.go('home')
