Router.route('/',{
	name:'home',
	controller:AppController,
	action:function() {
		if(Meteor.userId())
			this.redirect('myspace')
		else
			this.layout('kimaPublicLayout');
			this.render('publicHome');
	}
});

Router.route('/myspace',{
	name:'myspace',
	layoutTemplate:'kimaCustomerLayout',
	controller:AppController,
	template:'customerBoard',
	waitOn:function(){
		return [
			this.subscribe('myczones'),
			this.subscribe('userbasic'),
			this.subscribe('kimafiles'),
			this.subscribe('notifymsg')
		]
	}
});

Router.route('/adminboard',{
	name:'adminboard',
	controller:AppController,
	template:'adminBoard',
	layoutTemplate:'adminBoardLayout'
})




// Router.route('/',{
// 	name:'home',
// 	controller:AppController,
// 	action:function() {
// 		if(Roles.userIsInRole(Meteor.userId(),'customer')){
// 			this.redirect('customer')

// 		} else if(Roles.userIsInRole(Meteor.userId(),'internal')){
// 			this.redirect('internal')

// 		} else{
// 			this.layout('kimaPublicLayout');
// 			this.render('publicHome');
// 		}
// 	}
// });

Router.route('/mybucket',{
	name:'customerBucket',
	layoutTemplate:'kimaCustomerLayout',
	controller:AppController,
	template:'customerHome',
	waitOn:function(){
		return [
			// this.subscribe('myczones'),
			this.subscribe('userbasic')
			// this.subscribe('kimafiles')
		]
	}
});

Router.route('/publicczone/:zoneid/:folder_id?/:folder_name?',{
	name:'publicczone',
	layoutTemplate:'kimaCustomerLayout',
	controller:AppController,
	template:'publicZone',
	waitOn:function(){
		return [
			this.subscribe('publicczones'),
			this.subscribe('userbasic'),
			this.subscribe('kimafiles')
		]
	},
	data:function() {
		czone=CollaborationZones.findOne({_id:this.params.zoneid});
		return {
			czone:czone,
			atFolder:{
				_id:this.params.folder_id,
				name:this.params.folder_name
			}
		};
	},
	action:function() {
		var czone=CollaborationZones.findOne({_id:this.params.zoneid});

		if(czone){
			this.render('publicZone');
		}
		else{
			Router.go('home');
		}
	}
})

Router.route('/privateczone/:zoneid/:folder_id?/:folder_name?',{
	name:'privateczone',
	layoutTemplate:'kimaCustomerLayout',
	controller:AppController,
	template:'privateZone',
	waitOn:function(){
		return [
			this.subscribe('privateczones'),
			this.subscribe('userbasic'),
			this.subscribe('kimafiles')
		]
	},
	data:function() {
		var czone=CollaborationZones.findOne({_id:this.params.zoneid});
		return {
			czone:czone,
			atFolder:{
				_id:this.params.folder_id,
				name:this.params.folder_name
			}
		};
	},
	action:function() {
		var czone=CollaborationZones.findOne({_id:this.params.zoneid});

		if(czone){
			this.render('privateZone');
		}
		else{
			Router.go('home');
		}
	}
});

Router.route('/allmsg',{
	name:'allNotificationMsg',
	controller:AppController,
	template:'allNotificationMsg',
	layoutTemplate:'kimaCustomerLayout',
	waitOn:function(){
		return [
			// this.subscribe('attachments'),
			this.subscribe('kimafiles'),
			this.subscribe('myczones')
			// this.subscribe('notifymsg')
		]
	}
});

Router.route('/activities/:czoneid',{
	name:'activitiesBoard',
	controller:AppController,
	template:'activitiesBoard',
	layoutTemplate:'kimaCustomerLayout',
	// waitOn:function(){
	// 	return [
	// 		this.subscribe('myczones')
	// 		// this.subscribe('notifymsg')
	// 	]
	// },
	data:function() {
		// czone=CollaborationZones.findOne({_id:this.params.czoneid});
		return {
			czone_id:this.params.czoneid
		};
	}
});


