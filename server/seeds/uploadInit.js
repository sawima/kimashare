Meteor.startup(function() {
	UploadServer.init({
	    tmpDir: process.env.PWD + '/.uploads/tmp',
	    uploadDir: process.env.PWD + '/.uploads/',
	    checkCreateDirectories: true,
	    getDirectory: function(fileInfo, formData) {
	      if (formData && formData.directoryName != null) {
	        return formData.directoryName;
	      }
	      return "";
	    },
	    getFileName: function(fileInfo, formData) {
	      if (formData && formData.prefix != null) {
	      	timestr=(new Date()).getTime();
	        return formData.prefix +'_'+timestr+ '_' + fileInfo.name;
	      }
	      tokenstring=(new Date()).getTime();
	      return fileInfo.name+tokenstring;
	    },
	    finished: function(fileInfo, formData) {
	        var attachment={
	        	name:fileInfo.name,
	        	type:fileInfo.type,
	        	key:fileInfo.key,
	        	size:fileInfo.size,
	        	path:fileInfo.path,
	        	folderpath:fileInfo.folderpath,
	        	createdAt:new Date(),
	        	metadata:{
	        		owner:formData.owner
	        	}
	        };
	        var attach_id = KimaAttachments.insert(attachment);

			var current_folder=KimaFiles.findOne(formData.folder_id);
			// var isCZone=CollaborationZones.findOne(formData.folder_id);
			acestors=new Array();
			czone_id=formData.folder_id;
			parent={
				_id:formData.folder_id,
				name:formData.folder_name
			}

			if(current_folder){
				// if(!isCZone){
					acestors=current_folder.acestors;
					czone_id=current_folder.czone_id
				// }
				parent={
					_id:formData.folder_id,
					name:current_folder.name
				};
			}
			acestors.push(parent);
	        var newfile={
	        	name:fileInfo.name,
	        	file_id:attach_id,
	        	size:fileInfo.size,
	        	type:fileInfo.type,
	        	key:fileInfo.key,
	        	acestors:acestors,
	        	parent:parent,
	        	czone_id:czone_id,
	        	isRemoved:false,
	        	updatedAt:new Date()
	        };
	        KimaFiles.insert(newfile);

	      // if (formData && formData._id != null) {
	      //   console.log(fileinfo);
	      //   Items.update({_id: formData._id}, { $push: { uploads: fileInfo }});
	      // }
	    }
	  });
});