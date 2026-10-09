local rescile = import 'rescile/v1/rescile.libsonnet';
local providerLib = import 'provider.libsonnet';
local source = std.extVar('origin_resource');
local target = std.asciiLower(std.split(source.name, '-')[0]);
local providerName = if std.isArray(target) then target[0].name else target;
local provider = providerLib(std.asciiLower(providerName));
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.createResource(
  origin='service',
  createFrom=rescile.createFromProperty('database', asName='database'),
  resourceType='database',
  relationType='DERIVED_FROM',
  name=std.asciiLower(provider.name)  + '-' + provider.decode.database + '-{{- value | lower -}}-instance',
  properties={
    class: '{{- origin_resource.class | lower -}}',
    login: ['database-administrator', 'auditor'],
    component: ["RDBMS","Serverless","NoSQL","Memcached"],
    description: 'A ' + provider.decode.database + ' instance provided by ' + provider.name + ' is deployed, and accessed through a cloud computing environment. Instead of purchasing, installing, and maintaining physical database hardware in an on-premises data center, organizations run database workloads on public, private, or hybrid cloud platforms.',
    created: '{{- now(utc=true) | date(format="%Y-%m-%dT%H:%M:%SZ") -}}',
  },
  match=[rescile.eq('class', 'database')]
)
