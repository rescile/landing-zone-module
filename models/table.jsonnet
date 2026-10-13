local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiLower(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='network',
  createFrom=rescile.createFromProperty('name', asName='route_table'),
  resourceType='route_table',
  relationType='DERIVED_FROM',
  name= parent + '-route_table',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    region: '{{ origin_resource.region }}',
    description: 'The route table contains a set of rules, called routes, that determines where network traffic is directed from subnets or gateways within a network.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
