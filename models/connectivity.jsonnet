local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='service',
  resourceType='connectivity',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name) + '-{{ params.solution | lower }}-' + provider.getResource('connectivity'),
  properties={
    class: '{{- origin_resource.class | lower -}}',
    login: ['connectivity-administrator', 'auditor'],
    description: 'The ' + provider.getResource('connectivity') + ' interface provided by ' + provider.name + ' is a wide area network service that provides a dedicated, private connections from on-premises to a colocation facility.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'connectivity')]
)
