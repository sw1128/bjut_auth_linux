#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <StudentID> <Password> <v4|v6|v46>"
  exit 1
fi

account="$1"
password="$2"
version="$3"

curl_base_command="curl -s \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6' \
  -H 'Cache-Control: max-age=0' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Origin: http://lgn.bjut.edu.cn' \
  -H 'Referer: http://lgn.bjut.edu.cn/' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: cross-site' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76' \
  -H 'sec-ch-ua: \"Chromium\";v=\"116\", \"Not)A;Brand\";v=\"24\", \"Microsoft Edge\";v=\"116\"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: \"Windows\"' --compressed"

if [ "$version" = "v4" ]; then
  curl_command="$curl_base_command \
    'https://lgn.bjut.edu.cn/' \
    --data-raw 'DDDDD=$account&upass=$password&v46s=1&v6ip=&f4serip=172.30.201.10&0MKKey='"
elif [ "$version" = "v6" ]; then
  curl_command="$curl_base_command \
    'https://lgn6.bjut.edu.cn/' \
    --data-raw 'DDDDD=$account&upass=$password&v46s=2&v6ip=&f4serip=172.30.201.2&0MKKey='"
elif [ "$version" = "v46" ]; then
  curl_command="$curl_base_command \
    'https://lgn6.bjut.edu.cn/V6?https://lgn.bjut.edu.cn' \
    --data-raw 'DDDDD=$account&upass=$password&v46s=0&v6ip=&f4serip=172.30.201.2&0MKKey='"
else
  echo "Invalid Parameter, Please use 'v4', 'v6' or 'v46'"
  exit 1
fi

output=$(eval "$curl_command" | iconv -f GBK -t UTF-8)

if [ "$version" = "v4" ] || [ "$version" = "v6" ]; then
  if [[ $output == *"登录成功窗"* ]]; then
    echo "ip$version Auth Successful!"
  else
    echo "ip$version Auth Failed!"
  fi
elif [ "$version" = "v46" ]; then
  v6ip_value=$(echo "$output" | grep -oP "(?<=name='v6ip' value=').*?(?='></FORM>)")
  if [ -n "$v6ip_value" ]; then
    echo "ipv6 Address: $v6ip_value"
    extra_curl_command="$curl_base_command \
      'https://lgn.bjut.edu.cn/' \
      --data-raw 'DDDDD=$account&upass=$password&0MKKey=Login&v6ip=$v6ip_value'"
    extra_output=$(eval "$extra_curl_command" | iconv -f GBK -t UTF-8)
    if [[ $extra_output == *"登录成功窗"* ]]; then
      echo "ipv4&ipv6 Auth Successful!"
    else
      echo "ipv4&ipv6 Auth Failed!"
    fi
  else
    echo "Couldn't connect to server!"
  fi
fi
