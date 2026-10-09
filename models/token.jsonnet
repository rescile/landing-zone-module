local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='wallet',
  createFrom=rescile.createFromProperty('token', asName='token'),
  resourceType='token',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name)  + '-{{- value | lower -}}-token',
  properties={
    class: '{{ value | lower }}',
    description: 'The {{ value | lower }} token is a secure digital pass issued by an authorization server after a user or application authenticates. It proves who you are and what resources you are allowed to access.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
