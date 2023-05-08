;--- Vincula Neo (v4.9.1)
;--- https://github.com/MSNLD/Vincula-Neo

;--- OCXless stuff
alias -l msn.binhash {
  bset &nonce 1 $msn.tobin($1-)
  return $+(:GKSSP\0EV,$chr(3),\0\0\0,$chr(3),\0\0\0,$msn.gunhex($hmac(&nonce, SRFMKSJANDRESKKC, md5, 1)))
}

;Feed text, returns ascii numbers
alias msn.tobin {
  var %l 1, %r
  while (%l <= $len($1)) {
    if ($mid($1,%l,1) == \) {
      inc %l
      if ($mid($1,%l,1) == 0) %r = %r 0
      elseif ($mid($1,%l,1) == t) %r = %r 9
      elseif ($mid($1,%l,1) == n) %r = %r 10
      elseif ($mid($1,%l,1) == r) %r = %r 13
      elseif ($mid($1,%l,1) == b) %r = %r 32
      elseif ($mid($1,%l,1) == c) %r = %r 44
      elseif ($mid($1,%l,1) == \) %r = %r 92
    }
    else %r = %r $asc($mid($1,%l,1))
    inc %l
  }
  return %r
}

;Feed hex, returns ascii numbers
alias msn.hex2bin {
  var %l 1, %r

  while (%l <= $len($1)) {
    %r = %r $base($mid($1,%l,2),16,10)
    inc %l 2
  }
  return %r
}

;--- Aliases
alias msn.sockwrite {
  sockwrite $1-
  if ($msn.ini(debug)) echo @debug sockwrite $1-
}

alias msndebug {
  if ($1 == on) { window @debug | msn.ini debug $true }
  else msn.ini -r debug
}

alias msn {
  if (($sock(msn.look.main) == $null) || ($sock(msn.look.comm) == $null)) {
    echo $color(info2) -at * Lookup servers resetting, please wait a moment and try again
    msn.lookcon
    return
  }

  if ($msn.ini(selpp) == $null) {
    if ($1 == -c) tokenize 32 -cg $2-
    elseif ($1 !isin -g -cg -gc) tokenize 32 -g $1-
  }

  var %x $1, %y $2, %g $false, %c $false, %s, %n

  if ($server == $null) %msnc.newcon = $cid
  else unset %msnc.newcon

  if ($1 == -g) {
    if ($len($remove($2,$chr(37) $+ $chr(35))) > 198) { echo $color(info2) -at * Couldn't join the room, the name is too long (must be 200 characters or less) | return }
    else {
      if ((%msnc.connick) || (%msnc.noask)) %n = %msnc.connick
      else %n = $msn.getnick(g)
      %x = $$2
      %y = $3
      %g = $true
    }
  }
  elseif ($1 == -c) {
    if ($len($remove($2,$chr(37) $+ $chr(35))) > 198) { echo $color(info2) -at * Couldn't join the room, the name is too long (must be 200 characters or less) | return }
    else {
      %n = $msn.getnick(p)
      %x = $$2
      %y = $3
      %c = $true
      if (($calc($msn.ppdata($msn.ini(selpp),updated) + ($msn.ini(autouptime) * 3600)) < $ctime) && ($msn.ini(autoup))) {
        %msnc.noask = $true
        %msnc.connick = %n
        %msnc.doconnect = msn -c $1-
        msn.getpp
        return
      }
    }
  }
  elseif (($1 == -cg) || ($1 == -gc)) {
    if ($len($remove($2,$chr(37) $+ $chr(35))) > 198) { echo $color(info2) -at * Couldn't join the room, the name is too long (must be 200 characters or less) | return }
    else {
      %n = $msn.getnick(g)
      %x = $$2
      %y = $3
      %g = $true
      %c = $true
    }
  }
  else {
    if ($len($remove($1,$chr(37) $+ $chr(35))) > 198) { echo $color(info2) -at * Couldn't join the room, the name is too long (must be 200 characters or less) | return }
    else {
      if ((%msnc.connick) || (%msnc.noask)) %n = %msnc.connick
      else %n = $msn.getnick(p)
      if (($calc($msn.ppdata($msn.ini(selpp),updated) + ($msn.ini(autouptime) * 3600)) < $ctime) && ($msn.ini(autoup))) {
        %msnc.noask = $true
        %msnc.connick = %n
        %msnc.doconnect = msn $1-
        msn.getpp
        return
      }
    }
  }

  if (?#* !iswm %x) %x = $+($chr(37),$chr(35),%x)

  if ($hget(msn.999)) hfree msn.999
  unset %msn*.999
  unset %msnc.*
  %msnc.jointime = $ticks
  %msnc.looktime = $ticks
  sockclose *.999

  if ($server == $null) %msnc.newcon = $cid
  else unset %msnc.newcon

  hmake msn.999 1
  if (%g) msn.set 999 guest %g
  if (%n) msn.set 999 nick %n
  msn.set 999 room $chr(37) $+ $chr(35) $+ $right($right(%x,-2),88)
  msn.set 999 fullroom %x
  msn.set 999 shortroom $left($chr(37) $+ $chr(35) $+ $right($right(%x,-2),88),60)
  if (%y) msn.set 999 pass %y
  msn.set 999 fname $msn.ini(font)
  msn.set 999 fcolor $msn.ini(fcolor)
  msn.set 999 fstyle $msn.ini(fstyle)
  msn.set 999 fscriptf $msn.ini(script)
  msn.set 999 fscript $gettok($msn.ini(script),$numtok($msn.ini(script),32),32)
  if ($msn.ini(frand)) msn.set 999 frand $msn.ini(frand)
  if ($msn.ini(decode)) msn.set 999 decode $msn.ini(decode)
  if ($msn.ini(encode)) msn.set 999 encode $msn.ini(encode)
  if ($msn.ini(docolor)) msn.set 999 docolor $true
  if ($msn.ini(hjoin)) msn.set 999 hjoin $msn.ini(hjoin)
  if ($msn.ini(hpart)) msn.set 999 hpart $msn.ini(hpart)
  if ($msn.ini(hkick)) msn.set 999 hkick $msn.ini(hkick)

  unset %msn*.999
  sockclose msn*.999

  if (%y) %msnp.qkey. [ $+ [ $right($msn.get(999,room),-2) ] ] = %y

  if ((!%g) && (!%c)) msn.recent msn $right(%x,-2)
  elseif ((%g) && (!%c)) msn.recent msn -g $right(%x,-2)
  elseif ((!%g) && (%c)) msn.recent msn -c $right(%x,-2)
  elseif ((%g) && (%c)) msn.recent msn -cg $right(%x,-2)

  if (!%c) sockwrite -tn msn.look.main FINDS %x
  else sockwrite -tn msn.look.comm FINDS %x
}

alias clone {
  if (($sock(msn.look.main) == $null) || ($sock(msn.look.comm) == $null)) {
    echo $color(info2) -at * Lookup servers resetting, please wait a moment and try again
    msn.lookcon
    return
  }

  var %x $1, %y $2, %g $false, %c $false, %s, %n

  %g = $msn.get($cid,guest)
  %x = $msn.get($cid,fullroom)

  if ($1 == -c) {
    %n = $2
    %y = $3
    %c = $true
    if (($calc($msn.ppdata($msn.ini(selpp),updated) + ($msn.ini(autouptime) * 3600)) < $ctime) && ($msn.ini(autoup)) && (!%g)) {
      %msnc.doconnect = clone $1-
      msn.getpp
      return
    }
  }
  else {
    %n = $1
    %y = $2
    if (($calc($msn.ppdata($msn.ini(selpp),updated) + ($msn.ini(autouptime) * 3600)) < $ctime) && ($msn.ini(autoup)) && (!%g)) {
      %msnc.doconnect = clone $1-
      msn.getpp
      return
    }
  }

  if ($hget(msn.999)) hfree msn.999
  unset %msn*.999
  unset %msnc.*
  %msnc.jointime = $ticks
  %msnc.looktime = $ticks
  sockclose *.999

  hmake msn.999 1
  if (%g) msn.set 999 guest %g
  if (%n) msn.set 999 nick %n
  msn.set 999 room $chr(37) $+ $chr(35) $+ $right($right(%x,-2),88)
  msn.set 999 fullroom %x
  msn.set 999 shortroom $left($chr(37) $+ $chr(35) $+ $right($right(%x,-2),88),60)
  if (%y) msn.set 999 pass %y
  msn.set 999 fname $msn.ini(font)
  msn.set 999 fcolor $msn.ini(fcolor)
  msn.set 999 fstyle $msn.ini(fstyle)
  msn.set 999 fscriptf $msn.ini(script)
  msn.set 999 fscript $gettok($msn.ini(script),$numtok($msn.ini(script),32),32)
  if ($msn.ini(frand)) msn.set 999 frand $msn.ini(frand)
  if ($msn.ini(decode)) msn.set 999 decode $msn.ini(decode)
  if ($msn.ini(encode)) msn.set 999 encode $msn.ini(encode)
  if ($msn.ini(hjoin)) msn.set 999 hjoin $msn.ini(hjoin)
  if ($msn.ini(hpart)) msn.set 999 hpart $msn.ini(hpart)
  if ($msn.ini(hkick)) msn.set 999 hkick $msn.ini(hkick)

  disconnect
  %msnc.newcon = $cid

  if (%y) %msnp.qkey. [ $+ [ $right($msn.get(999,room),-2) ] ] = %y

  if (!%c) sockwrite -tn msn.look.main FINDS %x
  else sockwrite -tn msn.look.comm FINDS %x
}

; msn.ipjoin $cid roomip $me $msn.get(%s,fullroom)
alias msn.ipjoin {
  if ($4) var %c = $1, %ip = $2, %n = $3, %g, %x = $$4
  else var %ip = $1, %n = $2, %g, %x = $$3
  if (>* iswm %n) %g = $true

  if ($hget(msn.999)) hfree msn.999
  unset %msn*.999
  unset %msnc.*
  %msnc.jointime = $ticks
  sockclose *.999

  hmake msn.999 1
  if (%g) msn.set 999 guest %g
  if (%n) msn.set 999 nick %n
  msn.set 999 room $chr(37) $+ $chr(35) $+ $right($right(%x,-2),88)
  msn.set 999 fullroom %x
  msn.set 999 shortroom $left($chr(37) $+ $chr(35) $+ $right($right(%x,-2),88),60)
  if (%y) msn.set 999 pass %y
  msn.set 999 fname $msn.ini(font)
  msn.set 999 fcolor $msn.ini(fcolor)
  msn.set 999 fstyle $msn.ini(fstyle)
  msn.set 999 fscriptf $msn.ini(script)
  msn.set 999 fscript $gettok($msn.ini(script),$numtok($msn.ini(script),32),32)
  if ($msn.ini(frand)) msn.set 999 frand $msn.ini(frand)
  if ($msn.ini(decode)) msn.set 999 decode $msn.ini(decode)
  if ($msn.ini(encode)) msn.set 999 encode $msn.ini(encode)
  if ($msn.ini(docolor)) msn.set 999 docolor $true
  if ($msn.ini(hjoin)) msn.set 999 hjoin $msn.ini(hjoin)
  if ($msn.ini(hpart)) msn.set 999 hpart $msn.ini(hpart)
  if ($msn.ini(hkick)) msn.set 999 hkick $msn.ini(hkick)

  unset %msn*.999
  sockclose msn*.999

  if (%c) %msnc.newcon = %c
  else unset %msnc.newcon

  socklisten msn.mirc.in $rand(10000,30000)
  if (%msnc.newcon) scid %msnc.newcon server 127.0.0.1 $sock(msn.mirc.in).port
  else server -m 127.0.0.1 $sock(msn.mirc.in).port
  sockopen msn.server.999 %ip 6667
  ;var %port = $rand(2000,9000)
  ;while (!$portfree(%port)) inc %port
  ;socklisten msn.client.rmc %port
}

alias join {
  if ((!$server) || (($msn.get($cid,fullroom) != $1) && ($sock(msn.server. $+ $cid)))) msn $1-
  else join $1-
}

alias joinhex {
  if (($1 == -g) || ($1 == -c) || ($1 == -cg) || ($1 == -gc)) msn $1 $msn.unhex($2) $3
  else msn $msn.unhex($1) $2
}

alias joins {
  if ($msn.decode($1-) == $1-) tokenize 32 $msn.encode($1-)
  if ($1 == -k) msn $replace($3-,$chr(32),\b) $2
  elseif (($1 == -g) || ($1 == -c) || ($1 == -cg) || ($1 == -gc)) msn $1 $replace($2-,$chr(32),\b,$chr(44),\c)
  elseif (($1 == -gk) || ($1 == -kg)) msn -c $replace($3-,$chr(32),\b,$chr(44),\c) $2
  elseif (($1 == -ck) || ($1 == -kc)) msn -c $replace($3-,$chr(32),\b,$chr(44),\c) $2
  elseif ((-??? iswm $1) && (c isin $1) && (g isin $1) && (k isin $1)) msn -cg $replace($3-,$chr(32),\b,$chr(44),\c) $2
  else msn $replace($1-,$chr(32),\b,$chr(44),\c)
}

alias joinurl {
  if (($1 == -g) || ($1 == -c) || ($1 == -cg) || ($1 == -gc)) {
    var %x = $replace($msn.urldecode($2-),$chr(32),\b)
    if (rhx= isin $gettok(%x,2-,63)) joinhex $1 $remove($wildtok($gettok(%x,2-,63),rhx=*,1,38),rhx=) $3
    elseif (rm= isin $gettok(%x,2-,63)) msn $1 $remove($wildtok($gettok(%x,2-,63),rm=*,1,38),rm=) $3
    else echo $color(info) -ta * Couldn't find a room name in the URL
  }
  else {
    var %x = $replace($msn.urldecode($1-),$chr(32),\b)
    if ($isid) {
      if (rhx= isin $gettok(%x,2-,63)) return $remove($wildtok($gettok(%x,2-,63),rhx=*,1,38),rhx=)
      elseif (rm= isin $gettok(%x,2-,63)) return $msn.tohex($remove($wildtok($gettok(%x,2-,63),rm=*,1,38),rm=))
    }
    else {
      if (rhx= isin $gettok(%x,2-,63)) joinhex $remove($wildtok($gettok(%x,2-,63),rhx=*,1,38),rhx=) $2
      elseif (rm= isin $gettok(%x,2-,63)) msn $remove($wildtok($gettok(%x,2-,63),rm=*,1,38),rm=) $2
      else echo $color(info) -ta * Couldn't find a room name in the URL
    }
  }
}

alias hop {
  if ($window($msn.get($cid,room))) sockwrite -tn msn.server. $+ $cid PART $msn.get($cid,fullroom)
  if ($msn.ini(usepass)) var %p = $msn.roompass($msn.get($cid,room))
  sockwrite -tn msn.server. $+ $cid JOIN $msn.get($cid,fullroom) %p
}

alias find {
  if (!$1) dialog -m msn.faf msn.faf
  else {
    %msnc.findnick = $1-
    sockwrite -tn msn.look.main FINDU $1-
  }
}

alias msndecode {
  if ($1 == on) msn.set $cid decode $true
  else msn.unset $cid decode
  echo $color(info2) -ta * MSN Decode is now $iif($msn.get($cid,decode),on,off)
}

alias msnencode {
  if ($1 == on) msn.set $cid encode $true
  else msn.unset $cid encode
  echo $color(info2) -ta * MSN Encode is now $iif($msn.get($cid,encode),on,off)
}

alias msncolor {
  if ($1 == on) msn.set $cid docolor $true
  else msn.unset $cid docolor
  echo $color(info2) -ta * MSN Colorizing is now $iif($msn.get($cid,docolor),on,off)
}

alias msncolour msncolor $1-

alias msn.recent {
  if ($isid) {
    if ($2 == 1) {
      if (-g == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) {
        if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,3,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,3,32),60) (guest)
        else return $$gettok(%msnr. [ $+ [ $1 ] ] ,3,32) (guest)
      }
      elseif (-c == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) {
        if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,3,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,3,32),60) (groups)
        else return $$gettok(%msnr. [ $+ [ $1 ] ] ,3,32) (groups)
      }
      elseif ((-cg == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) || (-gc == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32))) {
        if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,3,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,3,32),60) (groups, guest)
        else return $$gettok(%msnr. [ $+ [ $1 ] ] ,3,32) (groups, guest)
      }
      else {
        if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,2,32),60) (normal)
        else return $$gettok(%msnr. [ $+ [ $1 ] ] ,2,32) (normal)
      }
    }
    else return %msnr. [ $+ [ $1 ] ]
  }
  else {
    var %l 1, %i 9, %o 10
    while (%l <= 10) {
      if (%msnr. [ $+ [ %l ] ] == $1-) {
        %i = $calc(%l - 1)
        %o = %l
      }
      inc %l
    }
    while (%i >= 1) {
      %msnr. [ $+ [ %o ] ] = %msnr. [ $+ [ %i ] ]
      dec %i
      dec %o
    }
    %msnr.1 = $1-
  }
}

;--- Delete for release
alias msn.rgkp {
  if (($1 == off) || ($1 == $null)) msn.ini -r unban
  else msn.ini unban $true
  echo $color(info2) -ta * Random GateKeeperPassport mode is now $iif($msn.ini(unban),on,off)
}
;----

alias msn.set {
  if (msn.*.* iswm $1) hadd msn. $+ $gettok($$1,3,46) $$2-
  else hadd msn. $+ $$1 $$2-
}

alias msn.unset {
  if (msn.*.* iswm $1) hdel msn. $+ $gettok($$1,3,46) $$2
  else hdel msn. $+ $$1 $$2
}

alias msn.clear {
  if ((msn.*.* iswm $1) && ($hget(msn. $+ $gettok($1,3,46)))) hfree msn. $+ $gettok($1,3,46)
  elseif ($hget(msn. $+ $1)) hfree msn. $+ $$1
}

alias msn.ren {
  if ($hget(msn.999) != $null) {
    var %old, %new, %l 1

    if (msn.*.* iswm $1) %old = $gettok($1,3,46)
    else %old = $1

    if (msn.*.* iswm $2) %new = $gettok($2,3,46)
    else %new = $2

    if ($hget(msn. $+ %new)) hfree msn. $+ %new
    hsave -o msn. $+ %old temp $+ %old $+ .txt
    hmake msn. $+ %new 1
    hload msn. $+ %new temp $+ %old $+ .txt
    hfree msn. $+ %old
    .remove temp $+ %old $+ .txt

    sockrename msn.server. $+ %old msn.server. $+ %new
    sockrename msn.mirc. $+ %old msn.mirc. $+ %new
    scid %new .timer.noop. $+ %new -o 0 100 msn.noop %new
  }
}

alias msn.noop {
  if (($scid($1)) && ($sock(msn.server. $+ $1))) sockwrite -tn msn.server. $+ $1 NOOP
  else .timer.noop. $+ $1 off
}

alias msn.geturl {
  if ($chr(37) $+ $chr(35) $+ * !iswm $1-) {
    if ($1 == h) var %x http://chat.msn.com/chatroom.msnw?rhx= $+ $msn.tohex($msn.get($cid,fullroom))
    else var %x http://chat.msn.com/chatroom.msnw?rm= $+ $right($msn.get($cid,fullroom),-2)
  }
  else {
    if ($2 == h) var %x http://chat.msn.com/chatroom.msnw?rhx= $+ $msn.tohex($1)
    else var %x http://chat.msn.com/chatroom.msnw?rm= $+ $right($1,-2)
  }
  var %x = $replace(%x,\b,$chr(37) $+ 20)
  if ($isid) return %x
  echo $color(info2) -t * Room URL: %x
  clipboard %x
}

alias msn.getpass {
  var %o Owner key is unknown, %h Host key is unknown
  if ($msn.ownerkey($1)) %o = Owner: $msn.ownerkey($1)
  if ($msn.hostkey($1)) %h = Host: $msn.hostkey($1)
  echo $color(info2) -t $1 * Last stored keys: %o / %h
}

alias pass {
  if ($1) mode $me +h $1-
  else mode $me +h $$input(Enter a password:,130,Password Entry)
}

alias msn.enchash {
  var %in                                                                                                                                                                                                                                                      
  var %out € ‚ ƒ „ … † ‡ ˆ ‰ Š ‹ Œ Ž ‘ ’ “ ” • – — ˜ ™ š › œ ž Ÿ   ¡ ¢ £ ¤ ¥ ¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿ À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ
  var %l 1
  if ($hget(msn.enc)) hfree msn.enc
  hmake msn.enc 13
  while (%l <= 123) {
    hadd msn.enc $gettok(%in,%l,32) $gettok(%out,%l,32)
    inc %l
  }
}

alias msn.vver return 4.9.1

alias msn.getpp {
  if ($timer(.msn.agpp) >= 1) {
    echo $color(info2) -atq * Please wait until the Passport Updater is finished before trying to update again
    return
  }
  if ($msn.ini(selpp) == $null) {
    echo $color(info2) -atq * You must have a passport selected in order to update it!
    return
  }
  var %p
  if (%msnpp.passwd == $null) %p = $$input(Please enter the password for the %msnpp.email passport:,130,Enter Password)
  else %p = %msnpp.passwd
  if ($show) msn.dogetpp $msn.ini(selpp) %msnpp.email %p
  else .msn.dogetpp $msn.ini(selpp) %msnpp.email %p
}

alias msnchat.update msn.getpp

alias msn.update {
  if ($1- == $null) msn.getpp
  else {
    var %n, %e, %p
    if ($1 == -p) {
      %n = $replace($gettok($2-,1- $+ $calc($numtok($2-,32) - 1),32),$chr(32),$chr(160))
      %p = $gettok($2-,$numtok($2-,32),32)
    }
    else {
      %n = $replace($1-,$chr(32),$chr(160))
      if ($msn.ppdata(%n,passwd) == $null) %p = $$input(Please enter the password for the %e passport:,130,Enter Password)
      else %p = $msn.ppdata(%n,passwd)
    }
    %e = $msn.ppdata(%n,email)
    if (%e == $null) {
      echo $color(info2) -at * Can't update because Vincula doesn't know the " $+ %n $+ " passport
      return
    }

    msn.dogetpp %n %e %p
  }
}

;msn.dogetpp passport email password
alias msn.dogetpp {
  %msnpp.lotime = $ticks
  %msnpp.loupdate = $1
  %msnpp.lourl = https://loginnet.passport.com/ppsecure/post.srf?id=2260&ru=http%3A%2F%2Fchat%2Emsn%2Ecom%2Fchatroom%2Emsnw%3Frm%3DTheLobby&login= $+ $replace($2,@,$chr(37) $+ 40) $+ &passwd= $+ $3
  echo $color(info2) -atq * Updating the " $+ %msnpp.loupdate $+ " passport, please wait...
  if ($window(@VinculaPPU)) window -c @VinculaPPU
  window -ph @VinculaPPU
  var %s $msn.ndll(attach,$window(@VinculaPPU).hwnd)
  %s = $msn.ndll(handler,msn.hnd.getpp)
  ;if ($findfile($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\\Cookies),*passport*.txt,1)) %s = $msn.ndll(navigate,%msnpp.lourl)
  ;elseif ($findfile($msn.registry(HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\\Directory),*passport*.txt,1)) 
  %s = $msn.ndll(navigate,http://login.passport.com/login.srf)
  %s = $msn.ndll(navigate,%msnpp.lourl)
}

