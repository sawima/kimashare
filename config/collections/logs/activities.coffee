@FileActivities = new Mongo.Collection 'activities'

# user
# attachments change, upload file

# user
# create item

# user
# update item detail

# user
# add receiver to share

# user
# comments update


# czone_id
# user_id
# action:[upload,remove,copy,move,rename,new folder,download]
# happendAt
# target
	# upload, files:[{name, _id}]
	# new folder, folder:{name,_id,description}
	# remove, files:[{name,_id,old_parent:{_id,name}}]
	# copy, files:[{_id,name,old_parent:{_id,name},new_parent:{_id:name}]
	# move, files:[{_id,name,old_parent:{_id,name},new_parent:{_id:name}}]
	# download, files:[{_id,name}]
	# share,

# czone:{_id,name}
# operator:{_id,name,email}
# happendAt
# action:[upload,remove,copy,move,rename,new folder,download,share]
# targets [files:{_id,name}]
# recievers:[users:{_id,name,email}]