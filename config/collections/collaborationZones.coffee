@CollaborationZones = new Mongo.Collection 'czones'

# name
# description
# consumer
	# [Object]
		# _id,fullname,email
# contributor
# coordinator

# isPublic
# openToAll


# isPrivate: true/false

# isRemoved

## undefined--->coordinator,contributor,consumer

CzoneSchema=new SimpleSchema
	name:
		type:String
		unique:true
	description:
		type:String
		optional:true
	consumers:
		type:[Object]
		optional:true
		blackbox:true
	contributors:
		type:[Object]
		optional:true
		blackbox:true
	coordinators:
		type:[Object]
		optional:true
		blackbox:true
	isPublic:
		type:Boolean
		optional:true
	openToAll:
		type:Boolean
		optional:true
	isRemoved:
		type:Boolean
		optional:true
	czoneMap:
		type:Object
		optional:true
		blackbox:true

@CollaborationZones.attachSchema CzoneSchema