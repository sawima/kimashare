Template.privateZone.rendered = () ->
	$('[data-toggle="tooltip"]').tooltip()

Template.privateZone.helpers
	czone: () ->
		Template.instance().data.czone
	isKeyUser:()->
		u_id=Meteor.userId()
		coordinators=Template.instance().data.czone.coordinators
		iskeyu=false
		for zone_admin in coordinators
			if _.contains(zone_admin,u_id)
				iskeyu=true
				break;
		return iskeyu
	# current_acestors:()->
	# 	acestors=KimaFiles.findOne(Template.instance().current_folder_id.get()).acestors

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
	selected_removed_id:()->
		Template.instance().selected_deleted_id.get()
	shareReceivers:()->
		czone=Template.instance().data.czone
		receivers=_.union(czone.consumers,czone.contributors,czone.coordinators)
		# receivers=_.uniq(receivers)
		return receivers
	# mutipleSelected:()->
	# 	console.log 'mutipleSelected'
	# 	file_ids=Template.instance().selected_file_id.get()
	# 	if file_ids.length>1
	# 		return true
	# 	else
	# 		return false
	czoneChildFolders:()->
		czone_id=Template.instance().data.czone._id
		children=[]
		children=Template.instance().retriveSubFolder(czone_id)
		return children
	czoneRootFolder:()->
		return {
			_id:Template.instance().data.czone._id
			name: Template.instance().data.czone.name
		}
	filenames:()->
		KimaFiles.find().fetch().map (file)->
			file.name
	myformData:()->
		current_folder=KimaFiles.findOne(Template.instance().current_folder_id.get())
		acestors=[]
		czone_id=""
		if current_folder
			acestors = current_folder.acestors

		folder_paths=_.pluck(acestors,'name')
		target_full_path=folder_paths.join('/')+"/"+Template.instance().current_folder_name.get()
		return {
			prefix:Template.instance().data.czone._id
			directoryName:target_full_path
			folder_id:Template.instance().current_folder_id.get()
			folder_name:Template.instance().current_folder_name.get()
			owner:Meteor.userId()
		}


Template.privateZone.created = () ->
	instance = @
	if not @data.atFolder._id
		@current_folder_id=new ReactiveVar(instance.data.czone._id)
		@current_folder_name=new ReactiveVar(instance.data.czone.name)
	else
		@current_folder_id=new ReactiveVar(instance.data.atFolder._id)
		@current_folder_name=new ReactiveVar(instance.data.atFolder.name)

	@selected_file_id=new ReactiveVar(new Array())
	@selected_deleted_id=new ReactiveVar("")
	@move_or_copy_target_folder=new ReactiveVar({})
	@move_or_copy_action = new ReactiveVar("")

	instance.retriveSubFolder=(f_id)->
		all_folders_under=KimaFiles.find({"parent._id":f_id,isRemoved:false,isDir:true},{sort:{"name":1}}).fetch()
		children=[]
		if all_folders_under.length>0
			for folder in all_folders_under
				if _.indexOf(instance.selected_file_id.get(),folder._id) ==-1
					children.push({
						_id:folder._id
						name:folder.name
						children:instance.retriveSubFolder(folder._id)
						})
			return children
		else
			return null

