local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiLower(std.join('-', std.slice(std.split(source.name, '-'), 0, 2)));

rescile.createResource(
  origin='network',
  createFrom=rescile.createFromProperty('subnet', asName='subnet'),
  resourceType='subnet',
  relationType='DERIVED_FROM',
  name= parent + '-subnet-{{- value | lower -}}',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    cidr: '{%- set count = origin_resource.subnet | length -%}' +
          '{%- set split_cidrs = origin_resource.segment | lib(path="network.rhai", function="cidr_split_n", n=count) -%}' +
          '{{ split_cidrs[property.index] }}',
    location: provider.region[source.location],
    availability_zone: '{{- value | lower -}}',
    description: 'Subnet {{ value | upper }} is a logical partition of the {{ params.solution | capitalize }} network, designed to improve network performance, routing efficiency, and security isolation.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
)
