#!/bin/bash

# bbl2idt.sh -- Post existing entries from http://beebole.com to http://idonethis.com

day=${1:-$(date '+%Y-%m-%d')}
bbl_token=${2:-66767f3330876e1332axxxxxxxxxxxxac20fa3b6}
idt_token=${3:-d342d7e0478b9965da6xxxxxxxxxxxx0981bf3f6}

tmp=/tmp/beebole2idonethis.$$; trap "rm -f $tmp" EXIT

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

bbl_acc=binary
bbl_svr=$bbl_acc.beebole-apps.com/api
bbl_uri="https://$bbl_token:x@$bbl_svr"

curl -s -w "\n" -k -X POST "$bbl_uri" -d "$request" | perl -e "$perl" >$tmp

idt_text=$(cat $tmp)
idt_api=https://idonethis.com/api/v0.1
idt_auth="Authorization: Token $idt_token"
idt_team=it-development-team
idt_json="Content-Type: application/json"

read -r -d '' idt_data <<IDT_DATA
{"team":"$idt_team", "raw_text":"$idt_text", "done_date":"$day"}
IDT_DATA

curl -w "\n" -H "$idt_json" -H "$idt_auth" -w $nl -k -X POST "$idt_api/dones/" -d "$idt_data"
