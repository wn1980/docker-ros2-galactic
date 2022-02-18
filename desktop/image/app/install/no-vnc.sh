#!/usr/bin/env bash

set -e

# install noVNC
export NO_VNC_HOME=/opt/noVNC

noVNC_VER=1.3.0
WEBSOCKIFY_VER=0.10.0

rm -Rf $NO_VNC_HOME && \
mkdir -p $NO_VNC_HOME/utils/websockify && \
wget -qO- https://github.com/novnc/noVNC/archive/v${noVNC_VER}.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME && \
wget -qO- https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VER}.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify

cat > "$NO_VNC_HOME/index.html" <<EOF
<html>
  <head>
    <script language="javascript" type="text/javascript">
     var url = '//' + document.location.hostname + ':' + document.location.port + '/vnc.html?resize=remote&autoconnect=1';
     window.location.assign(url);
     document.write('If redirection failed, please <a href=' + url + '>click here</a>.');
    </script>
  </head>
  <body></body>
</html>

EOF