local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local class = std.asciiLower(source.class);

[
  rescile.createResource(
    id='dns-private',
    origin='service',
    resourceType='dns',
    relationType='BASELINE_TEMPLATE',
    name=std.asciiLower(provider.name)  + '-' + provider.decode.dns + '-private-service',
    properties={
      class: 'private',
      login: ['dns-administrator', 'auditor'],
      zone: ['management.local', 'observability.local', 'service.local'],
      description: 'The Domain Name Service by ' + provider.name + ' provides name to address resolution for internal applications.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
    match=[rescile.eq('class', 'dns')]
  ),

  rescile.createResource(
    id='dns-public',
    origin='service',
    resourceType='dns',
    relationType='BASELINE_TEMPLATE',
    name=std.asciiLower(provider.name)  + '-' + provider.decode.dns + '-public-service',
    properties={
      class: 'public',
      login: ['dns-administrator', 'auditor'],
      zone: ['mydomain.com'],
      description: 'The public Domain Name Service by ' + provider.name + ' provides name to address resolution for internet services.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
    match=[rescile.eq('class', 'dns')]
  ),
]
