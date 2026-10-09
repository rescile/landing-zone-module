local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='wallet',
  createFrom=rescile.createFromProperty('secret', asName='secret'),
  resourceType= 'secret',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name)  + '-{{ value | lower }}-secret',
  properties={
    class: '{{ value | lower }}',
    description: 'The {{ value | lower }} secret is a specialized, highly sensitive digital credential, used to authenticate applications, services, and non-human workloads to one another.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
