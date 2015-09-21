Meteor.publish 'userbasic',()->
	Meteor.users.find({},{fields:{emails:1,profile:1,roles:1,username:1}})

Meteor.publish 'active_articles',(limit)->
	Articles.find({'archived':false},{sort:{createdAt:-1},limit:limit})

Meteor.publish 'categories',()->
	Categories.find()

Meteor.publish 'czones',()->
	CollaborationZones.find({isRemoved:false})

Meteor.publish 'myczones',()->
	CollaborationZones.find({isRemoved:false,$or:[{isPublic:true},{openToAll:true},{consumers:{$elemMatch:{_id:this.userId}}},{contributors:{$elemMatch:{_id:this.userId}}},{coordinators:{$elemMatch:{_id:this.userId}}}]})
Meteor.publish 'privateczones',()->
	CollaborationZones.find({isRemoved:false,$or:[{contributors:{$elemMatch:{_id:this.userId}}},{coordinators:{$elemMatch:{_id:this.userId}}}]})

Meteor.publish 'publicczones',()->
	CollaborationZones.find({isRemoved:false,$or:[{isPublic:true},{openToAll:true},{consumers:{$elemMatch:{_id:this.userId}}}]})

Meteor.publish 'kimafiles',()->
	user_zones=CollaborationZones.find($or:[{isPublic:true},{openToAll:true},{"consumers._id":this.userId},{"contributors._id":this.userId},{"coordinators._id":this.userId}]).fetch()
	user_zone_ids=_.pluck(user_zones,'_id')
	KimaFiles.find({czone_id:{$in:user_zone_ids}},{sort:{createdAt:-1}})

Meteor.publish 'notifymsg',()->
	Notifications.find({"receivers._id":this.userId},{sort:{createdAt:-1},limit:10})
	# Notifications.find({"receivers._id":this.userId},{sort:{createdAt:-1}})

Meteor.publish 'allMyMsg',(limit)->
	Notifications.find({"receivers._id":this.userId},{sort:{createdAt:-1},limit:limit})

Meteor.publish 'activities',(czone_id,limit)->
	FileActivities.find({'czone_id':czone_id},{sort:{happendAt:-1},limit:limit})