//single download file
Router.route('/download/:fileid',{
	name:'downloadFile',
	where:'server'
}).get(function() {
	var req = this.request;
	var res = this.response;
	var fileid=this.params.fileid;

	var mimeTypes={
	    "html": "text/html",
	    "jpeg": "image/jpeg",
	    "jpg": "image/jpeg",
	    "png": "image/png",
	    "gif": "image/gif",
	    "js": "text/javascript",
	    "css": "text/css",
	    "pdf": "application/pdf",
	    "doc": "application/msword",
	    "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
	    "zip": "application/zip, application/x-compressed-zip",
	    "txt": "text/plain"
	};
	res.setHeader('Pragma', 'no-cache');
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');

    var myfile=KimaAttachments.findOne(fileid);

    var filename=myfile.name;
    var filekey=myfile.key;
    var filepath=myfile.path;
    var stats;

	// this.response.end("this.params.fileid,ass:"+filename);
	var fs=Npm.require('fs');
	var path=Npm.require('path');

	var uploadDir=process.env.PWD+'/.uploads/';
	var fullpath=path.join(uploadDir,filepath);

	try {
	  stats = fs.lstatSync(fullpath); // throws if path doesn't exist
	} catch (e) {
	  res.writeHead(404, {'Content-Type': 'text/plain'});
	  res.write('404 Not Found\n');
	  res.end();
	  return;
	}
	if (stats.isFile()) {
      //path exists, is a file
      var mimeType = mimeTypes[path.extname(fullpath).split(".").reverse()[0]];
      if (!mimeType) {
        mimeType = "application/octet-stream";
      }

      res.setHeader('Content-disposition', 'attachment; filename=' + filename);
      res.writeHead(200, {'Content-Type': mimeType});
      var fileStream = fs.createReadStream(fullpath);
      fileStream.pipe(res);
      
      /********************archiver******************************/
      // res.setHeader('Content-disposition', 'attachment; filename=' + filename+".zip");
      // res.writeHead(200, {'Content-Type': "application/zip"});

      // var fileStream = fs.createReadStream(fullpath);

      // var archiver=Meteor.npmRequire('archiver');
      // var archive=archiver('zip');

      // archive.pipe(res);

      // archive.append(fileStream,{name:filename});
      // archive.finalize();
      /********************archiver end******************************/

    } 
   	else {
      res.writeHead(500, {'Content-Type': 'text/plain'});
      res.write('500 Internal server error\n');
      res.end();
    }
});
//bulk download files
Router.route('/bulkdownload/:zip_id',{name:'bulkDownload',where:"server"})
	.get(function(){
		var req = this.request;
		var res = this.response;

		var fs=Npm.require('fs');
		var path=Npm.require('path');

	    var uploadDir=process.env.PWD+'/.uploads/';
	    var file_ids=KimaBulkDownloads.findOne(this.params.zip_id).file_ids;
	    var myfiles=KimaFiles.find({_id:{$in:file_ids}}).fetch();

	    var bulkarray=new Array();

	    myfiles.forEach(function (kfile) {
	    	if(kfile.isDir){
	    		var acestors_path=_.pluck(kfile.acestors,'name');
	    		acestors_path.push(kfile.name);

	    		var folderpath='/'+acestors_path.join('/');
	    		bulkarray.push({
	    			expand:true,
	    			cwd:path.join(uploadDir,folderpath),
	    			src:['**'],
	    			dest:folderpath
	    		});
	    	}
	    	else{
	    		var attach=KimaAttachments.findOne(kfile.file_id);
	    		bulkarray.push({
	    			expand:true,
	    			cwd:path.join(uploadDir,attach.folderpath),
	    			src:[attach.key],
	    			dest:attach.folderpath
	    		});
	    	}
	    });
    	res.setHeader('Pragma', 'no-cache');
	    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
 		res.setHeader('Content-disposition', 'attachment; filename=kdownload.zip');
     	res.writeHead(200, {'Content-Type': "application/zip, application/x-compressed-zip"});

		var archiver=Meteor.npmRequire('archiver');
		var archive=archiver('zip');

		archive.pipe(res);

		archive.bulk(bulkarray);
		archive.finalize();
	});

Router.route('/search/:searchtext/:zoneid/:zonetype',{
	name:"searchResult",
	template:"searchResult",
	layoutTemplate:'kimaCustomerLayout',
	controller:AppController,
	waitOn:function() {
		return [
			this.subscribe('kimafiles'),
			this.subscribe('myczones')
		]
	},
	data:function() {
		var searchtext=this.params.searchtext;
		var searchre=new RegExp(searchtext,"i");
		var czoneid=this.params.zoneid;
		return {
			fileslist:KimaFiles.find({name:searchre,czone_id:czoneid}).fetch(),
			czone_id:czoneid,
			zonetype:this.params.zonetype
		}
	}
});



