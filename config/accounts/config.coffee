AccountsTemplates.configureRoute 'signIn',{layoutTemplate:'kimaPublicLayout'}
# AccountsTemplates.configureRoute 'signUp',{layoutTemplate:'customerLayout'}
# AccountsTemplates.configureRoute 'ensureSignedIn',{layoutTemplate:'customerLayout'}
AccountsTemplates.configureRoute 'forgotPwd',{layoutTemplate:'kimaPublicLayout'}
AccountsTemplates.configureRoute 'resetPwd',{layoutTemplate:'kimaPublicLayout'}
AccountsTemplates.configureRoute 'verifyEmail',{layoutTemplate:'kimaPublicLayout'}
AccountsTemplates.configureRoute 'enrollAccount',{layoutTemplate:'kimaPublicLayout'}
AccountsTemplates.configureRoute 'changePwd',{layoutTemplate:'kimaPublicLayout'}


mySubmitFunc=(err,state)->
	if(!err)
		if state=='signIn' and state=='resetPwd'
			# console.log 'signIn:',Meteor.user().profile.active
			if !Meteor.user().profile.active
				AccountsTemplates.logout()

AccountsTemplates.configure
	sendVerificationEmail:true
	showForgotPasswordLink:true
	enablePasswordChange:true
	# enforceEmailVerification:true
	forbidClientAccountCreation: true
	showForgotPasswordLink: true

	#onLogoutHook:
	onSubmitHook:mySubmitFunc

# mySubmitFunc=(error,state)->
# 	if(!error)
# 		if state==='signIn'
# 			#successfully logged in
# 		if state === "signUp"
# 			#successfully rigistered


