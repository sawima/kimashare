# this is the main documents to store the file and folder structure

@KimaFiles = new Mongo.Collection 'kimafiles'

# _id
# name,type,size,updatedAt
# idDir: Boolean
# acestors:[{_id:xxx,name:xxx}]
# parent: {_id:xxx,name:xxx}
# isRemoved
# czone_id