local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromProperty('accounts', asName='wallet'),
  resourceType='wallet',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name)  + '-{{- params.solution | lower -}}-{{- value | lower -}}-wallet',
  properties={
    class: '{{- params.solution | lower -}}',
    token: provider.portfolio,
    secret: '{{ params.secrets }}',
    certificate: '{{ params.certificates }}',
    description: 'The {{ value }} vault is a secure, managed storage container or service at ' + provider.name + ' designed to safeguard sensitive digital assets.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'key_management')],
)
