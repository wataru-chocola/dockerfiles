#!/bin/bash
#
# Pre start script for unbound
#

/usr/libexec/unbound-helper chroot_setup
/usr/libexec/unbound-helper root_trust_anchor_update