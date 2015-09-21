if(Meteor.isServer) {
	APPConfig={
		EmailFrom:'demo@kimatech.com',
		uploadDir:process.env.PWD+'/.uploads/'
	};
}