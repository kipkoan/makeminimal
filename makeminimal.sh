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

pkgs_needed=( $(printf '%s\n' $(pkgs 'core') $(pkgs 'base') | sort -u) )

deps_needed=()
for pkg in "${pkgs_needed[@]}"; do
  deps_needed+=( $(repoquery --requires --recursive --resolve --qf "%{NAME}" ${pkg}) )
done
deps_needed=( $(printf '%s\n' "${deps_needed[@]}" | sort -u) )

all_needed=( $(printf '%s\n' "${pkgs_needed[@]}" "${deps_needed[@]}" | sort -u) )
echo "Packages Needed:"
printf '%0.s*' $(seq 1 $(tput cols))
echo "${all_needed[@]}"

all_installed=( $(rpm -qa --qf "%{NAME}\n" | sort -u) )
echo -e "\n\n\nPackages Installed:"
printf '%0.s*' $(seq 1 $(tput cols))
echo "${all_installed[@]}"

delete=( $(comm -13 <(printf '%s\n' "${all_needed[@]}") <(printf '%s\n' "${all_installed[@]}")) )
echo -e "\n\n\nPackages to Delete:"
printf '%0.s*' $(seq 1 $(tput cols))
echo "${delete[@]}"

install=( $(comm -23 <(printf '%s\n' "${all_needed[@]}") <(printf '%s\n' "${all_installed[@]}")) )
echo -e "\n\n\nPackages to Install:"
printf '%0.s*' $(seq 1 $(tput cols))
echo "${delete[@]}"

#yum autoremove -y "${delete[@]}"
#yum install -y "${install[@]}"
