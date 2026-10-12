local rescile = import 'rescile/v1/rescile.libsonnet';
local source = std.extVar('origin_resource');
local parent = std.asciiUpper(std.join('-', std.slice(std.split(source.name, '-'), 0, 3)));

rescile.linkResources(
  origin='region',
  withResource='network',
  relationType='DEPENDS_ON',
  copyProperties=[
    { from: 'name', as: 'region' },
  ],
)
