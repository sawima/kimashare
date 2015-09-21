AdminController = RouteController.extend({
  layoutTemplate: 'adminBoardLayout'
  // onAfterAction: function () {
  //   Meta.setTitle('Kima');
  // }
});

AdminController.events({
  'click [data-action=logout]' : function() {
    AccountsTemplates.logout();
    // Meteor.logout();
  }
});
