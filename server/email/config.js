    // process.env.MAIL_URL = 'smtp://' + encodeURIComponent(smtp.username) + ':' + encodeURIComponent(smtp.password) + '@' + encodeURIComponent(smtp.server) + ':' + smtp.port;

    //set account email templates
    Accounts.emailTemplates.siteName='File Share Portal';
    Accounts.emailTemplates.from=APPConfig.EmailFrom;

    Accounts.emailTemplates.enrollAccount.subject=function(user) {
      return "Welcome to File Share Portal"; 
    };

    Accounts.emailTemplates.enrollAccount.text=function(user,url) {
      return "You have been selected to participate in building a better future!" + " To activate your account, simply click the link below:\n\n" + url;
    };

    // A Function that takes a user object and returns a String for the subject line of the email.
	  Accounts.emailTemplates.verifyEmail.subject = function(user) {
	    return 'Confirm Your Email Address';
	  };

	  // A Function that takes a user object and a url, and returns the body text for the email.
	  // Note: if you need to return HTML instead, use Accounts.emailTemplates.verifyEmail.html
	  Accounts.emailTemplates.verifyEmail.text = function(user, url) {
	    return 'click on the following link to verify your email address: ' + url;
	  };

// });


Meteor.methods({
    sendSMTPEmail: function (mailFields) {
        check([mailFields.to, mailFields.subject, mailFields.text, mailFields.html], [String]);
        // Let other method calls from the same client start running,
        // without waiting for the email sending to complete.
        this.unblock();

        Email.send({
            to: mailFields.to,
            from: APPConfig.EmailFrom,
            subject: mailFields.subject,
            text: mailFields.text,
            html: mailFields.html
        });
    }
  });