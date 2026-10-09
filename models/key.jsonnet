local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

rescile.createResource(
  origin='service',
  resourceType='key',
  relationType='PROTECTED_BY',
  name= std.asciiLower(provider.name) + '-master-key',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    login: ['vault-administrator', 'auditor'],
    description: 'The ' + provider.name + ' master or root key is a top-level symmetric cryptographic key that resides inside a hardware security module (HSM) and serves as the root of trust for data encryption.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'key_management')],
)
