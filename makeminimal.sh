get_packages_for_group () {
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
  done < <(yum group info core 2>/dev/null)
  echo "${result[@]}"
}

base=( $(get_packages_for_group 'base') )
core=( $(get_packages_for_group 'core') )

echo "BASE:"
for pkg in "${base[@]}"; do
  echo ${pkg}
done
echo -e "\n\n"

echo "CORE:"
for pkg in "${core[@]}"; do
  echo ${pkg}
done
