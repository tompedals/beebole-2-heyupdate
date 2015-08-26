#!/bin/bash

# bbl2heyupdate.sh -- Post existing entries from http://beebole.com to http://heyupdate.com

day=${1:-$(date '+%Y-%m-%d')}
bbl_token=${BBL_TOKEN:-66767f3330876e1332axxxxxxxxxxxxac20fa3b6}
heyupdate_token=${HEYUPDATE_TOKEN:-d342d7e0478b9965da6xxxxxxxxxxxx0981bf3f6}

bbl_acct=${BBL_ACCT:-binary}

tmp=/tmp/beebole2heyupdate.$$; trap "rm -f $tmp" EXIT

read -r -d '' request <<REQUEST
{"service":"time_entry.list", "from":"$day", "to":"$day"}
REQUEST

read -r -d '' perl <<'PERL'
    use strict;
    use warnings;
    use Data::Dumper;
    use JSON;
    local $/;
    my $json = <> || die "no data received\n";
    my $data = eval { decode_json($json) } || die "bad json ($json): $@\n";
    $data->{status} && $data->{status} eq 'ok' || die "I can't go on after this: " . Dumper($data);
    my $entries = $data->{timeEntries} || [];
    die "no time-entries received\n" unless @$entries;
    my $str = '';
    for my $entry (@$entries) {
        my $task = $entry->{task} && $entry->{task}->{name} || '';
        my $hours = $entry->{hours} || '?';
        my $notes = $entry->{notes} || '';
        $str .= "- $task ($hours hrs) $notes\n";
    }
    for ($str) {
       s/"/'/g;
       s/\n/\\n/g;
    }
    print $str;
PERL

bbl_svr=$bbl_acct.beebole-apps.com/api
bbl_uri="https://$bbl_token:x@$bbl_svr"

curl -s -k -X POST "$bbl_uri" -d "$request" | perl -e "$perl" >$tmp

if [ ! -s $tmp ]; then
    echo Not posting to HeyUpdate.
    exit 1
fi

heyupdate_text=$(cat $tmp)
heyupdate_api=https://api.heyupdate.com
heyupdate_auth="Authorization: Bearer $heyupdate_token"
heyupdate_json="Content-Type: application/json"

read -r -d '' heyupdate_data <<HEYUPDATE_DATA
{"message":"$heyupdate_text", "timestamp": "$day"}
HEYUPDATE_DATA

curl -w "\n" -H "$heyupdate_json" -H "$heyupdate_auth" -w $nl -k -X POST "$heyupdate_api/updates" -d "$heyupdate_data"

echo -e "\ndone"

