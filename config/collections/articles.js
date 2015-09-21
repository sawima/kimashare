Articles = new Mongo.Collection('articles');

OneTime = new SimpleSchema({
	expirydate:{
		type:Date,
		optional:true
	},
	expired:{
		type:Boolean,
		defaultValue:false,
		optional:true
	},
	accesstoken:{
		type:String,
		optional:true
	}
});

Receivers = new SimpleSchema({
	_id:{
		type:String
	},
	email:{
		type:String
	},
	fullname:{
		type:String,
		optional:true
	},
	isRead:{
		type:Boolean,
		optional:true,
		defaultValue:false
	},
	requestfiles:{
		type:[Object],
		optional:true,
		blackbox:true
	}
});

ArticleSchema = new SimpleSchema({
	title:{
		type:String,
		max:200
	},
	summary:{
		type:String,
		max:400,
		optional:true
	},
	content:{
		type:String,
		optional:true
	},
	createdAt: {
    type: Date,
    optional:true,
		autoValue: function() {
  		if (this.isInsert) {
  		  return new Date;
  		} else if (this.isUpsert) {
  		  return {$setOnInsert: new Date};
  		} else {
  		  this.unset();
  		}
		}
  	},
	updatedAt:{
		type:Date,
		autoValue:function() {
			if(this.isUpdate){
				return new Date();
			}
		},
		denyInsert:true,
		optional:true
	},
	attachments:{
		type:[Object],
		optional:true,
		blackbox:true
	},
	author:{
		type:Object,
		optional:true,
		blackbox:true
	},
	//receivers
	//{_id:"",fullname:"",email:"",isRead:""}
	receivers:{
		type:[Receivers],
		optional:true
	},
	noaccountrecievers:{
		type:[String],
		optional:true
	},
	archived:{
		type:Boolean,
		defaultValue:false
	},
	lastmodifiedby:{
		type:Object,
		optional:true,
		blackbox:true
	},
	category:{
		type:Object,
		optional:true,
		blackbox:true
	},
	keywords:{
		type:String,
		optional:true
	},
	parent:{
		type:String,
		optional:true
	},
	children:{
		type:[String],
		optional:true
	},
	onetime:{
		type:OneTime,
		optional:true
	},
	isrequest:{
		type:Boolean,
		defaultValue:false
	},
	// requestitems:{
	// 	type:[String],
	// 	optional:true
	// },
	//comments: {user_id,user_name,comment,date}
	comments:{
		type:[Object],
		optional:true,
		blackbox:true
	},
	groups:{
		type:[Object],
		optional:true,
		blackbox:true
	}
	//category
	//{name:"7090 M 2.1.10",parent:'7090 M', adminlist:['xxx@123.com','rrr@kimatech.com']}

	// lastmodifiedby: author date
	// comments
	// customize fields{name:"",value:""}
	// article_customize table {name,options}

	

});

Articles.attachSchema(ArticleSchema);

