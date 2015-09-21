Template.registerHelper 'toolong_filename',(filename,max)->
	if filename
		pos=filename.lastIndexOf('.');
		if pos !=-1
			name=filename.substr(0,pos)
			extension=filename.substr(pos)
			if name.length>max
			  filename=name.substr(0,max)+'...'+extension
		return filename


Template.registerHelper 'iconForFileType',(type)->
	typeclass=switch type
				when "image/jpeg","image/png","image/gif" then 'entypo-picture'
				when "application/pdf" then 'entypo-newspaper'
				when "application/zip" then 'entypo-doc-text-inv'
				when "application/mp3" then 'entypo-note-beamed'
				when "application/office" then 'entypo-docs'
				else 'entypo-docs'
	return typeclass

Template.registerHelper 'activityIcon',(action)->
	ActionIcon=switch action
		when "remove" then 'fa fa-remove'
		when "rename" then 'fa fa-retweet'
		when "upload" then 'fa fa-upload'
		when "new folder" then 'fa fa-folder-o'
		when "copy" then 'fa fa-copy'
		when "move" then 'fa fa-cut'
		when 'permanetly remove' then 'fa fa-ban'
		when 'download' then 'fa fa-cloud-download'
		else 'fa fa-unlink'
	return ActionIcon
		
	