Template.privateZone.events
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
			############activities##########
			operator={_id:Meteor.userId(),fullname:Meteor.user().profile.fullname,email:Meteor.user().emails[0].address}
			action="download"
			czone_id=template.data.czone._id

			activity=
				file:{_id:file_id,name:this.name}
				operator:operator
				action:action
				czone_id:czone_id
			Meteor.call 'insertNewActivity',activity
			############################
			# window.open(Attachments.findOne({_id:file_id}).url())
			# KimaAttachments.findOne({_id:file_id})
			# window.open(Router.url("downloadFile",{fileid:file_id}));
			window.open("/download/"+file_id)

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
		template.current_folder_id.set(parent_folder.parent._id)
		template.current_folder_name.set(parent_folder.parent.name)				

	'click #btn_save_new_folder':(ev,template)->
		folder_name=$('#newfoldername').val()
		folder_name.replace("\/","_")
		folder_description=$('#newFolderDescription').val()
		parent_id=template.current_folder_id.get()
		if folder_name
			parent=
				_id:parent_id
				name:template.current_folder_name.get()
			current_folder=KimaFiles.findOne(template.current_folder_id.get())
			isCZone=CollaborationZones.findOne(Template.instance().current_folder_id.get())
			acestors=[]
			if current_folder
				if not isCZone
					acestors=current_folder.acestors
			acestors.push parent

			existNames=new Array()
			all_files_under=KimaFiles.find({"parent._id":template.current_folder_id.get(),isRemoved:false}).fetch()
			existNames=_.pluck(all_files_under,'name')
			folder_name=checkDumplicateFolderName(existNames,folder_name,folder_name,0)

			new_dir=
				name:folder_name
				description:folder_description
				updatedAt:new Date()
				type:"folder"
				isDir: true
				acestors:acestors
				parent:parent
				czone_id:template.data.czone._id
			Meteor.call 'create_new_folder',new_dir,(err,result)->
				if !err
					$('#newfoldername').val('')
					$('#newFolderDescription').val("")
					############activities##########
					operator={_id:Meteor.userId(),fullname:Meteor.user().profile.fullname,email:Meteor.user().emails[0].address}
					action="new folder"
					czone_id=template.data.czone._id

					activity=
						file:{_id:result,name:folder_name}
						operator:operator
						action:action
						czone_id:czone_id
					Meteor.call 'insertNewActivity',activity
					############################
		else
			toastr["warning"]("New folder name should not be empty", "New Folder")

	
	# 'click #btn_save_upload_files':(ev,template)->
	# 	attach_ids=new Array()
	# 	$('.li_upload_attaches').each (index,element)->
	# 		attach_ids.push($(element).data('id'))

	# 	console.log attach_ids

	# 	attches = Attachments.find({"_id":{$in:attach_ids}}).fetch()

	# 	console.log attches

	# 	parent_id=template.current_folder_id.get()
	# 	parent=
	# 		_id:parent_id
	# 		name:template.current_folder_name.get()
	# 	current_folder=KimaFiles.findOne(template.current_folder_id.get())
	# 	isCZone=CollaborationZones.findOne(Template.instance().current_folder_id.get())
	# 	acestors=[]
	# 	if current_folder
	# 		if not isCZone
	# 			acestors=current_folder.acestors
	# 	acestors.push parent

	# 	existNames=new Array()
	# 	all_files_under=KimaFiles.find({"parent._id":template.current_folder_id.get(),isRemoved:false}).fetch()
	# 	existNames=_.pluck(all_files_under,'name')

	# 	for attch in attches
	# 		new_file_name=attch.copies.attachments.name
	# 		new_file_name=checkDumplicateFileName(existNames,new_file_name,new_file_name,0)
	# 		new_file=
	# 			name:new_file_name
	# 			file_id:attch._id
	# 			size:attch.copies.attachments.size
	# 			updatedAt:attch.copies.attachments.updatedAt
	# 			type:attch.copies.attachments.type
	# 			isDir: false
	# 			acestors:acestors
	# 			parent:parent
	# 			czone_id:template.data.czone._id

	# 		Meteor.call 'upload_new_file_to_target',new_file,(err,result)->
	# 			if err
	# 				console.log err
	# 			else
	# 				$('#upload_file_list').empty()
	# 			############activities##########
	# 			operator={_id:Meteor.userId(),fullname:Meteor.user().profile.fullname,email:Meteor.user().emails[0].address}
	# 			action="upload"
	# 			czone_id=template.data.czone._id

	# 			activity=
	# 				file:{_id:result,name:new_file_name}
	# 				folder:parent
	# 				operator:operator
	# 				action:action
	# 				czone_id:czone_id
	# 			Meteor.call 'insertNewActivity',activity
	# 			############################	


	'click [data-modallink=modal]':(ev,template)->
		target_model=$(ev.currentTarget).data('target')
		$(target_model).modal('show')
	
	'click #btn_files_search':(ev,template)->
		search_text=$('#txt_search_box').val()
		if search_text
			Router.go('searchResult',{searchtext:search_text,zoneid:template.data.czone._id,zonetype:"wild"})
			# window.open(Router.url('searchResult',{searchtext:search_text}))

		#db.products.find( { sku: { $regex: /^ABC/i } } )
	'keydown #txt_search_box':(ev,template)->
		if ev.keyCode==13
			if ev.currentTarget.value
				$('#btn_files_search').trigger 'click'
	'click #kima_files_table > tbody > tr':(ev,template)->
		if not $(ev.currentTarget).hasClass('go_upper_folder')
			if !$(ev.currentTarget).hasClass('removed_file')
				deleted_id=template.selected_deleted_id.get()
				if !$(ev.currentTarget).hasClass('selected')
					if ev.ctrlKey
						if deleted_id
							$('.removed_file').removeClass('selected')
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
				template.selected_deleted_id.set("")
			else
				template.selected_file_id.set(new Array())
				if !$(ev.currentTarget).hasClass('selected')
					$('#kima_files_table > tbody > tr').removeClass('selected')
					$(ev.currentTarget).addClass('selected')
					template.selected_deleted_id.set(this._id)
				else
					$(ev.currentTarget).removeClass('selected')
					template.selected_deleted_id.set("")

	'dblclick #kima_files_table > tbody > tr':(ev,template)->
		current_target=$(ev.currentTarget)
		if not current_target.hasClass('go_upper_folder')
			current_target.find('a.file_name_link').trigger 'click'
		else
			current_target.find('a.upper_folder_link').trigger 'click'

	#####file operation buttons events#######
	'click .operation_file_remove':(ev,template)->
		choosedfiles=new Array()
		choosedfiles=template.selected_file_id.get()

		############################activities
		operator={_id:Meteor.userId(),fullname:Meteor.user().profile.fullname,email:Meteor.user().emails[0].address}
		action="remove"
		czone_id=template.data.czone._id

		files=KimaFiles.find({_id:{$in:choosedfiles}}).fetch()

		for file in files 
			activity=
				file:{_id:file._id,name:file.name}
				operator:operator
				action:action
				czone_id:czone_id
			Meteor.call 'insertNewActivity',activity
		#############################################

		Meteor.call 'removekimafile',choosedfiles
				# toastr.options = 
				# 	"closeButton": false
				# 	"debug": false
				# 	"newestOnTop": false
				# 	"progressBar": false
				# 	"positionClass": "toast-top-center"
				# 	"preventDuplicates": false
				# 	"onclick": null
				# 	"showDuration": "300"
				# 	"hideDuration": "1000"
				# 	"timeOut": "80000"
				# 	"extendedTimeOut": "80000"
				# 	"showEasing": "swing"
				# 	"hideEasing": "linear"
				# 	"showMethod": "fadeIn"
				# 	"hideMethod": "fadeOut"
				# toastr["info"]("Sucess removed files <button class='btn btn-danger remove-undo-link' data-id='"+result._id+"'>Undo</button>", "Removed")
	# 'click .remove-undo-link':(ev,template)->
	# 	# ev.preventDefault()
	# 	file_id=$(ev.currentTarget).data 'id'
	# 	console.log file_id
	'click .operation_file_share':(ev,template)->
		$('#fileShareModal').modal('show')
	'click #share_current_folder':(ev,template)->
		template.selected_file_id.set(new Array())
		$('#fileShareModal').modal('show')

	'click #btn_share_to_users':(ev,template)->
		files_ids=new Array()
		files_ids = template.selected_file_id.get()
		czone_id=template.data.czone._id
		receivers_ids=$('#shareToUsers').val()

		receivers_arr=[]
		receivers_emails=[]

		receivers=Meteor.users.find({"_id":{$in:receivers_ids}}).fetch()
		for user in receivers
			receivers_arr.push {
				_id:user._id
				email:user.emails[0].address
				fullname:user.profile.fullname
			}
			receivers_emails.push user.emails[0].address

		# description=$('#share_comments').val()
		description=$('#share_comments').code()

		# title=$('#share_title').val()
		czone=template.data.czone
		czone_name=czone.name
		czone_id=czone._id
		author=Meteor.user()
		
		selected_files=KimaFiles.find({"_id":{$in:files_ids}}).fetch()
		notification=
			files:selected_files
			czone_id:czone_id
			czone_name:czone_name
			author:{
				_id:author._id
				email:author.emails[0].address
				fullname:author.profile.fullname
			}
			receivers:receivers_arr
			description:description
			isRead:false
			# title:title
		Meteor.call 'createNewNotification',notification

		site_link=window.location.href

		file_list="<ul>"
		for file in selected_files
			parent=file.parent
			folder_id = parent._id
			folder_name=parent.name
			if file.isDir
				folder_id=file._id
				folder_name=file.name
			file_link=site_link+"/"+folder_id+"/"+folder_name
			file_node="<li><a href='"+file_link+"'>"+file.name+"</li>"
			file_list+=file_node
			folder_id=""
			folder_name=""
		file_list+="</ul>"

		mailoption={
				to:receivers_emails.join()
				subject:'User share new files to you'
				text:'User share new files to you with comments'+description+" Please check it out"+site_link
				html:'<p>Hi,</p><p>This email is sent to the associates who referred with this items</p><p>here is the comments</p><strong>'+description+'</strong>'+file_list
			}
		Meteor.call 'sendSMTPEmail',mailoption

		$('#share_comments').val("")
		# $('#share_title').val("")
		$('#shareToUsers').val('').trigger('chosen:updated')

	'click #show_deleted':(ev,template)->
		template.selected_file_id.set(new Array())
		template.selected_deleted_id.set("")

		if $(ev.currentTarget).find('i').hasClass('entypo-cup')
			$(ev.currentTarget).find('i').removeClass('entypo-cup').addClass('entypo-trash')

			$('.removed_file').removeClass('show-out')
		else
			$(ev.currentTarget).find('i').addClass('entypo-cup').removeClass('entypo-trash')
			$('.removed_file').addClass('show-out')

	# rename
	# 'click .operation_file_rename':(ev,template)->
	# 	ev.preventDefault()

	# 	$('.file-rename-inputbox').remove()
	# 	#todo: set target a link as editable, save it 
	# 	selected_file_id=template.selected_file_id.get()[0]
	# 	target = $('.file_name_link[data-id='+selected_file_id+']')
	# 	target.closest('td').append("<input type='text' value='"+target.text()+"' data-value='"+target.text()+"' data-id='"+selected_file_id+"' class='file-rename-inputbox' />")
	# 	target.hide()
	# 	$('.file-rename-inputbox').focus()
	# 'focus .file-rename-inputbox':(ev)->
	# 	$(ev.currentTarget).select()
	# 'keydown .file-rename-inputbox':(ev,template)->
	# 	ev.stopImmediatePropagation()
	# 	selected_file_id=$(ev.currentTarget).data 'id'
	# 	old_value=$(ev.currentTarget).data 'value'
	# 	if ev.keyCode==13
	# 		if ev.currentTarget.value and (ev.currentTarget.value isnt old_value.trim())


	# 			Meteor.call 'renameKimaFiles',selected_file_id,ev.currentTarget.value,template.data.czone._id
			
	# 		$(ev.currentTarget).closest('td').find('a').show()
	# 		$(ev.currentTarget).remove()

	# deleted files operation
	'click .operation_removed_file_restore':(ev,template)->
		selected_deleted_id=template.selected_deleted_id.get()
		current_folder_id=template.current_folder_id.get()
		Meteor.call 'restoreRemovedFile',selected_deleted_id,current_folder_id,(err)->
			if !err
				# console.log $('tr[data-id='+selected_deleted_id+']')
				template.selected_deleted_id.set('')
				# $('tr[data-id='+selected_deleted_id+']').removeClass('show-out').removeClass('removed_file')

	'click .operation_removed_file_permanetly_remove':(ev,template)->
		selected_deleted_id=template.selected_deleted_id.get()
		############activities##########
		operator={_id:Meteor.userId(),fullname:Meteor.user().profile.fullname,email:Meteor.user().emails[0].address}
		action="permanetly remove"
		czone_id=template.data.czone._id
		filename=KimaFiles.findOne({_id:selected_deleted_id}).name
		activity=
			file:{_id:selected_deleted_id,name:filename}
			operator:operator
			action:action
			czone_id:czone_id
		Meteor.call 'insertNewActivity',activity
		############################	
		Meteor.call 'permanentlyDeleteKimaFile',selected_deleted_id,(err)->
			if !err
				template.selected_deleted_id.set('')

	#folder tree
	'click .zone-folder-tree-node':(ev,template)->
		template.move_or_copy_target_folder.set({isroot:false,_id:this._id,name:this.name})
		$('.zone-folder-tree-node').removeClass 'folder-node-choosed'
		$('.zone-root-node').removeClass 'folder-node-choosed'
		$(ev.currentTarget).addClass 'folder-node-choosed'

		# todo: avoid to choose slected folder, cause iteration endless


	#root folder choosed
	'click .zone-root-node':(ev,template)->
		ev.preventDefault()
		$('.zone-folder-tree-node').removeClass 'folder-node-choosed'
		$(ev.currentTarget).addClass 'folder-node-choosed'
		template.move_or_copy_target_folder.set({isroot:true,_id:this._id,name:this.name})

	'show.bs.modal #folderTreeModal':(ev,template)->
		template.move_or_copy_target_folder.set({})
	#copy to
	'click #btn_copy_to':(ev,template)->
		target_folder=template.move_or_copy_target_folder.get()
		selected_file_id=new Array()
		selected_file_id=template.selected_file_id.get()
		callback=template.move_or_copy_action.get()
		czoneid=template.data.czone._id
		if target_folder
			Meteor.call callback,selected_file_id,target_folder._id,target_folder.name,czoneid,target_folder.isroot,(err)->
				if not err
					##############activities###################
					action=""
					if callback=='moveToKimaFiles'
						action="move"
					else if callback=='copyToKimaFiles'
						action='copy'
					operator={_id:Meteor.userId(),fullname:Meteor.user().profile.fullname,email:Meteor.user().emails[0].address}
					czone_id=template.data.czone._id

					files=KimaFiles.find({_id:{$in:selected_file_id}}).fetch()
					for file in files 
						activity=
							file:{_id:file._id,name:file.name}
							target_foder:target_folder
							current_folder:file.parent
							operator:operator
							action:action
							czone_id:czone_id
						Meteor.call 'insertNewActivity',activity
					##########################################

					$('.zone-folder-tree-node').removeClass 'folder-node-choosed'
					$('.zone-root-node').removeClass 'folder-node-choosed'
					template.move_or_copy_target_folder.set({})
					template.move_or_copy_action.set("")
					template.selected_file_id.set(new Array())


	'click #btn_move_files':(ev,template)->
		ev.preventDefault()
		target_model=$(ev.currentTarget).data('target')
		$(target_model).modal('show')
		$('#btn_copy_to').text('Move To')
		template.move_or_copy_action.set('moveToKimaFiles')
		
	'click #btn_copy_files':(ev,template)->
		ev.preventDefault()
		target_model=$(ev.currentTarget).data('target')
		$(target_model).modal('show')
		$('#btn_copy_to').text('Copy To')
		template.move_or_copy_action.set('copyToKimaFiles')

	'click .operation_file_download':(ev,template)->
		ev.preventDefault()
		selected_files=new Array()
		selected_files=template.selected_file_id.get()

		Meteor.call 'storeBulkFiles',selected_files,(err,zip_id)->
			if not err
				# window.open(Router.url('bulkDownload',{zip_id:zip_id}))
				window.open('/bulkdownload/'+zip_id)
	    

#########################
#this function is to modify the folder name to avoid dumplicated folder name
# foldername(1),foldername(2)....
#########################		
checkDumplicateFolderName=(existNames,folder_name,new_folder_name,sufix)->
	sufix++
	if _.indexOf(existNames,new_folder_name)!=-1
		new_folder_name=folder_name+"("+sufix+")"
		checkDumplicateFolderName(existNames,folder_name,new_folder_name,sufix)
	else
		return new_folder_name

checkDumplicateFileName=(existNames,file_name,new_file_name,sufix)->
	sufix++
	if _.indexOf(existNames,new_file_name)!=-1
		pos=file_name.lastIndexOf('.')
		if pos!=-1
			extension=file_name.substr(pos)
			new_file_name=file_name.substr(0,pos)+"("+sufix+")"+extension
			checkDumplicateFileName(existNames,file_name,new_file_name,sufix)
		else		
			new_file_name=file_name+"("+sufix+")"
			checkDumplicateFileName(existNames,file_name,new_file_name,sufix)
	else
		return new_file_name
