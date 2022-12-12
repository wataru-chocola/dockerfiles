#!/bin/bash

[ "${OPTIMIZE_PERFORMANCE_SETTINGS}" = "1" ] || exit 0

set -u

CONFIG_FILE_PATH=/etc/unbound/unbound.conf.d/generated-performance.conf
BOUNDED_MEMORY_SIZE=$((12 * 1024 * 1024))

CGROUP_PATH=/sys/fs/cgroup

CGROUP_V1_MEMORY_LIMIT_PATH="${CGROUP_PATH%/}/memory/memory.limit_in_bytes"
CGROUP_V1_CPU_QUOTA_PATH="${CGROUP_PATH%/}/cpu/cpu.cfs_quota_us"
CGROUP_V1_CPU_PERIOD_PATH="${CGROUP_PATH%/}/cpu/cpu.cfs_period_us"

CGROUP_V2_MEMORY_MAX_PATH="${CGROUP_PATH%/}/memory.max"
CGROUP_V2_CPU_MAX_PATH="${CGROUP_PATH%/}/cpu.max"

function getLimitOfMemorySize() {
    # https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/6/html/resource_management_guide/sec-memory
    if [ -f "${CGROUP_V1_MEMORY_LIMIT_PATH}" ]; then
        cat "${CGROUP_V1_MEMORY_LIMIT_PATH}" || return 1
        return 0
    fi

    # https://facebookmicrosites.github.io/cgroup2/docs/memory-controller.html
    if [ -f "${CGROUP_V2_MEMORY_MAX_PATH}" ]; then
        cat "${CGROUP_V2_MEMORY_MAX_PATH}" || return 1
        return 0
    fi
}

function getMaxMemoryInBytes() {
    declare -i memorySize
    declare -i limitOfMemorySize

    limitOfMemorySize=$(getLimitOfMemorySize) || return 1
    memorySize=$((1024 * $( (grep MemAvailable /proc/meminfo || grep MemTotal /proc/meminfo) | sed 's/[^0-9]//g'))) || return 1

    if [ -n "${limitOfMemorySize}" ] && [ "${limitOfMemorySize}" -gt 0 ] && [ "${limitOfMemorySize}" -lt "${memorySize}" ]; then
        echo -n "${limitOfMemorySize}"
    else
        echo -n "${memorySize}"
    fi
    return 0
}

function getLimitOfCpuCores() {
    declare -i quota
    declare -i period
    declare -i numOfCores

    # https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/6/html/resource_management_guide/sec-cpu
    if [ -f "${CGROUP_V1_CPU_PERIOD_PATH}" ]; then
        if [ ! -f "${CGROUP_V1_CPU_QUOTA_PATH}" ]; then
            return 1
        fi

        quota=$(cat "${CGROUP_V1_CPU_QUOTA_PATH}") || return 1
        period=$(cat "${CGROUP_V1_CPU_PERIOD_PATH}") || return 1
        if [ "${quota}" -eq -1 ]; then
            numOfCores=$(nproc)
            echo -n "${numOfCores}"
            return 0
        fi

        numOfCores=$(("$quota" / "$period"))
        if [ $(("$quota" % "$period")) -gt 0 ]; then
            numOfCores=$(("$numOfCores" + 1))
        fi
        if [ "${numOfCores}" -lt 1 ]; then
            numOfCores=1
        fi
        echo -n "${numOfCores}"
        return 0
    fi

    # https://facebookmicrosites.github.io/cgroup2/docs/cpu-controller.html
    if [ -f "${CGROUP_V2_CPU_MAX_PATH}" ]; then
        declare cpu_max
        declare -a cpu_max_array

        cpu_max=$(cat "${CGROUP_V2_CPU_MAX_PATH}") || return 1
        IFS=" " read -r -a cpu_max_array <<<"${cpu_max}"
        if [ "${cpu_max_array[0]}" = "max" ]; then
            numOfCpus=$(nproc) || return 1
            echo -n "${numOfCores}"
            return 0
        fi

        quota="${cpu_max_array[0]}"
        period="${cpu_max_array[1]}"

        numOfCores=$(("$quota" / "$period"))
        if [ $(("$quota" % "$period")) -gt 0 ]; then
            numOfCores=$(("$numOfCores" + 1))
        fi
        if [ "${numOfCores}" -lt 1 ]; then
            numOfCores=1
        fi
        echo -n "${numOfCores}"
        return 0
    fi

    return 0
}

function getNumOfCpuCores() {
    declare -i numOfCores
    declare -i limitOfCores

    limitOfCores=$(getLimitOfCpuCores) || return 1
    numOfCores=$(nproc) || return 1
    if [ -n "${limitOfCores}" ] && [ "${limitOfCores}" -lt "${numOfCores}" ]; then
        echo -n "${limitOfCores}"
    else
        echo -n "${numOfCores}"
    fi
    return 0
}

function main() {
    declare -i numOfCpus
    numOfCpus=$(getNumOfCpuCores)
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to get the number of CPUs"
        exit 1
    fi
    echo "numOfCpus: ${numOfCpus}" >&2

    declare -i slabs=2
    declare -i c=1
    while [ $((2 ** c)) -lt "${numOfCpus}" ]; do
        c=$((c + 1))
        slabs=$((2 ** c))
    done
    echo "slabs: ${slabs}" >&2

    declare -i maxMemoryInBytes
    maxMemoryInBytes=$(getMaxMemoryInBytes)
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to get the size of memory"
        exit 1
    fi
    echo "memorySize: ${maxMemoryInBytes}"

    declare -i totalCacheSize
    declare -i rrset_cache_size
    declare -i msg_cache_size
    totalCacheSize=$(((maxMemoryInBytes - BOUNDED_MEMORY_SIZE) / 2))
    if [ "${totalCacheSize}" -le 0 ]; then
        echo "ERROR: Too small memory"
        exit 1
    fi
    rrset_cache_size=$((totalCacheSize * 2 / 3))
    msg_cache_size=$((totalCacheSize / 3))
    echo "rrset_cache_size: ${rrset_cache_size}" >&2
    echo "msg_cache_size: ${msg_cache_size}" >&2

    cat >"${CONFIG_FILE_PATH}" <<EOS
###########################################################################
# AUTO GENERATED PERFORMANCE SETTINGS
# ref: https://nlnetlabs.nl/documentation/unbound/howto-optimise/
###########################################################################
server:
    num-threads: ${numOfCpus}

    msg-cache-slabs: ${slabs}
    rrset-cache-slabs: ${slabs}
    infra-cache-slabs: ${slabs}
    key-cache-slabs: ${slabs}

    rrset-cache-size: ${rrset_cache_size}
    msg-cache-size: ${msg_cache_size}
EOS

    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create performance.conf"
        exit 1
    fi
    exit 0
}

main
