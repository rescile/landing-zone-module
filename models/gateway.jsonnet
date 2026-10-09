local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));

[
  rescile.createResource(
    origin='network',
    resourceType='gateway',
    relationType='DEFINED_BY',
    name=std.asciiLower(provider.name)  + '-{{ params.solution | lower }}-' + provider.decode.gateway,
    properties={
      class: '{{- origin_resource.class | lower -}}',
      description: 'The class: {{- origin_resource.class | lower -}} gateway is a network node that connects two different networks with dissimilar architectures and protocols so that data can flow between them.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
  ),
  rescile.createResource(
    origin='network',
    createFrom=rescile.createFromProperty('gateway', asName='gateway'),
    resourceType='gateway',
    relationType='DERIVED_FROM',
    name=std.asciiLower(provider.name)  + '-{{ params.solution | lower }}-{{ value }}_' + provider.decode.gateway,
    properties={
      class: '{{- origin_resource.class | lower -}}',
      description: 'The {{ value | lower }} gateway is a network node that connects two different networks with dissimilar architectures and protocols so that data can flow between them.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
  )
]
