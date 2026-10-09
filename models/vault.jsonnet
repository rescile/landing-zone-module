local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

local resource_type = 'software'; // or hardware

rescile.createResource(
  origin='service',
  resourceType='vault',
  relationType='DEFINED_BY',
  name= std.asciiLower(provider.name) + '_' + resource_type + '-vault',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    login: ['vault-administrator', 'auditor'],
    key: std.asciiLower(provider.name)  + '-master-key',
    component: ["vault", "wallet", "certificate", "token", "secret", "key"],
    description: 'The ' + resource_type + ' vault is a secure, managed storage container or service at ' + provider.name + ' designed to safeguard sensitive digital assets.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'key_management')],
)