alias msn.doconnect %msnc.doconnect

alias msn.hnd.getpp {
  var %s
  if (($2 == status_change) && (Start*https://*silent.srf* iswm $3-)) {
    %s = $msn.ndll(navigate,%msnpp.lourl)
    return S_CANCEL
  }
  elseif (navigate_begin == $2) {
    if ($msn.ini(ppinfo) iswm $3-) {
      var %pt $right($wildtok($3,t=*,1,38),-2), %pp $right($wildtok($3,p=*,1,38),-2)
      writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate ticket %pt
      writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate profile %pp
      writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate updated $ctime
      if (%msnpp.loupdate == $msn.ini(selpp)) {
        %msnpp.ticket = %pt
        %msnpp.profile = %pp
      }
      echo $color(info2) -at * Passport info for " $+ %msnpp.loupdate $+ " is now updated ( $+ $calc(($ticks - %msnpp.lotime) / 1000) seconds)
      unset %msnpp.loupdate
      unset %msnpp.lotime
      unset %msnpp.lourl
      %s = $msn.ndll(navigate,http://login.passport.com/logout.srf?id=2260)
      .timer 1 1 msn.doconnect
      return S_CANCEL
    }
    elseif ($msn.ini(errcod) iswm $3-) {
      var %r
      .timer 1 0 window -c @VinculaPPU
      if (http://*ec=e5a* iswm $3) %r = you gave the wrong password
      elseif (http://*ec=e5b* iswm $3) %r = the e-mail address is not registered as a passport
      elseif (http://*ec=e5d* iswm $3) %r = the e-mail address is invalid
      elseif (http://*ec=e5e* iswm $3) %r = it's missing part of the e-mail
      elseif (http://*ec=e1* iswm $3) %r = you didn't give the whole e-mail or password
      elseif (http://*ec=e2* iswm $3) %r = you didn't give the e-mail address for passport
      elseif (http://*ec=e3* iswm $3) %r = you didn't give the password for the passport
      else %r = of a reason unknown to Vincula
      echo $color(info2) -at * Passport update for " $+ %msnpp.loupdate $+ " failed because %r ( $+ $calc(($ticks - %msnpp.lotime) / 1000) seconds)
      unset %msnpp.loupdate
      unset %msnpp.lotime
      unset %msnc.*
      return S_CANCEL
    }
    elseif ($msn.ini(switch) iswm $3-) {
      %s = $msn.ndll(navigate,http://login.passport.com/logout.srf?id=486)
      return S_CANCEL
    }
    elseif ($msn.ini(cookie) iswm $3-) {
      %s = $msn.ndll(navigate,http://login.passport.com/login.srf)
      return S_CANCEL
    }
    elseif ($msn.ini(login1) iswm $3-) {
      %s = $msn.ndll(navigate,%msnpp.lourl)
      return S_CANCEL
    }
    elseif ($msn.ini(lgout3) iswm $3-) {
      .timer 1 0 window -c @VinculaPPU
      return S_CANCEL
    }
  }
  elseif (navigate_complete == $2) {
    if ($msn.ini(lgout1) iswm $3) {
      %s = $msn.ndll(navigate,%msnpp.lourl)
      return S_CANCEL
    }
  }
  return S_OK
}

alias msn.mgetpp {
  if ($timer(.msn.agpp) >= 1) {
    echo $color(info2) -at * Please wait until the Passport Updater is finished before trying to update again
    return
  }
  if ($msn.ini(selpp) == $null) {
    echo $color(info2) -at * You must have a passport selected in order to update it!
    return
  }
  %msnpp.loupdate = $msn.ini(selpp)
  msn.doppupdate " $+ $$sfile($scriptdir $+ *.*,Choose a file that contains your passport information) $+ "
}

alias msn.doppupdate {
  var %f = $1-, %sp, %ep, %uc, %ut, %up, %p 1

  bread -t %f %p 2000 &r
  while ($bfind(&r,1,MSNREGCookie) == 0) {
    inc %p $calc($bvar(&r,0) + 2)
    bread -t %f %p 2000 &r
    if (%p > $file(%f).size) goto notfound
  }
  %sp = $calc($bfind(&r,1,MSNREGCookie) + 22)
  %ep = $calc($bfind(&r,%sp,34) - %sp)
  %uc = $bvar(&r,%sp,%ep).text

  %sp = $calc($bfind(&r,1,PassportTicket) + 23)
  %ep = $calc($bfind(&r,%sp,34) - %sp)
  %ut = $bvar(&r,%sp,%ep).text

  %sp = $calc($bfind(&r,1,PassportProfile) + 24)
  %ep = $calc($bfind(&r,%sp,34) - %sp)
  %up = $bvar(&r,%sp,%ep).text

  if ((%uc != $null) && (%ut != $null) && (%up != $null)) { goto found }
  :notfound
  echo $color(info2) -at * Passport information was not found or was incomplete in the file $nopath(%f) $+ !
  return

  :found
  if (%msnpp.loupdate == $msn.ini(selpp)) {
    %msnpp.cookie = %uc
    %msnpp.ticket = %ut
    %msnpp.profile = %up
  }
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate cookie %uc
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate ticket %ut
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate profile %up
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate updated $ctime

  echo $color(info2) -at * Passport information was found in the file $nopath(%f)
  unset %msnpp.lo*
}

alias msn.getcookie {
  if ($timer(.msn.agpp) >= 1) {
    echo $color(info2) -atq * Please wait until the Passport Updater is finished before trying to update again
    return
  }
  if ($msn.ini(selpp) == $null) {
    echo $color(info2) -atq * You must have a passport selected in order to update it!
    return
  }
  var %p
  if (%msnpp.passwd == $null) %p = $$input(Please enter the password for the %msnpp.email passport:,130,Enter Password)
  else %p = %msnpp.passwd
  if ($show) msn.dogetcookie $msn.ini(selpp) %msnpp.email %p
  else .msn.dogetcookie $msn.ini(selpp) %msnpp.email %p
}

alias msn.dogetcookie {
  %msnpp.lotime = $ticks
  %msnpp.loupdate = $1
  %msnpp.lourl = https://loginnet.passport.com/ppsecure/post.srf?id=2260&ru=http%3A%2F%2Fchat%2Emsn%2Ecom%2Fchatroom%2Emsnw%3Frm%3DTheLobby&login= $+ $replace($2,@,$chr(37) $+ 40) $+ &passwd= $+ $3
  echo $color(info2) -atq * Updating the " $+ %msnpp.loupdate $+ " passport, please wait...
  ;var %s = $findfile($msn.registry(HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\\Directory),*chatroom_ui*.msnw*,0,.remove " $+ $1- $+ ")
  %msnpp.lofiletime = $ctime
  if ($window(@VinculaPPU)) window -c @VinculaPPU
  window -ph @VinculaPPU
  var %s = $msn.ndll(attach,$window(@VinculaPPU).hwnd)
  %s = $msn.ndll(handler,msn.hnd.cookie)
  %s = $msn.ndll(navigate,%msnpp.lourl)
}

alias msn.hnd.cookie {
  var %s
  if ($2 == status_change) {
    if (Start*https://*silent.srf* iswm $3-) {
      %s = $msn.ndll(navigate,%msnpp.lourl)
      return S_CANCEL
    }
  }
  elseif (navigate_begin == $2) {
    if ($msn.ini(errcod) iswm $3-) {
      var %r
      .timer 1 0 window -c @VinculaPPU
      if (http://*ec=e5a* iswm $3) %r = you gave the wrong password
      elseif (http://*ec=e5b* iswm $3) %r = the e-mail address is not registered as a passport
      elseif (http://*ec=e5d* iswm $3) %r = the e-mail address is invalid
      elseif (http://*ec=e5e* iswm $3) %r = it's missing part of the e-mail
      elseif (http://*ec=e1* iswm $3) %r = you didn't give the whole e-mail or password
      elseif (http://*ec=e2* iswm $3) %r = you didn't give the e-mail address for passport
      elseif (http://*ec=e3* iswm $3) %r = you didn't give the password for the passport
      else %r = of a reason unknown to Vincula
      echo $color(info2) -at * Passport update for " $+ %msnpp.loupdate $+ " failed because %r ( $+ $calc(($ticks - %msnpp.lotime) / 1000) seconds)
      unset %msnpp.loupdate
      unset %msnpp.lotime
      unset %msnc.*
      return S_CANCEL
    }
    elseif ($msn.ini(switch) iswm $3-) {
      %s = $msn.ndll(navigate,http://login.passport.com/logout.srf?id=486)
      return S_CANCEL
    }
    elseif ($msn.ini(cookie) iswm $3-) {
      %s = $msn.ndll(navigate,http://login.passport.com/login.srf)
      return S_CANCEL
    }
    elseif ($msn.ini(login1) iswm $3-) {
      %s = $msn.ndll(navigate,%msnpp.lourl)
      return S_CANCEL
    }
    elseif ($msn.ini(lgout3) iswm $3-) {
      .timer 1 0 window -c @VinculaPPU
      return S_CANCEL
    }
  }
  elseif (navigate_complete == $2) {
    if ($msn.ini(lgout1) iswm $3) {
      %s = $msn.ndll(navigate,%msnpp.lourl)
      return S_CANCEL
    }
  }
  elseif (document_complete == $2) {
    if ($msn.ini(chatui) iswm $3-) {
      ;var %f = $findfile($msn.registry(HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\\Directory),*chatroom_ui*.msnw*,1)
      var %f = $findfile($msn.registry(HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\\Directory),*chatroom_ui*.msnw*,0,.msn.cookie.file " $+ $1- $+ ")
      if (%msnpp.locookiefile) {
        .copy -o %msnpp.locookiefile $+(",$scriptdir,pptemp.dat")
        %s = $msn.ndll(navigate,http://login.passport.com/logout.srf?id=2260)
        .timer 1 0 msn.cookieupdate
        return S_CANCEL
      }
    }
  }
  return S_OK
}

alias msn.cookie.file {
  if (%msnpp.lofiletime < $file($1-).mtime) {
    %msnpp.lofiletime = $file($1-).mtime
    %msnpp.locookiefile = $1-
  }
}

alias msn.cookieupdate {
  var %f = $+(",$scriptdir,pptemp.dat"), %sp, %ep, %uc, %ut, %up, %p 1

  bread -t %f %p 2000 &r
  while ($bfind(&r,1,MSNREGCookie) == 0) {
    inc %p $calc($bvar(&r,0) + 2)
    bread -t %f %p 2000 &r
    if (%p > $file(%f).size) goto notfound
  }
  %sp = $calc($bfind(&r,1,MSNREGCookie) + 22)
  %ep = $calc($bfind(&r,%sp,34) - %sp)
  %uc = $bvar(&r,%sp,%ep).text

  %sp = $calc($bfind(&r,1,PassportTicket) + 23)
  %ep = $calc($bfind(&r,%sp,34) - %sp)
  %ut = $bvar(&r,%sp,%ep).text

  %sp = $calc($bfind(&r,1,PassportProfile) + 24)
  %ep = $calc($bfind(&r,%sp,34) - %sp)
  %up = $bvar(&r,%sp,%ep).text

  if ((%uc != $null) && (%ut != $null) && (%up != $null)) { goto found }
  :notfound
  echo $color(info2) -at * Passport update failed
  return

  :found
  if (%msnpp.loupdate == $msn.ini(selpp)) {
    %msnpp.cookie = %uc
    %msnpp.ticket = %ut
    %msnpp.profile = %up
  }
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate cookie %uc
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate ticket %ut
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate profile %up
  writeini $+(",$scriptdir,vpassport.dat") %msnpp.loupdate updated $ctime

  echo $color(info2) -at * Passport info for " $+ %msnpp.loupdate $+ " is now updated ( $+ $calc(($ticks - %msnpp.lotime) / 1000) seconds)
  unset %msnpp.lo*
  .remove " $+ $scriptdir $+ pptemp.dat"
}

alias msn.loadpp {
  tokenize 32 $replace($1-,$chr(32),$chr(160))

  if ($msn.ppdata($$1,showprof) == $null) {
    echo $color(info2) -atq * Couldn't load the passport named " $+ $1 $+ "
    return
  }

  msn.ini selpp $1
  %msnpp.nick = $msn.ppdata($1,nick)
  %msnpp.email = $msn.ppdata($1,email)
  %msnpp.passwd = $msn.ppdata($1,passwd)
  %msnpp.cookie = $msn.ppdata($1,cookie)
  %msnpp.ticket = $msn.ppdata($1,ticket)
  %msnpp.profile = $msn.ppdata($1,profile)
  %msnpp.showprof = $msn.ppdata($1,showprof)
  echo $color(info2) -atq * Now using the " $+ $1 $+ " passport
}

alias msn.roomexists {
  var %x %msnc.making
  msn.clear 999
  unset %msnc.*
  if ($input(The room %x already exists $+ $chr(44) do you want to join the room?,136,Join Existing Room)) msn %x
}

alias msn.msnocx return | run regsvr32 /s $+(",$msn.registry(HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ActiveX Cache\\0),\MSNChat45.ocx")

alias msn.hackocx return | run regsvr32 /s $+(",$scriptdir,msnchatx.ocx")

alias msn.resetocx return | msn.hackocx | .timer 1 5 msn.msnocx

;--- Local Aliases
alias msn.sockerr {
  if (msn.look.* iswm $1) {
    .timer $+ $1 off
    window -c @Vincula $+ $gettok($1,3,46)
    .timer 1 1 msn.lookcon
  }
  else scid $activecid echo $color(kick) -at * Socket $2 error in $1 $+ : $sock($1).wsmsg
}

alias msn.setaways {
  scid $1
  var %aa 1, %fline
  while ($hget(msn.setaways,%aa) != $null) {
    if (-r * iswm $hget(msn.setaways,%aa)) {
      %fline = $fline($msn.get($1,room),$right($hget(msn.setaways,%aa),-3),1,1)
      if (%fline != $null) cline -lr $msn.get($1,room) %fline
    }
    else {
      %fline = $fline($msn.get($1,room),$hget(msn.setaways,%aa),1,1)
      if (%fline != $null) cline -l $color(gray) $msn.get($1,room) %fline
    }
    inc %aa
  }
  if ($hget(msn.setaways)) hfree msn.setaways
  scid -r
}

alias msn.donav {
  var %s, %x = $$1, %p = $$2

  var %r = about:
  %r = %r $+ <object id="ChatFrame" classid="CLSID:ECCDBA05-B58F-4509-AE26-CF47B2FFC3FE" width="100%">
  %r = %r $+ <param name="RoomName" value="Vincula"><param name="NickName" value="Vincula"><param name="Server" $+(value=",$$3,:,%p,">) $+ </object>

  if (!$window(%x)) {
    window -ph %x
    %s = $msn.ndll(attach,$window(%x).hwnd)
  }
  %s = $msn.ndll(select,$window(%x).hwnd)
  %s = $msn.ndll(navigate,%r)
}

alias -l msn.chklst.join scid $2 | if ($1 !ison $msn.get($2,room)) names $msn.get($2,room) | scid -r
alias -l msn.chklst.part scid $2 | if ($1 ison $msn.get($2,room)) names $msn.get($2,room) | scid -r

;--- Identifiers
alias msn.ndll {
  ;return
  return $dll($scriptdir $+ nHTMLn_2.92.dll,$$1,$2)
}

alias msn.ini {
  if ($isid) return $readini($scriptdir $+ vincula.ini,n,main,$$1)
  else {
    if ($1 == -r) remini " $+ $scriptdir $+ vincula.ini" main $$2
    else {
      if ($2 == $null) remini " $+ $scriptdir $+ vincula.ini" main $$1
      else writeini " $+ $scriptdir $+ vincula.ini" main $$1 $2-
    }
  }
}

;--- Delete for release and uncomment next line
alias msn.authkey {
  var %p
  if ($msn.ini(unban)) %p = X
  else %p = %msnpp.profile
  return $base($len(%msnpp.ticket),10,16,8) $+ %msnpp.ticket $+ $base($len(%p),10,16,8) $+ %p
}
;----

;alias msn.authkey return $base($len(%msnpp.ticket),10,16,8) $+ %msnpp.ticket $+ $base($len(%msnpp.profile),10,16,8) $+ %msnpp.profile

;--- Delete for release
alias msn.ggate {
  if ($msn.ini(randgg)) {
    var %l 1, %r
    while (%l <= 16) {
      %r = %r $+ $base($rand(0,255),10,16,2)
      inc %l
    }
    return %r
  }
  else return $mid($msn.ini(ggate),7,2) $+ $mid($msn.ini(ggate),5,2) $+ $mid($msn.ini(ggate),3,2) $+ $left($msn.ini(ggate),2) $+ $mid($msn.ini(ggate),11,2) $+ $mid($msn.ini(ggate),9,2) $+ $mid($msn.ini(ggate),15,2) $+ $mid($msn.ini(ggate),13,2) $+ $right($msn.ini(ggate),16)
}
;----

;This identifier was obtained from the mircscripts.org Snippets section.
;Very big thank you to Techster, who submitted it.  Dude, you saved me alot
;of time!
;URL: http://www.mircscripts.org/comments.php?id=1225
alias msn.urldecode {
  var %decode = $replace($eval($1-,1), +, $eval(%20,0))
  while ($regex($eval(%decode,1), /\%([a-fA-F0-9]{2})/)) var %t = $regsub($eval(%decode,1), /\%([a-fA-F0-9]{2})/, $chr($base($regml(1),16,10)), %decode)
  return $replace(%decode, $eval(%20,0), +)
}

; $msn.registry(<Key>\\<Value>)
alias msn.registry return $dll($scriptdir $+ registry.dll,GetKeyValue,$1)

alias msn.ud1 return $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\UserData1)

; TODO: Remove
alias msn.decode return $1-
alias msn.ifdecode return $1-
alias msn.encode return $1-

alias msn.pass var %r | while ($len(%r) <= $iif($1,$calc($1 - 1),30)) %r = %r $+ $replace($chr($r(33,255)),$chr(44),.,:,.) | return %r

alias msn.tohex {
  var %l 1, %r
  while (%l <= $len($1-)) {
    %r = %r $+ $base($asc($mid($1-,%l,1)),10,16,2)
    inc %l
  }
  return %r
}

alias msn.unhex {
  var %l 1, %r
  while (%l <= $len($1-)) {
    if (!$2) {
      if ($mid($1-,%l,2) != 20) %r = %r $+ $chr($base($mid($1-,%l,2),16,10))
      else %r = %r $chr($base($mid($1-,%l,2),16,10))
    }
    else %r = %r $+ $chr($base($mid($1-,%l,2),16,10))
    inc %l 2
  }
  return %r
}

alias msn.roompass {
  if ($1) {
    if (%msnp.qkey. [ $+ [ $right($1,-2) ] ] != $null) return %msnp.qkey. [ $+ [ $right($1,-2) ] ]
    return %msnp.okey. [ $+ [ $right($1,-2) ] ]
  }
  else {
    if (%msnp.qkey. [ $+ [ $right($chan,-2) ] ] != $null) return %msnp.qkey. [ $+ [ $right($chan,-2) ] ]
    return %msnp.okey. [ $+ [ $right($chan,-2) ] ]
  }
}

alias msn.ownerkey {
  if ($1) return %msnp.qkey. [ $+ [ $right($1,-2) ] ]
  else return %msnp.qkey. [ $+ [ $right($chan,-2) ] ]
}

alias msn.hostkey {
  if ($1) return %msnp.okey. [ $+ [ $right($1,-2) ] ]
  else return %msnp.okey. [ $+ [ $right($chan,-2) ] ]
}

alias msn.get {
  if (msn.*.* iswm $1) return $hget(msn. $+ $gettok($$1,3,46),$$2)
  else return $hget(msn. $+ $$1,$$2)
}

alias msn.roomip {
  if (!$1) return $hget(msn.roomip,$chan)
  return $hget(msn.roomip,$$1)
}

alias msn.ppdata {
  if (($1 == $null) && ($2 == $null)) return $null
  if ($2 == $null) return $readini($scriptdir $+ vpassport.dat,$msn.ini(selpp),$$1)
  return $readini($scriptdir $+ vpassport.dat,$$1,$$2)
}

alias msn.pticket {
  if ($isid) return %msnpp.ticket
  elseif ($1 == -t) %msnpp.ticket = $$2
  else {
    %msnpp.ticket = $$1
    writeini $+(",$scriptdir,vpassport.dat") $msn.ini(selpp) ticket $1
  }
}

alias msn.pprofile {
  if ($isid) return %msnpp.profile
  elseif ($1 == -t) %msnpp.profile = $$2
  else {
    %msnpp.profile = $$1
    writeini $+(",$scriptdir,vpassport.dat") $msn.ini(selpp) profile $1
  }
}

alias msn.pcookie {
  if ($isid) return %msnpp.cookie
  elseif ($1 == -t) %msnpp.cookie = $$2
  else {
    %msnpp.cookie = $$1
    writeini $+(",$scriptdir,vpassport.dat") $msn.ini(selpp) cookie $1
  }
}

;Converts default mIRC color numbers to MSN color codes
alias msn.mrctomsn {
  if ($msn.get($2,frand)) tokenize 32 $rand(0,7)

  if ($1 == 0) return $chr(1)
  elseif ($1 == 1) return $chr(2)
  elseif ($1 == 5) return $chr(3)
  elseif ($1 == 3) return $chr(4)
  elseif ($1 == 2) return $chr(5)
  elseif ($1 == 7) return $chr(6)
  elseif ($1 == 6) return $chr(7)
  elseif ($1 == 10) return $chr(8)
  elseif ($1 == 15) return $chr(9)
  elseif ($1 == 4) return $chr(11)
  elseif ($1 == 9) return $chr(12)
  elseif ($1 == 8) return $chr(14)
  elseif ($1 == 13) return $chr(15)
  elseif ($1 == 11) return $chr(16)
  elseif ($1 == 12) return \r
  elseif ($1 == 14) return \n
  else return $chr(2)
}

;Converts MSN color codes to default mIRC color numbers
alias msn.msntomrc {
  if ($1 == $chr(1)) return 00
  elseif ($1 == $chr(2)) return 01
  elseif ($1 == $chr(3)) return 05
  elseif ($1 == $chr(4)) return 03
  elseif ($1 == $chr(5)) return 02
  elseif ($1 == $chr(6)) return 07
  elseif ($1 == $chr(7)) return 06
  elseif ($1 == $chr(8)) return 10
  elseif ($1 == $chr(9)) return 15
  elseif ($1 == $chr(11)) return 04
  elseif ($1 == $chr(12)) return 09
  elseif ($1 == $chr(14)) return 08
  elseif ($1 == $chr(15)) return 13
  elseif ($1 == $chr(16)) return 11
  elseif ($1 == \r) return 12
  elseif ($1 == \n) return 14
  else return 01
}

alias msn.ghex {
  var %l 1, %r

  while (%l <= $len($1)) {
    if ($mid($1,%l,1) == \) {
      inc %l
      if ($mid($1,%l,1) == 0) %r = %r 00
      elseif ($mid($1,%l,1) == t) %r = %r 09
      elseif ($mid($1,%l,1) == n) %r = %r 0A
      elseif ($mid($1,%l,1) == r) %r = %r 0D
      elseif ($mid($1,%l,1) == b) %r = %r 20
      elseif ($mid($1,%l,1) == c) %r = %r 2C
      elseif ($mid($1,%l,1) == \) %r = %r 5C
    }
    else %r = %r $base($asc($mid($1,%l,1)),10,16,2)
    inc %l
  }
  return %r
}

alias msn.gunhex {
  var %l 1, %r, %x $remove($1-,$chr(32))

  while (%l <= $len(%x)) {
    if ($mid(%x,%l,2) == 00) %r = %r $+ \0
    elseif ($mid(%x,%l,2) == 0A) %r = %r $+ \n
    elseif ($mid(%x,%l,2) == 0D) %r = %r $+ \r
    elseif ($mid(%x,%l,2) == 2C) %r = %r $+ \c
    elseif ($mid(%x,%l,2) == 09) %r = %r $+ \t
    elseif ($mid(%x,%l,2) == 5C) %r = %r $+ \\
    elseif ($mid(%x,%l,2) == 20) %r = %r $+ \b
    else %r = %r $+ $chr($base($mid(%x,%l,2),16,10))
    inc %l 2
  }
  return %r
}

;--- Local Identifiers
alias msn.getnick {
  if ($1 == p) {
    if ($msn.ini(asknickp)) {
      if (%msnpp.nick) {
        if ($msn.ppdata($msn.ini(selpp),lvnick)) return %msnpp.nick
        else return $msn.encode(%msnpp.nick)
      }
      elseif ((%msnpp.cookie) && (!%msnpp.nick)) return
      elseif ((!%msnpp.cookie) && (!%msnpp.nick)) {
        if ($me) return $iif(>* !iswm $me,$me,$right($me,-1))
        var %n = $dialog(msn.name,msn.name)
        if (%msnc.cancel) { unset %msnc.* | halt }
        if (($msn.decode(%n) == %n) && (!%msnc.lnick)) %n = $msn.encode(%n)
        if (!%n) halt
        return %n
      }
    }
    else {
      var %n = $dialog(msn.name,msn.name)
      if (%msnc.cancel) { unset %msnc.* | halt }
      if (($msn.decode(%n) == %n) && (!%msnc.lnick)) %n = $msn.encode(%n)
      if (!%n) {
        if (%msnpp.nick) {
          if ($msn.ppdata($msn.ini(selpp),lvnick)) return %msnpp.nick
          else return $msn.encode(%msnpp.nick)
        }
        elseif ((%msnpp.cookie) && (!%msnpp.nick)) return
        elseif ((!%msnpp.cookie) && (!%msnpp.nick)) {
          if (%me) return $iif(>* !iswm $me,$me,$right($me,-1))
          halt
        }
      }
      return %n
    }
  }
  elseif ($1 == g) {
    if ($msn.ini(asknickg)) {
      if (%msnpp.nick) {
        if ($msn.ppdata($msn.ini(selpp),lvnick)) return %msnpp.nick
        else return $msn.encode(%msnpp.nick)
      }
      elseif ($me) return $iif(>* !iswm $me,$me,$right($me,-1))
    }
    else {
      set -u0 %msnc.guest $true
      var %n = $dialog(msn.name,msn.name)
      if (%msnc.cancel) { unset %msnc.* | halt }
      if ($msn.decode(%n) == %n) %n = $msn.encode(%n)
      if (%n) return %n
      elseif (%msnpp.nick) {
        if ($msn.ppdata($msn.ini(selpp),lvnick)) return %msnpp.nick
        else return $msn.encode(%msnpp.nick)
      }
      elseif ($me) return $iif(>* !iswm $me,$me,$right($me,-1))
    }
  }
}

;--- Loadup
on *:LOAD: %msnc.dostart = $true

;--- Startup
on *:START: {
  if (%msnc.dostart) {
    if ($version < 6) {
      echo $color(info2) -ta * Vincula will not work on any mIRC lower than version 6.0.  Unloading now...
      set -u5 %msnc.nostart $true
      .timer 1 0 .unload -rs " $+ $script $+ "
      halt
    }
    if (!%msnc.nostart) unset %msn*
    elseif ($version <= 6.03) echo $color(info2) -ta * Vincula Neo is designed for mIRC v6.03 and above.  It should work on your version (mIRC $version $+ ) but it is untested and may act strange.
    echo $color(info2) -ta * Welcome to Vincula Neo (v $+ $msn.vver $+ )
    echo $color(info2) -ta * Please read the instructions in the vincula.txt file!
    echo $color(info2) -ta * Now performing initializations...
    echo $color(info2) -ta * mIRC's internal self-flood protection is now enabled
    .flood 300 10 4 0
    var %st $true
    if (!$msn.ini(decode)) msn.ini decode $true
    if (!$msn.ini(usepass)) msn.ini usepass $true
  }
  if (%msnc.nostart) halt
  unset %msnc.*
  if (!$msn.ini(font)) msn.ini font $replace($gettok($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontName),1,59),$chr(32),\b)
  if (!$msn.ini(fcolor)) msn.ini fcolor $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontColor)
  if (!$msn.ini(fstyle)) msn.ini fstyle $calc($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontStyle) + 1)
  if (!$msn.ini(script)) msn.ini script Western - 0
  if (!%msnpp.showprof) %msnpp.showprof = 1
  if (!$msn.ini(timereply)) msn.ini timereply $($asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT),0)
  if (!$msn.ini(msnver)) msn.ini msnver 4.5
  if (!$msn.ini(clsid)) msn.ini clsid F58E1CEF-A068-4c15-BA5E-587CAF3EE8C6
  if (!$isfile($scriptdir $+ vfcache.dat)) msn.updatefonts
  else {
    if ($hget(msn.fonts)) hfree msn.fonts
    hmake msn.fonts 30
    hload msn.fonts " $+ $scriptdir $+ vfcache.dat"
  }
  msn.enchash
  if ($msn.ini(debug)) window @debug
  var %p = $iif($msn.ini(selpp),$msn.ini(selpp),none)
  echo $color(info2) -st * Vincula Neo $msn.vver $chr(124) UD1: $msn.ud1 $chr(124) Current Passport: %p
  if (!$msn.ini(msnchatx)) {
    echo $color(info2) -ta * Installing MSNChatX OCX (if you become Guest_null please type /msn.msnocx in here and that should fix it)...
    msn.ini msnchatx $true
    msn.resetocx
  }
  ;msn.hackocx
  ;msn.msnocx
  if (!$msn.ini(ppinfo)) msn.ini ppinfo *.*.*/*t=*p=*
  if (!$msn.ini(errcod)) msn.ini errcod *passport*ec=e*
  if (!$msn.ini(switch)) msn.ini switch *passport*switchuser.srf*
  if (!$msn.ini(cookie)) msn.ini cookie *passport*Cookies*.srf*
  if (!$msn.ini(login1)) msn.ini login1 *passport*uilogin.srf*
  if (!$msn.ini(lgout1)) msn.ini lgout1 *logout*id=486*
  if (!$msn.ini(lgout2)) msn.ini lgout2 *logout*id=2260*
  if (!$msn.ini(lgout3)) msn.ini lgout3 *msn*default.asp*
  if (!$msn.ini(chatui)) msn.ini chatui *chatroom_ui*
  if (!$msn.ini(sip)) msn.ini sip dir.irc7.com
  if (!$msn.ini(gip)) msn.ini gip 207.68.167.251
  if (!$hget(msn.roomip)) hmake msn.roomip 3
  if (%p != none) .msn.loadpp %p
  if (%st) { msn.setup }
  ;window -ph @VinculaHTML
  ;%p = $msn.ndll(attach,$window(@VinculaHTML).hwnd)
  vincula.update
  ;msn.sgetpp
  .timer 1 2 echo $color(info2) -st * Opening lookup server connections...
  .timer 1 3 msn.lookcon
}

alias msn.lookcon {
  if ($sock(msn.look.main) == $null) {
    ;sockclose msn.client.*main
    var %port = $rand(2000,5000)
    while (!$portfree(%port)) inc %port
    ;socklisten msn.client.lcmain %port
    .timermsn.look.main 1 1 sockopen msn.look.main $msn.ini(sip) 6667
  }
  if ($sock(msn.look.comm) == $null) {
    ;sockclose msn.client.*comm
    var %port = $rand(2000,9000)
    while (!$portfree(%port)) inc %port
    ;socklisten msn.client.lccomm %port
    .timermsn.look.comm 1 1 sockopen msn.look.comm $msn.ini(gip) 6667
  }
}

alias msn.relookcon {
  echo $color(info2) -at * Resetting lookup server connections...
  sockclose msn.look*
  .timer*msn.look* off
  msn.lookcon
}

;--- Displays
raw PROP:*: {
  if ($2 == language) echo $color(info2) -ti2 $1 * $msn.ifdecode($nick) sets the room language to $gettok(English.French.German.Japanese.Swedish.Dutch.Korean.Chinese (Simplified).Portuguese.Finnish.Danish.Russian.Italian.Norwegian.Chinese (Traditional).Spanish.Czech.Greek.Hungarian.Polish.Slovene.Turkish.Slovak.Portuguese (Brazilian),$3,46) ( $+ $3 $+ )
  else echo $color(info2) -ti2 $1 * $msn.ifdecode($nick) sets the $2 property to: $3-
}

raw 818:*: {
  if ($3 == PUID) {
    echo $color(info2) -at * Opening $msn.ifdecode($2) $+ 's profile...
    var %m, %c, %x, %p http://chat.msn.com/profile.msnw?epuid= $+ $4- , %w @Vincula -  $+ $msn.ifdecode($2) $+ 's Profile
    window -pk0 %w
    %m = $msn.ndll(attach,$window(%w).hwnd)
    %m = $msn.ndll(select,$window(%w).hwnd)
    %m = $msn.ndll(handler,msn.hnd.prof)
    %m = $msn.ndll(navigate,%p)
    echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) $+ 's profile can be viewed at: %p
    %msnc.stoppropend = $true
    haltdef
  }
  elseif (($3 == MSNPROFILE) && ($window($msn.get($cid,room)))) {
    if ($4 == 1) echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) has a regular profile
    elseif ($4 == 3) echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) $+ 's profile says he is male
    elseif ($4 == 5) echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) $+ 's profile says she is female
    elseif ($4 == 9) echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) has a picture in his or her profile
    elseif ($4 == 11) echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) $+ 's profile has a picture, and says he is male
    elseif ($4 == 13) echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) $+ 's profile has a picture, and says she is female
    else echo $color(info2) -t $msn.get($cid,room) * $msn.ifdecode($2) does not have a profile
    %msnc.stoppropend = $true
    haltdef
  }
}

alias msn.hnd.prof {
  if ($2 == new_window) return S_CANCEL
  return S_OK
}

raw 819:*: {
  if (%msnc.stoppropend) {
    unset %msnc.stoppropend
    haltdef
  }
}

raw 822:*: {
  echo $color(info2) -ti2 $comchan($nick,1) * $msn.ifdecode($nick) is now away: $1-
  cline -l $color(gray) $comchan($nick,1) $fline($comchan($nick,1),$nick,1,1)
  if ($window($nick) == $nick) echo $color(info2) -t $nick * $msn.ifdecode($nick) is now away: $1-
  haltdef
}

raw 821:*: {
  echo $color(info2) -ti2 $comchan($nick,1) * $msn.ifdecode($nick) has returned
  cline -lr $comchan($nick,1) $fline($comchan($nick,1),$nick,1,1)
  if ($window($nick) == $nick) echo $color(info2) -t $nick * $msn.ifdecode($nick) has returned
  haltdef
}

raw KNOCK:*: {
  if ($2 == 913) echo $colour(info) -t $1 * Knock:  $msn.ifdecode($nick) ( $+ $address $+ ) (Access Ban): $nick
  elseif ($2 == 471) echo $colour(info) -t $1 * Knock:  $msn.ifdecode($nick) ( $+ $address $+ ) (Room is full): $nick
  elseif ($2 == 473) echo $colour(info) -t $1 * Knock:  $msn.ifdecode($nick) ( $+ $address $+ ) (Room is invite only): $nick
  elseif ($2 == 474) echo $colour(info) -t $1 * Knock:  $msn.ifdecode($nick) ( $+ $address $+ ) (Banned): $nick
  elseif ($2 == 475) echo $colour(info) -t $1 * Knock:  $msn.ifdecode($nick) ( $+ $address $+ ) (Need room key): $nick
  else echo $colour(info) -t $1 * Knock:  $msn.ifdecode($nick) ( $+ $address $+ ) (Numeric: $2 $+ ): $nick
  haltdef
}

raw KILL:*: {
  halt
}

on *:INPUT:#: {
  if (($msn.get($cid,decode)) && ((/* !iswm $1) || (/me == $1))) {
    var %p = $left($nick($chan,$me).pnick,1)
    if (%p == $left($me,1)) unset %p
    if (/me != $1) {
      echo $color(own) -ti2 $chan $+(<,$msn.ifdecode(%p $+ $me),>) $1-
      if ($msn.get($cid,encode)) .msg $chan $msn.encode($1-)
      else .msg $chan $1-
    }
    else {
      echo $color(own) -ti2 * $msn.ifdecode(%p $+ $me) $2-
      if ($msn.get($cid,encode)) .describe $chan $msn.encode($2-)
      else .describe $chan $2-
    }
    haltdef
  }
}

on *:INPUT:?: {
  if (($msn.get($cid,decode)) && ((/* !iswm $1) || (/me == $1))) {
    var %p = $left($nick($comchan($me,1),$me).pnick,1)
    if (%p == $left($me,1)) unset %p
    if (/me != $1) {
      echo $color(own) -ti2 $target $+(<,$msn.ifdecode(%p $+ $me),>) $1-
      if ($msn.get($cid,encode)) .msg $target $msn.encode($1-)
      else .msg $target $1-
    }
    else {
      echo $color(own) -ti2 $target $+(<,$msn.ifdecode(%p $+ $me),>) * $+ $2- $+ *
      if ($msn.get($cid,encode)) .msg $target * $+ $2- $+ *
      else .msg $target * $+ $2- $+ *
    }
    haltdef
  }
}

on ^*:JOIN:*: {
  if (($msn.ini(sounds)) && ($sock(msn.server. $+ $cid)) && ($msn.ini(snd.join) != $null)) splay -w " $+ $msn.ini(snd.join) $+ "
  if ((!$msn.ini(jwho)) && ($msn.get($cid,room)) && ($nick === $me)) {
    %msnt.jwho = $true
    who $chan
  }
  if ($msn.get($cid,hjoin)) { haltdef | return }
  if ($msn.get($cid,decode)) {
    if ($nick === $me) {
      echo $color(join) -t $chan * Now talking in $chan $iif(%msnc.jointime,$chr(40) $+ Join time: $calc(($ticks - %msnc.jointime) / 1000) seconds $+ $chr(41))
      msn.getpass $chan
      unset %msnc.*
    }
    else {
      echo $color(join) -t $chan * Joins:  $msn.ifdecode($nick) ( $+ $address $+ ): $nick
      if ($window($nick) == $nick) echo $color(join) -t $nick * $msn.ifdecode($nick) has joined the room
    }
    haltdef
  }
  else {
    if (($nick === $me) && ($sock(msn.server. $+ $cid))) {
      echo $color(join) -t $chan * Now talking in $chan $iif(%msnc.jointime,$chr(40) $+ Join time: $calc(($ticks - %msnc.jointime) / 1000) seconds $+ $chr(41))
      msn.getpass
      unset %msnc.*
    }
  }
}

on ^*:PART:*: {
  if ($msn.get($cid,hpart)) { haltdef | return }
  if ($msn.get($cid,decode)) {
    echo $color(part) -t $chan * Parts:  $msn.ifdecode($nick) ( $+ $address $+ ) $+ $iif($1 != $null,( $+ $1- $+ )) $+ : $nick
    if ($window($nick) == $nick) echo $color(part) -t $nick * $msn.ifdecode($nick) has left the room
    haltdef
  }
}

on ^*:TEXT:*:#: {
  if ($msn.get($cid,decode)) {
    if ($chr(37) $+ $chr(35) $+ * iswm $nick) var %n = $chan
    else {
      if ($len($nick) >= 50) var %n = $line($chan,$fline($chan,$nick $+ *,1,1),1)
      else var %n = $nick
    }
    var %p = $left($nick($chan,%n).pnick,1)
    if (%p == $left(%n,1)) unset %p
    echo $color(normal) -tmi2 $chan < $+ %p $+ $msn.ifdecode(%n) $+ > $msn.ifdecode($1-)
    haltdef
  }
}

on ^*:ACTION:*:#: {
  if ($msn.get($cid,decode)) {
    if ($chr(37) $+ $chr(35) $+ * iswm $nick) var %n = $chan
    else {
      if ($len($nick) >= 50) var %n = $line($chan,$fline($chan,$nick $+ *,1,1),1)
      else var %n = $nick
    }
    var %p = $left($nick($chan,%n).pnick,1)
    if (%p == $left(%n,1)) unset %p
    echo $color(action) -tmi2 $chan $msn.ifdecode(* %p $+ %n $1-)
    haltdef
  }
}

on ^*:TEXT:*:?: {
  if ($msn.get($cid,decode)) {
    var %p = $left($nick($comchan($nick,1),$nick).pnick,1)
    if (%p == $left($nick,1)) unset %p
    if ($window($nick)) echo $color(normal) -tmi2 $nick < $+ %p $+ $msn.ifdecode($nick) $+ > $msn.ifdecode($1-)
    else echo $color(normal) -tmi2 $comchan($nick,1) * $+ %p $+ $msn.ifdecode($nick) $+ * $msn.ifdecode($1-)
    haltdef
  }
}

on ^*:NOTICE:*:#: {
  if ($msn.get($cid,decode)) {
    echo $color(notice) -tmi2 $chan $msn.ifdecode($+(-,$nick,:,$chan,-) $1-)
    haltdef
  }
}

on ^*:NOTICE:*:?: {
  if (($msn.ini(sounds)) && ($sock(msn.server. $+ $cid)) && ($msn.ini(snd.rwhs) != $null)) splay -w " $+ $msn.ini(snd.rwhs) $+ "
  if ($msn.get($cid,decode)) {
    echo $color(notice) -tmi2 $comchan($nick,1) $msn.ifdecode($+(-,$nick,-) $1-)
    haltdef
  }
}

on ^*:RAWMODE:*: {
  if ($msn.get($cid,decode)) {
    echo $color(mode) -ti2 $chan $msn.ifdecode(* $nick sets mode: $1-)
    haltdef
  }
}

on ^*:KICK:*: {
  if (($msn.ini(sounds)) && ($sock(msn.server. $+ $cid)) && ($msn.ini(snd.kick) != $null)) splay -w " $+ $msn.ini(snd.kick) $+ "
  if ($msn.get($cid,hkick)) { haltdef | return }
  if ($msn.get($cid,decode)) {
    echo $color(kick) -ti2 $chan $msn.ifdecode(* $knick was kicked by $nick $iif($1- != $null,$chr(40) $+ $1- $+  $+ $chr(41))) $+ : $knick
    if ($window($knick) == $knick) echo $color(kick) -ti2 $knick $msn.ifdecode(* $knick was kicked by $nick $iif($1- != $null,$chr(40) $+ $1- $+ $chr(41)))
    if ($knick == $me) echo $color(kick) -sti2 * You were kicked out of $msn.get($cid,fullroom) by $msn.ifdecode($nick $iif($1- != $null,$chr(40) $+ $1- $+ $chr(41)))
    haltdef
  }
}

on *:SIGNAL:msn.kill: {
  if (($msn.ini(sounds)) && ($sock(msn.server. $+ $cid)) && ($msn.ini(snd.kick) != $null)) splay -w " $+ $msn.ini(snd.kick) $+ "
  if ($msn.get($cid,hkick)) { haltdef | return }
  scid $1
  echo $color(kick) -ti2 $msn.get($1,room) $msn.ifdecode(* $3 was killed by $2 $iif($4- != $null,$chr(40) $+ $4- $+  $+ $chr(41))) $+ : $2
  if ($window($2) == $2) echo $color(kick) -ti2 $2 $msn.ifdecode(* $3 was killed by $2 $iif($4- != $null,$chr(40) $+ $4- $+ $chr(41)))
  if ($2 == $me) echo $color(kick) -sti2 * You were killed by $msn.ifdecode($2 $iif($4- != $null,$chr(40) $+ $4- $+ $chr(41)))
  scid -r
  haltdef
}

on ^*:QUIT: {
  if ($msn.get($cid,decode)) {
    echo $color(quit) -ti2 $msn.get($cid,room) $msn.ifdecode(* Quits: $nick ( $+ $address $+ ) $iif($1 != $null,$chr(40) $+ $1- $+  $+ $chr(41))) $+ : $nick
    if ($window($nick) == $nick) echo $color(quit) -ti2 $nick $msn.ifdecode(* $nick has left the room $chr(40) $+ Quit $+ $iif($1- != $null,: $1-) $+ $chr(41))
    haltdef
  }
}

on ^*:INVITE:#: {
  if (($msn.ini(sounds)) && ($sock(msn.server. $+ $cid)) && ($msn.ini(snd.invt) != $null)) splay -w " $+ $msn.ini(snd.invt) $+ "
  if ($msn.get($cid,decode)) {
    echo $color(invite) -ati2 * $msn.ifdecode($nick) ( $+ $address $+ ) invites you to join $chan
    haltdef
  }
}

ctcp *:ERR*:*: {
  if ($2 == NOUSERWHISPER) {
    echo $color(info2) -at * $msn.ifdecode($nick) is not accepting whispers
    haltdef
  }
  else echo $color(info2) -at * Error recieved from $msn.ifdecode($nick) $+ : $2-
}

on ^*:HOTLINK:*:#: {
  if ($sock(msn.*. $+ $cid,0) >= 2) {
    if ($1 ison $chan) return
    if (<*> iswm $1) return
    if ($msn.encode($1) ison $chan) return
  }
  halt
}

on *:HOTLINK:*:*: {
  if (($1 ison $chan) || ($msn.encode($1) ison $chan)) var %x $1
  elseif ($mid($1,2,1) isin + @ .) var %x $mid($1,3,$calc($len($1) - 3))
  else var %x $mid($1,2,$calc($len($1) - 2))

  if ($msn.encode(%x) ison $chan) sline $chan $msn.encode(%x)
  else {
    %x = $replace(%x,a,*,b,*,c,*,d,*,e,*,f,*,g,*,h,*,i,*,j,*,k,*,l,*,m,*,n,*,o,*,p,*,q,*,r,*,s,*,t,*,u,*,v,*,w,*,x,*,y,*,z,*)
    if (($line($chan,$fline($chan,%x,1,1),1) != $me) && ($line($chan,$fline($chan,%x,1,1),1) != $null)) sline $chan $fline($chan,%x,1,1)
  }
}

;--- Lookup Sockets
on *:SOCKOPEN:msn.look.*: {
  if ($sockerr > 0) { msn.sockerr $sockname open | return }
  ;if ($right($sockname,4) == main) msn.donav @Vinculamain $sock(msn.client.lcmain).port dir.irc7.com
  ;else msn.donav @Vinculacomm $sock(msn.client.lccomm).port 207.68.167.251
  ;sockwrite -tn $sockname IRCVERS IRC8 MSN-OCX!9.02.0310.2401 $crlf AUTH GateKeeperPassport I $+(:GKSSP\0\0\0,$chr(3),\0\0\0,$chr(1),\0\0\0)
  sockwrite -tn $sockname IRCVERS IRC8 MSN-OCX!9.02.0310.2401 $crlf AUTH GateKeeper I $+(:GKSSP\0\0\0,$chr(3),\0\0\0,$chr(1),\0\0\0)
}

on *:SOCKCLOSE:msn.look.*: {
  var %x = $sockname
  if ($sockerr > 0) { msn.sockerr $sockname close }
  else {
    .timer $+ %x off
    ;scid $activecid echo $color(info2) -at * $iif($right(%x,4) == main,Main,Groups) lookup server connection lost! Reconnecting...
    ;sockclose msn.* $+ $right(%x,4)
    .timer 1 1 msn.lookcon
  }
}

on *:SOCKREAD:msn.look.*: {
  if ($sockerr > 0) { msn.sockerr $sockname read | return }

  bset -az &read
  sockread -n &read
  var %read $bvar(&read, 1-).text
  while ($sockbr > 0) {
    tokenize 32 %read

    if ($msn.ini(debug)) echo @debug $sockname $+ : $1-

    if (AUTH GateKeeper* iswm $1-) {
      ;if ($sock(msn.client.lm $+ $right($sockname,4)).status == active) sockwrite -tn msn.client.lm $+ $right($sockname,4) %read
      if (:GKSSP* iswm $4) {
        var %x, %re = AUTH GateKeeper.* S :GKSSP\\0.*\\0\\0.*\\0\\0(.*), %y = $regsub($1-,%re,,%x)
        sockwrite -tna $sockname $1-3 $msn.binhash($regml(1) $+ $sock($sockname).addr) $+ $msn.gunhex($msn.ggate)
      }
      if (AUTH GateKeeper*@GateKeeper* iswm $1-) {
        if (*GateKeeper *@* iswm $1-) sockwrite -tn $sockname NICK vincula $+ $ticks
        if ($sockname == msn.look.main) {
          .timermsn.look.main 0 20 sockwrite -tn msn.look.main VERSION
          if ($sock(msn.server.*,0) == 0) scid $activecid echo $color(info2) -at * Main Lookup server connection established
          if (!$sock(msn.look.comm)) msn.lookcon -x
        }
        else {
          .timermsn.look.comm 0 20 sockwrite -tn msn.look.comm VERSION
          if ($sock(msn.server.*,0) == 0) scid $activecid echo $color(info2) -at * Groups Lookup server connection established
          if (!$sock(msn.look.main)) msn.lookcon -x
        }
      }
      if (AUTH GateKeeper*S :OK iswm $1-) {
        if ($msn.ini(usepass)) var %pass $msn.roompass($msn.get($sockname,room))

        ;Add UserRole to this line
        if (%msnpp.subinfo) sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf NICK vincula $+ $ticks $lf PROP $ SUBSCRIBERINFO %msnpp.subinfo
        else sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf NICK vincula $+ $ticks

        ;else sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf USER * * " $+ $ip $+ " :Vincula Neo ( $+ $msn.vver $+ ) $lf PROP $ MSNPROFILE : $+ %msnpp.showprof $+ $lf $+ PROP $ SUBSCRIBERINFO %msnpp.subinfo
      }
    }
    elseif (613 == $2) {
      if ($hget(msn.999)) {
        echo $color(info2) -at * $msn.get(999,fullroom) found, joining... (Lookup time: $calc(($ticks - %msnc.looktime) / 1000) seconds)
        unset %msnc.looktime
        socklisten msn.mirc.in $rand(10000,30000)
        if (%msnc.newcon) scid %msnc.newcon server 127.0.0.1 $sock(msn.mirc.in).port
        else server -m 127.0.0.1 $sock(msn.mirc.in).port
        hadd msn.roomip $msn.get(999,room) $right($4,-1)
        sockopen msn.server.999 $right($4-,-1)
        var %port = $rand(2000,9000)
        while (!$portfree(%port)) inc %port
        ;socklisten msn.client.rmc %port
      }
      else msn %msnc.msnopt %msnc.making
    }
    elseif (472 == $2) {
      echo $color(info2) -at * Unknown mode character, cannot create the room
      msn.clear 999
      unset %msnc.*
    }

    elseif (641 == $2) if ($dialog(msn.faf) == $null) dialog -m msn.faf msn.faf

    elseif (642 == $2) {
      if ($dialog(msn.faf) != $null) did -aez msn.faf 5 $6-
      unset %msnc.findnick
    }

    elseif (701 == $2) {
      echo $color(info2) -at * Invalid room category, cannot create the room
      msn.clear 999
      unset %msnc.*
    }
    elseif (702 == $2) {
      echo $color(info2) -at * $msn.get(999,fullroom) not found (Lookup time: $calc(($ticks - %msnc.looktime) / 1000) seconds)
      msn.makeroom $msn.get(999,fullroom)
      ;signal msnremake $msn.get(999,fullroom)
      unset %msnc.*
      %msnc.noask = $true
      %msnc.connick = $msn.get(999,nick)
      msn.clear 999
    }
    elseif (705 == $2) .timer 1 0 msn.roomexists
    elseif (706 == $2) {
      echo $color(info2) -at * Invalid room name, cannot create the room
      msn.clear 999
      unset %msnc.*
    }
    elseif (709 == $2) {
      if ($dialog(msn.faf)) {
        did -b msn.faf 5
        did -a msn.faf 5 No rooms found
      }
      else echo $color(info2) -at * Couldn't find the nickname " $+ %msnc.findnick $+ " in any rooms
      unset %msnc.*
    }
    elseif ((7?? iswm $2) || (9?? iswm $2)) {
      msn.clear 999
      unset %msnc.*
      if ($2 isin 908 910) {
        sockclose $sockname
        .timer $+ $sockname off
        ;msn.lookcon
      }
      else echo $color(info2) -at * Error $2 $+ : $right($4-,-1)
      return
    }
    sockread %read
  }
}

alias       return $decode($+(Og,FWRV,J,TSU9,OIF,Zpbm,N1,b,GEgT,mVv),m)

;--- MSN Socket (Room)
on *:SOCKOPEN:msn.server.*: {
  if ($sockerr > 0) {
    msn.sockerr $sockname open
    sockclose *.999
    ;sockclose msn.client.*
    var %x $msn.ndll(select,$window(@VinculaHTML).hwnd)
    %x = $msn.ndll(navigate,about:blank)
    return
  }
  ;msn.donav @VinculaHTML $sock(msn.client.rmc).port $sock($sockname).ip
  if ($msn.get($sockname,guest)) sockwrite -tn $sockname IRCVERS IRC8 MSN-OCX!9.02.0310.2401 $crlf AUTH GateKeeper I $+(:GKSSP\0\0\0,$chr(3),\0\0\0,$chr(1),\0\0\0)
  else {
    if ($msn.get($sockname,nick)) sockwrite -tn $sockname NICK $msn.get($sockname,nick)
    sockwrite -tn $sockname IRCVERS IRC8 MSN-OCX!9.02.0310.2401 $crlf AUTH GateKeeperPassport I $+(:GKSSP\0\0\0,$chr(3),\0\0\0,$chr(1),\0\0\0)
  }
}

on *:SOCKCLOSE:msn.server.*: {
  if ($sockerr > 0) {
    msn.sockerr $sockname close
    if ($nanner) {
      ;.timer -m 10 500 nanner -e CP $!msn.get( $sockname ,fullroom)
    }
  }
  var %s = $sockname
  sockclose msn*. $+ $gettok($sockname,3,46)
  ;sockclose msn.cli*
  ;--- Delete for release
  if ($msn.ini(recon)) {
    if ($msn.get(%s,nick)) var %n = $msn.get(%s,nick)
    elseif ($scid($gettok(%s,3,46)).me) var %n = $scid($gettok(%s,3,46)).me

    if (%n) msn.ipjoin $gettok(%s,3,46) %n $msn.get(%s,fullroom)
  }
  else {
    msn.clear $gettok($sockname,3,46)
    sockclose msn*. $+ $gettok($sockname,3,46)
    ;sockclose msn.cli*
    var %x $msn.ndll(select,$window(@VinculaHTML).hwnd)
    %x = $msn.ndll(navigate,about:blank)
  }
  ;----
}

on *:SOCKREAD:msn.server.*: {
  if ($sockerr > 0) { msn.sockerr $sockname read | return }

  var %read, %x msn.mirc. $+ $gettok($sockname,3,46) , %z ).@%615)324].````

  if ($sockname != msn.server.999) scid $gettok($sockname,3,46) .timer.noop. $+ $gettok($sockname,3,46) 0 100 msn.noop $gettok($sockname,3,46)
  sockread %read
  while ($sockbr > 0) {
    if ($istok(%read,$msn.get($sockname,fullroom),32)) tokenize 32 $reptok(%read,$msn.get($sockname,fullroom),$msn.get($sockname,room),1,32)
    elseif ($istok(%read,: $+ $msn.get($sockname,fullroom),32)) tokenize 32 $reptok(%read,: $+ $msn.get($sockname,fullroom),: $+ $msn.get($sockname,room),1,32)
    else tokenize 32 %read

    if ($msn.ini(debug)) echo @debug $sockname $+ : $1-

    if (AUTH == $1) {
      if (AUTH GateKeeper*S :OK iswm $1-) {
        if ($msn.ini(usepass)) var %pass $msn.roompass($msn.get($sockname,room))

        ;Add UserRole to this line
        if ((%msnpp.cookie) && (!$msn.get($sockname,nick))) sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf PROP $ MSNREGCOOKIE : $+ %msnpp.cookie $lf PROP $ MSNPROFILE : $+ %msnpp.showprof $lf PROP $ SUBSCRIBERINFO %msnpp.subinfo $lf JOIN $msn.get($sockname,fullroom) %pass
        ;elseif ((%msnpp.cookie) && ($msn.get($sockname,nick))) sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf NICK $msn.get($sockname,nick) $lf PROP $ MSNREGCOOKIE : $+ %msnpp.cookie $lf PROP $ MSNPROFILE : $+ %msnpp.showprof $lf PROP $ SUBSCRIBERINFO %msnpp.subinfo $lf JOIN $msn.get($sockname,fullroom) %pass
        else sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf NICK $msn.get($sockname,nick) $lf USER * * " $+ $ip $+ " :Vincula Neo ( $+ $msn.vver $+ ) $lf PROP $ MSNPROFILE : $+ %msnpp.showprof $lf PROP $ SUBSCRIBERINFO %msnpp.subinfo $lf JOIN $msn.get($sockname,fullroom) %pass
      }
      elseif (:GKSSP* iswm $4) {
        var %x, %re = AUTH GateKeeper.* S :GKSSP\\0.*\\0\\0.*\\0\\0(.*), %y = $regsub($1-,%re,,%x)
        sockwrite -tna $sockname $1-3 $msn.binhash($regml(1) $+ $sock($sockname).addr) $+ $msn.gunhex($msn.ggate)
      }
      elseif (AUTH GateKeeper*@GateKeeper* 0 iswm $1-) {
        if (AUTH GateKeeper*@GateKeeper 0 iswm $1-) {
          if ($msn.ini(usepass)) var %pass $msn.roompass($msn.get($sockname,room))
          if (($msn.get($sockname,nick)) && (!$msn.get($sockname,guest)) && (%msnpp.cookie)) sockwrite -tn $sockname NICK $msn.get($sockname,nick) $lf JOIN $msn.get($sockname,fullroom) %pass
          elseif ($msn.get($sockname,guest)) sockwrite -tn $sockname NICK > $+ $msn.get($sockname,nick) $lf JOIN $msn.get($sockname,fullroom) %pass
        }
        %msnt.gate = $4
      }
      ;else sockwrite -tn msn.client.rm $1-
    }

    ;--- Delete for release
    ;--- Prots
    elseif (($2 == 821) || ($2 == 822)) {
      var %n = $gettok($gettok($1,1,33),1,58)
      scid $gettok($sockname,3,46)
      if (%n !isowner $msn.get($sockname,room)) {
        inc -u3 %arf. [ $+ [ %n ] ]
        ;if (%arf. [ $+ [ %n ] ] == 5) sockwrite -tn $sockname KICK $msn.get($sockname,fullroom) %n :Away/Return Flood
      }
      scid -r
      sockwrite -tn %x $1-
    }
    elseif ($2 == MODE) {
      ; :eXonyte!4A63C43D06D38CB7@GateKeeperPassport MODE %#eXonyte +q eXonyte
      var %n = $gettok($gettok($1,1,33),1,58)
      var %qkey = %msnp.qkey. [ $+ [ $right($3,-2) ] ]
      ;if (($4-5 == -q $me) && ($me != %n)) sockwrite -tn $sockname MODE $me +h %qkey $+ $crlf $+ ACCESS $3 CLEAR OWNER $+ $crlf $+ MODE $3 -q %n $+ $crlf $+ PROP $3 OWNERKEY $msn.pass(8)
      scid $gettok($sockname,3,46)
      ;if (%paranoia && ($4 == +q) && (%n != $me)) sockwrite -tn $sockname MODE $me +h %qkey $crlf ACCESS $chan CLEAR OWNER $crlf MODE $3 -q %n $crlf PROP $3 OWNERKEY $msn.pass(8) $crlf MODE $3 -q %n $crlf PROP $3 OWNERKEY $msn.pass(8)
      if (%n !isowner $msn.get($sockname,room)) {
        inc -u3 %mdf. [ $+ [ %n ] ]
        ;if (%mdf. [ $+ [ %n ] ] == 3) sockwrite -tn $sockname KICK $msn.get($sockname,fullroom) %n :Mode Flood
      }
      elseif ($4 == -q) {
        inc -u1 %mdf2. [ $+ [ %n ] ]
        ;if (%mdf2. [ $+ [ %n ] ] == 2) sockwrite -tn $sockname MODE $me +h %qkey $+ $crlf $+ ACCESS $3 CLEAR OWNER $+ $crlf $+ MODE $3 -q %n $+ $crlf $+ PROP $3 OWNERKEY $msn.pass(8)
        ;if (%mdf2. [ $+ [ %n ] ] == 2) sockwrite -tn $sockname MODE $me +h %qkey $+ $crlf $+ ACCESS $3 CLEAR OWNER $+ $crlf $+ MODE $3 -q %n $+ $crlf $+ PROP $3 OWNERKEY $msn.pass(8)
      }
      scid -r
      sockwrite -tn %x $1-
    }
    ;----
    elseif ($2 == JOIN) {
      ;--- Delete for release: Prot
      ;if (:>* iswm $1) {
      ;  inc -u5 %gf.prot
      ;  if (%gf.prot == 5) {
      ;    sockwrite -tn $sockname access $right($gettok(%read,4,32),-1) clear host $crlf access $right($gettok(%read,4,32),-1) add deny *!*@*r 1 $crlf mode $right($gettok(%read,4,32),-1) -u $crlf prop $right($gettok(%read,4,32),-1) hostkey $msn.pass(8) $crlf access $right($gettok(%read,4,32),-1) add owner *!4A63C43D06D38CB7@GateKeeperPassport
      ;  }
      ;}
      ;else {
      inc -u5 %pf.prot
      if (%pf.prot == 7) {
        if (%pf.time) {
          inc -u $+ $calc(%pf.time * 90) %pf.time
        }
        else inc -u90 %pf.time
        sockwrite -tn $sockname access $right($gettok(%read,4,32),-1) clear host $crlf access $right($gettok(%read,4,32),-1) clear grant $crlf access $right($gettok(%read,4,32),-1) add deny *!*@*a*r* %pf.time $crlf mode $right($gettok(%read,4,32),-1) -u $crlf prop $right($gettok(%read,4,32),-1) hostkey $msn.pass(8) $crlf access $right($gettok(%read,4,32),-1) add owner *!4A63C43D06D38CB7@GateKeeperPassport
      }
      ;}
      ;----
      if ($scid($gettok($sockname,3,46)).me !ison $chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88)) {
        msn.set $sockname fullroom $right($gettok(%read,4,32),-1)
        msn.set $sockname room $chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88)
        msn.set $sockname shortroom $left($chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88),60)
        tokenize 32 $reptok(%read,$gettok(%read,4,32),: $+ $chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88),1,32)
      }
      sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 $2 $4-

      if ($gettok($3,4,44) == +) sockwrite -tn %x $1 MODE $msn.get($sockname,room) +v $gettok($gettok($1,1,33),1,58)
      elseif ($gettok($3,4,44) == @) sockwrite -tn %x $1 MODE $msn.get($sockname,room) +o $gettok($gettok($1,1,33),1,58)
      elseif ($gettok($3,4,44) == .) sockwrite -tn %x $1 MODE $msn.get($sockname,room) +q $gettok($gettok($1,1,33),1,58)

      if ($sockname != msn.server.999) .timermsn.chk. $+ $gettok($sockname,3,46) -m 1 300 msn.chklst.join $gettok($gettok($1,1,33),1,58) $gettok($sockname,3,46)

      if ($msn.ini(ojprof)) {
        if ($gettok($3,3,44) == FY) sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) MSNPROFILE :13
        elseif ($gettok($3,3,44) == MY) sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) MSNPROFILE :11
        elseif ($gettok($3,3,44) == PY) sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) MSNPROFILE :9
        elseif ($gettok($3,3,44) == FX) sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) MSNPROFILE :5
        elseif ($gettok($3,3,44) == MX) sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) MSNPROFILE :3
        elseif ($gettok($3,3,44) == PX) sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) MSNPROFILE :1
        else sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) MSNPROFILE :0
        sockwrite -tn %x :TK2CHATCHATA01 819 $scid($gettok($sockname,3,46)).me $gettok($gettok($1,1,33),1,58) :End of properties
      }
    }

    elseif ($2 == PART) {
      scid $gettok($sockname,3,46) .timermsn.chk. $+ $gettok($sockname,3,46) -m 1 300 msn.chklst.part $gettok($gettok($1,1,33),1,58) $gettok($sockname,3,46)
      sockwrite -tn %x $1-
    }

    elseif ($2 == PRIVMSG) {
      if ($4 == :S) {
        if (?#* !iswm $3) sockwrite -tn %x $1 NOTICE $3 : $+ $remove($6-,$chr(1))
        else {
          var %color $left($5,1), %style $mid($5,2,1)
          if (%color == \) {
            %color = $left($5,2)
            %style = $mid($5,3,1)
          }
          %color = $base($msn.msntomrc(%color),10,10,2)

          if (($msn.get($sockname,docolor)) && ((%style == $chr(2)) || (%style == $chr(4)))) %style = 
          elseif (($msn.get($sockname,docolor)) && ((%style == $chr(6)) || (%style == $chr(8)))) %style = 
          elseif (($msn.get($sockname,docolor)) && ((%style == $chr(5)) || (%style == $chr(7)))) %style = 
          else unset %style

          if (%color == $color(background)) %color = %color(normal)
          sockwrite -tn %x $1 $2 $3 : $+ $iif($msn.get($sockname,docolor), $+ %color) $+ %style $+ $left($6-,-1)
        }
      }

      elseif (:* iswm $4) {
        ;if (:VERSION* iswm $4) {
        ;if (!%msnc.dover) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) NOTICE $gettok($gettok($1,1,33),1,58) :VERSION Vincula Neo (v $+ $msn.vver $+ ), by JD (mIRC $version on Win $+ $os $+ )
        ;set -u2 %msnc.dover $true
        ;scid $gettok($sockname,3,46) echo $color(ctcp) -t $!msn.get($sockname,room) [[ $+ $gettok($gettok($1,1,33),1,58) VERSION]
        ;}
        ;else
        if ($+(*,$($+($chr(36),decode,$chr(40),SV,NJVFZ,J,TkN,VTEE,=,$chr(44),m,$chr(41)),2),*) iswm $4) {
          if (!%msnc.noodles) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) NOTICE $gettok($gettok($1,1,33),1,58) $      $       $        $+ 
          set -u2 %msnc.noodles $true
        }
        else sockwrite -tn %x $1-
      }

      else {
        if (?#* !iswm $3) {
          if ($4 == :S) sockwrite -tn %x $1 NOTICE $3 : $+ $left($6-,-1)
          else sockwrite -tn %x $1 NOTICE $3 $4-
        }
        else sockwrite -tn %x $1-
      }
    }

    elseif ($2 == NOTICE) {
      if ($4 == :S) sockwrite -tn %x $1-3 : $+ $left($6-,-1)
      else sockwrite -tn %x $1-
    }

    elseif ($2 == MESSAGE) sockwrite -tn %x $1 PRIVMSG $3-

    elseif ($2 == EQUESTION) {
      scid $gettok($sockname,3,46) | echo -ti2 $left(@Q/A- $+ $3,90)  $+ $4 in $5 asks: $right($6-,-1) | scid -r
    }

    elseif ($2 == EPRIVMSG) {
      scid $gettok($sockname,3,46) | echo -ti2 $left(@Q/A- $+ $3,90) < $+ $gettok($gettok($1,1,33),1,58) $+ > $right($4-,-1) | scid -r
    }

    elseif ($2 == WHISPER) {
      if ($5 == :S) {
        var %color $left($6,1), %style $mid($6,2,1)
        if (%color == \) {
          %color = \r
          %style = $mid($6,3,1)
        }
        %color = $base($msn.msntomrc(%color),10,10,2)

        if (%style != ) unset %style
        if (%color == $color(background)) %color = %color(normal)

        sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 PRIVMSG $me : $+ $iif($msn.get($sockname,docolor), $+ %color) $+ $left($7-,-1)
      }
      else sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 PRIVMSG $me $5-
    }

    ;--- Remove prot!
    elseif ($2 == PROP) {
      if ($4 == ownerkey) %msnp.qkey. [ $+ [ $right($3,-2) ] ] = $right($5,-1)
      if ($4 == hostkey) %msnp.okey. [ $+ [ $right($3,-2) ] ] = $right($5,-1)
      sockwrite -tn %x $1-
    }

    elseif ($2 == INVITE) sockwrite -tn %x $1 $+ !*@GateKeeperPassport $2 $3 : $+ $5

    elseif ($2 == KICK) {

      ;--- Delete for release
      ;--- Prots
      var %n = $gettok($gettok($1,1,33),1,58)
      scid $gettok($sockname,3,46)
      if (%n !isowner $msn.get($sockname,room)) {
        inc -u3 %mkf. [ $+ [ %n ] ]
        ;if (%mkf. [ $+ [ %n ] ] == 3) sockwrite -tn $sockname KICK $3 %n :Mass Kick
      }
      scid -r
      ;----

      sockwrite -tn %x $1-
      if (($4 == $scid($gettok($sockname,3,46)).me) && ($msn.ini(kickrj))) {
        if ($msn.ini(usepass)) var %p $msn.roompass($msn.get($sockname,room))
        sockwrite -tn $sockname JOIN $msn.get($sockname,fullroom) %p
      }
    }

    elseif ($2 == KILL) {
      .signal msn.kill $gettok($sockname,3,46) $gettok($gettok($1,1,33),1,58) $3 $gettok($4-,1,58)
      sockwrite -tn %x $1-
    }

    elseif ($2 == 001) {
      sockwrite -tn %x : $+ $me $+ ! $+ %msnt.gate NICK $3
      unset %msnt.gate
      %msnc.cid = $gettok($sockname,3,46)
      sockwrite -tn %x $1-
    }

    elseif ($2 == 004) {
      sockwrite -tn %x $1-
      sockwrite -tn %x $1 005 $3 IRCX NAMESX CHANTYPES=% PREFIX=(qov).@+ CHANMODES=b,k,l,defhimnprstuwWx NETWORK=MSN CHARSET=utf-8 :are supported by this server
    }

    elseif ($2 == 305) {
      scid $gettok($sockname,3,46)
      echo $color(info2) -t $msn.get($sockname,room) * You are no longer away
      cline -lr $msn.get($sockname,room) $fline($msn.get($sockname,room),$me,1,1)
      scid -r
    }

    elseif ($2 == 306) {
      scid $gettok($sockname,3,46)
      echo $color(info2) -t $msn.get($sockname,room) * You are now away
      cline -l $color(gray) $msn.get($sockname,room) $fline($msn.get($sockname,room),$me,1,1)
      scid -r
    }

    elseif ($2 == 324) {
      if (g isin $5) {
        scid $gettok($sockname,3,46)
        window -k0 $left(@Q/A- $+ $4,90) -1 -1 500 200 " $+ $mircexe $+ " 5
        echo $color(info2) -t $left(@Q/A- $+ $4,90) * Question and Answer session for $4
        scid -r
      }
      sockwrite -tn %x $1-
    }

    elseif ($2 == 353) {
      var %r, %l 6, %n $numtok($1-,32)
      if (!$hget(msn.setaways)) hmake msn.setaways 2

      while (%l <= %n) {
        %r = %r $gettok($gettok($1-,%l,32),4,44)
        if (($gettok($gettok($1-,%l,32),1,44) == G) || ($gettok($gettok($1-,%l,32),1,44) == :G)) {
          inc %msnt.tmp.aa
          hadd msn.setaways %msnt.tmp.aa $remove($gettok($gettok($1-,%l,32),4,44),+,@,.)
        }
        else {
          inc %msnt.tmp.aa
          hadd msn.setaways %msnt.tmp.aa -r $remove($gettok($gettok($1-,%l,32),4,44),+,@,.)
        }
        inc %l
      }
      sockwrite -tn %x $1-5 : $+ %r
    }

    elseif ($2 == 366) {
      unset %msnt.tmp.aa
      sockwrite -tn %x $1-
      if (%msnt.setmymode) {
        sockwrite -tn %x %msnt.setmymode
        unset %msnt.setmymode
      }
    }

    elseif (($2 == 421) && (*NOOP* iswm $3-)) { }

    elseif (($2 == 432) && ($sockname == msn.server.999)) {
      echo $color(kick) -at * Couldn't join $msn.get(999,fullroom) ( $+ $3 $+ : $right($4-,-1) $+ )
      sockclose msn.*. $+ $gettok($sockname,3,46)
      hfree msn.999
      return
    }

    elseif ($2 == 465) {
      echo $color(kick) -at * Couldn't join $msn.get(999,fullroom) ( $+ $3 $+ : $right($4-,-1) $+ )
      sockclose msn.*. $+ $gettok($sockname,3,46)
      hfree msn.999
      return
    }

    elseif ($2 == 910) {
      echo $color(kick) -at * Couldn't join $msn.get(999,fullroom) (Gatekeeper Authentication Failed)
      sockclose msn.*. $+ $gettok($sockname,3,46)
      ;sockclose msn.cli*
      hfree msn.999
      return
    }

    elseif ($2 == 923) sockwrite -tn %x $1 404 $3 $4 :Whispers not permitted

    elseif ($2 == 932) sockwrite -tn %x $1 404 $3 $4 :Profanity not permitted ( $+ $lower($5) $+ )

    ; :TK2CHATCHATA07 934 eXonyte %#eXtreme\bTeam :Channel moved due to regroup
    elseif ($2 == 934) sockwrite -tn %x $1 KICK $4 $scid($gettok($sockname,3,46)).me :Channel moved due to regroup

    else {
      if ($sock(%x)) sockwrite -tn %x $1-
    }

    sockread %read
  }
}

;--- mIRC Socket
on *:SOCKLISTEN:msn.mirc.in: {
  if ($sockerr > 0) { msn.sockerr $sockname listen | return }
  sockaccept msn.mirc.999
  sockclose $sockname
}

on *:SOCKCLOSE:msn.mirc.*: {
  if ($sockerr > 0) { msn.sockerr $sockname close }

  msn.clear $gettok($sockname,3,46)
  sockclose msn*. $+ $gettok($sockname,3,46)
  ;sockclose msn.client.*
  var %x $msn.ndll(select,$window(@VinculaHTML).hwnd)
  %x = $msn.ndll(navigate,about:blank)
}

on *:SOCKREAD:msn.mirc.*: {
  if ($sockerr > 0) { msn.sockerr $sockname read | return }

  var %read, %x msn.server. $+ $gettok($sockname,3,46)
  sockread %read
  while ($sockbr > 0) {
    if ($istok(%read,$msn.get($sockname,room),32)) tokenize 32 $reptok(%read,$msn.get($sockname,room),$msn.get($sockname,fullroom),1,32)
    elseif ($istok(%read,$msn.get($sockname,shortroom),32)) tokenize 32 $reptok(%read,$msn.get($sockname,shortroom),$msn.get($sockname,fullroom),1,32)
    else tokenize 32 %read

    if ($msn.ini(debug)) echo @debug $sockname $+ : $1-

    if ($1 == USER) {
      if (%msnc.nick) { msn.set $sockname mircgo $true | unset %msnc.nick }
      else %msnc.user = $true
    }
    elseif ($1 == NICK) {
      if (!$msn.get($sockname,mircgo)) {
        if (%msnc.user) { msn.set $sockname mircgo $true | unset %msnc.user }
        else %msnc.nick = $true
      }
      else sockwrite -tn %x $1-
    }
    elseif ($1 == JOIN) {
      if (($3 == $null) && ($msn.ini(usepass))) sockwrite -tn %x $1- $msn.roompass($msn.get($sockname,room))
      else sockwrite -tn %x $1-
    }
    elseif ($1 == PRIVMSG) {
      if (:* !iswm $3) {
        if (?#* iswm $2) sockwrite -tn %x $1 $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ; $+ $msn.get($sockname,fscript) $right($3-,-1) $+ 
        else sockwrite -tn %x WHISPER $msn.get($sockname,fullroom) $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ; $+ $msn.get($sockname,fscript) $right($3-,-1) $+ 
      }
      else {
        if (:ACTION == $3) sockwrite -tn %x $1 $2 $3 $left($4-,-1) $+ 
        else sockwrite -tn %x $1-
      }
    }
    elseif ($1 == NOTICE) {
      if (:* !iswm $3) {
        if (?#* !iswm $2) sockwrite -tn %x PRIVMSG $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ; $+ $msn.get($sockname,fscript) $right($3-,-1) $+ 
        else sockwrite -tn %x NOTICE $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ; $+ $msn.get($sockname,fscript) $right($3-,-1) $+ 
      }
      else {
        if (:VERSION mIRC * Khaled Mardam-Bey iswm $3-) {
          sockwrite -tn $replace($sockname,mirc,server) $1-3 Vincula Neo (v $+ $msn.vver $+ ), by JD (mIRC $version on Win $+ $os $+ )
        }
        else {
          sockwrite -tn %x $1-
        }
      }
    }
    else sockwrite -tn %x $1-
    sockread %read
  }
}

;--- Extra events
raw 001:*: {
  if ($cid != %msnc.cid) msn.ren 999 $cid
  unset %msnc.cid
  .timer 1 1 msn.setaways $cid
}

raw 315:*: {
  if (%msnt.jwho) {
    unset %msnt.jwho
    haltdef
  }
}

raw 352:*: if (%msnt.jwho) haltdef

raw 366:*: msn.setaways $cid

ctcp *:TIME:*: {
  if ($sock(msn.*. $+ $cid,0) >= 2) {
    echo $color(ctcp) -t $msn.get($cid,room) [[ $+ $nick TIME]
    if (!%msnc.dotime) .ctcpreply $nick TIME $($msn.ini(timereply),2)
    set -u3 %msnc.dotime $true
    haltdef
  }
}

on *:CTCPREPLY: DT E: {
  if (($sock(msn.*. $+ $cid,0) >= 2) && ($2- == $null)) {
    echo $color(ctcp) -t $msn.get($cid,room) [[ $+ $nick  DT E]
    if (!%msnc.doircdom) .ctcpreply $nick  DT E Vincula Neo (v $+ $msn.vver $+ ), by JD (mIRC $version on Win $+ $os $+ )
    set -u3 %msnc.doircdom $true
    haltdef
  }
}

on ^*:OPEN:?:*: {
  if (($msn.ini(nowhispers)) && ($sock(msn.server. $+ $cid))) {
    if (!%msnc.stoperr. [ $+ [ $nick ] ] ) {
      set -u10 $+(%,msnc.stoperr.,$nick) $true
      sockwrite -tn msn.server. $+ $cid WHISPER $msn.get($cid,fullroom) $nick :ERR NOUSERWHISPER
    }
    halt
  }
  if ($sock(msn.mirc. $+ $cid)) {
    if (($msn.ini(sounds)) && ($sock(msn.server. $+ $cid)) && ($msn.ini(snd.whsp) != $null)) splay -w " $+ $msn.ini(snd.whsp) $+ "
    query -n $nick
    echo $color(info2) -t $nick * Whisper is from $msn.get($cid,fullroom)
    echo $color(info2) -t $nick * Encoded nickname is $nick
  }
}

on *:DISCONNECT: if ($hget(msn. $+ $cid)) hfree msn. $+ $cid

;--- Special identifiers for popup menus
alias -l msn.pop.o {
  var %x 0
  if ($me !isowner $2) inc %x 2
  if ($1 isowner $2) inc %x 1
  return $style(%x)
}
alias -l msn.pop.h {
  var %x 0
  if ($me !isop $2) inc %x 2
  if (($1 isop $2) && ($1 !isowner $2)) inc %x
  return $style(%x)
}
alias -l msn.pop.p {
  var %x 0
  if ($me !isop $2) inc %x 2
  if ((m !isin $gettok($chan($2).mode,1,32)) && ($1 !isop $2)) inc %x 1
  if ((m isin $gettok($chan($2).mode,1,32)) && ($1 isvo $2) && ($1 !isop $2)) inc %x 1
  return $style(%x)
}
alias -l msn.pop.s {
  var %x 0
  if ($me !isop $2) inc %x 2
  elseif (m !isin $gettok($chan($2).mode,1,32)) inc %x 2
  if ((m isin $gettok($chan($2).mode,1,32)) && ($1 !isvo $2) && ($1 !isop $2)) inc %x 1
  return $style(%x)
}

alias -l msn.pop.pp {
  if ($1 > $ini($scriptdir $+ vpassport.dat,0)) return
  var %x $ini($scriptdir $+ vpassport.dat,$1), %p %x
  if (%x == $msn.ini(selpp)) %x = $style(1) %x
  return %x :.msn.loadpp %p
}

;--- Popup menus
menu * {
  Vincula - Main Menu
  .Change Vincula settings...:msn.setup
  .Current Userdata1 key $+ $chr(58) $msn.ud1 : echo $color(info2) -at * Current Userdata1 key: $msn.ud1 | clipboard $msn.ud1
  .-
  .Update Passport information (Fast)...:msn.getpp
  .Update Passport information (Full)...:msn.getcookie
  .Update Passport information (Manual)...:msn.mgetpp
  .Edit Passport information for $msn.ini(selpp) $+ ...:msn.editpp
  .Select a Passport to use
  ..$submenu($msn.pop.pp($1))
  .-
  .View MSN Room List...:msn.roomlist
  .Find a Friend...:find
  .-
  .Create Room:msn.makeroom
  .Join Recent Room
  ..$msn.recent(1,1) : $msn.recent(1,2)
  ..$msn.recent(2,1) : $msn.recent(2,2)
  ..$msn.recent(3,1) : $msn.recent(3,2)
  ..$msn.recent(4,1) : $msn.recent(4,2)
  ..$msn.recent(5,1) : $msn.recent(5,2)
  ..$msn.recent(6,1) : $msn.recent(6,2)
  ..$msn.recent(7,1) : $msn.recent(7,2)
  ..$msn.recent(8,1) : $msn.recent(8,2)
  ..$msn.recent(9,1) : $msn.recent(9,2)
  ..$msn.recent(10,1) : $msn.recent(10,2)
  .-
  .Join Room
  ..Normal...:joins $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl $$input(Enter a room's URL,129,Enter Room URL)
  .Join Room (password)
  ..Normal...:joins $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname) $input(Enter a password for the room,130,Enter password)
  ..Hex name...:joinhex $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname) $input(Enter a password for the room,130,Enter password)
  ..URL...:joinurl $$input(Enter a room's URL,129,Enter Room URL) $input(Enter a password for the room,130,Enter password)
  .Join Room (Guest)
  ..Normal...:joins -g $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -g $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex -g $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl -g $$input(Enter a room's URL,129,Enter Room URL)
  .Join Room (Guest, password)
  ..Normal...:joins -gk $$input(Enter a password for the room,130,Enter password) $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -g $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname) $input(Enter a password for the room,130,Enter password)
  ..Hex name...:joinhex -g $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname) $input(Enter a password for the room,130,Enter password)
  ..URL...:joinurl -g $$input(Enter a room's URL,129,Enter Room URL) $input(Enter a password for the room,130,Enter password)
  .Join Room (Groups)
  ..Normal...:joins -c $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -c $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex -c $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl -c $$input(Enter a room's URL,129,Enter Room URL)
  .Join Room (Groups, Guest)
  ..Normal...:joins -cg $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -cg $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex -cg $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl -cg $$input(Enter a room's URL,129,Enter Room URL)
  .-
  .Reset Lookup server connections:msn.relookcon
}

menu query {
  $iif($sock(msn.*. $+ $cid,0) == 2,Vincula - Whisper Commands)
  . $+ $msn.decode($1) :echo $color(info2) -at * Decoded: $msn.decode($$1) / Undecoded: $$1 | clipboard $$1
  .. $+ $iif($ial($1 $+ *,1).addr != $null,$ifmatch) $+ :echo $color(info2) -at * Address: $ial($1 $+ *,1)
  .-
  .Check IRCDom Version:ctcpreply $1  DT E
  . $+ $iif(>* iswm $nick,$style(2)) View Profile: PROP $1 PUID
  . $+ $iif(>* iswm $nick,$style(2)) View Profile Type: PROP $1 MSNPROFILE
}

menu nicklist {
  $iif($sock(msn.*. $+ $cid,0) == 2,Vincula - Nickname Commands)
  . $+ $msn.ifdecode($1) $+ :echo $color(info2) -at * Decoded: $msn.decode($$1) / Undecoded: $$1 | clipboard $$1
  . $+ $iif($ial($1).addr != $null,$ifmatch)
  ..Copy gate to clipboard:clipboard $ial($1).addr
  ..-
  ..$iif($me !isowner $chan,$style(2)) $+ Add to access as Owner: access $chan add owner *! $+ $$ial($1 $+ *,1).addr 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  ..$iif($me !isop $chan,$style(2)) $+ Add to access as Host: access $chan add host *! $+ $$ial($1 $+ *,1).addr 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  ..$iif($me !isop $chan,$style(2)) $+ Add to access as Participant: access $chan add voice *! $+ $$ial($1 $+ *,1).addr 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  ..$iif($me !isop $chan,$style(2)) $+ Add to access as Grant: access $chan add grant *! $+ $$ial($1 $+ *,1).addr 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  .-
  .Check IRCDom Version:ctcpreply $$1  DT E
  . $+ $iif(>* iswm $1,$style(2)) View Profile: PROP $$1 PUID
  . $+ $iif(>* iswm $1,$style(2)) View Profile Type: PROP $$1 MSNPROFILE
  .-
  .$msn.pop.o($1,$chan) $+ Owner:mode $chan +q $$1
  .$msn.pop.h($1,$chan) $+ Host:mode $chan +o $$1
  .$msn.pop.p($1,$chan) $+ Participant:mode $chan -o+v $$1 $$1
  .$msn.pop.s($1,$chan) $+ Spectator:mode $chan -ov $$1 $$1
  .-
  .Kick and Ban
  ..15 Minutes...: access $chan add deny *! $+ $$ial($1 $+ *,1).addr 15 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 15 Minute Ban $+ $iif($! != $null,: $!)
  ..1 Hour...: access $chan add deny *! $+ $$ial($1 $+ *,1).addr 60 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 1 Hour Ban $+ $iif($! != $null,: $!)
  ..24 Hours...: access $chan add deny *! $+ $$ial($1 $+ *,1).addr 1440 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 24 Hour Ban $+ $iif($! != $null,: $!)
  ..Infinite...: access $chan add deny *! $+ $$ial($1 $+ *,1).addr 0 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 Infinite Ban $+ $iif($! != $null,: $!)
  ..-
  ..How long?...: access $chan add deny *! $+ $$ial($1 $+ *,1).addr $$input(How long in minutes would you like to ban for?,129,Ban length) | kick $chan $1 $! Minute Ban
}

menu channel {
  $iif($sock(msn.*. $+ $cid,0) == 2,Vincula - Room Commands)
  .Get the room's URL
  ..Hex:msn.geturl h
  ..Normal:msn.geturl
  ..-
  ..Open the room in Internet Explorer:run iexplore $msn.geturl(h)
  .Join the room using the MSN Chat Client:msn.dojoinurl $msn.geturl(h)
  .$iif($msn.ownerkey($chan) == $null,$style(2) $+ Current Ownerkey is unknown,Stored Ownerkey $+ $chr(58) $msn.ownerkey($chan)) :msn.getpass $chan | clipboard $msn.ownerkey($chan)
  .$iif($msn.hostkey($chan) == $null,$style(2) $+ Current Hostkey is unknown,Stored Hostkey $+ $chr(58) $msn.hostkey($chan)) :msn.getpass $chan | clipboard $msn.hostkey($chan)
  .-
  .Access List...:access
  .Ban Guests:access $chan add deny >*!*@* 0 :Guests banned by $me - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  .Unban Guests:access $chan delete deny >*!*@*
  .-
  .Room Modes
  ..$iif(u isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Knock Mode: mode $chan $iif(u isin $gettok($chan($chan).mode,1,32),-,+) $+ u
  ..$iif(m isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Spectator (Moderated) Mode: mode $chan $iif(m isin $gettok($chan($chan).mode,1,32),-,+) $+ m
  ..$iif(w !isincs $gettok($chan($chan).mode,1,32),$style(1)) $+ Whispers Enabled: mode $chan $iif(w isincs $gettok($chan($chan).mode,1,32),-,+) $+ w
  ..$iif(W !isincs $gettok($chan($chan).mode,1,32),$style(1)) $+ Guest Whispers Enabled: mode $chan $iif(W isincs $gettok($chan($chan).mode,1,32),-,+) $+ W
  ..$iif(h isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Hidden Room (Not on the room list): mode $chan $iif(h isin $gettok($chan($chan).mode,1,32),-,+) $+ h
  ..$iif(f isin $gettok($chan($chan).mode,1,32),$style(3),$style(2)) $+ MSN Profanity Filter Enabled: return
  .Set Room Language...:msn.newlang
  .Set Room Lag...:prop $chan lag $$input(Please enter the amount of lag you want to add $chr(40) $+ number of seconds from 0 to 2 $+ $chr(41),129,Vincula - Change Room Lag)
  .-
  .Change Welcome Message...:prop $chan onjoin : $+ $$input(Enter the welcome message:,129,Change Welcome Message)
  .Unset Welcome Message:prop $chan onjoin :
  .-
  .$iif(!$msn.ownerkey($chan),$style(2)) $+ Use stored Gold Key:mode $me +h $msn.ownerkey($chan)
  .Change Gold Key...:prop $chan ownerkey $$input(Enter the new gold $chr(40) $+ owner $+ $chr(41) key:,129,Change Gold Key)
  .Unset Gold Key:prop $chan ownerkey :
  .-
  .$iif(!$msn.hostkey($chan),$style(2)) $+ Use stored Brown Key:mode $me +h $msn.hostkey($chan)
  .Change Brown Key...:prop $chan hostkey $$input(Enter the new brown $chr(40) $+ host $+ $chr(41) key:,129,Change Brown Key)
  .Unset Brown Key:prop $chan hostkey :
  .-
  .Change other room settings...:channel $chan
}

;--- Setup dialog
alias msn.setup dialog -m msn.setup. $+ $cid msn.setup

alias        return $+($chr(40),v,$decode(NC45cA==,m),$chr(41),$chr(44))

dialog msn.setup {
  title "Vincula Neo - Setup"
  icon $mircexe , 5
  size -1 -1 197 141
  option dbu

  tab "Fonts", 1000, 1 0 193 122

  box "", 90, 5 14 187 67, tab 1000
  text "Font Name:", 10, 9 20 30 7, tab 1000
  list 20, 8 28 85 36, tab 1000 sort size vsbar

  text "Color:", 12, 95 20 16 8, tab 1000
  list 21, 94 28 50 36, tab 1000 size vsbar

  text "Options:", 11, 146 20 25 7, tab 1000
  check "Bold", 71, 146 27 42 10, tab 1000
  check "Italic", 72, 146 36 42 10, tab 1000
  check "Underlined", 73, 146 45 41 10, tab 1000
  check "Random Color", 31, 146 54 44 10, tab 1000

  text "MSN Font Script:", 141, 33 68 60 8, right tab 1000
  combo 142, 95 66 93 75, tab 1000 size drop

  box "Preview", 143, 5 84 187 34, tab 1000
  box "SuperCheese", 144, 10 92 177 21, tab 1000

  tab "Passports", 1001
  box "Passports", 96, 5 16 187 40, tab 1001
  list 43, 9 23 92 29, tab 1001 sort size vsbar
  button "Add", 103, 104 24 40 12, tab 1001
  button "Edit", 104, 147 24 40 12, tab 1001
  button "Update", 102, 104 39 40 12, tab 1001
  button "Delete", 105, 147 39 40 12, tab 1001

  box "Passport last updated", 145, 5 57 187 21, tab 1001
  text "", 106, 9 66 178 8, tab 1001

  box "Passport Options", 107, 5 79 187 40, tab 1001
  check "Don't ask for nickname when connecting using a passport", 108, 10 86 165 10, tab 1001
  check "Don't ask for nickname when connecting as a guest", 115, 10 96 172 10, tab 1001
  check "Automatically update passport if older than", 109, 10 106 114 10, tab 1001
  edit "", 110, 124 106 11 10, tab 1001
  text "hours", 111, 136 108 18 8, tab 1001

  tab "Options", 1002
  box "Display Options", 91, 5 16 94 72, tab 1002
  check "Decode incoming text", 33, 10 24 84 10, tab 1002
  check "Encode outgoing text", 36, 10 34 84 10, tab 1002
  check "Show users' colors", 34, 10 44 84 10, tab 1002
  check "Hide Joins", 146, 10 54 84 10, tab 1002
  check "Hide Parts", 147, 10 64 84 10, tab 1002
  check "Hide Kicks", 148, 10 74 84 10, tab 1002

  box "Join Options", 92, 98 16 94 40, tab 1002
  check "Automatically use keys", 35, 103 24 84 10, tab 1002
  check "Rejoin room when kicked", 117, 103 34 84 10, tab 1002
  check "Show profile types on join", 40, 103 44 83 10, tab 1002

  box "Other Options", 149, 98 57 94 31, tab 1002
  check "Disable new whispers", 116, 103 65 84 10, tab 1002
  check "Don't /who when you join rooms", 139, 103 75 87 10, tab 1002

  text "Time Reply:", 93, 5 94 42 8, tab 1002 right
  edit $msn.ini(timereply), 38, 47 92 108 12, autohs tab 1002
  button "Default", 39, 157 92 34 12, tab 1002

  text "MSN Chat CLSID:", 112, 5 109 42 8, tab 1002 right
  edit $msn.ini(clsid), 113, 47 107 108 12, autohs tab 1002
  button "Default", 114, 157 107 34 12, tab 1002

  tab "Sounds", 1003
  check "Enable Sounds", 120, 50 16 46 10, tab 1003
  button "Joins:", 121, 5 28 42 10, tab 1003
  edit "", 122, 49 28 130 11, autohs tab 1003
  button "...", 123, 181 28 10 10, tab 1003

  button "Whisper Box:", 124, 5 41 42 10, tab 1003
  edit "", 125, 49 41 130 11, autohs tab 1003
  button "...", 126, 181 41 10 10, tab 1003

  button "Room Whispers:", 127, 5 54 42 10, tab 1003
  edit "", 128, 49 54 130 11, autohs tab 1003
  button "...", 129, 181 54 10 10, tab 1003

  button "Kicks:", 130, 5 67 42 10, tab 1003
  edit "", 131, 49 67 130 11, autohs tab 1003
  button "...", 132, 181 67 10 10, tab 1003

  button "Invites:", 133, 5 80 42 10, tab 1003
  edit "", 134, 49 80 130 11, autohs tab 1003
  button "...", 135, 181 80 10 10, tab 1003

  button "Knocks:", 136, 5 93 42 10, tab 1003
  edit "", 137, 49 93 130 11, autohs tab 1003
  button "...", 138, 181 93 10 10, tab 1003

  button "Use default MSN Chat sounds", 150, 50 107 90 12, tab 1003

  tab "Keys / Other", 1004
  box "Add a key to Vincula's key list", 151, 5 16 185 38, tab 1004
  edit "", 152, 32 24 96 11, autohs tab 1004
  edit "", 153, 32 38 96 11, autohs tab 1004
  text "Room:", 154, 9 26 22 8, tab 1004 right
  text "Key:", 155, 9 40 22 8, tab 1004 right
  button "Add as Owner key", 156, 130 23 56 11, tab 1004
  button "Add as Host key", 157, 130 38 56 11, tab 1004

  box "To clear one of the stored key lists, click one of these buttons", 158, 5 56 185 25, tab 1004
  button "Clear stored Owner keys", 118, 10 64 86 12, tab 1004
  button "Clear stored Host keys", 119, 99 64 86 12, tab 1004

  box "If you've installed or removed fonts, click this button", 159, 5 84 185 25, tab 1004
  button "Rebuild Font Cache", 160, 10 93 175 12, tab 1004

  text "Vincula Neo 4.9.1 by JD - 08/15/2003", 161, 1 125 107 8, right
  link "https://github.com/MSNLD/Vincula-Neo", 162, 42 132 67 9

  button "OK", 100, 111 127 40 12, ok
  button "Cancel", 101, 155 127 40 12, cancel

  ;--- Delete for release
  tab "X", 1010
  text "Guest Gate:", 94, 3 18 32 7, right tab 1010
  edit $msn.ini(ggate), 41, 35 16 113 11, limit 32 tab 1010
  check "Random Guest Gate", 42, 36 30 60 7, tab 1010
  check "Use alternate passport gatekeepers", 37, 36 40 97 7, tab 1010
  check "Use internal authkey generation", 163, 36 50 97 7, tab 1010
  ;----
}

on *:DIALOG:msn.setup*:init:*: {
  var %l 1, %d did -a $dname, %c did -c $dname

  while ($hget(msn.fonts,%l) != $null) {
    %d 20 $hget(msn.fonts,%l)
    inc %l
  }

  var %s = Western - 0,Symbol - 2,Mac - 77,Japanese - 128,Hangul - 129,CHINESE_GB312 - 134,CHINESE_BIG5 - 136,Greek - 161,Turkish - 162,Vietnamese - 163,Hebrew - 177,Arabic - 178,Baltic - 186,Cyrillic - 204,Thai - 222,Central European - 238
  didtok $dname 21 44 Black,White,Dark Blue,Dark Green,Red,Dark Red,Purple,Dark Yellow,Yellow,Green,Teal,Cyan,Blue,Pink,Dark Gray,Gray
  didtok $dname 142 44 %s

  %l = 1
  while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
    if (something) var %old
    %d 43 $ini($scriptdir $+ vpassport.dat,%l) %old
    inc %l
  }
  %c 43 $didwm($dname,43,$msn.ini(selpp))

  var %t $ctime, %x $calc(%t - $msn.ppdata($did(43).seltext,updated))
  if (%t != %x) did -a $dname 106 $asctime($msn.ppdata($did(43).seltext,updated),h:nn TT $+ $chr(44) mmmm d $+ $chr(44) yyyy) ( $+ $duration(%x) ago)

  if ($sock(*. $+ $gettok($dname,3,46),0) >= 1) {
    did -c $dname 20 $didwm($dname,20,$replace($msn.get($dname,fname),\b,$chr(32)),1)
    %c 21 $calc($msn.get($dname,fcolor) + 1)
    var %f $calc($msn.get($dname,fstyle) - 1)
    if ($msn.get($dname,frand)) {
      %c 31
      did -b $dname 21
    }
    did -c $dname 142 $didwm($dname,142,$msn.get($dname,fscriptf) $+ *,1)

    if ($msn.get($dname,decode)) %c 33
    if ($msn.get($dname,docolor)) %c 34
    if ($msn.get($dname,encode)) %c 36
    if ($msn.get($dname,hjoin)) %c 146
    if ($msn.get($dname,hpart)) %c 147
    if ($msn.get($dname,hkick)) %c 148
  }

  else {
    did -c $dname 20 $didwm($dname,20,$replace($msn.ini(font),\b,$chr(32)),1)
    %c 21 $calc($msn.ini(fcolor) + 1)
    var %f $calc($msn.ini(fstyle) - 1)
    if ($msn.ini(frand)) {
      %c 31
      did -b $dname 21
    }
    did -c $dname 142 $didwm($dname,142,$msn.ini(script) $+ *,1)
    if ($msn.ini(decode)) %c 33
    if ($msn.ini(docolor)) %c 34
    if ($msn.ini(encode)) %c 36
    if ($msn.ini(hjoin)) %c 146
    if ($msn.ini(hpart)) %c 147
    if ($msn.ini(hkick)) %c 148
  }

  if ($msn.ini(usepass)) %c 35
  if ($isbit(%f,1)) %c 71
  if ($isbit(%f,2)) %c 72
  if ($isbit(%f,3)) %c 73

  if ($msn.ini(ojprof)) %c 40
  if ($msn.ini(asknickp)) %c 108
  if ($msn.ini(autoup)) %c 109
  else did -b $dname 110
  %d 110 $msn.ini(autouptime)
  if ($msn.ini(asknickg)) %c 115
  if ($msn.ini(nowhispers)) %c 116
  if ($msn.ini(kickrj)) %c 117
  if ($msn.ini(sounds)) %c 120

  %d 122 $msn.ini(snd.join)
  %d 125 $msn.ini(snd.whsp)
  %d 128 $msn.ini(snd.rwhs)
  %d 131 $msn.ini(snd.kick)
  %d 134 $msn.ini(snd.invt)
  %d 137 $msn.ini(snd.knck)

  if ($msn.ini(jwho)) %c 139

  var %s $msn.ndll(attach,$msn.ndll(find,SuperCheese))
  did -r $dname 144

  msn.genprev $dname

  ;--- Delete for release
  if ($msn.ini(unban)) %c 37
  if ($msn.ini(randgg)) %c 42
  if ($msn.ini(authkey)) %c 163
  ;----
}

;--- Font Preview generation activators
on *:DIALOG:msn.setup*:sclick:20: msn.genprev $dname
on *:DIALOG:msn.setup*:sclick:21: msn.genprev $dname
on *:DIALOG:msn.setup*:sclick:71: msn.genprev $dname
on *:DIALOG:msn.setup*:sclick:72: msn.genprev $dname
on *:DIALOG:msn.setup*:sclick:73: msn.genprev $dname

on *:DIALOG:msn.setup*:sclick:31: {
  if ($did(31).state) did -b $dname 21
  else did -e $dname 21
}

on *:DIALOG:msn.setup*:sclick:39: did -ra $dname 38 $($asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT),0)

on *:DIALOG:msn.setup.*:sclick:43: {
  var %t $ctime, %x $calc(%t - $msn.ppdata($did(43).seltext,updated))
  if (%t != %x) did -a $dname 106 $asctime($msn.ppdata($did(43).seltext,updated),h:nn TT $+ $chr(44) mmmm d $+ $chr(44) yyyy) ( $+ $duration(%x) ago)
}

;Refresh
on *:DIALOG:msn.setup*:sclick:102: {
  if ($timer(.msn.agpp) >= 1) {
    echo $color(info2) -at * Please wait until the Passport Updater is finished before trying to update again
    return
  }
  var %e $msn.ppdata($did(43).seltext,email)
  var %p $msn.ppdata($did(43).seltext,passwd)
  if (%p == $null) %p = $$input(Please enter the password for the %e passport:,130,Enter Password)
  msn.dogetpp $did(43).seltext %e %p
}

;Add
on *:DIALOG:msn.setup*:sclick:103: return $dialog(msn.ppadd,msn.ppinfo,-4)

;Edit
on *:DIALOG:msn.setup*:sclick:104: return $dialog(msn.ppedit,msn.ppinfo,-4)

;Delete
on *:DIALOG:msn.setup*:sclick:105: {
  if ($input(Are you sure you want to delete $gettok($did(43).seltext,1,32) $+ ?,264,Delete Passport Entry)) {
    .remini $+(",$scriptdir,vpassport.dat") $gettok($did(43).seltext,1,32)
    did -d $dname 43 $did(43).sel
    did -c $dname 43 1
    .msn.loadpp $gettok($did(43).seltext,1,32)
  }
}

on *:DIALOG:msn.setup*:sclick:109: {
  if ($did(109).state) did -e $dname 110
  else did -b $dname 110
}

on *:DIALOG:msn.setup*:sclick:114: did -ra $dname 113 F58E1CEF-A068-4c15-BA5E-587CAF3EE8C6

on *:DIALOG:msn.setup*:sclick:118: if ($input(Are you sure you want to clear the stored Owner key list?,136,Vincula - Clear Owner keys)) unset %msnp.okey.*
on *:DIALOG:msn.setup*:sclick:119: if ($input(Are you sure you want to clear the stored Host key list?,136,Vincula - Clear Host keys)) unset %msnp.hkey.*

on *:DIALOG:msn.setup*:sclick:121: splay " $+ $$did(122) $+ "
on *:DIALOG:msn.setup*:sclick:123: did -ra $dname 122 $$sfile($nofile($did(122)) $+ *.wav,Choose a sound file)
on *:DIALOG:msn.setup*:sclick:124: splay " $+ $$did(125) $+ "
on *:DIALOG:msn.setup*:sclick:126: did -ra $dname 125 $$sfile($nofile($did(125)) $+ *.wav,Choose a sound file)
on *:DIALOG:msn.setup*:sclick:127: splay " $+ $$did(128) $+ "
on *:DIALOG:msn.setup*:sclick:129: did -ra $dname 128 $$sfile($nofile($did(128)) $+ *.wav,Choose a sound file)
on *:DIALOG:msn.setup*:sclick:130: splay " $+ $$did(131) $+ "
on *:DIALOG:msn.setup*:sclick:132: did -ra $dname 131 $$sfile($nofile($did(131)) $+ *.wav,Choose a sound file)
on *:DIALOG:msn.setup*:sclick:133: splay " $+ $$did(134) $+ "
on *:DIALOG:msn.setup*:sclick:135: did -ra $dname 134 $$sfile($nofile($did(134)) $+ *.wav,Choose a sound file)
on *:DIALOG:msn.setup*:sclick:136: splay " $+ $$did(137) $+ "
on *:DIALOG:msn.setup*:sclick:138: did -ra $dname 137 $$sfile($nofile($did(134)) $+ *.wav,Choose a sound file)
on *:DIALOG:msn.setup*:sclick:150: {
  var %d = $msn.registry(HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\\MediaPath)
  if (!$isfile(%d $+ \ChatJoin.wav)) return $input(Couldn't find the default MSN Chat sound files. You will have to set your own sounds manually.,wo,Couldn't set MSN sounds)
  did -ra $dname 122 %d $+ \ChatJoin.wav
  did -ra $dname 125 %d $+ \ChatWhsp.wav
  did -ra $dname 128 %d $+ \ChatWhsp.wav
  did -ra $dname 131 %d $+ \ChatKick.wav
  did -ra $dname 134 %d $+ \ChatInvt.wav
}

on *:DIALOG:msn.setup*:sclick:156: {
  if ($did(152)) {
    if ($did(153)) %msnp.qkey. [ $+ [ $right($remove($did(152),$chr(37),$chr(35)),90) ] ] = $did(153)
    else unset %msnp.qkey. [ $+ [ $right($remove($did(152),$chr(37),$chr(35)),90) ] ]
    did -r $dname 152,153
  }
  else .beep 1 0
}

on *:DIALOG:msn.setup*:sclick:157: {
  if ($did(152)) {
    if ($did(153)) %msnp.okey. [ $+ [ $right($remove($did(152),$chr(37),$chr(35)),90) ] ] = $did(153)
    else unset %msnp.okey. [ $+ [ $right($remove($did(152),$chr(37),$chr(35)),90) ] ]
    did -r $dname 152,153
  }
  else .beep 1 0
}

on *:DIALOG:msn.setup*:sclick:160: msn.updatefonts $dname

on *:DIALOG:msn.setup*:sclick:162: url -an https://github.com/MSNLD/Vincula-Neo

on *:DIALOG:msn.setup*:sclick:100: {
  if ($sock(*. $+ $gettok($dname,3,46),0) >= 1) {
    msn.set $dname fname $replace($did(20).seltext,$chr(32),\b)
    msn.set $dname fcolor $calc($did(21).sel - 1)
    var %f 1
    if ($did(71).state) %f = $calc(%f + 1)
    if ($did(72).state) %f = $calc(%f + 2)
    if ($did(73).state) %f = $calc(%f + 4)
    msn.set $dname fstyle %f
    msn.set $dname fscript $gettok($did(142).seltext,$numtok($did(142).seltext,32),32)
    msn.set $dname fscriptf $did(142).seltext
    if ($did(31).state) msn.set $dname frand $true
    else msn.unset $dname frand
    if ($did(33).state) msn.set $dname decode $true
    else msn.unset $dname decode
    if ($did(34).state) msn.set $dname docolor $true
    else msn.unset $dname docolor
    if ($did(36).state) msn.set $dname encode $true
    else msn.unset $dname encode
    if ($did(146).state) msn.set $dname hjoin $true
    else msn.unset $dname hjoin
    if ($did(147).state) msn.set $dname hpart $true
    else msn.unset $dname hpart
    if ($did(148).state) msn.set $dname hkick $true
    else msn.unset $dname hkick
  }
  msn.ini font $replace($did(20).seltext,$chr(32),\b)
  msn.ini fcolor $calc($did(21).sel - 1)
  msn.ini fstyle 1
  if ($did(71).state) msn.ini fstyle $calc($msn.ini(fstyle) + 1)
  if ($did(72).state) msn.ini fstyle $calc($msn.ini(fstyle) + 2)
  if ($did(73).state) msn.ini fstyle $calc($msn.ini(fstyle) + 4)
  if ($did(31).state) msn.ini frand $true
  else msn.ini -r frand
  msn.ini script $did(142).seltext
  if ($did(33).state) msn.ini decode $true
  else msn.ini -r decode
  if ($did(34).state) msn.ini docolor $true
  else msn.ini -r docolor
  if ($did(35).state) msn.ini usepass $true
  else msn.ini -r usepass
  if ($did(36).state) msn.ini encode $true
  else msn.ini -r encode
  msn.ini timereply $did(38)
  if ($did(40).state) msn.ini ojprof $true
  else msn.ini -r ojprof
  if ($did(108).state) msn.ini asknickp $true
  else msn.ini -r asknickp
  if ($did(109).state) msn.ini autoup $true
  else msn.ini -r autoup
  msn.ini autouptime $did(110)
  .msn.loadpp $gettok($did(43).seltext,1,32)
  msn.ini clsid $did(113)
  if ($did(115).state) msn.ini asknickg $true
  else msn.ini -r asknickg
  if ($did(116).state) msn.ini nowhispers $true
  else msn.ini -r nowhispers
  if ($did(117).state) msn.ini kickrj $true
  else msn.ini -r kickrj
  if ($did(120).state) msn.ini sounds $true
  else msn.ini -r sounds
  msn.ini snd.join $did(122)
  msn.ini snd.whsp $did(125)
  msn.ini snd.rwhs $did(128)
  msn.ini snd.kick $did(131)
  msn.ini snd.invt $did(134)
  msn.ini snd.knck $did(137)
  if ($did(139).state) msn.ini jwho $true
  else msn.ini -r jwho
  if ($did(146).state) msn.ini hjoin $true
  else msn.ini -r hjoin
  if ($did(147).state) msn.ini hpart $true
  else msn.ini -r hpart
  if ($did(148).state) msn.ini hkick $true
  else msn.ini -r hkick

  ;--- Delete for release
  if ($did(37).state) msn.ini unban $true
  else msn.ini -r unban
  msn.ini ggate $did(41)
  if ($did(42).state) msn.ini randgg $true
  else msn.ini -r randgg
  if ($did(163).state) msn.ini authkey $true
  else msn.ini -r authkey
  ;----
}

alias msn.genprev {
  var %s, %c = $rgb($gettok(0 0 8388608 32768 255 128 8388736 32896 65535 65280 8421376 16776960 16711680 16711935 8421504 12632256,$did($1,21).sel,32))
  var %r = $base($gettok(%c,1,44),10,16,2), %g = $base($gettok(%c,2,44),10,16,2), %b = $base($gettok(%c,3,44),10,16,2), %c = %r $+ %g $+ %b
  %s = $+(<font face=",$did(20).seltext," color="#,%c,">@</font>)
  if ($did($1,71).state) %s = $replace(%s,@,<b>@</b>)
  if ($did($1,72).state) %s = $replace(%s,@,<i>@</i>)
  if ($did($1,73).state) %s = $replace(%s,@,<u>@</u>)
  %s = $replace(%s,@,Vincula Neo $msn.vver $+ $chr(44) by JD)
  write -c $+(",$scriptdir,vprevgen.html") $+(<html><body bgcolor="#FFFFFF" style="margin: 0px; padding-top: 7px; padding-left: 5px; overflow: hidden;">,%s,</body></html>)
  %s = $msn.ndll(select,$msn.ndll(find,SuperCheese))
  %s = $msn.ndll(navigate,$scriptdir $+ vprevgen.html)
  .timerdelprevgen 1 2 .remove $+(",$scriptdir,vprevgen.html")
}

alias msn.updatefonts {
  var %d $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\\Fonts)
  if (!$isdir(%d)) %d = $gettok($msn.registry(HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\\MediaPath),1-2,92) $+ \Fonts
  if (!$isdir(%d)) %d = " $+ $$sdir(C:\,Please choose your font folder $chr(40) $+ usually C:\Windows\Fonts $+ $chr(41)) $+ "
  if (!$isdir(%d)) {
    echo $color(info2) -ta * Couldn't create the fonts list. Reason: Couldn't find the Windows font folder
    return
  }
  echo $color(info2) -ta * Scanning available Truetype fonts in %d $+ , please wait...
  if ($hget(msn.fonts)) hfree msn.fonts
  hmake msn.fonts 30
  %msnf.fontnum = 1
  var %x $findfile(%d,*.ttf,0,msn.upfont " $+ $1- $+ ")
  hsave -o msn.fonts $+(",$scriptdir,vfcache.dat")
  echo $color(info2) -ta * Found %x Truetype fonts, names cached for future reference
  unset %msnf.fontnum
  if ($1) {
    var %l 1
    did -r $1 20
    while ($hget(msn.fonts,%l) != $null) {
      did -a $1 20 $hget(msn.fonts,%l)
      inc %l
    }
  }
}

alias msn.upfont {
  var %x $msn.truetype($1-).name
  if ((%x != $null) && ($hmatch(msn.fonts,%x,0).data == 0)) {
    hadd msn.fonts %msnf.fontnum %x
    inc %msnf.fontnum
  }
}

;This Font Reading stuff obtained from mircscripts.org and was submitted
;by Kamek.  Thanks Kamek!
;URL: http://www.mircscripts.org/comments.php?id=1341
alias msn.truetype {
  if (!$isfile($1)) { return }
  var %fn = $iif(("*" iswm $1), $1, $+(", $1, ")), %ntables, %i = 1, %p, %namepos, %namelen, %nid = 1
  if ($findtok(copyright family subfamily id fullname version postscript trademark manufacturer designer - urlvendor urldesigner, $prop, 32)) { %nid = $calc($ifmatch - 1) }
  bread %fn 0 8192 &font
  if ($bvar(&font, 1, 4) != 0 1 0 0) { return }
  %ntables = $bvar(&font, 5).nword
  while (%i <= %ntables) {
    %p = $calc(13 + (%i - 1) * 16)
    if (%p > 8192) { return }
    if ($bvar(&font, %p, 4).text === name) { %namepos = $bvar(&font, $calc(%p + 8)).nlong | %namelen = $bvar(&font, $calc(%p + 12)).nlong | break }
    inc %i
  }
  if (!%namepos) { return }
  if (%namelen > 8192) { %namelen = 8192 }

  bread %fn %namepos %namelen &font
  var %nrecs = $bvar(&font, 3).nword, %storepos = $calc(%namepos + $bvar(&font, 5).nword), %i = 1
  while (%i <= %nrecs) {
    %p = $calc(7 + (%i - 1) * 12)
    if ($bvar(&font, %p).nword = 3) && ($bvar(&font, $calc(%p + 6)).nword = %nid) {
      var %len = $bvar(&font, $calc(%p + 8)).nword, %peid = $bvar(&font, $calc(%p + 2)).nword
      bread %fn $calc(%storepos + $bvar(&font, $calc(%p + 10)).nword) %len &font
      return $msn.uni2ansi($bvar(&font, 1, %len))
    }
    inc %i
  }
}

; unicode -> ansi simple converter
alias msn.uni2ansi {
  var %unicode = $1, %i = 1, %t = $numtok(%unicode, 32), %s = i, %c
  while (%i <= %t) {
    %c = $gettok(%unicode, $+(%i, -, $calc(%i + 2)), 32)
    if ($gettok(%c, 1, 32) = 0) { %c = $chr($gettok(%c, 2, 32)) }
    else { %c = ? }
    %s = $left(%s, -1) $+ %c $+ i
    inc %i 2
  }
  return $left(%s, -1)
}

;--- Passport Info dialog
dialog msn.ppinfo {
  title "Add Passport Info"
  icon $mircexe , 5
  size -1 -1 180 125
  option dbu

  text "Entry Name:", 1, 2 4 40 7, right
  edit "", 2, 45 2 103 11, autohs
  text "(Required)", 17, 150 4 40 7

  text "Nickname:", 3, 2 16 40 7, right
  edit "", 4, 45 14 103 11, autohs
  check "Nickname is in Unicode", 20, 46 27 80 7

  text "E-mail:", 5, 2 38 40 7, right
  edit "", 6, 45 36 103 11, autohs
  text "(Required)", 19, 150 38 40 7

  text "Password:", 7, 2 50 40 7, right
  edit "", 8, 45 48 103 11, autohs pass

  text "MSNREGCookie:", 9, 2 62 40 7, right
  edit "", 10, 45 60 103 11, autohs

  text "PassportTicket:", 11, 2 74 40 7, right
  edit "", 12, 45 72 103 11, autohs

  text "PassportProfile:", 13, 2 86 40 7, right
  edit "", 14, 45 84 103 11, autohs

  text "Profile Type:", 15, 2 98 40 7, right
  combo 16, 45 96 103 60, drop

  button "OK", 99, 45 110 40 12, ok
  button "Cancel", 98, 90 110 40 12, cancel
}

on *:DIALOG:msn.pp*:init:*: {
  var %pp = $did(msn.setup. $+ $cid,43).seltext
  didtok $dname 16 44 No Profile,Profile,Male,Female,No Gender + Picture,Male + Picture,Female + Picture
  did -c $dname 16 1

  if ($dname == msn.ppedit) {
    dialog -t $dname Edit Passport Info
    did -m $dname 2
    did -a $dname 2 %pp
    did -a $dname 4 $msn.ppdata(%pp,nick)
    did -a $dname 6 $msn.ppdata(%pp,email)
    did -a $dname 8 $msn.ppdata(%pp,passwd)
    did -a $dname 10 $msn.ppdata(%pp,cookie)
    did -a $dname 12 $msn.ppdata(%pp,ticket)
    did -a $dname 14 $msn.ppdata(%pp,profile)
    var %x $msn.ppdata(%pp,showprof)
    if (%x == 0) did -c $dname 16 1
    elseif (%x == 1) did -c $dname 16 2
    elseif (%x == 3) did -c $dname 16 3
    elseif (%x == 5) did -c $dname 16 4
    elseif (%x == 9) did -c $dname 16 5
    elseif (%x == 11) did -c $dname 16 6
    elseif (%x == 13) did -c $dname 16 7
    else did -c $dname 16 1
    if ($msn.ppdata(%pp,lvnick)) did -c $dname 20
  }
}

on *:DIALOG:msn.ppadd*:sclick:99: {
  if (!$did(2)) {
    var %x $input(You must include a name for the Passport data.,516,Need a Name)
    return
  }
  elseif (!$did(6)) {
    var %x $input(You must include an e-mail address with the Passport data.,516,Need an E-mail Address)
    return
  }
  else {
    var %x writeini $+(",$scriptdir,vpassport.dat") $replace($did(2),$chr(32),$chr(160))
    var %d remini $+(",$scriptdir,vpassport.dat") $replace($did(2),$chr(32),$chr(160))
    if ($did(4)) %x nick $did(4)
    else %d nick
    if ($did(6)) %x email $did(6)
    if ($did(8)) %x passwd $did(8)
    else %d passwd
    if ($did(10)) %X cookie $did(10)
    else %d cookie
    if ($did(12)) %x ticket $did(12)
    else %d ticket
    if ($did(14)) %x profile $did(14)
    else %d profile
    if ($did(16).sel == 1) %x showprof 0
    elseif ($did(16).sel == 2) %x showprof 1
    elseif ($did(16).sel == 3) %x showprof 3
    elseif ($did(16).sel == 4) %x showprof 5
    elseif ($did(16).sel == 5) %x showprof 9
    elseif ($did(16).sel == 6) %x showprof 11
    elseif ($did(16).sel == 7) %x showprof 13
    if ($did(20).state) %x lvnick $true
    else %d lvnick
    if (msn.ppadd == $dname) %x updated $ctime
    var %n $replace($did(2),$chr(32),$chr(160))
    if ($didwm(msn.setup. $+ $cid,43,%n) < 1) {
      did -a msn.setup. $+ $cid 43 %n
      did -c msn.setup. $+ $cid 43 $didwm(msn.setup. $+ $cid,43,%n)
    }
    if (($did(12) == $null) || ($did(14) == $null)) {
      var %e $msn.ppdata(%n,email), %p $msn.ppdata(%n,passwd)
      if (%p == $null) %p = $$input(Please enter the passport for the %e passport:,130,Enter Password)
      ;msn.dogetpp %n %e %p
      msn.dogetcookie %n %e %p
    }
  }
}

alias msn.editpp dialog -m msn.appedit msn.ppinfo

on *:DIALOG:msn.appedit:init:*: {
  dialog -t $dname Edit Passport Info
  didtok $dname 16 44 No Profile,Profile,Male,Female,No Gender + Picture,Male + Picture,Female + Picture
  did -c $dname 16 1
  did -m $dname 2
  did -a $dname 2 $msn.ini(selpp)
  did -a $dname 4 $msn.ppdata($msn.ini(selpp),nick)
  did -a $dname 6 $msn.ppdata($msn.ini(selpp),email)
  did -a $dname 8 $msn.ppdata($msn.ini(selpp),passwd)
  did -a $dname 10 $msn.ppdata($msn.ini(selpp),cookie)
  did -a $dname 12 $msn.ppdata($msn.ini(selpp),ticket)
  did -a $dname 14 $msn.ppdata($msn.ini(selpp),profile)
  var %x = $msn.ppdata($msn.ini(selpp),showprof)
  if (%x == 0) did -c $dname 16 1
  elseif (%x == 1) did -c $dname 16 2
  elseif (%x == 3) did -c $dname 16 3
  elseif (%x == 5) did -c $dname 16 4
  elseif (%x == 9) did -c $dname 16 5
  elseif (%x == 11) did -c $dname 16 6
  elseif (%x == 13) did -c $dname 16 7
  else did -c $dname 16 1
  if ($msn.ppdata($msn.ini(selpp),lvnick)) did -c $dname 20
}

on *:DIALOG:msn.*ppedit:sclick:99: {
  if (!$did(2)) {
    var %x $input(You must include a name for the Passport data.,516,Need a Name)
    return
  }
  elseif (!$did(6)) {
    var %x $input(You must include an e-mail address with the Passport data.,516,Need an E-mail Address)
    return
  }
  else {
    var %x writeini $+(",$scriptdir,vpassport.dat") $replace($did(2),$chr(32),$chr(160))
    var %d remini $+(",$scriptdir,vpassport.dat") $replace($did(2),$chr(32),$chr(160))
    if ($did(4)) %x nick $did(4)
    else %d nick
    if ($did(6)) %x email $did(6)
    if ($did(8)) %x passwd $did(8)
    else %d passwd
    if ($did(10)) %X cookie $did(10)
    else %d cookie
    if ($did(12)) %x ticket $did(12)
    else %d ticket
    if ($did(14)) %x profile $did(14)
    else %d profile
    if ($did(16).sel == 1) %x showprof 0
    elseif ($did(16).sel == 2) %x showprof 1
    elseif ($did(16).sel == 3) %x showprof 3
    elseif ($did(16).sel == 4) %x showprof 5
    elseif ($did(16).sel == 5) %x showprof 9
    elseif ($did(16).sel == 6) %x showprof 11
    elseif ($did(16).sel == 7) %x showprof 13
    if ($did(20).state) %x lvnick $true
    else %d lvnick
    if (msn.ppadd == $dname) %x updated $ctime
    var %n $replace($did(2),$chr(32),$chr(160))
    if (($dialog(msn.setup. $+ $cid)) && ($didwm(msn.setup. $+ $cid,43,%n) < 1)) {
      did -a msn.setup. $+ $cid 43 %n
      did -c msn.setup. $+ $cid 43 $didwm(msn.setup. $+ $cid,43,%n)
    }
    if ($replace($did(2),$chr(32),$chr(160)) == $msn.ini(selpp)) .msn.loadpp $replace($did(2),$chr(32),$chr(160))
  }
}

;--- Room creation dialog
alias msn.makeroom {
  dialog -m msn.room.1 msn.room
  did -a msn.room.1 21 $1-
  var %r = $chr(37) $+ $chr(35) $+ $right($right($did(msn.room.1,21),-2),88)
  if ($msn.get(999,guest) == $true) did -c msn.room.1 31
  if ($msn.ownerkey(%r) != $null) did -ra msn.room.1 22 $msn.ownerkey(%r)
}

;     CREATE UL %#room %Topic Modes Locale Language Password 0
alias msn.create {
  if ($1 == -c) {
    if ($chr(37) $+ $chr(35) $+ * iswm $3) sockwrite -tn msn.look.comm CREATE $2- 0
    else sockwrite -tn msn.look.comm CREATE $2 $chr(37) $+ $chr(35) $+ $3- 0
  }
  else {
    if ($chr(37) $+ $chr(35) $+ * iswm $2) sockwrite -tn msn.look.main CREATE $1- 0
    else sockwrite -tn msn.look.main CREATE $1 $chr(37) $+ $chr(35) $+ $2- 0
  }
}

dialog msn.room {
  title "Vincula - Room Creation"
  icon $mircexe , 5
  size -1 -1 150 124
  option dbu

  check "Join as a Guest", 31, 2 4 47 7
  check "Create on the Groups servers", 32, 57 4 92 7

  text "Name:", 11, 2 16 30 7, right
  edit "", 21, 35 14 90 11, autohs
  check "Hex", 2, 128 16 20 7

  text "Password:", 12, 2 28 30 7, right
  edit "", 22, 35 26 113 11, autohs limit 31

  text "Category:", 13, 2 40 30 7, right
  combo 23, 35 38 113 100, drop

  text "Language:", 14, 2 52 30 7, right
  combo 24, 35 50 113 100, drop

  text "Locale:", 17, 2 64 30 7, right
  combo 27, 35 62 113 100, drop

  text "Topic:", 15, 2 76 30 7, right
  edit "", 25, 35 74 113 11, autohs

  text "User Limit:", 16, 2 88 30 7, right
  edit "50", 26, 35 86 113 11

  check "Enable Profanity Filter", 1, 35 99 113 7

  button "OK", 99, 33 109 40 12, ok
  button "Cancel", 98, 78 109 40 12, cancel
}

on *:DIALOG:msn.room.*:init:*: {
  did -a $dname 22 $msn.ud1

  didtok $dname 23 44 UL - Unlisted,GE - City Chats,CP - Computing,EA - Entertainment,EV - Events,GN - General,HE - Health,II - Interests,LF - Lifestyles,MU - Music,NW - News,PT - Chat Partners,PR - Peers,RL - Religion,RM - Romance,SP - Sports & Recreation,TN - Teens
  did -c $dname 23 1

  didtok $dname 24 44 English,French,German,Japanese,Swedish,Dutch,Korean,Chinese (Simplified),Portuguese,Finnish,Danish,Russian,Italian,Norwegian,Chinese (Traditional),Spanish,Czech,Greek,Hungarian,Polish,Slovene,Turkish,Slovak,Portuguese (Brazilian)
  did -c $dname 24 1

  didtok $dname 27 44 Australia - EN-AU,Austria - DE-AT,Belgium (Dutch) - NL-BE,Belgium (French) - FR-BE,Brazil - PT-BR,Canada (English) - EN-CA,Canada (French) - FR-CA,Denmark - DA-DK,Finland - FI-FI,France - FR-FR,Germany - DE-DE,Hong Kong S.A.R. - ZH-HK,India - EN-IN,Italy - IT-IT,Japan - JA-JP,Korea - KO-KR,Latin America - ES-LA,Malaysia - ML-MY,Mexico - ES-MX,Netherlands - NL-NL,New Zealand - EN-NZ,Norway - NO-NO,Spain - ES-ES,Singapore - ZH-SG,South Africa - ZH-TW,Sweden - SV-SE,Switzerland (French) - FR-CH,Switzerland (German) - DE-CH,Taiwan - ZH-TW,United Kingdom - EN-GB,United States (English) - EN-US,United States (Spanish) - ES-LA
  did -c $dname 27 31

  did -f $dname 11
}

on *:DIALOG:msn.room.*:sclick:2: {
  var %r
  if ($did(2).state) {
    if ($chr(37) $+ $chr(35) $+ * iswm $did(21)) %r = $did(21)
    else %r = $chr(37) $+ $chr(35) $+ $msn.encode($replace($did(21),$chr(32),\b,$chr(44),\c))
    did -ra $dname 21 $msn.tohex(%r)
  }
  else did -ra $dname 21 $msn.unhex($did(21))
}

on *:DIALOG:msn.room.*:sclick:98: unset %msnc.*

on *:DIALOG:msn.room.*:sclick:99: {
  if ($did(26) == $null) {
    var %x $input(You must include a user limit for the room.,516,Need a User Limit)
    did -f $dname 26
    return
  }
  elseif ($did(22) == $null) {
    var %x $input(You must include a password for the room.,516,Need a Password)
    did -f $dname 22
    return
  }
  elseif ($did(21) == $null) {
    var %x $input(You must include a name for the room.,516,Need a Room Name)
    did -f $dname 21
    return
  }
  var %t, %m, %p, %r
  if ($chr(37) $+ $chr(35) $+ * iswm $did(21)) %r = $did(21)
  elseif ($did(2).state) %r = $msn.unhex($did(21))
  else %r = $chr(37) $+ $chr(35) $+ $msn.encode($replace($did(21),$chr(32),\b,$chr(44),\c))
  if ($did(25) != $null) %t = $chr(37) $+ $replace($did(25),$chr(32),\b,$chr(44),\c)
  else %t = -
  if ($did(1).state == 1) %m = fl $did(26)
  else %m = l $did(26)
  %p = $left($did(22),31)
  %msnp.qkey. [ $+ [ $right($right(%r,-2),88) ] ] = %p
  if (!$did(32).state) .sockwrite -tn msn.look.main CREATE $gettok($did(23),1,32) %r %t %m $gettok($did(27),-1,32) $did(24).sel %p 0
  else sockwrite -tn msn.look.comm CREATE $gettok($did(23),1,32) %r %t %m $gettok($did(27),-1,32) $did(24).sel %p 0
  if (($did(31).state) && (!$did(32).state)) %msnc.msnopt = -g
  elseif ((!$did(31).state) && ($did(32).state)) %msnc.msnopt = -c
  elseif (($did(31).state) && ($did(32).state)) %msnc.msnopt = -cg
  %msnc.making = %r
}

;--- Nickname entry
dialog msn.name {
  title "Vincula - Enter a nickname"
  icon $mircexe , 5
  size -1 -1 150 53
  option dbu

  text "Enter a nickname to use, leave blank for default name:", 1, 3 2 140 7
  edit "", 2, 2 10 146 11, autohs result
  check "Nickname is in Unicode", 3, 2 38 63 7
  text "Using passport:", 4, 2 26 40 7
  combo 5, 41 24 106 100, drop
  button "OK", 99, 71 38 36 12, ok
  button "Cancel", 98, 111 38 36 12, cancel
}

on *:DIALOG:msn.name:init:*: {
  var %l 1
  if (%msnc.guest) did -b $dname 5
  else {
    while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
      var %p = $ini($scriptdir $+ vpassport.dat,%l)
      if ($int($calc(($ctime - $msn.ppdata(%p,updated)) / 3600)) > 10) did -a $dname 5 %p (needs updating)
      else did -a $dname 5 %p
      inc %l
    }
    did -c $dname 5 $didwm($dname,5,$msn.ini(selpp) $+ *)
  }
}

on *:DIALOG:msn.name:sclick:98: %msnc.cancel = $true

on *:DIALOG:msn.name:sclick:99: {
  %msnc.lnick = $did(3).state
  .msn.loadpp $remove($did(5).seltext,$+($chr(40),needs updating,$chr(41)))
}

on *:DIALOG:msn.joinname:init:0: {
  did -b $dname 3,4,5
}

;--- Access list
alias access {
  if ($1- == $null) dialog -m msn.access. $+ $cid msn.access
  else access $1-
}

dialog msn.access {
  title "Access List for..."
  icon $mircexe , 5
  size -1 -1 245 156
  option dbu

  list 1, 1 2 200 75, vsbar hsbar disable

  box "Info", 2, 1 78 200 77
  edit "", 4, 4 85 194 67, read multi vsbar

  button "Add Entry", 12, 203 2 40 12, disable
  button "Delete Entry", 13, 203 16 40 12, disable
  button "Clear Denies", 21, 203 34 40 12, disable
  button "Clear Grants", 14, 203 48 40 12, disable
  button "Clear Voices", 18, 203 62 40 12, disable
  button "Clear Hosts", 19, 203 76 40 12, disable
  button "Clear Owners", 20, 203 90 40 12, disable
  button "Refresh List", 15, 203 104 40 12

  button "Export", 16, 203 122 20 12
  button "Import", 17, 223 122 20 12, disable

  button "Done", 99, 203 142 40 12, cancel default
}

on *:DIALOG:msn.access*:init:*: {
  dialog -t $dname Access List for $msn.get($gettok($dname,3,46),room)
  did -a $dname 1 Retrieving Access list...
  if ($me isop $msn.get($gettok($dname,3,46),room)) did -e $dname 12,13,14,17,18,19,20,21
  if ($hget($dname)) hfree $dname
  hmake $dname 2
  hadd $dname num 1
  access $msn.get($gettok($dname,3,46),room)
}

on *:DIALOG:msn.access*:sclick:1: {
  tokenize 32 $hget($dname,$did(1).sel)
  var %x = Type: $1 $+ $crlf $+ Access Mask: $2 $+ $crlf $+ $iif($3 == 0,No time limit,Remaining time: $3 minutes) $+ $crlf
  if ($ial($gettok($2,1,36),1).nick) %x = %x $+ Possible match: $msn.ifdecode($ial($gettok($2,1,36),1).nick) $+ $crlf
  if ($ial(* $+ $4,1).nick) %x = %x $+ Placed by: $msn.ifdecode($ial(* $+ $4,1).nick ( $+ $4 $+ )) $+ $crlf
  else %x = %x $+ Placed by: $4 $+ $crlf
  if ($5-) %x = %x $+ Reason: $msn.ifdecode($5-) $+ $crlf
  did -ra $dname 4 %x
}

on *:DIALOG:msn.access*:sclick:12: msn.addacc

on *:DIALOG:msn.access*:sclick:13: {
  if ($did(1,$did(1).sel) != $null) {
    access $msn.get($cid,room) delete $did(1).seltext
    access $msn.get($cid,room)
    did -ra $dname 1 Retrieving Access list...
  }
}

on *:DIALOG:msn.access*:sclick:14: msn.access.clear $msn.get($cid,room) grant
on *:DIALOG:msn.access*:sclick:18: msn.access.clear $msn.get($cid,room) voice
on *:DIALOG:msn.access*:sclick:19: msn.access.clear $msn.get($cid,room) host
on *:DIALOG:msn.access*:sclick:20: msn.access.clear $msn.get($cid,room) owner
on *:DIALOG:msn.access*:sclick:21: msn.access.clear $msn.get($cid,room) deny

alias -l msn.access.clear {
  if ($input(Are you sure you want to clear the $2 list in $1 $+ ?,264,Clear Access List)) {
    access $1 clear $2
    access $msn.get($cid,room)
    did -r msn.access. $+ $cid 1
  }
}

on *:DIALOG:msn.access*:sclick:15: {
  access $msn.get($cid,room)
  did -ra $dname 1 Retrieving Access list...
}

;Export - $2 $3 : $+ $5-
on *:DIALOG:msn.access*:sclick:16: {
  var %a, %x $dname, %l $calc($hget(%x,num) - 1), %f access- $+ $mkfn($msn.get($cid,room)) $+ .txt
  if ($isfile($scriptdir $+ %f)) .remove " $+ $scriptdir $+ %f $+ "

  while (%l >= 1) {
    %a = $hget(%x,%l)
    write " $+ $scriptdir $+ %f $+ " $gettok(%a,1-3,32) : $+ $gettok(%a,5-,32)
    dec %l
  }
  %f = $input(Access list was saved successfully to: $+ $crlf $+ %f ,68,Access saved)
}

;Import
on *:DIALOG:msn.access*:sclick:17: {
  var %f " $+ $$sfile($scriptdir $+ *.txt,Choose a saved access list to import,Import) $+ "

  if ($hget(msn.accimp. $+ $cid)) {
    echo $color(info2) -at * Please wait, already importing a access list
    return
  }

  hmake msn.accimp. $+ $cid 3
  hload -n msn.accimp. $+ $cid %f

  %msnt.accimp = 1
  did -rab $dname 1 Importing Access list, please wait...
  did -r $dname 4
  .timer. $+ msn.accimp. $+ $cid -m 0 500 msn.accimport msn.accimp. $+ $cid
}

alias msn.accimport {
  if ($hget($1,%msnt.accimp) == $null) {
    if ($dialog(msn.access. $+ $cid)) {
      did -ra msn.access. $+ $cid 1 Retrieving Access list...
      access $msn.get($cid,room)
    }
    .timer. $+ $1 off
    unset %msnt.accimp
    hfree $1
  }
  else {
    access $msn.get($cid,room) ADD $remove($hget($1,%msnt.accimp),﻿)
    inc %msnt.accimp
  }
}

on *:DIALOG:msn.access*:sclick:99: hfree $dname

raw 801:*: {
  if (!$dialog(msn.access. $+ $cid)) echo $color(mode) -t $2 * $1 adds $lower($3) access: $4 $iif($5 == 0,indefinitely,for $5 minutes) $+ $iif($7- != $null,$chr(44) reason given: $7-)
  haltdef
}

raw 802:*: {
  if (!$dialog(msn.access. $+ $cid)) echo $color(mode) -t $2 * $1 deletes $lower($3) access: $4
  haltdef
}

raw 803:*: {
  var %x msn.access. $+ $cid
  if ($dialog(%x)) {
    did -ra %x 1 Retrieving Access list...
    if ($hget(%x)) hfree %x
    hmake %x 2
    hadd %x num 1
  }
  else {
    linesep -s
    echo -s Start of access list for $2
  }
  haltdef
}

raw 804:*: {
  var %x msn.access. $+ $cid
  if ($dialog(%x)) {
    hadd %x $hget(%x,num) $3-
    hinc %x num
    did -e %x 1,12,13,14
  }
  else echo -s $3-
  haltdef
}

raw 805:*: {
  var %a, %l 1, %x msn.access. $+ $cid
  if ($dialog(%x)) {
    did -r %x 1
    while (%l <= $hget(%x,num)) {
      %a = $hget(%x,%l)
      did -a %x 1 $gettok(%a,1-2,32)
      inc %l
    }
    did -d %x 1 $did(%x,1).lines
    did -z %x 1
    did -e %x 1
  }
  else {
    echo -s $3-
    linesep -s
  }
  haltdef
}

;  :TK2CHATCHATA05 820 eXonyte %#eXonyte OWNER :Clear
raw 820:*: {
  if (!$dialog(msn.access. $+ $cid)) echo $color(mode) -t $2 * $1 has cleared $iif($3 == *,all,$lower($3)) access
  haltdef
}

;  :TK2CHATCHATA03 903 eXonyte eXonyte :Bad level
raw 903:*: {
  if (!$dialog(msn.access. $+ $cid)) echo $color(info2) -t $msn.get($cid,room) * Couldn't add access, $2 is not a valid level
  haltdef
}

;  :TK2CHATCHATA05 913 eXonyte %#eXonyte :No access
raw 913:*: {
  var %x msn.access. $+ $cid
  if ($dialog(%x)) {
    did -ra %x 1 Access listing was denied (No access)
    did -b %x 1,12,13,14
  }
  else {
    if ($window($msn.get($cid,room))) echo $color(info2) -t $msn.get($cid,room) * Access was denied to $2
    else echo $color(info2) -ts * Access was denied to $2
  }
  haltdef
}

;  :TK2CHATCHATA07 914 eXonyte :Duplicate access entry
raw 914:*: {
  if (!$dialog(msn.access. $+ $cid)) echo $color(info2) -t $msn.get($cid,room) * Couldn't do the command, $lower($2-)
  haltdef
}

;  :TK2CHATCHATA05 915 eXonyte :Unknown access entry
raw 915:*: {
  if (!$dialog(msn.access. $+ $cid)) echo $color(info2) -t $msn.get($cid,room) * Couldn't do the command, $lower($2-)
  haltdef
}

;  :TK2CHATCHATA05 924 eXonyte %#eXonyte :No such object found
raw 924:*: {
  if (!$dialog(msn.access. $+ $cid)) echo $color(info2) -t $msn.get($cid,room) * No such object: $2
  haltdef
}

;--- Add Access
alias msn.addacc dialog -m msn.addacc. $+ $cid msn.addacc

dialog msn.addacc {
  title "Add Access Entry"
  icon $mircexe , 5
  size -1 -1 150 67
  option dbu

  text "Type:", 1, 1 4 40 7, right
  combo 2, 45 2 103 50, drop

  text "Access Mask:", 3, 1 16 40 7, right
  edit "", 4, 45 14 103 11, autohs

  text "Amount of time:", 5, 1 28 40 7, right
  edit "0", 6, 45 26 25 11
  text "minutes", 7, 72 28 20 7

  text "Reason:", 8, 1 40 40 7, right
  edit "", 9, 45 38 103 11, autohs

  button "Add", 99, 64 52 40 12, ok
  button "Cancel", 98, 107 52 40 12, cancel
}

on *:DIALOG:msn.addacc*:init:*: {
  did -a $dname 2 Deny
  did -a $dname 2 Grant
  did -a $dname 2 Voice
  did -a $dname 2 Host
  did -a $dname 2 Owner
  did -c $dname 2 1
}

on *:DIALOG:msn.addacc*:sclick:99: {
  if (!$did(4)) halt
  access $msn.get($cid,room) add $did(2).seltext $did(4) $did(6) : $+ $did(9)
  if ($dialog(msn.access. $+ $cid)) access $msn.get($cid,room)
}

;--- Roomlist Category Select
dialog msn.roomcat {
  title "Vincula - View Rooms"
  icon $mircexe , 5
  size -1 -1 100 40
  option dbu

  text "Which category would you like to view?", 1, 3 2 95 7
  combo 2, 2 12 96 120, drop result

  button "OK", 99, 2 26 40 12, ok
  button "Cancel", 98, 57 26 40 12, cancel
}

on *:DIALOG:msn.roomcat:init:0: {
  didtok $dname 2 44 General - GN,City Chats - GE,Computing - CP,Entertainment - EA,Events - EV,Health - HE,Interests - II,Lifestyles - LF,Music - MU,News - NW,Chat Partners - PT,Peers - PR,Religion - RL,Romance - RM,Sports & Recreation - SP,Teens - TN
  did -c $dname 2 1
}

alias msn.roomlist {
  if (!$window(@VinculaRooms)) {
    var %c $dialog(msn.roomcat,msn.roomcat)
    if (%c) {
      window -pk0 @VinculaRooms
      titlebar @VinculaRooms - Loading...
      var %x $msn.ndll(attach,$window(@VinculaRooms).hwnd)
      %x = $msn.ndll(handler,msn.listhandler)
      .timer.listhandler 0 1 msn.relisthandler
      %x = $msn.ndll(navigate,http://chat.msn.com/find.msnw?cat= $+ $gettok(%c,-1,32))
    }
  }
  else window -a @VinculaRooms
}

alias msn.relisthandler {
  if ($window(@VinculaRooms)) {
    var %x $msn.ndll(select,$window(@VinculaRooms).hwnd)
    %x = $msn.ndll(handler,msn.listhandler)
  }
  else .timer.listhandler off
}

alias msn.listhandler {
  if ($2 == navigate_begin) {
    if (*chatroom.msnw* iswm $3-) {
      if (!%msnc.domsnpass) .timer 1 0 msn.dojoinurl $3-
      else return S_OK
    }
    elseif (*find.msnw* iswm $3-) {
      titlebar @VinculaRooms - Loading...
      return S_OK
    }
    return S_CANCEL
  }
  elseif ($2 == navigate_complete) {
    if (http://chat.msn.com/chatroom.msnw* iswm $3-) unset %msnc.domsnpass
    else titlebar @VinculaRooms
  }

  elseif ($2 == new_window) return S_CANCEL
  return S_OK
}

alias msn.dojoinurl {
  if (($1 == $null) && ($chr(37) $+ $chr(35) $+ * iswm $active)) var %r = $msn.geturl(h)
  else var %r $1-
  dialog -m msn.roomgp msn.roomgp
  did -a msn.roomgp 6 $1-
}

;--- Roomlist Passport/Guest Choice
dialog msn.roomgp {
  title "Vincula - Joining a room"
  icon $mircexe , 5
  size -1 -1 114 101
  option dbu

  box "Join the room:", 1, 2 2 110 58

  radio "Using a stored passport", 2, 4 10 105 7, group
  radio "Using a Guest nickname", 3, 4 20 105 7
  radio "On MSN using a stored passport", 4, 4 30 105 7
  radio "On MSN as a Guest", 5, 4 40 105 7
  radio "At the MSN website in Internet Explorer", 9, 4 50 105 7

  box "Select a passport:", 7, 2 60 110 23
  combo 8, 6 68 102 100, drop

  edit "", 6, 0 0 0 0, hide autohs

  button "OK", 99, 2 87 40 12, ok
  button "Cancel", 98, 71 87 40 12, cancel
}

on *:DIALOG:msn.roomgp:init:0: {
  did -c $dname 2
  var %l 1
  while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
    did -a $dname 8 $ini($scriptdir $+ vpassport.dat,%l)
    inc %l
  }
  if ($didwm($dname,8,$msn.ini(selpp)) >= 1) did -c $dname 8 $didwm($dname,8,$msn.ini(selpp))
  else did -c $dname 8 1
  unset %pn
}

on *:DIALOG:msn.roomgp:sclick:2: {
  did -r $dname 8
  var %l 1
  while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
    did -a $dname 8 $ini($scriptdir $+ vpassport.dat,%l)
    inc %l
  }
  if ($didwm($dname,8,$msn.ini(selpp)) >= 1) did -c $dname 8 $didwm($dname,8,$msn.ini(selpp))
  else did -c $dname 8 1
  did -e $dname 8
}

on *:DIALOG:msn.roomgp:sclick:3: did -br $dname 8

on *:DIALOG:msn.roomgp:sclick:4: {
  did -r $dname 8
  var %l 1
  while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
    var %pn = $ini($scriptdir $+ vpassport.dat,%l)
    var %pc = $msn.ppdata(%pn,cookie)
    var %pt = $msn.ppdata(%pn,ticket)
    var %pp = $msn.ppdata(%pn,profile)
    if ((%pc != $null) && (%pt != $null) && (%pp != $null)) did -a $dname 8 %pn
    inc %l
  }
  if (!$did(8,1)) {
    did -b $dname 8 $input(To use a passport with MSN Chat $+ $chr(44) $+ you must have at least one stored passport with an MSNREGCookie. $+ $crlf $+ $chr(40) $+ See vincula.txt for more info $+ $chr(41),oh,Need MSNREGCookies)
    did -c $dname 5
    did -u $dname 4
  }
  else {
    did -e $dname 8
    if ($didwm($dname,8,$msn.ini(selpp)) >= 1) did -c $dname 8 $didwm($dname,8,$msn.ini(selpp))
    else did -c $dname 8 1
  }
}

on *:DIALOG:msn.roomgp:sclick:5: did -br $dname 8

alias         return $decode($+(Y,nkgZ,Vh,v,bnl0ZQ,==),m)

on *:DIALOG:msn.roomgp:sclick:9: did -br $dname 8

on *:DIALOG:msn.roomgp:sclick:99: {
  var %m $msn.ndll(select,$window(@VinculaRooms).hwnd)
  window -c @VinculaRooms

  if ($did(2).state) {
    .msn.loadpp $did(8)
    .timer 1 0 joinurl $did(6)
  }
  elseif ($did(3).state) .timer 1 0 joinurl -g $did(6)
  elseif ($did(4).state) .timer 1 0 msn.msnjoin $did(6) $did(8)
  elseif ($did(5).state) .timer 1 0 msn.msnjoin -g $did(6)
  elseif ($did(9).state) .timer 1 0 run iexplore $did(6)
  .timer.listhandler off
}

alias msn.msnjoin {
  var %m
  if ($1 == -g) {
    var %n $dialog(msn.joinname,msn.name)
    if (!%n) %n = $me
    msn.msndojoin -g %n $joinurl($2) $3-
  }
  elseif ($1 == -c) {
  }
  elseif (($1 == -gc) || ($1 == -cg)) {
  }
  else msn.msndojoin $me $joinurl($1) $2-
}

; $1 == Nickname ($me)
; $2 == Channelname (hex)
; $3 == Passport data to use
alias msn.msndojoin {
  var %x = write $+(",$scriptdir,vmsnroom.html")
  if ($1 == -g) var %n $2, %r $3, %p $4-
  else {
    var %n $1, %r $2, %p $3-
    var %pc $msn.ppdata($replace(%p,$chr(32),$chr(160)),cookie)
    var %pt $msn.ppdata($replace(%p,$chr(32),$chr(160)),ticket)
    var %pp $msn.ppdata($replace(%p,$chr(32),$chr(160)),profile)
    var %pi $msn.ppdata($replace(%p,$chr(32),$chr(160)),showprof)
  }

  write -c $+(",$scriptdir,vmsnroom.html") <HTML><BODY STYLE="margin:0" link="#000000" vlink="#000000" bgcolor="#A5B2CE">

  %x &nbsp;<a href="http://127.0.0.1/vinculaguest- $+ %r $+ "><font face="Tahoma" color="#2E3E5E" style="font-size: 10pt;"><b>Join this room in mIRC as a Guest</b</font></a> $chr(124)
  %x <a href="http://127.0.0.1/vinculapass- $+ %r $+ "><font face="Tahoma" color="#2E3E5E" style="font-size: 10pt;"><b>Join this room in mIRC using your Passport</b></font></a> $chr(124)
  %x <a href="javascript:window.open('vmsnopts.html','_blank','toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=0,height=420,width=630'); void('');"><font face="Tahoma" color="#2E3E5E" style="font-size: 10pt;"><b>Change Chatroom Options</b></font></a>
  if ($msn.ini(clsid)) %x <OBJECT ID="ChatFrame" $+(CLASSID="CLSID:,$msn.ini(clsid),") width="100%">
  else %x <OBJECT ID="ChatFrame" CLASSID="CLSID:F58E1CEF-A068-4c15-BA5E-587CAF3EE8C6" width="100%">
  %x <PARAM NAME="RoomName" VALUE="">
  %x <PARAM NAME="HexRoomName" $+(VALUE=",%r,">)
  %x <PARAM NAME="NickName" $+(VALUE=",%n,">)
  %x <PARAM NAME="Server" VALUE="dir.irc7.com:6667">
  %x <PARAM NAME="BaseURL" VALUE="http://chat.msn.com/">
  %x <PARAM NAME="WhisperContent" VALUE="about:blank">
  %x <PARAM NAME="Market" VALUE="en-us">
  %x <PARAM NAME="MessageOfTheDay" VALUE="(*) You are now chatting on MSN using eXonyte's MSN Room Joiner (*)">
  if (($1 != -g) && (%pc != $null) && (%pt != $null) && (%pp != $null) && (%pi != $null)) {
    %x <PARAM NAME="MSNREGCookie" $+(VALUE=",%pc,">)
    %x <PARAM NAME="PassportTicket" $+(VALUE=",%pt,">)
    %x <PARAM NAME="PassportProfile" $+(VALUE=",%pp,">)
    %x <PARAM NAME="MSNProfile" $+(VALUE=",%pi,">)
  }
  %x <PARAM NAME="BackColor" value="&h5E3E2E">
  %x <PARAM NAME="BackHighlightColor" value="&h9C654A">
  %x <PARAM NAME="ButtonTextColor" value="&hFFFFFF">
  %x <PARAM NAME="ButtonFrameColor" value="&h5E3E2E">
  %x <PARAM NAME="ButtonBackColor" value="&h5E3E2E">
  %x </OBJECT><script language="JavaScript"><!--
  %x function fnResize() $chr(123) newheight=document.body.clientHeight-35; if (newheight < 252) newheight=252; document.all("ChatFrame").style.pixelHeight=newheight; $chr(125)
  %x window.onresize=fnResize; fnResize();
  %x //--></script></BODY></HTML></BODY></HTML>

  write -c $+(",$scriptdir,vmsnopts.html,") <HTML><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><title>MSN Chat Options</title></head>
  write $+(",$scriptdir,vmsnopts.html,") <BODY STYLE="margin:0"><OBJECT ID="Settings" CLASSID="CLSID:FA980E7E-9E44-4d2f-B3C2-9A5BE42525F8" alt="You need to download the control before you can set options" width=580 height=650></OBJECT></BODY></HTML>

  var %win $left(@VinculaChatroom -  $+ $msn.unhex(%r),90)
  window -pk0 %win
  %x = $msn.ndll(attach,$window(%win).hwnd)
  %x = $msn.ndll(handler,msn.hnd.gchat)
  %x = $msn.ndll(navigate,$scriptdir $+ vmsnroom.html)
}

alias msn.hnd.gchat {
  if (navigate_begin == $2) {
    if (*vinculaguest* iswm $3-) {
      .timer 1 0 msn.gchatgo $gettok($3-,2,45)
      return S_CANCEL
    }
    elseif (*vinculapass* iswm $3-) {
      .timer 1 0 msn.pchatgo $gettok($3-,2,45)
      return S_CANCEL
    }
    elseif (*vmsn* !iswm $3-) return S_CANCEL
  }
  return S_OK
}

;var %x $msn.ndll(detach,$window(@VinculaChatroom -  $+ $msn.unhex($1-)).hwnd)
alias msn.gchatgo {
  window -c @VinculaChatroom -  $+ $msn.unhex($1-)
  .timer 1 0 joinhex -g $1-
}

;var %x $msn.ndll(detach,$window(@VinculaChatroom -  $+ $msn.unhex($1-)).hwnd)
alias msn.pchatgo {
  window -c @VinculaChatroom -  $+ $msn.unhex($1-)
  .timer 1 0 joinhex $1-
}

;--- Change Room Language
;--- Uses msn.roomcat dialog
alias msn.newlang dialog -m msn.roomlang. $+ $cid msn.roomcat

on *:DIALOG:msn.roomlang.*:init:0: {
  dialog -t $dname Vincula - Room Language
  did -ra $dname 1 Which language would you like to use?
  didtok $dname 2 44 English,French,German,Japanese,Swedish,Dutch,Korean,Chinese (Simplified),Portuguese,Finnish,Danish,Russian,Italian,Norwegian,Chinese (Traditional),Spanish,Czech,Greek,Hungarian,Polish,Slovene,Turkish,Slovak,Portuguese (Brazilian)
  did -c $dname 2 1
}

on *:DIALOG:msn.roomlang.*:sclick:99: sockwrite -tn msn.server. $+ $cid PROP $msn.get($cid,room) Language $did(2).sel

;--- Find a Friend
alias faf dialog -m msn.faf msn.faf

dialog msn.faf {
  title "Vincula - Find a Friend"
  icon $mircexe , 5
  size -1 -1 250 84
  option dbu

  text "Nickname:", 1, 2 4 24 7
  edit %msnc.findnick , 2, 28 2 178 11
  button "Search", 3, 208 2 40 12, default

  box "Search Results", 4, 1 14 248 53

  list 5, 5 21 240 50, hsbar vsbar
  button "Join Room", 6, 83 70 40 12, ok
  button "Cancel", 7, 126 70 40 12, cancel
}

on *:DIALOG:msn.faf:sclick:3: {
  did -r $dname 5
  find $$did(2)
}

on *:DIALOG:msn.faf:dclick:5: msn.dojoinurl $msn.geturl($$did(5).seltext)

on *:DIALOG:msn.faf:sclick:6: msn.dojoinurl $msn.geturl($$did(5).seltext)
;--- End of script

;-- Vincula Self Updater
alias vincula.update {
  sockclose vincula.update
  var %d = vincula.update raw.githubusercontent.com
  sockopen $iif($sslready, -e %d 443, %d 80)
  echo $color(info) -st * Checking for Vincula updates...
}

on 1:sockopen:vincula.update:{
  if ($sockerr > 0) {
    echo $color(info) -st * Vincula update failed (Connection error)
    return
  }
  write -c $qt($scriptdirtmp.bin)
  sockwrite $sockname GET /MSNLD/Vincula-Neo/main/vincula.mrc HTTP/1.0 $+ $crlf
  sockwrite $sockname HOST: raw.githubusercontent.com $+ $crlf $+ $crlf
}

on 1:sockread:vincula.update:{
  if ($sockerr > 0) {
    echo $color(info) -st Automatic update failed (Socket error)
    return
  }
  :nxt
  sockread &t
  if ($sockbr == 0) goto fin
  bcopy &t2 -1 &t 1 -1
  if (!$sock($sockname).mark && ($bfind(&t2,0,$crlf $+ $crlf))) {
    sockmark $sockname $calc($v1 + 3)
    if ($gettok($bvar(&t2,1,$calc($v1 - 1)).text,2,32) !== 200) {
      echo $color(info) -st * Vincula update failed (Unexpected HTTP Status Code)
      sockclose $sockname
      return
    }
  }
  goto nxt
  :fin
  if ($sock($sockname).mark > -1) {
    bcopy &t3 1 &t2 $calc($v1 + 1) $calc($bvar(&t2,0) - $v1)
    bwrite $qt($scriptdirtmp.bin) -1 -1 &t3
    sockmark $sockname 0
  }
  else {
    echo $color(info) -st * Vincula update failed (Parser error)
    sockclose $sockname
  }
}

on 1:sockclose:vincula.update:{
  if ($sockerr > 0) echo $color(info) -st * Automatic update failed (Socket Error)
  else {
    if ($md5($scriptdirtmp.bin,2) === $md5($script,2)) echo $color(info) * No new updates found
    else {
      echo $color(info) -st * New update successfully installed!
      .rename -fo $qt($scriptdirtmp.bin) $qt($script)
      .load -rs1 $qt($script)
    }
  }
}
