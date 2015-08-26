beebole-2-heyupdate
===================

Post **beebole.com** entries to **heyupdate.com**
-----------------------------------------

This script will post existing task entries from the time-recording tool
[__BeeBole__](http://beebole.com "BeeBole Home Page")
to the workgroup notification tool
[__HeyUpdate__](http://heyupdate.com "HeyUpdate Home Page").

It uses the APIs of the respective products, described in the
[HeyUpdate API Documentation](http://help.heyupdate.com/integrations/api)
and the
[BeeBole API Documentation](http://beebole.com/api/).

Strategy
--------

To authenticate yourself to each API you will first need to find your personal authentication tokens.
For both services, login using your usual account, and then you'll find your tokens here:

- [http://beebole.com/api/#authentication](http://beebole.com/api/#authentication)
- HeyUpdate: Go to your User settings > Personal Access Tokens

In each case the token is a string that looks typically like this:

66767f3330876e1332ababa12345678ac20fa3b6

Cut-and-paste this and either set up environment variables as shown below or just patch the script.

Requirements
------------

- A valid account at __HeyUpdate__
- A valid account at __BeeBole__
- A Linux terminal window
- curl (you almost certainly have this)
- The Perl module JSON.  If you get error messages about this, install it with e.g. `cpan -i JSON`.

Instructions
------------

- Download [bbl2heyupdate.sh](../master/bbl2heyup.sh) and put it anywhere
- chmod +x bbl2heyupdate.sh
- Set up regular environment variables `BBL_TOKEN` and `HEYUPDATE_TOKEN` to the values you retrieved above.
- Set up regular environment variable `BBL_ACCT` for your __BeeBole__ company-level "account" name.
    The most convenient place to declare these is in your .profile or .bash_profile.  e.g.:


```bash
export BBL_TOKEN=66767f3330876e1332ababa12345678ac20fa3b6
export HEYUPDATE_TOKEN=aba12345678ac20fa3b666767f3330876e1332ab
export BBL_ACCT=arkey-malarkey
```

  After your next fresh login test that these are now available. e.g.:


```bash
echo BBL_TOKEN is $BBL_TOKEN, reading from company $BBL_ACCT
echo HEYUPDATE_TOKEN is $HEYUPDATE_TOKEN
```

- Alternatively, just hard-code your tokens as can be seen in the first few lines of the script.  It's not a sin.

Usage
-----

```
./bbl2heyupdate.sh [yyyy-mm-dd]
```

This will do the synch for the given date.  The date is optional and defaults to today.

Author
------

Frank Carnovale

http://binary.com

Modified for use with HeyUpdate by Tom Graham.
