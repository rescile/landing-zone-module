local aws = import 'aws.libsonnet';
local azure = import 'azure.libsonnet';
local empty = import 'empty.libsonnet';
local google = import 'google.libsonnet';
local incus = import 'incus.libsonnet';
local oci = import 'oci.libsonnet';

function(name)
  if name == 'aws' then aws
  else if name == 'azure' then azure
  else if name == 'oci' then oci
  else if name == 'google' then google
  else if name == 'incus' then incus
  else empty
