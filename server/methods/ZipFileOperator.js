Meteor.methods({
	'createBulkZip':function(fileids){
		// console.log(fileids);
		var fs=Npm.require('fs');
		var path=Npm.require('path');

	    var uploadDir=process.env.PWD+'/.uploads/';
		// var fullpath=path.join(uploadDir,filepath);

	    var myfiles=KimaFiles.find({_id:{$in:fileids}}).fetch();

	    var bulkarray=new Array();
	    // console.log('kimafiles is',myfiles);

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
	    		console.log(attach)
	    		bulkarray.push({
	    			expand:true,
	    			cwd:path.join(uploadDir,attach.folderpath),
	    			src:[attach.key],
	    			dest:attach.folderpath
	    		});
	    	}
	    });
	    var tmpDownloadFilaName="download_"+this.userId+"_"+new Date().valueOf()+'.zip';
	    var radmonFileName=uploadDir+"tmp/"+tmpDownloadFilaName;
	    var output=fs.createWriteStream(radmonFileName);


	      var archiver=Meteor.npmRequire('archiver');
	      var archive=archiver('zip');

	      archive.pipe(output);

	      archive.bulk(bulkarray);
	      archive.finalize();

	      return tmpDownloadFilaName;

	 //    output.on('close', function() {
		//   // console.log(archive.pointer() + ' total bytes');
		//   // console.log('archiver has been finalized and the output file descriptor has closed.');
	 //      return radmonFileName;
		// });
	}
});
	
