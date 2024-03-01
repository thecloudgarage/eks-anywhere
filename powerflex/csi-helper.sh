sed -i '/^ *\initContainers:/{
:sub;
  $b eof;
  N;
/^\( *\)[^ ].*\n\1[^ ][^\n]*$/!b sub;
:eof;
  s/^\( *\)[^ ].*\n\(\1[^ ][^\n]*\)$/\2/;
  t loop;
  d;
:loop; n; b loop;
}' dell-helm-charts/charts/csi-vxflexos/templates node.yaml
