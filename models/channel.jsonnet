local rescile = import 'rescile/v1/rescile.libsonnet';

[
  rescile.createResource(
    origin='role',
    createFrom=rescile.createFromProperty('channel', asName='channel'),
    resourceType='channel',
    relationType='DERIVED_FROM',
    name= '{{ value }}-channel',
    properties={
      class: '{{ value | lower }}',
      description: 'The {{ value | lower }} channel enables communication for operators.',
      created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
    },
  ),

  rescile.linkResources(
    origin='service',
    withResource='channel',
    relationType='DEPENDS_ON',
    match=[rescile.eq('class', 'iam')],
  ),
]
