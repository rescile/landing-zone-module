local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

local bgp = '172.16.0.1/30';


[
  rescile.createResource(
    origin='service',
    resourceType='router',
    relationType='DERIVED_FROM',
    name=std.asciiLower(provider.name)  + '-{{ params.solution | lower }}-' + std.get(provider.decode, 'router', ''),
    properties={
      class: '{{- origin_resource.class | lower -}}',
      provider: std.asciiLower(provider.name),
      bgp: bgp,
      description: 'The ' + provider.name + '{{ origin_resource.class | lower }} virtual ' + std.get(provider.decode, 'router', '') + ' analyzes incoming data packets, determines the best path for them to travel across interconnected networks, and forwards them toward their intended destination.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
    match=[rescile.eq('class', 'connectivity')]
  ),

  rescile.linkResources(
    origin='router',
    withResource='region',
    relationType='DERIVED_FROM',
  ),
]
