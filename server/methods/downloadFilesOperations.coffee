fs = Npm.require('fs')
path = Npm.require('path')
# mv=Meteor.npmRequire('mv')
uploadDir=process.env.PWD+'/.uploads/'

Meteor.methods
	# temperary store bulk files id for zip download
	'storeBulkFiles':(file_ids)->
		KimaBulkDownloads.insert({file_ids:file_ids})
	# remove file from physical storage
	'removeFileFromStorage':(filepath)->
		physicalPath=path.join(uploadDir,filepath)
		if fs.existsSync(physicalPath)
			fs.unlinkSync(physicalPath)
	'copyFile':(oldefile,newfile,full_path)->
		oldfilepath=path.join(uploadDir,oldefile)
		newfilepath=path.join(uploadDir,newfile)
		target_parent_path=path.join(uploadDir,full_path)
		if !fs.existsSync(target_parent_path)
			fs.mkdirSync target_parent_path
		fs.createReadStream(oldfilepath).pipe(fs.createWriteStream(newfilepath))
	'removeEmptyFolder':(folderpath)->
		real_path=path.join(uploadDir,folderpath)
		if fs.existsSync(real_path)
			fs.rmdirSync(real_path)
	'moveFile':(current_path,target_path,parent_path)->
		source=path.join(uploadDir,current_path)
		dest=path.join(uploadDir,target_path)
		target_parent_path=path.join(uploadDir,parent_path)
		if !fs.existsSync(target_parent_path)
			fs.mkdirSync target_parent_path
		sourceStream=fs.createReadStream(source)
		destStream=fs.createWriteStream(dest)
		# fs.createReadStream(source).pipe(fs.createWriteStream(dest))
		sourceStream.on 'close',()->
			fs.unlinkSync source
		sourceStream.pipe destStream
	'createNewPhysicalFolder':(dirPath)->
		physicalPath=path.join(uploadDir,dirPath)
		if not fs.existsSync(physicalPath)
			fs.mkdirSync physicalPath
	# 'dirRename':(oldepath,newpath)->
	# 	real_old_path=path.join(uploadDir,oldepath)
	# 	real_new_path=path.join(uploadDir,newpath)
	# 	if fs.existsSync(real_old_path)
	# 		fs.renameSync(real_old_path,real_new_path)
	# 	else
	# 		fs.mkdirSync real_new_path

