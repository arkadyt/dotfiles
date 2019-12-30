### Progress notes
  Was able to setup dante proxy (check prev commits).
  A simple HTTP server would serve requests over private IP, from Europe, just fine.

  However neither standard q3 nor ioq3 support SOCKS protocol properly.
  Multiple mentions of this around the internet, no one have been able to get it working since 1999.
  This will need some work.

  Note: iD uses their own protocol for q3 that is supposedly compatible with SOCKS5.