Router.plugin('ensureSignedIn', {
    except: ['home','atSignIn','atForgotPwd','atResetPwd','atEnrollAccount']
});

/**********Administration***********/

	/**collaboration zone**/
Router.route('/czoneadmin',{
	name:'CZoneAdmin',
	template:"collaborationZoneAdmin",
	layoutTemplate:'adminBoardLayout',
	waitOn:function() {
		return [
			this.subscribe('czones')			
		] 
	}
});

Router.route('/newczone',{
	name:'newCZone',
	template:'newCollaborationZone',
	layoutTemplate:'adminBoardLayout',
	waitOn:function() {
		return [
			this.subscribe('userbasic')
		]
	}
});

Router.route('/editczone/:czone_id',{
	name:"editCZone",
	template:"newCollaborationZone",
	layoutTemplate:"adminBoardLayout",
	waitOn:function() {
		return [
			this.subscribe('czones'),
			this.subscribe('userbasic')
		]
	},
	data:function() {
		return CollaborationZones.findOne(this.params.czone_id);
	}
});

Router.route('/viewczone/:czone_id',{
	name:"viewCZone",
	template:"collaborationZoneDetail",
	layoutTemplate:"adminBoardLayout",
	waitOn:function() {
		return [
			this.subscribe('czones'),
			this.subscribe('userbasic')
		]
	},
	data:function() {
		return CollaborationZones.findOne(this.params.czone_id);
	}
});


/************User*****************/
Router.route('/user-profile',{
	name:"userProfile",
	template:"userProfile",
	controller:AdminController
	// layoutTemplate:"adminBoardLayout",
});

Router.route('/quickAdd',{
	name:"quickAddUser",
	template:"quickAddUser",
	controller:AdminController
});

Router.route('/useradmin',{
	name:"useradmin",
	template:"useradmin",
	controller:AdminController,
	waitOn:function() {
		return [
			this.subscribe('userbasic')
		]
	}
});

// Router.route('/signin',{
// 	name:'mysignin',
// 	template:"signin"
// });
Router.route('/edit-user/:user_id',{
	name:'editUser',
	template:"editUser",
	controller:AdminController,
	waitOn:function(){
		return [
			this.subscribe('userbasic')
			]
	},
	data:function() {
		return Meteor.users.findOne(this.params.user_id);
	}
});

// var UserGroup=function() {
// 	if(Roles.userIsInRole(Meteor.userId(),'useradmin')){
// 		this.next();
// 	} else{
// 		Router.go('home');
// 	}
// };

// var InternalGroup=function() {
// 	if(Roles.userIsInRole(Meteor.userId(),'internal'))
// 		this.next();
// 	else
// 		Router.go('home');
// };

var SysAdminGroup=function() {
	if(Roles.userIsInRole(Meteor.userId(),'systemadmin'))
		this.next();
	else
		Router.go('home');
};

// Router.onBeforeAction(UserGroup,{only:['useradmin','quickAddUser','editUser','adminboard']});
Router.onBeforeAction(SysAdminGroup,{only:['CZoneAdmin','newCZone','editCZone','viewCZone','useradmin','quickAddUser','editUser','adminboard']});


// var requireLogin=function() {
// 	if(! Meteor.user()){
// 		if(Meteor.loggingIn()){
// 			this.render(this.loadingTemplate);
// 		} else{
// 			Router.go('mysignin');
// 		}
// 	} else{
// 		this.next();
// 	}
// };
// Router.onBeforeAction(requireLogin,{except:['mysignin']});


/*******Users********/
// Router.route('/signin',{
// 	name:'atSignIn',
// 	template:'signin'
// 	// layoutTemplate:'appLayout'
// 	// controller:'AppController'
// });

// Router.route('/signup',{
// 	name:'atSignUp',
// 	template:'signup'
// });

// Router.onBeforeAction(requireLogin,{only:['admin','fileAdmin','eventsAdmin','editEvent','contactadmin','productCategoriesAdmin','productNodesAdmin','productPagesAdmin']});


// Iron.Router.plugins.authorize = function(router, options) {
//   router.onBeforeAction(function(){
//     if (Meteor.loggingIn())
//       this.render('loading');
//     else if (!Meteor.user())
//       var redirect = 'home'
      
//       if (this.lookupOption('notAuthorizedRoute') !== undefined)
//         redirect = this.lookupOption('notAuthorizedRoute')
        
//       this.redirect(redirect);
//     else
//       this.next();
//   }, options);
// }