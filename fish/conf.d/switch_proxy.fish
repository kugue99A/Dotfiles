set -g proxy 'http://proxy.nagaokaut.ac.jp:8080'
set _dns '133.44.62.201'
#set _dns '192.168.0.1'

set -gx http_proxy ''
set -gx https_proxy ''
set -gx ftp_proxy ''
set -gx all_proxy ''
set -gx no_proxy ''

function set_proxy
  set -gx http_proxy $proxy
  set -gx https_proxy $proxy
  set -gx ftp_proxy $proxy
  set -gx all_proxy $proxy
  set -gx no_proxy '.local,169.254/16,10.10.10.10,127.0.0.1'

  set -gx HTTP_PROXY $proxy
  set -gx HTTPS_PROXY $proxy
  set -gx FTP_PROXY $proxy
  set -gx ALL_PROXY $proxy
  set -gx NO_PROXY '.local,169.254/16,10.10.10.10,127.0.0.1'

  git config --global http.proxy $proxy
  git config --global https.proxy $proxy
  git config --global url."https://".insteadOf git://
end

function unset_proxy
  set -e http_proxy
  set -e https_proxy
  set -e ftp_proxy
  set -e all_proxy
  set -e no_proxy
  set -e HTTP_PROXY
  set -e HTTPS_PROXY
  set -e FTP_PROXY
  set -e ALL_PROXY
  set -e NO_PROXY

  git config --global --unset http.proxy
  git config --global --unset https.proxy
  git config --global --unset url."https://".insteadOf
end

if test -e /etc/resolv.conf
  grep $_dns /etc/resolv.conf | read _dns_state
else
  grep $_dnslan /etc/resolv.conf | read _dns_state
end

if test -n "$_dns_state"
  set_proxy
else
  unset_proxy
end
