Template.publicZone.rendered = () ->
	$('[data-toggle="tooltip"]').tooltip()

Template.publicZone.helpers
	czone: () ->
		Template.instance().data.czone
	currentid:()->
		Template.instance().current_folder_id.get()
	subItems:()->
		KimaFiles.find({"parent._id":Template.instance().current_folder_id.get()},{sort:{"isDir":-1,"name":1}})
	currentPath:()->
		current_folder=KimaFiles.findOne(Template.instance().current_folder_id.get())
		acestors=[]
		if current_folder
			acestors = current_folder.acestors
		if acestors.length<4
			return acestors
		else
			return acestors[0..1].concat({_id:null,name:"..."}).concat(acestors[-1..])

	currentName:()->
		Template.instance().current_folder_name.get()
	selected_target_ids:()->
		Template.instance().selected_file_id.get()
	czoneRootFolder:()->
		return {
			_id:Template.instance().data.czone._id
			name: Template.instance().data.czone.name
		}


Template.publicZone.created = () ->
	instance = @
	if not @data.atFolder._id
		@current_folder_id=new ReactiveVar(instance.data.czone._id)
		@current_folder_name=new ReactiveVar(instance.data.czone.name)
	else
		@current_folder_id=new ReactiveVar(instance.data.atFolder._id)
		@current_folder_name=new ReactiveVar(instance.data.atFolder.name)

	@selected_file_id=new ReactiveVar(new Array())

Template.publicZone.events
	'click .file_name_link': (ev,template) ->
		ev.preventDefault()
		ev.stopPropagation() 
		if this.isDir
			template.current_folder_id.set(this._id)
			template.current_folder_name.set(this.name)
			template.selected_file_id.set(new Array())
			template.selected_deleted_id.set("")
		else
			file_id=this.file_id
			window.open(Attachments.findOne({_id:file_id}).url())
	'click .folder_path_link':(ev,template)->
		ev.preventDefault()
		template.current_folder_id.set(this._id)
		template.current_folder_name.set(this.name)
		template.selected_file_id.set(new Array())
		template.selected_deleted_id.set("")

	'click .upper_folder_link':(ev,template)->
		ev.preventDefault()
		current_id=template.current_folder_id.get()
		parent_folder=KimaFiles.findOne(current_id)
		console.log parent_folder

		template.current_folder_id.set(parent_folder.parent._id)
		template.current_folder_name.set(parent_folder.parent.name)		

	'click #btn_files_search':(ev,template)->
		console.log 'show search result page'
	'click #kima_files_table > tbody > tr':(ev,template)->
		if !$(ev.currentTarget).hasClass('selected')
			if ev.ctrlKey
				$(ev.currentTarget).addClass('selected')
				selected_file_ids=template.selected_file_id.get()
				selected_file_ids.push(this._id)
				template.selected_file_id.set(selected_file_ids)
			else
				$('#kima_files_table > tbody > tr').removeClass('selected')
				$(ev.currentTarget).addClass('selected')
				selected_ids=new Array()
				selected_ids.push(this._id)
				template.selected_file_id.set(selected_ids)
		else
			$(ev.currentTarget).removeClass('selected')
			selected_file_ids=template.selected_file_id.get()
			pos=selected_file_ids.indexOf(this._id)
			if pos>-1
				selected_file_ids.splice pos,1
			template.selected_file_id.set(selected_file_ids)
	
	'dblclick #kima_files_table > tbody > tr':(ev,template)->
		current_target=$(ev.currentTarget)
		if not current_target.hasClass('go_upper_folder')
			current_target.find('a.file_name_link').trigger 'click'
		else
			current_target.find('a.upper_folder_link').trigger 'click'
	'click .operation_file_download':(ev,template)->
		ev.preventDefault()
		selected_files=new Array()
		selected_files=template.selected_file_id.get()

		Meteor.call 'storeBulkFiles',selected_files,(err,zip_id)->
			if not err
				window.open(Router.url('bulkDownload',{zip_id:zip_id}))
	'click #btn_files_search':(ev,template)->
		search_text=$('#txt_search_box').val()
		if search_text
			Router.go('searchResult',{searchtext:search_text,zoneid:template.data.czone._id,zonetype:"square"})
			# window.open(Router.url('searchResult',{searchtext:search_text}))

		#db.products.find( { sku: { $regex: /^ABC/i } } )
	'keydown #txt_search_box':(ev,template)->
		if ev.keyCode==13
			if ev.currentTarget.value
				$('#btn_files_search').trigger 'click'