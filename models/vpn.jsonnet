local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

local instances = ['dev','int','prod'];

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromList('instances'),
  resourceType='vpn',
  relationType='DEFINED_BY',
  name= std.asciiLower(provider.name) + '-{{ value | lower }}-' + provider.decode.vpn + '-connection',
  properties={
    class: 'vpn',
    login: ['vpn-administrator','auditor'],
    component: ["gateway"],
    description: 'A ' + provider.decode.vpn + ' instance provided by ' + provider.name + ' establishes an encrypted, secure connection—often referred to as a "tunnel"—over a public network. It encapsulates network packets and encrypts their payload, ensuring data privacy, integrity, and identity masking between endpoints.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'vpn')],
) + {
  instances: instances,
}
