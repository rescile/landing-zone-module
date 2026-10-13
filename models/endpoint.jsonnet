local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='network',
  createFrom=rescile.createFromProperty('endpoint', asName='endpoint'),
  resourceType='endpoint',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name)  + '-{{ value }}-enpoint',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    description: 'tbd',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
