local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

[
  rescile.createResource(
    origin='zone',
    createFrom=rescile.createFromProperty('record', asName='record'),
    resourceType='record',
    relationType='DERIVED_FROM',
    name='{{- params.tenant | lower -}}--{{- value | lower -}}.{{- origin_resource.name | lower -}}',
    properties={
      class: '{{- value | lower -}}',
      record_type: "A",
      provider: std.asciiLower(provider.name),
      description: 'The DNS record (Domain Name System record) is a single instruction stored on a DNS authoritative name server that maps human-readable domain names for {{ origin_resource.name | lower }} to IP addresses.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    }
  )
]
