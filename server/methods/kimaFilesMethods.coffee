Meteor.methods
	'create_new_folder':(new_dir)->
		new_dir=_.extend(new_dir,{isRemoved:false})

		acestors=new_dir.acestors
		acestors_arr=_.pluck(acestors,'name')
		acestors_arr.push(new_dir.name)
		dirPath=acestors_arr.join('/')

		Meteor.call "createNewPhysicalFolder",dirPath
		KimaFiles.insert new_dir

	'removekimafile':(file_ids)->
		KimaFiles.update({_id:{$in:file_ids}},{$set:{isRemoved:true}},{multi:true})
	'restoreRemovedFile':(file_id,current_folder_id)->
		target_file=KimaFiles.findOne(file_id)
		existNames=Meteor.call 'getParentChildrenNames',current_folder_id

		newname=""
		if not target_file.isDir
			newname=Meteor.call 'checkDumplicateFileName',existNames,target_file.name,target_file.name,0
		else
			newname=Meteor.call 'checkDumplicateFolderName',existNames,target_file.name,target_file.name,0
		KimaFiles.update({_id:target_file._id},{$set:{name:newname,isRemoved:false}})


	'permanentlyDeleteKimaFile':(file_id)->
		target=KimaFiles.findOne(file_id)

		attach_id=target.file_id
		target_type=target.isDir
		if not target_type
			KimaFiles.remove file_id
			#todo remove file first then remove file record
			filepath=KimaAttachments.findOne(attach_id).path 
			Meteor.call 'removeFileFromStorage',filepath
			KimaAttachments.remove attach_id
		else
			Meteor.call 'folderIterationDelete',file_id


	'copyToKimaFiles':(file_ids,target_folder_id,target_folder_name,czoneid,isroot)->
		copyfilescollection=KimaFiles.find({_id:{$in:file_ids}})
		parent=
			_id:target_folder_id
			name:target_folder_name

		targetfolder_acestors=new Array()
		if not isroot
			targetfolder_acestors=KimaFiles.findOne(target_folder_id).acestors
		targetfolder_acestors.push parent

		full_path=_.pluck(targetfolder_acestors,'name').join('/')

		copyfilescollection.forEach (fc) ->
			if not fc.isDir
				oldfile=KimaAttachments.findOne(fc.file_id)
				datestr=(new Date()).getTime()
				new_file_key=czoneid+"_"+datestr+"_"+oldfile.name
				newfile=
					name:oldfile.name
					type:oldfile.type
					size:oldfile.size
					createdAt:new Date()
					key:new_file_key
					path:full_path+"/"+new_file_key
					folderpath:full_path
					metadata:{
						owner:Meteor.userId()
					}
				Meteor.call 'copyFile',oldfile.path,newfile.path,full_path
				newfile_id=KimaAttachments.insert(newfile)

				newfilerecord=
					name:oldfile.name
					file_id:newfile_id
					size:oldfile.size
					type:oldfile.type
					updatedAt:new Date()
					acestors:targetfolder_acestors
					parent:
						_id:target_folder_id
						name:target_folder_name
					isRemoved:false
					czone_id:czoneid


				# KimaFiles.insert newfilerecord
				Meteor.call 'insertFileWithNameCheck',newfilerecord
			else
				Meteor.call 'folderIterationCopy',fc._id,target_folder_id,target_folder_name,isroot,czoneid

	'moveToKimaFiles':(file_ids,target_folder_id,target_folder_name,czoneid,isroot)->
		new_parent=
			_id:target_folder_id
			name:target_folder_name

		targetfolder_acestors=new Array()
		if not isroot
			targetfolder_acestors=KimaFiles.findOne(target_folder_id).acestors
		targetfolder_acestors.push new_parent

		acestors_name_path=_.pluck(targetfolder_acestors,'name')

		target_path=acestors_name_path.join('/')
		
		#KimaFiles.update({_id:{$in:file_ids}},{$set:{acestors:target_acestors,parent:new_parent}},{multi:true})
		tryMovedFiles=KimaFiles.find({_id:{$in:file_ids}})

		existNames=Meteor.call 'getParentChildrenNames',target_folder_id

		tryMovedFiles.forEach (file) ->
			newname=""
			if not file.isDir
				newname=Meteor.call 'checkDumplicateFileName',existNames,file.name,file.name,0
				#todo: move file to target folder
				attach=KimaAttachments.findOne(file.file_id)
				source_path=attach.path
				source_key=attach.key
				update_path=target_path+'/'+source_key
				update_folderpath=target_path
				Meteor.call 'moveFile',source_path,update_path,target_path
				KimaAttachments.update({_id:file.file_id},{$set:{path:update_path,folderpath:update_folderpath}})
				KimaFiles.update({_id:file._id},{$set:{acestors:targetfolder_acestors,parent:new_parent,name:newname}})
			else
				newname=Meteor.call 'checkDumplicateFolderName',existNames,file.name,file.name,0
				Meteor.call 'createNewPhysicalFolder',target_path+'/'+newname
				Meteor.call 'folderIterationMove',file._id,target_folder_id,target_folder_name,isroot,czoneid

	# 'renameKimaFiles':(file_id,new_file_name,czoneid)->
	# 	# current_file_info=KimaFiles.findOne(file_id)

	# 	# target_acestors=current_file_info.acestors
	# 	# parent=current_file_info.parent

	# 	# if not current_file_info.isDir
	# 	# 	oldfile=KimaAttachments.findOne(current_file_info.file_id)
	# 	# 	datestr=(new Date()).getTime()
	# 	# 	newfile=
	# 	# 		name:oldfile.name
	# 	# 		type:oldfile.type
	# 	# 		size:oldfile.size
	# 	# 		createdAt:new Date()
	# 	# 		key:czoneid+"_"+datestr+"_"+oldfile.key
	# 	# 		path:full_path+"/"+oldfile.key
	# 	# 		folderpath:full_path
	# 	# 		metadata:{
	# 	# 			owner:Meteor.userId()
	# 	# 		}
	# 	# 	Meteor.call 'copyFile',oldfile.path,newfile.path
	# 	# 	newfile_id=KimaAttachments.insert(newfile)


	# 	# 	newfilerecord=
	# 	# 		name:new_file_name
	# 	# 		file_id:newfile_id
	# 	# 		size:newfile.size
	# 	# 		type:newfile.type
	# 	# 		updateAt:new Date()
	# 	# 		acestors:target_acestors
	# 	# 		parent:parent
	# 	# 		isRemoved:false
	# 	# 		czone_id:czoneid
	# 	# 	# KimaFiles.insert newfilerecord
	# 	# 	KimaFiles.update({_id:file_id},{$set:{isRemoved:true}})
	# 	# 	Meteor.call 'insertFileWithNameCheck',newfilerecord
	# 	# else

	# 	current_file_info=KimaFiles.findOne(file_id)
	# 	target_acestors=current_file_info.acestors
	# 	parent=current_file_info.parent

	# 	full_path=_.pluck(target_acestors,'name').join('/')
	# 	if not current_file_info.isDir
	# 		KimaFiles.update({_id:file_id}, {$set:{name:new_file_name}})
	# 	else
	# 		old_folder_path=full_path+'/'+current_file_info.name
	# 		new_folder_path=full_path+'/'+new_file_name
	# 		Meteor.call 'dirRename',old_folder_path,new_folder_path
	# 		KimaFiles.update({_id:file_id}, {$set:{name:new_file_name}})

	'folderIterationDelete':(folder_id)->
		target_folder=KimaFiles.findOne(folder_id)

		children=KimaFiles.find({'parent._id':folder_id})

		children.forEach (child) ->
			if not child.isDir
				filepath=KimaAttachments.findOne(child.file_id).path 
				Meteor.call 'removeFileFromStorage',filepath
				KimaAttachments.remove child.file_id
				KimaFiles.remove(child._id)
			else
				Meteor.call 'folderIterationDelete',child._id

		folder_acestors=target_folder.acestors
		path_array=_.pluck(folder_acestors,'name')
		path_array.push(target_folder.name)
		fullpath=path_array.join('/')
		Meteor.call "removeEmptyFolder",fullpath

		KimaFiles.remove target_folder._id

	'folderIterationCopy':(folder_id,target_pos_id,target_pos_name,isroot,czoneid)->
		origin_folder=KimaFiles.findOne(folder_id)
		children=KimaFiles.find({'parent._id':folder_id})

		existNames=Meteor.call 'getParentChildrenNames',target_pos_id
		newname=Meteor.call 'checkDumplicateFolderName',existNames,origin_folder.name,origin_folder.name,0
	
		target_parent=
			_id:target_pos_id
			name:target_pos_name
		target_parent_acestors=new Array()
		if not isroot
			target_parent_acestors=KimaFiles.findOne(target_pos_id).acestors
		target_parent_acestors.push target_parent

		full_path=_.pluck(target_parent_acestors,'name').join('/')

		delete origin_folder._id
		origin_folder.parent=target_parent
		origin_folder.acestors=target_parent_acestors
		new_folder_name=newname
		Meteor.call 'createNewPhysicalFolder',full_path+'/'+newname
		new_folder_id=Meteor.call 'insertFolderWithNameCheck',origin_folder

		children.forEach (child) ->
			fake_ids=new Array()
			fake_ids.push child._id
			Meteor.call 'copyToKimaFiles',fake_ids,new_folder_id,new_folder_name,czoneid

	'folderIterationMove':(folder_id,target_pos_id,target_pos_name,isroot,czoneid)->
		origin_folder=KimaFiles.findOne(folder_id)
		children=KimaFiles.find({'parent._id':folder_id})

		current_folder_acestors=_.pluck(origin_folder.acestors,'name')
		current_folder_acestors.push(origin_folder.name)
		current_folder_path=current_folder_acestors.join('/')
	
		target_parent=
			_id:target_pos_id
			name:target_pos_name
		target_parent_acestors=new Array()
		if not isroot
			target_parent_acestors=KimaFiles.findOne(target_pos_id).acestors
		target_parent_acestors.push target_parent
		old_folder_id=origin_folder._id

		delete origin_folder._id
		origin_folder.parent=target_parent
		origin_folder.acestors=target_parent_acestors
		new_folder_name=origin_folder.name
		# new_folder_id = KimaFiles.insert origin_folder
		new_folder_id=Meteor.call 'insertFolderWithNameCheck',origin_folder
		KimaFiles.remove(old_folder_id)


		children.forEach (child) ->
			fake_ids=new Array()
			fake_ids.push child._id
			Meteor.call 'moveToKimaFiles',fake_ids,new_folder_id,new_folder_name,czoneid

	'checkDumplicateFolderName':(existNames,folder_name,new_folder_name,sufix)->
		sufix++
		if _.indexOf(existNames,new_folder_name)!=-1
			new_folder_name=folder_name+"("+sufix+")"
			Meteor.call 'checkDumplicateFolderName',existNames,folder_name,new_folder_name,sufix
		else
			return new_folder_name

	'checkDumplicateFileName':(existNames,file_name,new_file_name,sufix)->
		sufix++
		if _.indexOf(existNames,new_file_name)!=-1
			pos=file_name.lastIndexOf('.')
			if pos!=-1
				extension=file_name.substr(pos)
				new_file_name=file_name.substr(0,pos)+"("+sufix+")"+extension
				Meteor.call 'checkDumplicateFileName',existNames,file_name,new_file_name,sufix
			else		
				new_file_name=file_name+"("+sufix+")"
				Meteor.call 'checkDumplicateFileName',existNames,file_name,new_file_name,sufix

		else
			return new_file_name
	'getParentChildrenNames':(parent_id)->
		existNames=new Array()
		all_files_under=KimaFiles.find({"parent._id":parent_id,isRemoved:false}).fetch()
		existNames=_.pluck(all_files_under,'name')
		return existNames
	#correct the dumplicated name before insert new file into the KimaFile collection
	'insertFileWithNameCheck':(newfile)->
		filename=newfile.name
		parent_id=newfile.parent._id
		existNames=Meteor.call 'getParentChildrenNames',parent_id
		new_file_name=Meteor.call 'checkDumplicateFileName',existNames,filename,filename,0
		newfile.name=new_file_name
		KimaFiles.insert newfile

	'insertFolderWithNameCheck':(newfolder)->
		foldername=newfolder.name
		parent_id=newfolder.parent._id

		existNames=Meteor.call 'getParentChildrenNames',parent_id
		new_folder_name=Meteor.call 'checkDumplicateFolderName',existNames,foldername,foldername,0
		newfolder.name=new_folder_name
		return KimaFiles.insert newfolder








