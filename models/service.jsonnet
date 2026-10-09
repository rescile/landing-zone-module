local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = source.provider;
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

local compute_instances = ['test', 'dev'];
local database_instances = ['oracle'];
local kubernetes_cluster = ['test', 'dev'];

rescile.createResource(
  origin='account',
  createFrom=rescile.createFromProperty('service', asName='service'),
  resourceType='service',
  relationType='DEFINED_BY',
  name=std.asciiLower(provider.name)  + '-{{- value | lower -}}-service',
  properties={
    class: '{{- value | lower -}}',
    accounts: '{{ accounts }}',
    compute: compute_instances,
    kubernetes: kubernetes_cluster,
    database: database_instances,
    description: 'The {{ value | lower }} service provides access to a platform operated by {{ origin_resource.provider | lower }}.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
) + {
  accounts: '{{ [x.environment for x in origin_resource] | unique }}',
}
