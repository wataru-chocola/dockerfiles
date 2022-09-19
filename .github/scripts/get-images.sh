#!/usr/bin/bash

changed_only=false

while getopts c-: opt; do
  [[ "$opt" = - ]] && opt="-$OPTARG"

  case "-$opt" in
    -c|--changed)
      changed_only=true
      ;;
    -\?)
      exit 1
      ;;
    --*)
      echo "$0: illegal option -- ${opt##-}" >&2
      exit 1
      ;;
  esac
done


declare -a images

for subdir in "."/*
do
  if [ ! -d "${subdir}" ]
  then
    continue
  fi

  image=$(basename ${subdir})

  if ${changed_only}; then
    changes=$(git diff origin/main...${GITHUB_SHA} --relative="${subdir}" --name-only) || exit 1
    if [ -z "$changes" ]; then
      continue
    fi
  fi

  if [ ! -f "${subdir}/Dockerfile" ]
  then
    continue
  fi

  # https://docs.docker.com/engine/reference/commandline/tag/
  # > Name components may contain lowercase letters, digits and separators.
  # > A separator is defined as a period, one or two underscores, or one or more dashes.
  # > A name component may not start or end with a separator.
  if [[ ${image} =~ ^([[:lower:][:digit:]])(([[:lower:][:digit:]]|[-_.])*([[:lower:][:digit:]]))?$ ]]
  then
    images+=("$image")
  fi
done

images_str=$(IFS=,; echo "${images[*]}")
echo "${images_str}"
