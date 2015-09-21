Router.configure({
  // controller: 'AppController',
  // layoutTemplate:"customerLayout",
  loadingTemplate: 'loading'
});

// Router.plugin('loading', {loadingTemplate: 'loading'});
Router.plugin('dataNotFound', {dataNotFoundTemplate: 'notFound'});
