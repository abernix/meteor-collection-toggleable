Package.describe({
  git: 'https://github.com/abernix/meteor-collection-toggleable.git',
  name: 'abernix:collection-toggleable',
  summary: 'Add toggleable to collections',
  version: '1.0.1'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');

  api.use([
    'check',
    'coffeescript',
    'underscore'
  ]);

  api.use([
    'matb33:collection-hooks@0.7.6',
    'zimme:collection-behaviours@1.0.3'
  ]);

  api.use([
    'aldeed:autoform@4.0.0 || 5.0.0',
    'aldeed:collection2@2.0.0',
    'aldeed:simple-schema@1.0.3'
  ], ['client', 'server'], {weak: true});

  api.imply('zimme:collection-behaviours');

  api.addFiles('toggleable.coffee');
});
