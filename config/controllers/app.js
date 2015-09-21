AppController = RouteController.extend({
  // onAfterAction: function () {
  //   Meta.setTitle('File Share Portal');
  // }
});

AppController.events({
  'click [data-action=logout]' : function() {
    AccountsTemplates.logout();
    // Meteor.logout();
  }
});
