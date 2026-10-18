local aws = import 'aws.libsonnet';
local azure = import 'azure.libsonnet';
local empty = import 'empty.libsonnet';
local google = import 'google.libsonnet';
local incus = import 'incus.libsonnet';
local oci = import 'oci.libsonnet';

// Universal fallback trait guaranteeing getResource and decode exist everywhere
local baseProvider = {
  decode: {},
  getResource(key, default=''):: std.get(self.decode, key, if default != '' then default else key),
};

function(name)
  local rawProvider = (
    if name == 'aws' then aws
    else if name == 'azure' then azure
    else if name == 'oci' then oci
    else if name == 'google' then google
    else if name == 'incus' then incus
    else empty
  );

  // baseProvider provides the safe defaults; rawProvider overrides them if specific ones exist
  baseProvider + rawProvider
