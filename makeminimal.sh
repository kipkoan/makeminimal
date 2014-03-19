#!/usr/bin/env bash

pkgs () {
  group=${1}
  result=()
  section=0
  while read line; do
    if [[ $section -eq 0 ]]; then
      if [[ $line =~ "Mandatory Packages:" ]]; then
        section=1
      fi
      continue
    elif [[ $section -eq 1 ]]; then
      if [[ $line =~ "Default Packages:" ]]; then
        section=2
      else
        result+=($line)
      fi
      continue
    elif [[ $section -eq 2 ]]; then
      if [[ $line =~ "Optional Packages:" ]]; then
        break
      else
        result+=($line)
      fi
    fi
  done < <(yum group info ${group} 2>/dev/null)
  echo "${result[@]}"
}

core=( $(pkgs 'core') )
base=( $(pkgs 'base') )

#install_packages=( "${core[@]}" "${base[@]}" )
#printf '%s\n' "${core[@]}" "${base[@]}" | sort -u
printf '%s\n' $(pkgs 'core') $(pkgs 'base') | sort -u

#for pkg in "${install_packages[@]}"; do
#  echo ${pkg}
#done
