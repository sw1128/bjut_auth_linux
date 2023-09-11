#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <StudentID> <Password>"
  exit 1
fi

studentId="$1"
studentPwd="$2"

url="http://10.21.221.98:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=${studentId}@campus&user_password=${studentPwd}"

response=$(curl -s "$url")

echo "Response: $response"
