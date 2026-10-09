local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='service',
  resourceType='resolver',
  relationType='DEFINED_BY',
  name=std.asciiLower(provider.name)  + '-{{- origin_resource.class | lower -}}-resolver',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    description: 'The DNS resolver is a managed, authoritative name service that operates exclusively within the control plane of a cloud network.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'dns')]
)
