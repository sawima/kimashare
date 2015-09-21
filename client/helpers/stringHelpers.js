Template.registerHelper('truncate', function(string, length) {
  var cleanString = _(string).stripTags();
  return _(cleanString).truncate(length);
});

Template.registerHelper('format_time',function(inputdate) {
	if(inputdate){
		return moment(inputdate).format('YYYY-MM-DD');
	}
});

Template.registerHelper('calendar_time',function(inputdate) {
	if(inputdate){
		return moment(inputdate).calendar();
	}
});

Template.registerHelper('format_folder_time',function(inputdate) {
	if(inputdate){
		return moment(inputdate).format('MMMM Do YYYY, h:mm:ss a'); 
	}
});

Template.registerHelper('format_size',function(inputsize) {
	if(inputsize){
		return numeral(inputsize).format('0.0b');
	}
});
