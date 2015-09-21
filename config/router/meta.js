if(Meteor.isClient) {
  Meta.config({
      options: {
        // Meteor.settings[Meteor.settings.environment].public.meta.title
        title: 'File Share Portal',
        suffix: 'Online Service'
      }
  });
}