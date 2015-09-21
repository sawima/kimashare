# attachmentStore = new FS.Store.GridFS('attachments')
# attachmentStore=new FS.Store.FileSystem('attachments',{path:"/home/kima/projects/uploads"})

# @Attachments = new FS.Collection "attachments",{
# 	stores:[
# 		attachmentStore
# 	]
# 	filter:{
# 		maxSize:4096000000
# 		# allow:{
# 		# 	contentTypes:['image/*','application/pdf',"application/zip",""]
# 		# }
# 		deny:{
# 			contentTypes:["application/javascript","text/html","text/x-markdown","text/css"]
# 		}
# 	}
# }