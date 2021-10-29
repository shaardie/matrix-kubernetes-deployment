#/bin/bash

set -eu

for line in $(grep -vE "^#|^$" <<<"
# Sync requests
^/_matrix/client/(v2_alpha|r0)/sync$
^/_matrix/client/(api/v1|v2_alpha|r0)/events$
^/_matrix/client/(api/v1|r0)/initialSync$
^/_matrix/client/(api/v1|r0)/rooms/[^/]+/initialSync$

# Federation requests
^/_matrix/federation/v1/event/
^/_matrix/federation/v1/state/
^/_matrix/federation/v1/state_ids/
^/_matrix/federation/v1/backfill/
^/_matrix/federation/v1/get_missing_events/
^/_matrix/federation/v1/publicRooms
^/_matrix/federation/v1/query/
^/_matrix/federation/v1/make_join/
^/_matrix/federation/v1/make_leave/
^/_matrix/federation/v1/send_join/
^/_matrix/federation/v2/send_join/
^/_matrix/federation/v1/send_leave/
^/_matrix/federation/v2/send_leave/
^/_matrix/federation/v1/invite/
^/_matrix/federation/v2/invite/
^/_matrix/federation/v1/query_auth/
^/_matrix/federation/v1/event_auth/
^/_matrix/federation/v1/exchange_third_party_invite/
^/_matrix/federation/v1/user/devices/
^/_matrix/federation/v1/get_groups_publicised$
^/_matrix/key/v2/query
^/_matrix/federation/unstable/org.matrix.msc2946/spaces/
^/_matrix/federation/unstable/org.matrix.msc2946/hierarchy/

# Inbound federation transaction request
^/_matrix/federation/v1/send/

# Client API requests
^/_matrix/client/(api/v1|r0|unstable)/createRoom$
^/_matrix/client/(api/v1|r0|unstable)/publicRooms$
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/joined_members$
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/context/.*$
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/members$
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/state$
^/_matrix/client/unstable/org.matrix.msc2946/rooms/.*/spaces$
^/_matrix/client/unstable/org.matrix.msc2946/rooms/.*/hierarchy$
^/_matrix/client/unstable/im.nheko.summary/rooms/.*/summary$
^/_matrix/client/(api/v1|r0|unstable)/account/3pid$
^/_matrix/client/(api/v1|r0|unstable)/devices$
^/_matrix/client/(api/v1|r0|unstable)/keys/query$
^/_matrix/client/(api/v1|r0|unstable)/keys/changes$
^/_matrix/client/versions$
^/_matrix/client/(api/v1|r0|unstable)/voip/turnServer$
^/_matrix/client/(api/v1|r0|unstable)/joined_groups$
^/_matrix/client/(api/v1|r0|unstable)/publicised_groups$
^/_matrix/client/(api/v1|r0|unstable)/publicised_groups/
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/event/
^/_matrix/client/(api/v1|r0|unstable)/joined_rooms$
^/_matrix/client/(api/v1|r0|unstable)/search$

# Registration/login requests
^/_matrix/client/(api/v1|r0|unstable)/login$
^/_matrix/client/(r0|unstable)/register$
^/_matrix/client/unstable/org.matrix.msc3231/register/org.matrix.msc3231.login.registration_token/validity$

# Event sending requests
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/redact
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/send
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/state/
^/_matrix/client/(api/v1|r0|unstable)/rooms/.*/(join|invite|leave|ban|unban|kick)$
^/_matrix/client/(api/v1|r0|unstable)/join/
^/_matrix/client/(api/v1|r0|unstable)/profile/
"); do
  wo_prefix=${line#"^"}
  wo_suffix=${wo_prefix%"$"}
  echo "- path: \"$wo_suffix\"
  pathType: ImplementationSpecific
  backend:
    service:
      name: synapse-worker
      port:
        number: 80"
done