// Apply AdminLTE skin
Meteor.startup(function() {
   // $('body').addClass('skin-purple');
	// $.noConflict();
  Uploader.finished = function(index, file) {
  	// console.log('file uploaded!!!!!');
  	// console.log(file);
    // Uploads.insert(file);
  }
});