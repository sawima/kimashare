UserProfile = new SimpleSchema
	fullname:
		type:String
		optional:true
	address:
		type:String
		optional:true
	description:
		type:String
		optional:true
	phone:
		type:String
		optional:true
	mobile:
		type:String
		optional:true
	company:
		type:String,
		optional:true
	deleted:
		type:Boolean
		optional:true
	active:
		type:Boolean
		optional:true
		defaultValue:true

UserSchema = new SimpleSchema
	username:
		type:String
		regEx:/^[a-z0-9A-Z_]{3,15}$/
		optional:true
	emails:
		type:[Object]
		optional:true
	'emails.$.address':
		type:String
		regEx:SimpleSchema.RegEx.Email
		optional:true
	'emails.$.verified':
		type:Boolean
		optional:true
	createAt:
		type:Date
		optional:true
		autoValue: ->
	  		if this.isInsert
	  		  new Date;
	  		else if (this.isUpsert)
	  		  {$setOnInsert: new Date}
	  		else
	  		  this.unset()
	profile:
		type: UserProfile
		optional:true
	services:
		type:Object
		optional:true
		blackbox:true
	roles:
		type:[String]
		optional:true

	#groups

Meteor.users.attachSchema UserSchema

