local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

local instances = ['prod'];

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromList('instances'),
  resourceType='load_balancer',
  relationType='DEFINED_BY',
  name= std.asciiLower(provider.name) + '-{{ value | lower }}-' + provider.decode.load_balancer,
  properties={
    class: 'load_balancer',
    login: ['load_balancer-administrator', 'auditor'],
    component: ["self_managed", "provider_managed"],
    description: 'The ' + provider.decode.load_balancer + ' interface provided by ' + provider.name + ' is a wide area network service that provides a dedicated, private connections from on-premises to a colocation facility.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'load_balancer')],
) + {
  instances: instances,
}
