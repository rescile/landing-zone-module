local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

[
  rescile.createResource(
    origin='dns',
    createFrom=rescile.createFromProperty('zone', asName='zone'),
    resourceType='zone',
    relationType='DERIVED_FROM',
    name='{{- value | lower -}}',
    properties={
      class: '{{- origin_resource.class | lower -}}',
      provider: std.asciiLower(provider.name),
      description: 'The {{ origin_resource.class | capitalize }} hosted DNS zone is an administrative namespace that a single entity manages, containing resource records that map domain names to IP addresses.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
  ),

  rescile.linkResources(
    origin='zone',
    withResource='subscription',
    relationType='DEPENDS_ON',
    copyProperties=[
      { from: 'account', as: 'record' },
    ],
    match=[rescile.eq('class', 'public')],
  ),

  rescile.linkResources(
    origin='zone',
    withResource='subscription',
    relationType='DEPENDS_ON',
    copyProperties=[
      { from: 'util', as: 'record' },
    ],
    match=[rescile.eq('name', 'management.local')],
  ),

  rescile.linkResources(
    origin='zone',
    withResource='resolver',
    relationType='SATISFIES',
  ),

  rescile.linkResources(
    origin='zone',
    withResource='account',
    relationType='DEPENDS_ON',
    copyProperties=[
      { from: 'service', as: 'record' },
    ],
    match=[rescile.eq('name', 'service.local')],
  )
]
