local rescile = import 'rescile/v1/rescile.libsonnet';
local source = std.extVar('origin_resource');
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='subscription',
  createFrom=rescile.createFromProperty('region', asName='region'),
  resourceType='region',
  relationType='DEFINED_BY',
  name=parent +'-{{ locations[value | trim].city | upper | default(value="") }}',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    city: '{{ value | trim }}',
    country: '{{ locations[value | trim].country | default(value="") }}',
    timezone: '{{ locations[value | trim].tz | default(value="") }}',
    iata: '{{ locations[value | trim].iata | default(value="") }}',
    description: 'The {{ value }} cloud region is a distinct, isolated geographic area containing multiple physically separated and network-connected Availability Zones designed to provide high availability, fault tolerance, and low-latency infrastructure for cloud workloads.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
) + {
  locations: import 'location_codes.json',
}
