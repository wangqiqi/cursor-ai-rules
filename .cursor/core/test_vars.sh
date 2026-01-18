#!/bin/bash
echo "BASH_SOURCE[0]=${BASH_SOURCE[0]}"
echo "0=$0"
echo "条件判断结果: $([[ "${BASH_SOURCE[0]}" == "$0" ]] && echo "true" || echo "false")"
