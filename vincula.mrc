;--- Vincula Neo (v4.0)
;--- http://exonyte.dyndns.org

;--- Aliases
alias msndebug {
  if ($1 == on) { window @debug | %msnx.debug = $true }
  else unset %msnx.debug
}

alias msn {
  if (($sock(msn.look.main) == $null) || ($sock(msn.look.comm) == $null)) {
    echo $color(info2) -at * Please wait until both lookup server connections are established and try joining again
    msn.lookcon
    return
  }

  if (%msnx.selpp == $null) {
    if ($1 == -c) tokenize 32 -cg $2-
    elseif ($1 !isin -g -cg -gc) tokenize 32 -g $1-
  }

  var %x $1, %y $2, %g $false, %c $false, %s, %n

  if ($server == $null) %msnc.newcon = $cid
  else unset %msnc.newcon

  if ($1 == -g) {
    if ((%msnc.connick) || (%msnc.noask)) %n = %msnc.connick
    else %n = $msn.getnick(g)
    %x = $$2
    %y = $3
    %g = $true
  }
  elseif ($1 == -c) {
    %n = $msn.getnick(p)
    %x = $$2
    %y = $3
    %c = $true
    if (($calc($msn.ppdata(%msnx.selpp,updated) + (%msnx.autouptime * 3600)) < $ctime) && (%msnx.autoup)) {
      %msnc.noask = $true
      %msnc.connick = %n
      %msnc.doconnect = msn -c $1-
      msn.getpp
      return
    }
  }
  elseif (($1 == -cg) || ($1 == -gc)) {
    %n = $msn.getnick(g)
    %x = $$2
    %y = $3
    %g = $true
    %c = $true
  }
  else {
    if ((%msnc.connick) || (%msnc.noask)) %n = %msnc.connick
    else %n = $msn.getnick(p)
    if (($calc($msn.ppdata(%msnx.selpp,updated) + (%msnx.autouptime * 3600)) < $ctime) && (%msnx.autoup)) {
      %msnc.noask = $true
      %msnc.connick = %n
      %msnc.doconnect = msn $1-
      msn.getpp
      return
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
  msn.set 999 guest %g
  msn.set 999 nick %n
  msn.set 999 room $chr(37) $+ $chr(35) $+ $right($right(%x,-2),88)
  msn.set 999 fullroom %x
  msn.set 999 shortroom $left($chr(37) $+ $chr(35) $+ $right($right(%x,-2),88),60)
  msn.set 999 pass %y
  msn.set 999 fname %msnf.font
  msn.set 999 fcolor %msnf.fcolor
  msn.set 999 fstyle %msnf.fstyle
  msn.set 999 frand %msnf.frand
  msn.set 999 decode %msnx.decode
  msn.set 999 encode %msnx.encode

  unset %msn*.999
  sockclose msn*.999

  if (%y) %msnp.qkey. [ $+ [ $right(%x,-2) ] ] = %y

  if ((!%g) && (!%c)) msn.recent msn $right(%x,-2)
  elseif ((%g) && (!%c)) msn.recent msn -g $right(%x,-2)
  elseif ((!%g) && (%c)) msn.recent msn -c $right(%x,-2)
  elseif ((%g) && (%c)) msn.recent msn -cg $right(%x,-2)

  if (!%c) sockwrite -tn msn.look.main FINDS %x
  else sockwrite -tn msn.look.comm FINDS %x
}

alias clone {
  if (($sock(msn.look.main) == $null) || ($sock(msn.look.comm) == $null)) {
    echo $color(info2) -at * Please wait until both lookup server connections are established before joining a room
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
    if (($calc($msn.ppdata(%msnx.selpp,updated) + (%msnx.autouptime * 3600)) < $ctime) && (%msnx.autoup) && (!%g)) {
      %msnc.doconnect = clone $1-
      msn.getpp
      return
    }
  }
  else {
    %n = $1
    %y = $2
    if (($calc($msn.ppdata(%msnx.selpp,updated) + (%msnx.autouptime * 3600)) < $ctime) && (%msnx.autoup) && (!%g)) {
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
  msn.set 999 guest %g
  msn.set 999 nick %n
  msn.set 999 room $left(%x,90)
  msn.set 999 fullroom %x
  msn.set 999 shortroom $left(%x,60)
  msn.set 999 pass %y
  msn.set 999 fname %msnf.font
  msn.set 999 fcolor %msnf.fcolor
  msn.set 999 fstyle %msnf.fstyle
  msn.set 999 frand %msnf.frand
  msn.set 999 decode %msnx.decode
  msn.set 999 encode %msnx.encode

  disconnect
  %msnc.newcon = $cid

  if (%y) %msnp.qkey. [ $+ [ $right(%x,-2) ] ] = %y

  if (!%c) sockwrite -tn msn.look.main FINDS %x
  else sockwrite -tn msn.look.comm FINDS %x
}

alias joinhex {
  if (($1 == -g) || ($1 == -c) || ($1 == -cg) || ($1 == -gc)) msn $1 $msn.unhex($2) $3
  else msn $msn.unhex($1) $2
}

alias joins {
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
  if (%msnx.usepass) var %p = $msn.ownerkey($msn.get($cid,room))
  sockwrite -tn msn.server. $+ $cid JOIN $msn.get($cid,fullroom) %p
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

; "/msn.set $sockname item value" or "/msn.set $cid item value"
alias msn.set {
  if (msn.*.* iswm $1) hadd msn. $+ $gettok($$1,3,46) $$2-
  else hadd msn. $+ $$1 $$2-
}

; "/msn.unset $sockname item value" or "/msn.unset $cid item value"
alias msn.unset {
  if (msn.*.* iswm $1) hdel msn. $+ $gettok($$1,3,46) $$2
  else hdel msn. $+ $$1 $$2
}

; "/msn.clear $sockname" or "/msn.clear $cid"
alias msn.clear {
  if ((msn.*.* iswm $1) && ($hget(msn. $+ $gettok($1,3,46)))) hfree msn. $+ $gettok($1,3,46)
  elseif ($hget(msn. $+ $1)) hfree msn. $+ $$1
}

; "/msn.ren oldcid newcid" or whatever
alias msn.ren {
  if ($hget(msn.999) != $null) {
    var %old, %new, %l 1

    if (msn.*.* iswm $1) %old = $gettok($1,3,46)
    else %old = $1

    if (msn.*.* iswm $2) %new = $gettok($2,3,46)
    else %new = $2

    hsave -o msn. $+ %old temp $+ %old $+ .txt
    hmake msn. $+ %new 1
    hload msn. $+ %new temp $+ %old $+ .txt
    hfree msn. $+ %old
    .remove temp $+ %old $+ .txt

    sockrename msn.server. $+ %old msn.server. $+ %new
    sockrename msn.mirc. $+ %old msn.mirc. $+ %new
    .timer.noop. $+ %new 0 60 .raw NOOP
  }
}

alias msn.geturl {
  if ($1 !iswm $chr(35) $+ $chr(37) $+ *) {
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
  var %in � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �
  var %out € ‚ ƒ „ … † ‡ ˆ ‰ Š ‹ Œ Ž ‘ ’ “ ” • – — ˜ ™ š › œ ž Ÿ   ¡ ¢ £ ¤ ¥ ¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿ À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ
  var %l 1
  if ($hget(msn.enc)) hfree msn.enc
  hmake msn.enc 13
  while (%l <= 123) {
    hadd msn.enc $gettok(%in,%l,32) $gettok(%out,%l,32)
    inc %l
  }
}

; https://login.passport.com/ppsecure/post.srf?id=2260&ru=http://chat.msn.com/chatroom.msnw%3frm%3dTheLobby&login= $+ %msnx.email $+ &passwd= $+ %msnx.passwd
alias msn.getpp {
  if ($timer(.msn.agpp) >= 1) {
    echo $color(info2) -at * Please wait until the Passport Updater is finished before trying to update again
    return
  }
  var %p
  if (%msnx.passwd == $null) %p = $$input(Please enter the password for the %msnx.email passport:,130,Enter Password)
  else %p = %msnx.passwd
  msn.dogetpp %msnx.selpp %msnx.email %p
}

;msn.dogetpp passport email password
alias msn.dogetpp {
  %msnpass.lotime = $ticks
  %msnpass.loupdate = $1
  echo $color(info2) -at * Updating the " $+ %msnpass.loupdate $+ " passport, please wait...
  window -ph @VinculaPPU
  var %s $msn.ndll(attach,$window(@VinculaPPU).hwnd)
  %s = $msn.ndll(handler,msn.hnd.getpp)
  %s = $msn.ndll(navigate,https://login.passport.com/ppsecure/post.srf?id=2260&ru=http://chat.msn.com/chatroom.msnw%3frm%3dTheLobby&login= $+ $replace($2,@,$chr(37) $+ 40) $+ &passwd= $+ $3)
}

alias msn.hnd.getpp {
  if (navigate_begin http://chat.msn.com*chatroom.msnw* iswm $2-) {
    .timer 1 0 msn.urlpp $1 $3
    return S_CANCEL
  }
  return S_OK
}

alias msn.urlpp {
  var %s, %pt $right($wildtok($2,t=*,1,38),-2), %pp $right($wildtok($2,p=*,1,38),-2), %pu %msnpass.loupdate
  %s = $msn.ndll(select,$1)
  %s = $msn.ndll(navigate,about:blank)
  window -c @VinculaPPU

  writeini $+(",$scriptdir,vpassport.dat") %msnpass.loupdate ticket %pt
  writeini $+(",$scriptdir,vpassport.dat") %msnpass.loupdate profile %pp
  writeini $+(",$scriptdir,vpassport.dat") %msnpass.loupdate updated $ctime
  if (%msnpass.loupdate == %msnx.selpp) {
    %msnpass.ticket = %pt
    %msnpass.profile = %pp
  }
  echo $color(info2) -at * Passport info for " $+ %msnpass.loupdate $+ " is now updated ( $+ $calc(($ticks - %msnpass.lotime) / 1000) seconds)
  unset %msnpass.loupdate
  unset %msnpass.lotime
  %msnc.doconnect
}

alias msn.mgetpp {
  if ($timer(.msn.agpp) >= 1) {
    echo $color(info2) -at * Please wait until the Passport Updater is finished before trying to update again
    return
  }
  %msnpass.loupdate = %msnx.selpp
  msn.doppupdate " $+ $$sfile($scriptdir $+ *.*,Choose a file that contains your passport information) $+ "
}

alias msn.doppupdate {
  var %f $1-, %uc, %ut, %up

  %uc = $gettok($read(%f,w,*MSNREGCookie*),4,34)
  %ut = $gettok($read(%f,w,*PassportTicket*),4,34)
  %up = $gettok($read(%f,w,*PassportProfile*),4,34)
  %msnx.clsid = $right($gettok($read(%f,w,*CLSID*),4,34),-6)

  if ((%uc != $null) && (%ut != $null) && (%up != $null)) { goto found }
  echo $color(info2) -at * Passport information was not found or was incomplete in the file $nopath(%f) $+ !
  return

  :found
  if (%msnpass.loupdate == %msnx.selpp) {
    %msnpass.cookie = %uc
    %msnpass.ticket = %ut
    %msnpass.profile = %up
  }
  writeini $+(",$scriptdir,vpassport.dat") %msnpass.loupdate cookie %uc
  writeini $+(",$scriptdir,vpassport.dat") %msnpass.loupdate ticket %ut
  writeini $+(",$scriptdir,vpassport.dat") %msnpass.loupdate profile %up
  writeini $+(",$scriptdir,vpassport.dat") %msnpass.loupdate updated $ctime

  echo $color(info2) -at * Passport information was found in the file $nopath(%f)
  unset %msnpass.lo*
}

alias msn.loadpp {
  tokenize 32 $replace($1-,$chr(32),$chr(160))

  if ($msn.ppdata($$1,showprof) == $null) {
    echo $color(info2) -atq * Couldn't load the passport named " $+ $1 $+ "
    return
  }

  %msnx.selpp = $1
  %msnx.nick = $msn.ppdata($1,nick)
  %msnx.email = $msn.ppdata($1,email)
  %msnx.passwd = $msn.ppdata($1,passwd)
  %msnpass.cookie = $msn.ppdata($1,cookie)
  %msnpass.ticket = $msn.ppdata($1,ticket)
  %msnpass.profile = $msn.ppdata($1,profile)
  %msnx.showprof = $msn.ppdata($1,showprof)
  echo $color(info2) -atq * Now using the " $+ $1 $+ " passport
}

alias msn.roomexists {
  var %x %msnc.making
  msn.clear 999
  unset %msnc.*
  if ($input(The room %x already exists $+ $chr(44) do you want to join the room?,136,Join Existing Room)) {
    msn %x
  }
}

;--- Local Aliases
alias -l msn.sockerr scid $activecid echo $color(kick) -at * Socket error in $1 $+ : $sock($1).wsmsg

alias -l msn.writehtml {
  if ($2 != $null) {
    var %x write $+(",$scriptdir,$2,")
    write -c $+(",$scriptdir,$2") <html><body>
  }
  else {
    var %x write $+(",$scriptdir,vincula.html")
    write -c $+(",$scriptdir,vincula.html") <html><body>
  }
  if (%msnx.clsid) {
    %x <object id="ChatFrame" $+(classid="CLSID:,%msnx.clsid,") width="100%">
  }
  else {
    %x <object id="ChatFrame" classid="CLSID:7a32634b-029c-4836-a023-528983982a49" width="100%">
  }
  %x <param name="RoomName" value="Vincula"><param name="NickName" value="Vincula"><param name="Server" $+(value="127.0.0.1:,$1,">)
  %x </object></body></html>
}

alias -l msn.setaways {
  scid $1
  var %aa 1, %fline
  while ($hget(msn.setaways,%aa) != $null) {
    if (-r * iswm $hget(msn.setaways,%aa)) {
      %fline = $fline($msn.get($1,room),$right($hget(msn.setaways,%aa),-3),1,1)
      if (%fline != $null) cline -lr $msn.get($1,room) %fline
    }
    else {
      %fline = $fline($msn.get($1,room),$hget(msn.setaways,%aa),1,1)
      if (%fline != $null) cline -l $color(grayed) $msn.get($1,room) %fline
    }
    inc %aa
  }
  if ($hget(msn.setaways)) hfree msn.setaways
  scid -r
}

alias -l msn.donav {
  var %s, %x = $1, %f = $2
  if (%x == $null) %x = @VinculaHTML
  if (%f == $null) %f = vincula.html
  if (!$window(%x)) {
    window -ph %x
    %s = $msn.ndll(attach,$window(%x).hwnd)
  }
  %s = $msn.ndll(select,$window(%x).hwnd)
  %s = $msn.ndll(navigate,$scriptdir $+ %f)
}

alias -l msn.chklst.join scid $2 | if ($1 !ison $msn.get($2,room)) names $msn.get($2,room) | scid -r
alias -l msn.chklst.part scid $2 | if ($1 ison $msn.get($2,room)) names $msn.get($2,room) | scid -r

;--- Identifiers
alias msn.ndll return $dll($scriptdir $+ nHTMLn_2.92.dll,$$1,$2)

alias msn.authkey return $base($len(%msnpass.ticket),10,16,8) $+ %msnpass.ticket $+ $base($len(%msnpass.profile),10,16,8) $+ %msnpass.profile

;This identifier was obtained from the mircscripts.org Snippets section.
;Very big thank you to Techster, who submitted it.  Dude, you saved me alot
;of time!
;URL: http://www.mircscripts.org/comments.php?id=1225
alias msn.urldecode {
  var %decode = $replace($eval($1-,1), +, $eval(%20,0))
  while ($regex($eval(%decode,1), /\%([a-fA-F0-9]{2})/)) {
    var %t = $regsub($eval(%decode,1), /\%([a-fA-F0-9]{2})/, $chr($base($regml(1),16,10)), %decode)
  }
  return $replace(%decode, $eval(%20,0), +)
}

; $msn.registry(<Key>\\<Value>)
alias msn.registry {
  return $dll($scriptdir $+ registry.dll,GetKeyValue,$1)
}

alias msn.ud1 return $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\UserData1)

;Decodes text
alias msn.decode {
  var %r, %l 1
  %r = $replace($1-,,B,,-,�>,-,,-,,-,,E,,C,,A,,R,,K,,y,ﺘ,i,ﺉ,s,דּ,t,טּ,u,ﻉ,e,,k,,F,,u,,g,Χ,X,,>,,$chr(37),,8,,d,,m,,h,ﻛ,s,,G,,M,,l,,s,,_,,T,,r,,a,,n,,c,,e,,N,,a,,t,,i,,o,,n,,f,,w,,\,,|,,@,,P,,D,,',,�,,$chr(40),,$chr(41),,*,,:,,[,,],,p,,.)
  %r = $replace(%r,χ,X,ņ,n,Ω,n,��,y,р,p,Р,P,ř,r,х,x,Į,I,Ļ,L,Ф,o,Ĉ,C,ŏ,o,ũ,u,ń,n,Ģ,G,ŕ,r,ś,s,ķ,k,Ŗ,R,ז,i,ε,e,ק,r,ћ,h,м,m,،,�,ī,i,‘,�,’,�,۱,',ē,e,¢,�,,S,,Y,,O,,I,Ά,A,ъ,b,��,T,Φ,o,Ђ,b,я,r,Ё,E,д,A,К,K,Ď,D,и,n,θ,o,М,M,Ї,I,Т,T,Є,e,Ǻ,A,ö,�,ä,�,–,�,·,�,Ö,�,Ü,�,Ë,�,ѕ,s,ą,a,ĭ,i,й,n,в,b,о,o,ш,w,Ğ,G,đ,d,з,e,Ŧ,T,α,a,ğ,g,ú,�,Ŕ,R,Ą,A,ć,c,Đ,�,Κ,K,ў,y,µ,�,Í,�,‹,�,¦,�,Õ,�,Ù,�,À,�,Π,N,ғ,f,ΰ,u,Ŀ,L,ō,o,ς,c,ċ,c,ħ,h,į,i,ŧ,t,Ζ,Z,Þ,�,þ,�,ç,�,á,�,¾,�,ž,�,Ç,�,� $+ $chr(173),-,Á,�,…,�,¨,�,ý,�,ˉ,�,”,�,Û,�,ì,�,ρ,p,έ,e,г,r,à,�,È,�,¼,�,ĵ,j,ã,�,ę,e,ş,s,º,�,Ñ,�,ã,�,Æ,�,˚,�,Я,R,˜,�,Î,�,Ê,�,Ý,�,Ï,�,É,�,‡,�,Ì,�,ª,�,ó,�,™,�,Ò,�,í,�,¿,�,Ä,�,¶,�,ü,�,ƒ,�,ð,�,ò,�,õ,�,¡,�,é,�,ß,�,¤,�,×,�,ô,�,Š,�,ø,�,›,�,â,�,î,�,€,�,š,�,ï,�,ÿ,�,å,�,©,�,®,�,û,�,†,�,°,�,§,�,±,�,²,�,è,�)
  %r = $replace(%r,Ň,N,۰,�,Ĵ,J,І,I,Σ,E,ι,i,Ő,O,δ,o,ץ,y,ν,v,ע,y,מ,n,Ž,�,ő,o,Č,C,ė,e,₤,L,Ō,O,ά,a,Ġ,G,Ω,O,Н,H,ể,e,ẵ,a,Ж,K,ề,e,ế,e,ỗ,o,ū,u,₣,F,∆,a,Ắ,A,ủ,u,Ķ,K,Ť,T,Ş,S,Θ,O,Ш,W,Β,B,П,N,ẅ,w,ﻨ,i,ﯼ,s,џ,u,ђ,h,¹,�,Ỳ,Y,λ,a,С,C,� $+ $chr(173),E,Ű,U,Ī,I,č,c,Ĕ,E,Ŝ,S,Ị,I,ĝ,g,ŀ,l,ї,i,٭,*,ŉ,n,Ħ,H,Д,A,Μ,M,ё,e,Ц,U,э,e,“,�,ф,o,у,y,с,c,к,k,Å,�,Ƥ,P,℞,R,,I,ɳ,n,ʗ,c,▫,�,ѓ,r,ệ,e,ắ,a,ẳ,a,ů,u,Ľ,L,ư,u,·,�,˙,',η,n,ℓ,l,,�,,�,,�,׀,i,ġ,g,Ŵ,W,Δ,A,ﮊ,J,μ,�,Ÿ,�,ĥ,h,β,�,Ь,b,ų,u,є,e,ω,w,Ċ,C,і,i,ł,l,ǿ,o,∫,s,ż,z,ţ,t,æ,�,≈,=,Ł,L,ŋ,n,گ,S,ď,d,ψ,w,σ,o,ģ,g,Ή,H,ΐ,i,ґ,r,κ,k,Ŋ,N,�,\,,/,¬,�,щ,w,ە,o,ם,o,³,�,½,�,İ,I,ľ,l,ĕ,e,Ţ,T,ŝ,s,ŷ,y,ľ,l,ĩ,i,Ô,�,Ś,S,Ĺ,L,а,a,е,e,Ρ,P,Ј,J,Ν,N,ǻ,a,ђ,h,ή,n,ί,l,Œ,�,¯,�,ā,a,ŵ,w,Â,�,Ã,�,н,H,ˇ,',¸,�,̣,$chr(44),ط,b,Ó,�,Й,N,«,�,ù,�,Ø,�,ê,�)
  %r = $replace(%r,ا,I,л,n,ы,bl,б,6,ש,w,―,-,Ϊ,I,,`,ŭ,u,ổ,o,Ǿ,�,ẫ,a,ầ,a,,q,Ẃ,W,Ĥ,H,ỏ,o,−,-,,^,ล,a,Ĝ,G,ﺯ,j,ى,s,Ѓ,r,ứ,u,●,�,ύ,u,,0,,7,,",ө,O,ǐ,i,Ǒ,O,Ơ,O,,2,ү,y,,v,А,A,≤,<,≥,>,ẩ,a,,H,٤,e,ﺂ,i,Ќ,K,Ū,U,,;,ă,a,ĸ,k,Ć,C,Ĭ,I,ň,n,Ĩ,I,Ń,N,Ι,I,Ϋ,Y,,J,,X,,$chr(125),,$chr(123),Ξ,E,ˆ,^,,V,,L,γ,y,ﺎ,i,Ώ,o,ỳ,y,Ć,C,Ĭ,I,ĸ,k,Ŷ,y,๛,c,ỡ,o,๓,m,ﺄ,i,פֿ,G,Ŭ,U,Ē,E,Ă,A,÷,�, ,�,‚,�,„,�,ˆ,�,‰,�,ă,a,,x,,=,ق,J,,?,￼,-,◊,o,т,T,Ā,A,קּ,P,Ė,E,Ę,E,ο,o,ϋ,u,‼,!!,ט,u,ﮒ,S,Ч,y,Ґ,r,ě,e,Ę,E,ĺ,I,Λ,a,ο,o,Ú,�,Ř,R,Ư,U,œ,�,,-,—,�,ห,n,ส,a,ฐ,s,Ψ,Y,Ẫ,A,π,n,Ņ,N,�!,o,Ћ,h,ợ,o,ĉ,c,◦,�,ﮎ,S,Ų,U,Е,E,Ѕ,S,۵,o,ي,S,ب,u,ة,o,ئ,s,ļ,l,ı,i,ŗ,r,ж,x,΅,",ώ,w,▪,�,ζ,l,Щ,W,฿,B,ỹ,y,ϊ,i,ť,t,п,n,´,�,ک,s,ﱢ,*,ξ,E,ќ,k,√,v,τ,t,Ð,�,£,�,ñ,�,¥,�,•,�,ë,�,ǎ,a)
  %r = $replace(%r,ằ,a, ,�,Ο,O,₪,n,Ậ,A,,�,,�,,�,,�,,�,,�,ờ,o,‍,�,ֱ,�,־,-,הּ,n,ź,z,‌,�,ُ,',๘,c,ฅ,m,,�,,<,▼,v,ﻜ,S,℮,e,ź,z,ậ,a,๑,a,ﬁ,fi,ь,b,ﺒ,.,ﺜ,:,ศ,a,ภ,n,๏,o,ะ,=,צּ,y,ซ,i,‾,�,∂,a,：,:,≠,=,,+,م,r,ồ,o,Ử,U,Л,N,Ӓ,A,Ọ,O,Ẅ,W,Ỵ,Y,ﺚ,u,ﺬ,i,ﺏ,u,Ż,Z,ﮕ,S,ﺳ,w,ﯽ,u,ﺱ,uw,ﻚ,J,ﺔ,a,,!,ễ,e,ل,J,ر,j,ـ,_,ό,o,₫,d,№,no,ữ,u,Ě,E,φ,o,ﻠ,I,ц,u,,A,,N,Њ,H,Έ,E,,~,,U,ạ,a,,1,,4,,3,ỉ,i,Ε,E,Џ,U,ك,J,★,*,,b,,$chr(35),,$,○,o,ю,10,ỵ,y,ẁ,w,қ,k,ٿ,u,♂,o,תּ,n,٥,o,ﮐ,S,ⁿ,n,ﻗ,9,,b,,$chr(35),,$,○,o,ю,10,ị,i,Α,A, ,�,ﻩ,o,ﻍ,E,ن,u,ẽ,e,ث,u,ㅓ,t,ӛ,e,Ә,E,ﻘ,o,۷,v,שׁ,w,ụ,u,Ŏ,O,,�,ự,u,Ｊ,J,ｅ,e,ａ,a,Ｎ,N,（,$chr(40),＠,@,｀,`,．,.,′,',）,$chr(41),▬,-,◄,<,►,>,∑,E,ֻ,$chr(44),‬,|,‎,|,‪,|,‫,|,Ộ,O,И,N,,W,,z)
  %r = $replace(%r,ס,o,╳,X,٠,�,Ғ,F,υ,u,‏,�,ּ,�,ǔ,u,ผ,w,Ằ,A,Ấ,A,»,�)
  return %r
}

alias msn.ifdecode {
  if (($msn.get($cid,decode)) && ($sock(msn.*. $+ $cid,1) != $null)) return $msn.decode($1-)
  else return $1-
}

alias msn.encode {
  var %x, %l 1
  while (%l <= $len($1-)) {
    if ($hget(msn.enc,$mid($1-,%l,1)) != $null) %x = %x $+ $hget(msn.enc,$mid($1-,%l,1))
    else {
      if ($mid($1,%l,1) != $chr(32)) %x = %x $+ $mid($1-,%l,1)
      else %x = %x $mid($1-,%l,1)
    }
    inc %l
  }
  return %x
}

alias msn.pass {
  var %r, %nl, %l 1, %c $1
  if (!%c) %c = 8
  while (%l <= %c) {
    if ($calc($rand(0,9) % 2) == 0) %nl = $rand(0,9)
    else {
      if ($calc($rand(0,9) % 2) == 0) %nl = $rand(A,Z)
      else %nl = $rand(a,z)
    }
    %r = %r $+ %nl
    inc %l
  }
  return %r
}

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
      if ($mid($1-,%l,2) != 20) {
        %r = %r $+ $chr($base($mid($1-,%l,2),16,10))
      }
      else {
        %r = %r $chr($base($mid($1-,%l,2),16,10))
      }
    }
    else {
      %r = %r $+ $chr($base($mid($1-,%l,2),16,10))
    }
    inc %l 2
  }
  return %r
}

alias msn.roompass {
  if ($1) return %msnp.qkey. [ $+ [ $right($1,-2) ] ]
  else return %msnp.qkey. [ $+ [ $right($chan,-2) ] ]
}

alias msn.ownerkey {
  if ($1) return %msnp.qkey. [ $+ [ $right($1,-2) ] ]
  else return %msnp.qkey. [ $+ [ $right($chan,-2) ] ]
}

alias msn.hostkey {
  if ($1) return %msnp.okey. [ $+ [ $right($1,-2) ] ]
  else return %msnp.okey. [ $+ [ $right($chan,-2) ] ]
}

; $msn.get($sockname,room) or $msn.get($cid,room)
alias msn.get {
  if (msn.*.* iswm $1) return $hget(msn. $+ $gettok($$1,3,46),$$2)
  else return $hget(msn. $+ $$1,$$2)
}

; $msn.ppdata(ppname,item)
alias msn.ppdata {
  if (($1 == $null) && ($2 == $null)) return $null
  return $readini($scriptdir $+ vpassport.dat,$1,$2)
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
  if ($1 == $chr(1)) return 0
  elseif ($1 == $chr(2)) return 1
  elseif ($1 == $chr(3)) return 5
  elseif ($1 == $chr(4)) return 3
  elseif ($1 == $chr(5)) return 2
  elseif ($1 == $chr(6)) return 7
  elseif ($1 == $chr(7)) return 6
  elseif ($1 == $chr(8)) return 10
  elseif ($1 == $chr(9)) return 15
  elseif ($1 == $chr(11)) return 4
  elseif ($1 == $chr(12)) return 9
  elseif ($1 == $chr(14)) return 8
  elseif ($1 == $chr(15)) return 13
  elseif ($1 == $chr(16)) return 11
  elseif ($1 == \r) return 12
  elseif ($1 == \n) return 14
  else return 1
}

;--- Local Identifiers
alias msn.getnick {
  if ($1 == p) {
    if (%msnx.asknickp) {
      if (%msnx.nick) { return %msnx.nick }
      elseif (%msnpass.cookie && !%msnx.nick) { return }
      elseif (!%msnpass.cookie && !%msnx.nick) {
        if ($me) return $iif(>* !iswm $me,$me,$right($me,-1))
        var %n = $dialog(msn.name,msn.name)
        if ((!%msnc.unicodenick) && (%n != $null)) %n = $msn.encode(%n)
        unset %msnc.unicodenick
        if (!%n) halt
        return %n
      }
    }
    else {
      var %n = $dialog(msn.name,msn.name)
      if ((!%msnc.unicodenick) && (%n != $null)) %n = $msn.encode(%n)
      unset %msnc.unicodenick
      if (!%n) {
        if (%msnx.nick) { return %msnx.nick }
        elseif (%msnpass.cookie && !%msnx.nick) { return }
        elseif (!%msnpass.cookie && !%msnx.nick) {
          if (%me) return $iif(>* !iswm $me,$me,$right($me,-1))
          halt
        }
      }
      return %n
    }
  }
  elseif ($1 == g) {
    if (%msnx.asknickg) {
      if (%msnx.nick) return %msnx.nick
      elseif ($me) return $iif(>* !iswm $me,$me,$right($me,-1))
    }
    else {
      set -u0 %msnc.guest $true
      var %n = $dialog(msn.name,msn.name)
      if ((!%msnc.unicodenick) && (%n != $null)) %n = $msn.encode(%n)
      unset %msnc.unicodenick
      if (%n) return %n
      elseif (%msnx.nick) return %msnx.nick
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
      set -u5 %msn.nostart $true
      .timer 1 0 .unload -rs " $+ $script $+ "
      halt
    }
    if (!%msnc.nostart) unset %msn*
    elseif ($version != 6.03) echo $color(info2) -ta * Vincula Neo is designed for mIRC v6.03.  It should work on your version (mIRC $version $+ ) but it is untested and may act strange.
    echo $color(info2) -ta * Welcome to Vincula Neo (v4.0)
    echo $color(info2) -ta * Please read the instructions in the vincula.txt file!
    echo $color(info2) -ta * Now performing initializations, please wait...
    %msnc.startup = $true
  }
  if (%msnc.nostart) halt
  unset %msnc.*
  if (%msnf.font == $null) %msnf.font = $gettok($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontName),1,59)
  if (%msnf.fcolor == $null) %msnf.fcolor = $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontColor)
  if (%msnf.fstyle == $null) %msnf.fstyle = $calc($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontStyle) + 1)
  if (%msnx.decode == $null) %msnx.decode = $true
  if (%msnx.usepass == $null) %msnx.usepass = $true
  if (%msnx.showprof == $null) %msnx.showprof = 1
  if (%msnx.encode == $null) %msnx.encode = $false
  if (%msnx.timereply == $null) %msnx.timereply = $($asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT),0)
  if (%msnx.clsid == $null) %msnx.clsid = 7a32634b-029c-4836-a023-528983982a49
  if (!$isfile($scriptdir $+ vfcache.dat)) msn.updatefonts
  else {
    if ($hget(msn.fonts)) hfree msn.fonts
    hmake msn.fonts 30
    hload msn.fonts " $+ $scriptdir $+ vfcache.dat"
  }
  msn.enchash
  var %p = $iif(%msnx.selpp,%msnx.selpp,none)
  echo $color(info2) -st * Vincula Neo $chr(124) UD1: $msn.ud1 $chr(124) Current Passport: %p
  if (%p != none) .msn.loadpp %p
  if (%msnc.startup) { msn.setup | unset %msnc.startup }
  window -ph @VinculaHTML
  %p = $msn.ndll(attach,$window(@VinculaHTML).hwnd)
  echo $color(info2) -st * Opening lookup server connections...
  msn.lookcon
}

alias msn.lookcon {
  if ($sock(msn.look.main) == $null) {
    var %x main
    sockclose msn.client.*main
    socklisten msn.client.lcmain
    msn.writehtml $sock(msn.client.lcmain).port vinculam.html
    msn.donav @Vinculamain vinculam.html
  }
  if ($sock(msn.look.comm) == $null) {
    var %x comm
    sockclose msn.client.*comm
    socklisten msn.client.lccomm
    msn.writehtml $sock(msn.client.lccomm).port vinculac.html
    msn.donav @Vinculacomm vinculac.html
  }
}

;--- Displays
raw PROP:*: {
  if ($2 == language) {
    echo $color(info2) -ti2 $1 * $msn.ifdecode($nick) sets the room language to $gettok(English.French.German.Japanese.Swedish.Dutch.Korean.Chinese (Simplified).Portuguese.Finnish.Danish.Russian.Italian.Norwegian.Chinese (Traditional).Spanish.Czech.Greek.Hungarian.Polish.Slovene.Turkish.Slovak.Portuguese (Brazilian),$3,46) ( $+ $3 $+ )
  }
  else {
    echo $color(info2) -ti2 $1 * $msn.ifdecode($nick sets the $2 property to:  $3-)
  }
}

raw 818:*: {
  if ($3 == PUID) {
    echo $color(info2) -at * Opening $msn.ifdecode($2) $+ 's profile...
    var %m, %c, %x, %p http://chat.msn.com/profile.msnw?epuid= $+ $4- , %w @Vincula�-� $+ $msn.ifdecode($2) $+ 's�Profile
    window -pk0 %w
    %m = $msn.ndll(attach,$window(%w).hwnd)
    %m = $msn.ndll(select,$window(%w).hwnd)
    %m = $msn.ndll(handler,msn.hnd.prof)
    %m = $msn.ndll(navigate,%p)
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
  echo $color(info2) -ti2 $comchan($nick,1) * $msn.ifdecode($nick) is now away
  cline -l $color(grayed) $comchan($nick,1) $fline($comchan($nick,1),$nick,1,1)
  if ($window($nick) == $nick) echo $color(info2) -t $nick * $msn.ifdecode($nick) is now away
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
  if ((%msnx.sounds) && ($sock(msn.server. $+ $cid)) && (%msnx.snd.join != $null)) splay -w " $+ %msnx.snd.join $+ "
  if ($msn.get($cid,decode)) {
    if ($nick === $me) {
      echo $color(join) -t $chan * Now talking in $chan $iif(%msnc.jointime,$chr(40) $+ Join time: $calc(($ticks - %msnc.jointime) / 1000) seconds $+ $chr(41))
      msn.getpass $chan
      unset %msnc.*
      %msnt.jwho = $true
      who $chan
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
      %msnt.jwho $true
      who $chan
    }
  }
  ;if (($sock(msn.server. $+ $cid)) && ($nick != $me)) .timer -m 1 300 msn.chklst.join $nick $cid
}

alias msn.recent {
  if ($isid) {
    if (-g == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) {
      if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,3,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,3,32),60) (guest): %msnr. [ $+ [ $1 ] ]
      else return $gettok(%msnr. [ $+ [ $1 ] ] ,3,32) (guest): %msnr. [ $+ [ $1 ] ]
    }
    elseif (-c == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) {
      if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,3,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,3,32),60) (community): %msnr. [ $+ [ $1 ] ]
      else return $gettok(%msnr. [ $+ [ $1 ] ] ,3,32) (community): %msnr. [ $+ [ $1 ] ]
    }
    elseif ((-cg == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) || (-gc == $gettok(%msnr. [ $+ [ $1 ] ] ,2,32))) {
      if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,3,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,3,32),60) (community, guest): %msnr. [ $+ [ $1 ] ]
      else return $gettok(%msnr. [ $+ [ $1 ] ] ,3,32) (community, guest): %msnr. [ $+ [ $1 ] ]
    }
    if ($len($gettok(%msnr. [ $+ [ $1 ] ] ,2,32)) > 60) return $chr(160) $+ ... $+ $right($gettok(%msnr. [ $+ [ $1 ] ] ,2,32),60) (normal): %msnr. [ $+ [ $1 ] ]
    else return $gettok(%msnr. [ $+ [ $1 ] ] ,2,32) (normal): %msnr. [ $+ [ $1 ] ]
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

on ^*:PART:*: {
  if ($msn.get($cid,decode)) {
    echo $color(part) -t $chan * Parts:  $msn.ifdecode($nick) ( $+ $address $+ ) $+ $iif($1 != $null,( $+ $1- $+ )) $+ : $nick
    if ($window($nick) == $nick) echo $color(part) -t $nick * $msn.ifdecode($nick) has left the room
    haltdef
  }
  ;if ($sock(msn.server. $+ $cid)) .timer -m 1 300 msn.chklst.part $nick $cid
}

on ^*:TEXT:*:#: {
  if ($msn.get($cid,decode)) {
    if ($chr(37) $+ $chr(35) $+ * iswm $nick) var %n = $chan
    else var %n = $line($chan,$fline($chan,$nick $+ *,1,1),1)
    var %p = $left($nick($chan,%n).pnick,1)
    if (%p == $left(%n,1)) unset %p
    echo $color(normal) -tmi2 $chan < $+ %p $+ $msn.ifdecode(%n) $+ > $msn.ifdecode($1-)
    haltdef
  }
}

on ^*:ACTION:*:#: {
  if ($msn.get($cid,decode)) {
    var %n $line($chan,$fline($chan,$nick $+ *,1,1),1)
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
    echo $color(normal) -tmi2 $nick < $+ %p $+ $msn.ifdecode($nick) $+ > $msn.ifdecode($1-)

    haltdef
  }
}

on ^*:NOTICE:*:#: {
  if ($msn.get($cid,decode)) {
    echo $color(notice) -tmi2 $chan $msn.ifdecode($+(-,$nick,-) $1-)
    haltdef
  }
}

on ^*:NOTICE:*:?: {
  if ((%msnx.sounds) && ($sock(msn.server. $+ $cid)) && (%msnx.snd.rwhs != $null)) splay -w " $+ %msnx.snd.rwhs $+ "
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
  if ((%msnx.sounds) && ($sock(msn.server. $+ $cid)) && (%msnx.snd.kick != $null)) splay -w " $+ %msnx.snd.kick $+ "
  if ($msn.get($cid,decode)) {
    echo $color(kick) -ti2 $chan $msn.ifdecode(* $knick was kicked by $nick $iif($1- != $null,$chr(40) $+ $1- $+  $+ $chr(41))) $+ : $knick
    if ($window($knick) == $knick) echo $color(kick) -ti2 $knick $msn.ifdecode(* $knick was kicked by $nick $iif($1- != $null,$chr(40) $+ $1- $+ $chr(41)))
    if ($knick == $me) echo $color(kick) -sti2 * You were kicked out of $msn.get($cid,fullroom) by $msn.ifdecode($nick $iif($1- != $null,$chr(40) $+ $1- $+ $chr(41)))
    haltdef
  }
}

on ^*:QUIT: {
  if ($msn.get($cid,decode)) {
    echo $color(quit) -ti2 $msn.get($cid,room) $msn.ifdecode(* Quits: $nick ( $+ $address $+ ) $iif($1 != $null,$chr(40) $+ $1- $+  $+ $chr(41))) $+ : $nick
    if ($window($nick) == $nick) echo $color(quit) -ti2 $nick $msn.ifdecode(* $nick has left the room $chr(40) $+ Quit $+ $iif($1- != $null,: $1-) $+ $chr(41))
    haltdef
  }
}

on ^*:INVITE:#: {
  if ((%msnx.sounds) && ($sock(msn.server. $+ $cid)) && (%msnx.snd.invt != $null)) splay -w " $+ %msnx.snd.invt $+ "
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
  if ($sockerr > 0) { msn.sockerr $sockname | return }
  sockwrite -tn msn.look. $+ $right($sockname,4) IRCVERS IRC7 MSN-OCX!7.00.0206.0401 $lf AUTH GateKeeper I :GKSSP\0#7\0\0\0\0\0\0
}

on *:SOCKCLOSE:msn.look.*: {
  if ($sockerr > 0) { msn.sockerr $sockname }
  .timer $+ $sockname off
  scid $activecid echo $color(info2) -at * $iif($gettok($sockname,3,46) == main,Main,Community) lookup server connection lost! Reconnecting...
  sockclose msn.client.* $+ $right($sockname,4)
  .timer 1 1 msn.lookcon
}

on *:SOCKREAD:msn.look.*: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }

  var %read
  sockread %read
  while ($sockbr > 0) {
    tokenize 32 %read

    if (%msnx.debug) echo @debug $sockname $+ : $1-

    if (AUTH GateKeeper S :GKSSP* iswm $1-) sockwrite -tn msn.client.lm $+ $right($sockname,4) %read
    elseif (AUTH GateKeeper *@GateKeeper* iswm $1-) {
      sockwrite -tn $sockname NICK vincula $+ $rand(111,999)
      if ($sockname == msn.look.main) {
        .timermsn.look.main 0 3 sockwrite -tn msn.look.main NOOP
        scid $activecid echo $color(info2) -at * Main Lookup server connection established
      }
      else {
        .timermsn.look.comm 0 3 sockwrite -tn msn.look.comm NOOP
        scid $activecid echo $color(info2) -at * Community Lookup server connection established
      }
    }
    elseif (613 == $2) {
      if ($hget(msn.999)) {
        echo $color(info2) -at * $msn.get(999,fullroom) found, joining... (Lookup time: $calc(($ticks - %msnc.looktime) / 1000) seconds)
        unset %msnc.looktime
        socklisten msn.mirc.in $rand(10000,30000)
        if (%msnc.newcon) scid %msnc.newcon server 127.0.0.1 $sock(msn.mirc.in).port
        else server -m 127.0.0.1 $sock(msn.mirc.in).port
        sockopen msn.server.999 $right($4-,-1)
        socklisten msn.client.rmc
        msn.writehtml $sock(msn.client.rmc).port
        msn.donav
      }
      else {
        msn %msnc.msnopt %msnc.making
      }
    }
    elseif (472 == $2) {
      echo $color(info2) -at * Unknown mode character, cannot create the room
      msn.clear 999
      unset %msnc.*
    }
    elseif (701 == $2) {
      echo $color(info2) -at * Invalid room category, cannot create the room
      msn.clear 999
      unset %msnc.*
    }
    elseif (702 == $2) {
      echo $color(info2) -at * $msn.get(999,fullroom) not found (Lookup time: $calc(($ticks - %msnc.looktime) / 1000) seconds)
      msn.makeroom $msn.get(999,fullroom)
      msn.clear 999
      unset %msnc.*
    }
    elseif (705 == $2) {
      .timer 1 0 msn.roomexists
    }
    elseif (706 == $2) {
      echo $color(info2) -at * Invalid room name, cannot create the room
      msn.clear 999
      unset %msnc.*
    }
    elseif ((7?? iswm $2) || (9?? iswm $2)) {
      echo $color(info2) -at * Error $2 $+ : $right($4-,-1)
      msn.clear 999
      unset %msnc.*
    }
    sockread %read
  }
}

;--- Client Socket (Lookup)
on *:SOCKLISTEN:msn.client.lc*: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }
  sockaccept msn.client.lm $+ $right($sockname,4)
  if ($right($sockname,4) == main) {
    sockopen msn.look.main 207.68.167.253 6667
  }
  else {
    sockopen msn.look.comm 207.68.167.251 6667
  }
  sockclose $sockname
}

on *:SOCKREAD:msn.client.lm*: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }

  var %read
  sockread %read
  while ($sockbr > 0) {
    tokenize 32 %read

    if (%msnx.debug) echo @debug $sockname $+ : $1-

    if (AUTH GateKeeper S :GKSSP* iswm $1-) {
      var %x $right($sockname,4)
      sockclose msn.client.* $+ %x
      window -c @Vincula $+ %x
      .remove $+(",$scriptdir,vincula,$left(%x,1),.html")
      sockwrite -tn msn.look. $+ %x %read
      return
    }

    sockread %read
  }
}

;--- Client Socket (Room)
on *:SOCKLISTEN:msn.client.rmc: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }
  sockaccept msn.client.rm
  sockclose $sockname
  if (($sock(msn.server.999).status == active) && ($sock(msn.mirc.999).status == active)) {
    if ($msn.get(999,guest)) {
      sockwrite -tn msn.server.999 IRCVERS IRC7 MSN-OCX!7.00.0206.0401 $lf AUTH GateKeeper I :GKSSP\0#7\0\0\0\0\0\0
    }
    else {
      sockwrite -tn msn.server.999 IRCVERS IRC7 MSN-OCX!7.00.0206.0401 $lf AUTH GateKeeperPassport I :GKSSP\0#7\0\0\0\0\0\0
    }
  }
}

on *:SOCKREAD:msn.client.rm: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }

  var %read
  sockread %read
  while ($sockbr > 0) {
    tokenize 32 %read

    if (%msnx.debug) echo @debug $sockname $+ : $1-

    if (AUTH GateKeeper* S :GKSSP* iswm $1-) {
      if ($msn.get(999,guest)) sockwrite -tn msn.server.999 $1-
      else sockwrite -tn msn.server.999 $1 GateKeeperPassport $3-
      sockclose $sockname
      var %s $msn.ndll(select,$window(@VinculaHTML).hwnd)
      %s = $msn.ndll(navigate,about:blank)
      return
    }

    sockread %read
  }
}

;--- MSN Socket (Room)
on *:SOCKOPEN:msn.server.*: {
  if ($sockerr > 0) {
    msn.sockerr $sockname
    sockclose *.999
    sockclose msn.client.*
    var %x $msn.ndll(select,$window(@VinculaHTML).hwnd)
    %x = $msn.ndll(navigate,about:blank)
    return
  }
  if (($sock(msn.client.rm).status == active) && ($sock(msn.mirc.999).status == active)) {
    if ($msn.get(999,guest)) {
      sockwrite -tn msn.server.999 IRCVERS IRC7 MSN-OCX!7.00.0206.0401 $lf AUTH GateKeeper I :GKSSP\0#7\0\0\0\0\0\0
    }
    else {
      sockwrite -tn msn.server.999 IRCVERS IRC7 MSN-OCX!7.00.0206.0401 $lf AUTH GateKeeperPassport I :GKSSP\0#7\0\0\0\0\0\0
    }
  }
}

on *:SOCKCLOSE:msn.server.*: {
  if ($sockerr > 0) { msn.sockerr $sockname }

  msn.clear $gettok($sockname,3,46)
  sockclose msn*. $+ $gettok($sockname,3,46)
  sockclose msn.cli*
  var %x $msn.ndll(select,$window(@VinculaHTML).hwnd)
  %x = $msn.ndll(navigate,about:blank)
}

on *:SOCKREAD:msn.server.*: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }

  var %read, %x msn.mirc. $+ $gettok($sockname,3,46)
  sockread %read
  while ($sockbr > 0) {
    if ($istok(%read,$msn.get($sockname,fullroom),32)) tokenize 32 $reptok(%read,$msn.get($sockname,fullroom),$msn.get($sockname,room),1,32)
    elseif ($istok(%read,: $+ $msn.get($sockname,fullroom),32)) tokenize 32 $reptok(%read,: $+ $msn.get($sockname,fullroom),: $+ $msn.get($sockname,room),1,32)
    else tokenize 32 %read

    if (%msnx.debug) echo @debug $sockname $+ : $1-

    if (AUTH GateKeeper* S :GKSSP* iswm $1-) sockwrite -tn msn.client.rm $1-
    elseif (AUTH GateKeeper*S :OK iswm $1-) {
      if (%msnx.usepass) var %pass $msn.ownerkey($msn.get($sockname,room))
      if ((%msnpass.cookie) && (!$msn.get($sockname,nick))) {
        sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf PROP $ MSNREGCOOKIE : $+ %msnpass.cookie $lf PROP $ MSNPROFILE : $+ %msnx.showprof $lf JOIN $msn.get($sockname,fullroom) %pass
      }
      elseif ((%msnpass.cookie) && ($msn.get($sockname,nick))) {
        sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf NICK $msn.get($sockname,nick) $lf PROP $ MSNREGCOOKIE : $+ %msnpass.cookie $lf PROP $ MSNPROFILE : $+ %msnx.showprof $lf JOIN $msn.get($sockname,fullroom) %pass
      }
      else {
        sockwrite -tn $sockname AUTH GateKeeperPassport S : $+ $msn.authkey $lf USER * * " $+ $ip $+ " :Vincula Neo (4.0) $lf NICK $msn.get($sockname,nick) $lf PROP $ MSNPROFILE : $+ %msnx.showprof $lf JOIN $msn.get($sockname,fullroom) %pass
      }
    }
    elseif (AUTH GateKeeper*@GateKeeper* 0 iswm $1-) {
      if (AUTH GateKeeper*@GateKeeper 0 iswm $1-) {
        if (%msnx.usepass) var %pass $msn.ownerkey($msn.get($sockname,room))
        if (($msn.get($sockname,nick)) && (!$msn.get($sockname,guest)) && (%msnpass.cookie)) sockwrite -tn $sockname NICK $msn.get($sockname,nick) $lf JOIN $msn.get($sockname,fullroom) %pass
        elseif ($msn.get($sockname,guest)) sockwrite -tn $sockname NICK > $+ $msn.get($sockname,nick) $lf JOIN $msn.get($sockname,fullroom) %pass
      }
      %msnt.gate = $4
    }

    ; :moo!ident@GKP JOIN H,U,RX :%#room
    elseif ($2 == JOIN) {
      if ($scid($gettok($sockname,3,46)).me !ison $chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88)) {
        msn.set $sockname fullroom $right($gettok(%read,4,32),-1)
        msn.set $sockname room $chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88)
        msn.set $sockname shortroom $left($chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88),60)
        tokenize 32 $reptok(%read,$gettok(%read,4,32),: $+ $chr(37) $+ $chr(35) $+ $right($right($gettok(%read,4,32),-3),88),1,32)
      }
      sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 $2 $4-

      if ($gettok($3,4,44) == +) { sockwrite -tn %x $1 MODE $msn.get($sockname,room) +v $right($gettok($1,1,33),-1) }
      elseif ($gettok($3,4,44) == @) { sockwrite -tn %x $1 MODE $msn.get($sockname,room) +o $right($gettok($1,1,33),-1) }
      elseif ($gettok($3,4,44) == .) { sockwrite -tn %x $1 MODE $msn.get($sockname,room) +q $right($gettok($1,1,33),-1) }

if ($sockname != msn.server.999) .timer -m 1 300 msn.chklst.join $right($gettok($1,1,33),-1) $gettok($sockname,3,46)

      if (%msnx.ojprof) {
        if ($gettok($3,3,44) == FY) { sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) MSNPROFILE :13 }
        elseif ($gettok($3,3,44) == MY) { sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) MSNPROFILE :11 }
        elseif ($gettok($3,3,44) == PY) { sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) MSNPROFILE :9 }
        elseif ($gettok($3,3,44) == FX) { sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) MSNPROFILE :5 }
        elseif ($gettok($3,3,44) == MX) { sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) MSNPROFILE :3 }
        elseif ($gettok($3,3,44) == PX) { sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) MSNPROFILE :1 }
        else { sockwrite -tn %x :TK2CHATCHATA01 818 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) MSNPROFILE :0 }
        sockwrite -tn %x :TK2CHATCHATA01 819 $scid($gettok($sockname,3,46)).me $right($gettok($1,1,33),-1) :End of properties
      }
    }

    elseif ($2 == PART) {
      scid $gettok($sockname,3,46) .timer -m 1 300 msn.chklst.part $right($gettok($1,1,33),-1) $gettok($sockname,3,46)
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
        if (:VERSION* iswm $4) {
          if (!%msnc.dover) {
            sockwrite -tn msn.server. $+ $gettok($sockname,3,46) NOTICE $right($gettok($1,1,33),-1) :VERSION Vincula Neo (v4.0), by eXonyte (mIRC $version on Win $+ $os $+ )
          }
          set -u3 %msnc.dover $true
          scid $gettok($sockname,3,46) echo $color(ctcp) -t $!msn.get($sockname,room) [[ $+ $right($gettok($1,1,33),-1) VERSION]
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

    elseif ($2 == MESSAGE) {
      sockwrite -tn %x $1 PRIVMSG $3-
    }

    ; :'DishDiva!DishDiva@cg EQUESTION %#Onstage3 Auntiehoo %#Onstage1 :Is there anyone you would like to do a duo or compilation with that hasn't presented itself yet?
    elseif ($2 == EQUESTION) {
      scid $gettok($sockname,3,46) | echo -ti2 $left(@Q/A- $+ $3,90)  $+ $4 in $5 asks: $right($6-,-1) | scid -r
    }

    ; :'Toby_Keith_Live!Toby_Keith_Live@cg EPRIVMSG %#Onstage3 :It makes me feel great. I consider myself a songwritter first and foremost. I write for myself and if something I write touches someone else, that's awesome. That's all the approval I need.
    elseif ($2 == EPRIVMSG) {
      scid $gettok($sockname,3,46) | echo -ti2 $left(@Q/A- $+ $3,90) < $+ $right($gettok($1,1,33),-1) $+ > $right($4-,-1) | scid -r
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

    elseif ($2 == PROP) {
      if ($4 == ownerkey) %msnp.qkey. [ $+ [ $right($3,-2) ] ] = $right($5,-1)
      if ($4 == hostkey) %msnp.okey. [ $+ [ $right($3,-2) ] ] = $right($5,-1)
      sockwrite -tn %x $1-
    }

    elseif ($2 == INVITE) sockwrite -tn %x $1 $+ !*@GateKeeperPassport $2 $3 : $+ $5

    elseif ($2 == KICK) {
      sockwrite -tn %x $1-
      if (%msnx.usepass) var %p $msn.ownerkey($msn.get($sockname,room))
      if (($4 == $scid($gettok($sockname,3,46)).me) && (%msnx.kickrj)) sockwrite -tn $sockname JOIN $msn.get($sockname,fullroom) %p
    }

    elseif ($2 == 001) {
      sockwrite -tn %x : $+ $me $+ ! $+ %msnt.gate NICK $3
      unset %msnt.gate
      %msnc.cid = $gettok($sockname,3,46)
      sockwrite -tn %x $1-
    }

    elseif ($2 == 004) {
      sockwrite -tn %x $1-
      sockwrite -tn %x $1 005 $3 IRCX CHANTYPES=% PREFIX=(qov).@+ CHANMODES=b,k,l,defhimnprstuwWx NETWORK=MSN :are supported by this server
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
      cline -l $color(grayed) $msn.get($sockname,room) $fline($msn.get($sockname,room),$me,1,1)
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
      ;.timer 1 1 msn.setaways $gettok($sockname,3,46)
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
      hfree msn.999
      return
    }

    ;elseif ($2 == 913) sockwrite -tn %x $1 474 $3 $4 :Cannot join channel (+b)

    elseif ($2 == 923) sockwrite -tn %x $1 404 $3 $4 :Whispers not permitted

    elseif ($2 == 932) sockwrite -tn %x $1 404 $3 $4 :Profanity not permitted ( $+ $lower($5) $+ )

    else {
      if ($sock(%x)) sockwrite -tn %x $1-
    }

    sockread %read
  }
}

;--- mIRC Socket
on *:SOCKLISTEN:msn.mirc.in: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }
  sockaccept msn.mirc.999
  sockclose $sockname
  if (($sock(msn.server.999).status == active) && ($sock(msn.client.rm).status == active)) {
    if ($msn.get(999,guest)) {
      sockwrite -tn msn.server.999 IRCVERS IRC7 MSN-OCX!7.00.0206.0401 $lf AUTH GateKeeper I :GKSSP\0#7\0\0\0\0\0\0
    }
    else {
      sockwrite -tn msn.server.999 IRCVERS IRC7 MSN-OCX!7.00.0206.0401 $lf AUTH GateKeeperPassport I :GKSSP\0#7\0\0\0\0\0\0
    }
  }
}

on *:SOCKCLOSE:msn.mirc.*: {
  if ($sockerr > 0) { msn.sockerr $sockname }

  msn.clear $gettok($sockname,3,46)
  sockclose msn*. $+ $gettok($sockname,3,46)
  sockclose msn.client.*
  var %x $msn.ndll(select,$window(@VinculaHTML).hwnd)
  %x = $msn.ndll(navigate,about:blank)
}

on *:SOCKREAD:msn.mirc.*: {
  if ($sockerr > 0) { msn.sockerr $sockname | return }

  var %read, %x msn.server. $+ $gettok($sockname,3,46)
  sockread %read
  while ($sockbr > 0) {
    if ($istok(%read,$msn.get($sockname,room),32)) tokenize 32 $reptok(%read,$msn.get($sockname,room),$msn.get($sockname,fullroom),1,32)
    elseif ($istok(%read,$msn.get($sockname,shortroom),32)) tokenize 32 $reptok(%read,$msn.get($sockname,shortroom),$msn.get($sockname,fullroom),1,32)
    else tokenize 32 %read

    if (%msnx.debug) echo @debug $sockname $+ : $1-

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
      if (($3 == $null) && (%msnx.usepass)) sockwrite -tn %x $1- $msn.ownerkey($msn.get($sockname,room))
      else sockwrite -tn %x $1-
    }
    elseif ($1 == PRIVMSG) {
      if (:* !iswm $3) {
        if (?#* iswm $2) {
          sockwrite -tn %x $1 $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
        else {
          sockwrite -tn %x WHISPER $msn.get($sockname,fullroom) $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
      }
      else {
        if (:ACTION == $3) {
          sockwrite -tn %x $1 $2 $3 $left($4-,-1) $+ 
        }
        else sockwrite -tn %x $1-
      }
    }
    elseif ($1 == NOTICE) {
      if (:* !iswm $3) {
        if (?#* !iswm $2) {
          sockwrite -tn %x PRIVMSG $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
        else {
          sockwrite -tn %x NOTICE $2 :S $msn.mrctomsn($msn.get($sockname,fcolor),$gettok($sockname,3,46)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
      }
      else sockwrite -tn %x $1-
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

ctcp *:TIME:*: {
  if ($sock(msn.*. $+ $cid,0) >= 2) {
    echo $color(ctcp) -t $msn.get($cid,room) [[ $+ $nick TIME]
    if (!%msnc.dotime) {
      .ctcpreply $nick TIME $(%msnx.timereply,2)
    }
    set -u3 %msnc.dotime $true
    haltdef
  }
}

on *:CTCPREPLY:�DT�E: {
  if (($sock(msn.*. $+ $cid,0) >= 2) && ($2- == $null)) {
    echo $color(ctcp) -t $msn.get($cid,room) [[ $+ $nick �DT�E]
    if (!%msnc.doircdom) {
      .ctcpreply $nick �DT�E Vincula Neo (v4.0), by eXonyte (mIRC $version on Win $+ $os $+ )
    }
    set -u3 %msnc.doircdom $true
    haltdef
  }
}

on ^*:OPEN:?:*: {
  if ((%msnx.nowhispers) && ($sock(msn.server. $+ $cid))) {
    if (!%msnc.stoperr. [ $+ [ $nick ] ] ) {
      set -u10 $+(%,msnc.stoperr.,$nick) $true
      sockwrite -tn msn.server. $+ $cid WHISPER $msn.get($cid,fullroom) $nick :ERR NOUSERWHISPER
    }
    halt
  }
  if ($sock(msn.mirc. $+ $cid)) {
    if ((%msnx.sounds) && ($sock(msn.server. $+ $cid)) && (%msnx.snd.whsp != $null)) splay -w " $+ %msnx.snd.whsp $+ "
    var %p = $left($nick($comchan($nick,1),$nick).pnick,1)
    if (%p == $left($nick,1)) unset %p
    .timer 1 0 echo -tm $nick $msn.ifdecode(< $+ %p $+ $nick $+ > $1-)
    .timer 1 0 echo $color(info2) -t $nick * Decoded nickname is $nick
    .timer 1 0 echo $color(info2) -t $nick * Whisper from $!msn.get($cid,fullroom)
    query -n $nick
    halt
  }
}

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
  if (%x == %msnx.selpp) %x = $style(1) %x
  return %x :msn.loadpp %p
}

;--- Popup menus
menu query {
  $iif($sock(msn.*. $+ $cid,0) == 2,Vincula Neo (4.0))
  . $+ $msn.decode($1) :echo $color(info2) -at * Decoded: $msn.decode($$1) / Undecoded: $$1 | clipboard $msn.ifdecode($$1)
  .. $+ $iif($gettok($ial($1 $+ *,1),2,33) != $null,$ifmatch) $+ :echo $color(info2) -at * Address:  $ial($1 $+ *,1)
  .-
  .Check IRCDom Version:ctcpreply $1 �DT�E
  . $+ $iif(>* iswm $nick,$style(2)) View Profile: PROP $1 PUID
  . $+ $iif(>* iswm $nick,$style(2)) View Profile Type: PROP $1 MSNPROFILE
}

menu nicklist {
  $iif($sock(msn.*. $+ $cid,0) == 2,Vincula Neo (4.0))
  . $+ $msn.decode($$1)
  .. $+ $1 $+ :echo $color(info2) -at * Decoded: $msn.decode($$1) / Undecoded: $$1 | clipboard $msn.ifdecode($$1)
  .. $+ $iif($gettok($ial($1 $+ *,1),2,33) != $null,$ifmatch) $+ :echo $color(info2) -at * Address:  $ial($1 $+ *,1)
  ..-
  ..$iif($me !isowner $chan,$style(2)) $+ Add to access as Owner: access $chan add owner *! $+ $gettok($ial($1 $+ *,1),2,33) 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  ..$iif($me !isop $chan,$style(2)) $+ Add to access as Host: access $chan add host *! $+ $gettok($ial($1 $+ *,1),2,33) 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  ..$iif($me !isop $chan,$style(2)) $+ Add to access as Participant: access $chan add voice *! $+ $gettok($ial($1 $+ *,1),2,33) 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  ..$iif($me !isop $chan,$style(2)) $+ Add to access as Grant: access $chan add grant *! $+ $gettok($ial($1 $+ *,1),2,33) 0 : $+ $me added $1 - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  .-
  .Check IRCDom Version:ctcpreply $$1 �DT�E
  . $+ $iif(>* iswm $1,$style(2)) View Profile: PROP $$1 PUID
  . $+ $iif(>* iswm $1,$style(2)) View Profile Type: PROP $$1 MSNPROFILE
  .-
  .$msn.pop.o($1,$chan) $+ Owner:mode $chan +q $$1
  .$msn.pop.h($1,$chan) $+ Host:mode $chan +o $$1
  .$msn.pop.p($1,$chan) $+ Participant:mode $chan -o+v $$1 $$1
  .$msn.pop.s($1,$chan) $+ Spectator:mode $chan -ov $$1 $$1
  .-
  .Kick and Ban
  ..15 Minutes...: access $chan add deny *! $+ $gettok($ial($1 $+ *,1),2,33) 15 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 15 Minute Ban $+ $iif($! != $null,: $!)
  ..1 Hour...: access $chan add deny *! $+ $gettok($ial($1 $+ *,1),2,33) 60 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 1 Hour Ban $+ $iif($! != $null,: $!)
  ..24 Hours...: access $chan add deny *! $+ $gettok($ial($1 $+ *,1),2,33) 1440 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 24 Hour Ban $+ $iif($! != $null,: $!)
  ..Infinite...: access $chan add deny *! $+ $gettok($ial($1 $+ *,1),2,33) 0 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 Infinite Ban $+ $iif($! != $null,: $!)
  ..-
  ..How long?...: access $chan add deny *! $+ $gettok($ial($1 $+ *,1),2,33) $$input(How long in minutes would you like to ban for?,129,Ban length) | kick $chan $1 $! Minute Ban
}

menu channel {
  $iif($sock(msn.*. $+ $cid,0) == 2,Vincula Neo (4.0))
  .Get the room's URL
  ..Hex:msn.geturl h
  ..Normal:msn.geturl
  .Join the room using the MSN Chat Client:msn.dojoinurl $msn.geturl(h)
  .$iif($msn.ownerkey($chan) == $null,$style(2) $+ Current Ownerkey is unknown,Stored Ownerkey $+ $chr(58) $msn.ownerkey($chan)) :msn.getpass $chan | clipboard $msn.ownerkey($chan)
  .$iif($msn.hostkey($chan) == $null,$style(2) $+ Current Hostkey is unknown,Stored Hostkey $+ $chr(58) $msn.hostkey($chan)) :msn.getpass $chan | clipboard $msn.hostkey($chan)
  .-
  .Access List...:access
  .Ban Guests:access $chan add deny >*!*@* :Guests banned by $me - $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
  .Unban Guests:access $chan delete deny >*!*@*
  .-
  .Room Modes
  ..$iif(u isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Knock Mode: mode $chan $iif(u isin $gettok($chan($chan).mode,1,32),-,+) $+ u
  ..$iif(m isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Spectator (Moderated) Mode: mode $chan $iif(m isin $gettok($chan($chan).mode,1,32),-,+) $+ m
  ..$iif(w !isincs $gettok($chan($chan).mode,1,32),$style(1)) $+ Whispers Enabled: mode $chan $iif(w isincs $gettok($chan($chan).mode,1,32),-,+) $+ w
  ..$iif(W !isincs $gettok($chan($chan).mode,1,32),$style(1)) $+ Guest Whispers Enabled: mode $chan $iif(W isincs $gettok($chan($chan).mode,1,32),-,+) $+ W
  ..$iif(h isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Hidden Room (Not on the room list): mode $chan $iif(h isin $gettok($chan($chan).mode,1,32),-,+) $+ h
  ..$iif(f isin $gettok($chan($chan).mode,1,32),$style(3),$style(2)) $+ MSN Profanity Filter Enabled: return
  ..$iif(x isin $gettok($chan($chan).mode,1,32),$style(3),$style(2)) $+ Auditorium Mode Enabled: return
  .Set Room Language...:msn.newlang
  .Set Room Lag...:prop $chan lag $$input(Please enter the amount of lag you want to add $chr(40) $+ number of seconds from 0 to 2 $+ $chr(41),129,Vincula - Change Room Lag)
  .-
  .Change Welcome Message...:prop $chan onjoin : $+ $$input(Enter the welcome message:,129,Change Welcome Message)
  .Unset Welcome Message:prop $chan onjoin :
  .-
  .Change Gold Key...:prop $chan ownerkey $$input(Enter the new gold $chr(40) $+ owner $+ $chr(41) key:,129,Change Gold Key)
  .Unset Gold Key:prop $chan ownerkey :
  .-
  .Change Brown Key...:prop $chan hostkey $$input(Enter the new brown $chr(40) $+ host $+ $chr(41) key:,129,Change Brown Key)
  .Unset Brown Key:prop $chan hostkey :
  .-
  .Change other room settings...:channel $chan
}

menu menubar,status {
  Vincula Neo (4.0)
  .Change Vincula settings...:msn.setup
  .Current Userdata1 key $+ $chr(58) $msn.ud1 : echo $color(info2) -at * Current Userdata1 key: $msn.ud1 | clipboard $msn.ud1
  .-
  .Update Passport information (Auto)...:msn.getpp
  .Update Passport information (Manual)...:msn.mgetpp
  .Edit Passport information for %msnx.selpp $+ ...:msn.editpp
  .Select a Passport to use
  ..$submenu($msn.pop.pp($1))
  .-
  .View MSN Room List...:msn.roomlist
  .-
  .Create Room:msn.makeroom
  .Join Recent Room
  ..$submenu($msn.recent($1))
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

  .Join Room (Community)
  ..Normal...:joins -c $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -c $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex -c $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl -c $$input(Enter a room's URL,129,Enter Room URL)

  .Join Room (Community, Guest)
  ..Normal...:joins -cg $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -cg $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex -cg $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl -cg $$input(Enter a room's URL,129,Enter Room URL)
}

;--- Setup dialog
alias msn.setup dialog -m msn.setup. $+ $cid msn.setup

dialog msn.setup {
  title "Vincula - Setup"
  icon $mircexe , 5
  size -1 -1 152 119
  option dbu

  tab "General", 1000, 0 0 151 101

  box "", 90, 3 14 146 51, tab 1000
  text "Font name:", 10, 4 22 29 7, right tab 1000
  combo 20, 34 20 112 70, edit drop sort tab 1000

  text "Font style:", 11, 4 34 29 7, right tab 1000
  check "Bold", 71, 34 34 20 7, tab 1000
  check "Italic", 72, 34 44 22 7, tab 1000
  check "Underline", 73, 34 54 40 7, tab 1000

  text "Font color:", 12, 74 34 29 7, right tab 1000
  combo 21, 104 33 42 130, drop tab 1000
  check "Random", 31, 104 47 30 7, tab 1000

  box "", 91, 3 61 73 38, tab 1000
  check "Decode incoming text", 33, 6 67 60 7, tab 1000
  check "Show users' colors", 34, 6 77 60 7, tab 1000
  check "Disable whispers", 116, 6 87 60 7, tab 1000

  box "", 92, 75 61 74 38, tab 1000
  check "Auto password usage", 35, 78 67 65 7, tab 1000
  check "Encode outgoing text", 36, 78 77 65 7, tab 1000
  check "Rejoin when kicked", 117, 78 87 65 7, tab 1000

  tab "Passports", 1001
  text "Stored Passports:", 96, 3 19 43 7, tab 1001
  combo 43, 47 17 101 100, drop tab 1001
  button "Add", 103, 3 30 33 10, tab 1001
  button "Edit", 104, 40 30 33 10, tab 1001
  button "Delete", 105, 77 30 33 10, tab 1001
  button "Refresh", 102, 114 30 34 10, tab 1001
  text "", 106, 3 42 145 7, right tab 1001
  box "", 107, 3 48 145 50, tab 1001
  check "Don't ask for nickname when connecting with passport", 108, 7 55 140 7, tab 1001
  check "Don't ask for nickname when connecting as a guest", 115, 7 65 140 7, tab 1001
  check "Auto update info if older than", 109, 7 75 81 7, tab 1001
  edit "", 110, 88 73 11 11, tab 1001
  text "hours", 111, 100 75 20 7, tab 1001

  tab "Extra", 1002
  box "Time Reply:", 93, 3 16 146 21, tab 1002
  edit %msnx.timereply , 38, 6 23 108 11, autohs tab 1002
  button "Default", 39, 116 22 30 12, tab 1002
  check "Show user's profile type upon entry", 40, 7 61 100 7, tab 1002
  button "Clear stored Owner keys", 118, 3 71 71 12, tab 1002
  button "Clear stored Host keys", 119, 77 71 71 12, tab 1002

  box "MSN Chat CLSID:", 112, 3 37 146 21, tab 1002
  edit %msnx.clsid, 113, 6 44 108 11, autohs tab 1002
  button "Default", 114, 116 43 30 12, tab 1002

  tab "Sounds", 1003
  check "Enable Sounds", 120, 50 17 50 7, tab 1003

  button "Joins:", 121, 3 25 45 10, tab 1003
  edit "", 122, 49 25 87 11, autohs tab 1003
  button "...", 123, 137 25 10 10, tab 1003

  button "Whisper Box:", 124, 3 37 45 10, tab 1003
  edit "", 125, 49 37 87 11, autohs tab 1003
  button "...", 126, 137 37 10 10, tab 1003

  button "Room Whispers:", 127, 3 49 45 10, tab 1003
  edit "", 128, 49 49 87 11, autohs tab 1003
  button "...", 129, 137 49 10 10, tab 1003

  button "Kicks:", 130, 3 61 45 10, tab 1003
  edit "", 131, 49 61 87 11, autohs tab 1003
  button "...", 132, 137 61 10 10, tab 1003

  button "Invites:", 133, 3 73 45 10, tab 1003
  edit "", 134, 49 73 87 11, autohs tab 1003
  button "...", 135, 137 73 10 10, tab 1003

  button "Knocks:", 136, 3 85 45 10, tab 1003
  edit "", 137, 49 85 87 11, autohs tab 1003
  button "...", 138, 137 85 10 10, tab 1003

  button "OK", 100, 67 105 40 12, ok default
  button "Cancel", 101, 110 105 40 12, cancel
}

on *:DIALOG:msn.setup*:init:*: {
  var %l 1, %d did -a $dname, %c did -c $dname

  while ($hget(msn.fonts,%l) != $null) {
    %d 20 $hget(msn.fonts,%l)
    inc %l
  }

  didtok $dname 21 44 Black,White,Dark Blue,Dark Green,Red,Dark Red,Purple,Dark Yellow,Yellow,Green,Teal,Cyan,Blue,Pink,Dark Gray,Gray

  %l = 1
  while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
    %d 43 $ini($scriptdir $+ vpassport.dat,%l)
    inc %l
  }
  %c 43 $didwm($dname,43,%msnx.selpp)

  var %t $ctime, %x $calc(%t - $msn.ppdata($did(43),updated))
  if (%t != %x) %d 106 Passport last refreshed $duration(%x) ago

  if ($sock(*. $+ $gettok($dname,3,46),0) >= 1) {
    did -i $dname 20 0 $replace($msn.get($dname,fname),\b,$chr(32))
    %c 21 $calc($msn.get($dname,fcolor) + 1)
    var %f $calc($msn.get($dname,fstyle) - 1)
    if ($msn.get($dname,frand)) {
      %c 31
      did -b $dname 21
    }
    if ($msn.get($dname,decode)) %c 33
    if ($msn.get($dname,docolor)) %c 34
    if ($msn.get($dname,encode)) %c 36
  }

  else {
    did -i $dname 20 0 $replace(%msnf.font,\b,$chr(32))
    %c 21 $calc(%msnf.fcolor + 1)
    var %f $calc(%msnf.fstyle - 1)
    if (%msnf.rand) {
      %c 31
      did -b $dname 21
    }
    if (%msnx.decode) %c 33
    if (%msnx.docolor) %c 34
    if (%msnx.encode) %c 36
  }

  if (%msnx.usepass) %c 35
  if ($isbit(%f,1)) %c 71
  if ($isbit(%f,2)) %c 72
  if ($isbit(%f,3)) %c 73

  if (%msnx.ojprof) %c 40
  if (%msnx.asknickp) %c 108
  if (%msnx.autoup) %c 109
  else did -b $dname 110
  %d 110 %msnx.autouptime
  if (%msnx.asknickg) %c 115
  if (%msnx.nowhispers) %c 116
  if (%msnx.kickrj) %c 117
  if (%msnx.sounds) %c 120

  %d 122 %msnx.snd.join
  %d 125 %msnx.snd.whsp
  %d 128 %msnx.snd.rwhs
  %d 131 %msnx.snd.kick
  %d 134 %msnx.snd.invt
  %d 137 %msnx.snd.knck
}

on *:DIALOG:msn.setup*:sclick:31: {
  if ($did(31).state) did -b $dname 21
  else did -e $dname 21
}

on *:DIALOG:msn.setup*:sclick:39: {
  did -ra $dname 38 $($asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT),0)
}

on *:DIALOG:msn.setup.*:sclick:43: {
  var %t $ctime, %x $calc(%t - $msn.ppdata($did(43),updated))
  if (%t != %x) did -a $dname 106 Passport last refreshed $duration(%x) ago
}

;Refresh
on *:DIALOG:msn.setup*:sclick:102: {
  if ($timer(.msn.agpp) >= 1) {
    echo $color(info2) -at * Please wait until the Passport Updater is finished before trying to update again
    return
  }
  var %e $msn.ppdata($did(43),email)
  var %p $msn.ppdata($did(43),passwd)
  if (%p == $null) %p = $$input(Please enter the passport for the %e passport:,130,Enter Password)
  msn.dogetpp $did(43) %e %p
}

;Add
on *:DIALOG:msn.setup*:sclick:103: {
  return $dialog(msn.ppadd,msn.ppinfo,-4)
}

;Edit
on *:DIALOG:msn.setup*:sclick:104: {
  return $dialog(msn.ppedit,msn.ppinfo,-4)
}

;Delete
on *:DIALOG:msn.setup*:sclick:105: {
  if ($input(Are you sure you want to delete $did(43) $+ ?,264,Delete Passport Entry)) {
    .remini $+(",$scriptdir,vpassport.dat") $did(43)
    did -d $dname 43 $did(43).sel
    did -c $dname 43 1
  }
}

on *:DIALOG:msn.setup*:sclick:109: {
  if ($did(109).state) did -e $dname 110
  else did -b $dname 110
}

on *:DIALOG:msn.setup*:sclick:114: {
  did -ra $dname 113 7a32634b-029c-4836-a023-528983982a49
}

on *:DIALOG:msn.setup*:sclick:118: {
  if ($input(Are you sure you want to clear the stored Owner key list?,136,Vincula - Clear Owner keys)) unset %msnp.okey.*
}

on *:DIALOG:msn.setup*:sclick:119: {
  if ($input(Are you sure you want to clear the stored Host key list?,136,Vincula - Clear Host keys)) unset %msnp.hkey.*
}

on *:DIALOG:msn.setup*:sclick:121: {
  splay " $+ $$did(122) $+ "
}

on *:DIALOG:msn.setup*:sclick:123: {
  did -ra $dname 122 $$sfile($nofile($did(122)) $+ *.wav,Choose a sound file)
}

on *:DIALOG:msn.setup*:sclick:124: {
  splay " $+ $$did(125) $+ "
}

on *:DIALOG:msn.setup*:sclick:126: {
  did -ra $dname 125 $$sfile($nofile($did(125)) $+ *.wav,Choose a sound file)
}

on *:DIALOG:msn.setup*:sclick:127: {
  splay " $+ $$did(128) $+ "
}

on *:DIALOG:msn.setup*:sclick:129: {
  did -ra $dname 128 $$sfile($nofile($did(128)) $+ *.wav,Choose a sound file)
}

on *:DIALOG:msn.setup*:sclick:130: {
  splay " $+ $$did(131) $+ "
}

on *:DIALOG:msn.setup*:sclick:132: {
  did -ra $dname 131 $$sfile($nofile($did(131)) $+ *.wav,Choose a sound file)
}

on *:DIALOG:msn.setup*:sclick:133: {
  splay " $+ $$did(134) $+ "
}

on *:DIALOG:msn.setup*:sclick:135: {
  did -ra $dname 134 $$sfile($nofile($did(134)) $+ *.wav,Choose a sound file)
}

on *:DIALOG:msn.setup*:sclick:136: {
  splay " $+ $$did(137) $+ "
}

on *:DIALOG:msn.setup*:sclick:138: {
  did -ra $dname 137 $$sfile($nofile($did(134)) $+ *.wav,Choose a sound file)
}

on *:DIALOG:msn.setup*:sclick:100: {
  if ($sock(*. $+ $gettok($dname,3,46),0) >= 1) {
    msn.set $dname fname $replace($did(20),$chr(32),\b)
    msn.set $dname fcolor $calc($did(21).sel - 1)
    var %f 1
    if ($did(71).state) %f = $calc(%f + 1)
    if ($did(72).state) %f = $calc(%f + 2)
    if ($did(73).state) %f = $calc(%f + 4)
    msn.set $dname fstyle %f
    if ($did(31).state) msn.set $dname frand $true
    else msn.unset $dname frand
    if ($did(33).state) msn.set $dname decode $true
    else msn.unset $dname decode
    if ($did(34).state) msn.set $dname docolor $true
    else msn.unset $dname docolor
    if ($did(36).state) msn.set $dname encode $true
    else msn.unset $dname encode
  }

  %msnf.font = $replace($did(20),$chr(32),\b)
  %msnf.fcolor = $calc($did(21).sel - 1)
  %msnf.fstyle = 1
  if ($did(71).state) %msnf.fstyle = $calc(%msnf.fstyle + 1)
  if ($did(72).state) %msnf.fstyle = $calc(%msnf.fstyle + 2)
  if ($did(73).state) %msnf.fstyle = $calc(%msnf.fstyle + 4)
  if ($did(31).state) %msnf.rand = $true
  else unset %msnf.rand
  if ($did(33).state) %msnx.decode = $true
  else unset %msnx.decode
  if ($did(34).state) %msnx.docolor = $true
  else unset %msnx.docolor
  if ($did(35).state) %msnx.usepass = $true
  else unset %msnx.usepass
  if ($did(36).state) %msnx.encode = $true
  else unset %msnx.encode
  %msnx.timereply = $did(38)
  if ($did(40).state) %msnx.ojprof = $true
  else unset %msnx.ojprof
  if ($did(108).state) %msnx.asknickp = $true
  else unset %msnx.asknickp
  if ($did(109).state) %msnx.autoup = $true
  else unset %msnx.autoup
  %msnx.autouptime = $did(110)
  .msn.loadpp $did(43)
  %msnx.clsid = $did(113)
  if ($did(115).state) %msnx.asknickg = $true
  else unset %msnx.asknickg
  if ($did(116).state) %msnx.nowhispers = $true
  else unset %msnx.nowhispers
  if ($did(117).state) %msnx.kickrj = $true
  else unset %msnx.kickrj
  if ($did(120).state) %msnx.sounds = $true
  else unset %msnx.sounds
  %msnx.snd.join = $did(122)
  %msnx.snd.whsp = $did(125)
  %msnx.snd.rwhs = $did(128)
  %msnx.snd.kick = $did(131)
  %msnx.snd.invt = $did(134)
  %msnx.snd.knck = $did(137)
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
alias -l msn.uni2ansi {
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
  size -1 -1 178 115
  option dbu

  text "Entry Name:", 1, 2 4 40 7, right
  edit "", 2, 45 2 103 11, autohs
  text "(Required)", 17, 150 4 40 7

  text "Nickname:", 3, 2 16 40 7, right
  edit "", 4, 45 14 103 11, autohs

  text "E-mail:", 5, 2 28 40 7, right
  edit "", 6, 45 26 103 11, autohs
  text "(Required)", 19, 150 28 40 7

  text "Password:", 7, 2 40 40 7, right
  edit "", 8, 45 38 103 11, autohs pass

  text "MSNREGCookie:", 9, 2 52 40 7, right
  edit "", 10, 45 50 103 11, autohs

  text "PassportTicket:", 11, 2 64 40 7, right
  edit "", 12, 45 62 103 11, autohs

  text "PassportProfile:", 13, 2 76 40 7, right
  edit "", 14, 45 74 103 11, autohs

  text "Profile Type:", 15, 2 88 40 7, right
  combo 16, 45 86 103 60, drop

  button "OK", 99, 45 100 40 12, ok
  button "Cancel", 98, 90 100 40 12, cancel
}

on *:DIALOG:msn.pp*:init:*: {

  didtok $dname 16 44 No Profile,Profile,Male,Female,No Gender + Picture,Male + Picture,Female + Picture
  did -c $dname 16 1

  if ($dname == msn.ppedit) {
    dialog -t $dname Edit Passport Info
    did -m $dname 2
    did -a $dname 2 $did(msn.setup. $+ $cid,43)
    did -a $dname 4 $msn.ppdata($did(msn.setup. $+ $cid,43),nick)
    did -a $dname 6 $msn.ppdata($did(msn.setup. $+ $cid,43),email)
    did -a $dname 8 $msn.ppdata($did(msn.setup. $+ $cid,43),passwd)
    did -a $dname 10 $msn.ppdata($did(msn.setup. $+ $cid,43),cookie)
    did -a $dname 12 $msn.ppdata($did(msn.setup. $+ $cid,43),ticket)
    did -a $dname 14 $msn.ppdata($did(msn.setup. $+ $cid,43),profile)
    var %x $msn.ppdata($did(msn.setup. $+ $cid,43),showprof)
    if (%x == 0) did -c $dname 16 1
    elseif (%x == 1) did -c $dname 16 2
    elseif (%x == 3) did -c $dname 16 3
    elseif (%x == 5) did -c $dname 16 4
    elseif (%x == 9) did -c $dname 16 5
    elseif (%x == 11) did -c $dname 16 6
    elseif (%x == 13) did -c $dname 16 7
    else did -c $dname 16 1
  }
}

on *:DIALOG:msn.ppadd*:sclick:99: {
  if (!$did(2)) {
    var %x $input(You must include a name for the Passport data.,516,Need a Name)
    halt
  }
  elseif (!$did(6)) {
    var %x $input(You must include an e-mail address with the Passport data.,516,Need an E-mail Address)
    halt
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
    if (msn.ppadd == $dname) %x updated $ctime
    var %n $replace($did(2),$chr(32),$chr(160))
    if ($didwm(msn.setup. $+ $cid,43,%n) < 1) {
      did -a msn.setup. $+ $cid 43 %n
      did -c msn.setup. $+ $cid 43 $didwm(msn.setup. $+ $cid,43,%n)
    }
    if (($did(12) == $null) || ($did(14) == $null)) {
      var %e $msn.ppdata(%n,email), %p $msn.ppdata(%n,passwd)
      if (%p == $null) %p = $$input(Please enter the passport for the %e passport:,130,Enter Password)
      msn.dogetpp %n %e %p
    }
  }
}

alias msn.editpp dialog -m msn.appedit msn.ppinfo

on *:DIALOG:msn.appedit:init:*: {
  didtok $dname 16 44 No Profile,Profile,Male,Female,No Gender + Picture,Male + Picture,Female + Picture
  did -c $dname 16 1
  dialog -t $dname Edit Passport Info
  did -m $dname 2
  did -a $dname 2 %msnx.selpp
  did -a $dname 4 $msn.ppdata(%msnx.selpp,nick)
  did -a $dname 6 $msn.ppdata(%msnx.selpp,email)
  did -a $dname 8 $msn.ppdata(%msnx.selpp,passwd)
  did -a $dname 10 $msn.ppdata(%msnx.selpp,cookie)
  did -a $dname 12 $msn.ppdata(%msnx.selpp,ticket)
  did -a $dname 14 $msn.ppdata(%msnx.selpp,profile)
  var %x = $msn.ppdata(%msnx.selpp,showprof)
  if (%x == 0) did -c $dname 16 1
  elseif (%x == 1) did -c $dname 16 2
  elseif (%x == 3) did -c $dname 16 3
  elseif (%x == 5) did -c $dname 16 4
  elseif (%x == 9) did -c $dname 16 5
  elseif (%x == 11) did -c $dname 16 6
  elseif (%x == 13) did -c $dname 16 7
  else did -c $dname 16 1
}

on *:DIALOG:msn.appedit:sclick:99: {
  if (!$did(2)) {
    var %x $input(You must include a name for the Passport data.,516,Need a Name)
    halt
  }
  elseif (!$did(6)) {
    var %x $input(You must include an e-mail address with the Passport data.,516,Need an E-mail Address)
    halt
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
    if (msn.ppadd == $dname) %x updated $ctime
    var %n $replace($did(2),$chr(32),$chr(160))
    if ($didwm(msn.setup. $+ $cid,43,%n) < 1) {
      did -a msn.setup. $+ $cid 43 %n
      did -c msn.setup. $+ $cid 43 $didwm(msn.setup. $+ $cid,43,%n)
    }
  }
}

;--- Room creation dialog
alias msn.makeroom {
  dialog -m msn.room.1 msn.room
  did -a msn.room.1 21 $$1-
  if ($msn.get(999,guest) == $true) did -c msn.room.1 31
  if ($msn.ownerkey($left($1,90)) != $null) did -ra msn.room.1 22 $msn.ownerkey($left($1,90))
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
  check "Create on the Community servers", 32, 57 4 92 7

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

  didtok $dname 23 44 UL - Unlisted,GE - City Chats,CP - Computing,EA - Entertainment,EV - Events,GN - General,HE - Health,II - Interests,LF - Lifestyles,MU - Music,NW - News,PR - Peers,RL - Religion,RM - Romance,SP - Sports & Recreation,TN - Teens
  did -c $dname 23 1

  didtok $dname 24 44 English,French,German,Japanese,Swedish,Dutch,Korean,Chinese (Simplified),Portuguese,Finnish,Danish,Russian,Italian,Norwegian,Chinese (Traditional),Spanish,Czech,Greek,Hungarian,Polish,Slovene,Turkish,Slovak,Portuguese (Brazilian)
  did -c $dname 24 1

  didtok $dname 27 44 Australia - EN-AU,Austria - DE-AT,Belgium (Dutch) - NL-BE,Belgium (French) - FR-BE,Brazil - PT-BR,Canada (English) - EN-CA,Canada (French) - FR-CA,Denmark - DA-DK,Finland - FI-FI,France - FR-FR,Germany - DE-DE,Hong Kong S.A.R. - ZH-HK,India - EN-IN,Italy - IT-IT,Japan - JA-JP,Korea - KO-KR,Latin America - ES-LA,Malaysia - ML-MY,Mexico - ES-MX,Netherlands - NL-NL,New Zealand - EN-NZ,Norway - NO-NO,Spain - ES-ES,Singapore - ZH-SG,South Africa - ZH-TW,Sweden - SV-SE,Switzerland (French) - FR-CH,Switzerland (German) - DE-CH,Taiwan - ZH-TW,United Kingdom - EN-GB,United States (English) - EN-US,United States (Spanish) - ES-LA
  did -c $dname 27 31

  did -f $dname 11
}

on *:DIALOG:msn.room.*:sclick:99: {
  if ($did(26) == $null) {
    var %x $input(You must include a user limit for the room.,516,Need a User Limit)
    did -f $dname 26
    halt
  }
  elseif ($did(22) == $null) {
    var %x $input(You must include a password for the room.,516,Need a Password)
    did -f $dname 22
    halt
  }
  elseif ($did(21) == $null) {
    var %x $input(You must include a name for the room.,516,Need a Room Name)
    did -f $dname 21
    halt
  }
  var %t, %m, %p, %r
  if ($chr(37) $+ $chr(35) $+ * iswm $did(21)) %r = $did(21)
  elseif ($did(2).state) %r = $msn.unhex($did(21))
  else %r = $chr(37) $+ $chr(35) $+ $msn.encode($replace($did(21),$chr(32),\b,$chr(44),\c))
  if ($did(25) != $null) %t = $chr(37) $+ $replace($did(25),$chr(32),\b,$chr(44),\c)
  else %t = -
  if ($did(1).state == 1) %m = fl $did(26)
  else %m = l $did(26)
  %p = $did(22)
  else %p = $msn.pass(10)
  %msnp.qkey. [ $+ [ $right(%r,-2) ] ] = $left(%p,90)
  if (!$did(32).state) .sockwrite -tn msn.look.main CREATE $gettok($did(23),1,32) %r %t %m $gettok($did(27),-1,32) $did(24).sel %p 0
  else .sockwrite -tn msn.look.comm CREATE $gettok($did(23),1,32) %r %t %m $gettok($did(27),-1,32) $did(24).sel %p 0
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
  text "Using passport:", 4, 2 26 40 7
  combo 5, 41 24 106 100, drop
  check "Nickname is in Unicode Format", 3, 2 38 82 7
  button "OK", 99, 107 38 40 12, ok
}

on *:DIALOG:msn.name:init:*: {
  var %l 1
  if (%msnc.guest) did -b $dname 5
  else {
    while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
      did -a $dname 5 $ini($scriptdir $+ vpassport.dat,%l)
      inc %l
    }
    did -c $dname 5 $didwm($dname,5,%msnx.selpp)
  }
}

on *:DIALOG:msn.name:sclick:99: {
  %msnc.unicodenick = $did(3).state
  .msn.loadpp $did(5).seltext
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
  size -1 -1 246 137
  option dbu

  list 1, 1 2 200 60, vsbar hsbar disable

  box "Info", 2, 1 58 200 77
  text "Placed by:", 3, 5 66 40 7, right
  edit "", 4, 48 64 150 11, read autohs
  text "Remaining Time:", 5, 5 78 40 7, right
  edit "", 6, 48 76 25 11, read autohs
  text "minutes", 7, 75 78 150 7
  text "Reason:", 8, 5 90 40 7, right
  edit "", 9, 48 88 150 31, read multi autovs
  text "Access Mask:", 10, 5 122 40 7, right
  edit "", 11, 48 120 150 11, read autohs

  button "Add Entry", 12, 203 2 40 12, disable
  button "Delete Entry", 13, 203 16 40 12, disable
  button "Clear Grant", 14, 203 30 40 12, disable
  button "Clear Voice", 18, 203 44 40 12, disable
  button "Clear Host", 19, 203 58 40 12, disable
  button "Clear Owner", 20, 203 72 40 12, disable
  button "Refresh List", 15, 203 86 40 12

  button "Export", 16, 203 104 20 12
  button "Import", 17, 223 104 20 12, disable

  button "Done", 99, 203 122 40 12, cancel default
}

on *:DIALOG:msn.access*:init:*: {
  dialog -t $dname Access List for $msn.get($gettok($dname,3,46),room)
  did -a $dname 1 Retrieving Access list...
  if ($me isop $msn.get($gettok($dname,3,46),room)) {
    did -e $dname 12,13,14,17,18,19
  }
  if ($me isowner $msn.get($gettok($dname,3,46),room)) did -e $dname 20
  if ($hget($dname)) hfree $dname
  hmake $dname 2
  hadd $dname num 1
  access $msn.get($gettok($dname,3,46),room)
}

on *:DIALOG:msn.access*:sclick:1: {
  tokenize 32 $hget($dname,$did(1).sel)
  if ($gettok($ial(*! $+ $4,1),1,33)) did -ra $dname 4 $msn.ifdecode($gettok($ial(*! $+ $4,1),1,33)) ( $+ $4 $+ )
  else did -ra $dname 4 $4

  did -ra $dname 6 $3
  did -ra $dname 9 $msn.ifdecode($5-)
  did -ra $dname 11 $2
}

on *:DIALOG:msn.access*:sclick:12: {
  msn.addacc
}

on *:DIALOG:msn.access*:sclick:13: {
  if ($did(1,$did(1).sel) != $null) {
    access $msn.get($cid,room) delete $did(1).seltext
    access $msn.get($cid,room)
    did -ra $dname 1 Retrieving Access list...
  }
}

on *:DIALOG:msn.access*:sclick:14: {
  msn.access.clear $msn.get($cid,room) grant
}

on *:DIALOG:msn.access*:sclick:18: {
  msn.access.clear $msn.get($cid,room) voice
}

on *:DIALOG:msn.access*:sclick:19: {
  msn.access.clear $msn.get($cid,room) host
}

on *:DIALOG:msn.access*:sclick:20: {
  msn.access.clear $msn.get($cid,room) owner
}

alias -l msn.access.clear {
  if ($input(Are you sure you want to clear the $2 access list in $1 $+ ?,264,Clear Access List)) {
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
  var %a, %x $dname, %l $calc($hget(%x,num) - 1), %f access- $+ $gettok($mklogfn($msn.get($cid,room)),1,46) $+ .txt
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

  %msnx.accimp = 1
  did -ra $dname 1 Importing Access list, please wait...
  .timer. $+ msn.accimp. $+ $cid -m 0 500 msn.accimport msn.accimp. $+ $cid
}

alias msn.accimport {
  if ($hget($1,%msnx.accimp) == $null) {
    did -ra msn.access. $+ $cid 1 Retrieving Access list...
    access $msn.get($cid,room)
    .timer. $+ $1 off
    unset %msnx.accimp
    hfree $1
  }
  else {
    access $msn.get($cid,room) ADD $hget($1,%msnx.accimp)
    inc %msnx.accimp
  }
}

on *:DIALOG:msn.access*:sclick:99: {
  hfree $dname
}

raw 801:*: {
  if ($dialog(msn.access. $+ $cid)) haltdef
}

raw 802:*: {
  if ($dialog(msn.access. $+ $cid)) haltdef
}

raw 803:*: {
  var %x msn.access. $+ $cid
  if ($dialog(%x)) {
    did -ra %x 1 Retrieving Access list...
    if ($hget(%x)) hfree %x
    hmake %x 2
    hadd %x num 1
    haltdef
  }
}

raw 804:*: {
  var %x msn.access. $+ $cid
  if ($dialog(%x)) {
    hadd %x $hget(%x,num) $3-
    hinc %x num
    did -e %x 1,12,13,14
    haltdef
  }
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
    haltdef
  }
}

raw 820:*: {
  if ($dialog(msn.access. $+ $cid)) haltdef
}

;  :TK2CHATCHATA05 913 eXonyte %#�!!~~AChristiansChatWorld~~!! � :No access
raw 913:*: {
  var %x msn.access. $+ $cid
  if ($dialog(%x)) {
    did -ra %x 1 Access listing was denied (No access)
    did -b %x 1,12,13,14
  }
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
  didtok $dname 2 44 General - GN,City Chats - GE,Computing - CP,Entertainment - EA,Events - EV,Health - HE,Interests - II,Lifestyles - LF,Music - MU,News - NW,Peers - PR,Religion - RL,Romance - RM,Sports & Recreation - SP,Teens - TN
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
  else {
    window -a @VinculaRooms
  }
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
    if (http://chat.msn.com/chatroom.msnw* iswm $3-) {
      unset %msnc.domsnpass
    }
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
  size -1 -1 114 91
  option dbu

  box "Join the room:", 1, 2 2 110 48

  radio "Using a stored passport", 2, 4 10 105 7, group
  radio "Using a Guest nickname", 3, 4 20 105 7
  radio "On MSN using a stored passport", 4, 4 30 105 7
  radio "On MSN as a Guest", 5, 4 40 105 7

  box "Select a passport:", 7, 2 50 110 23
  combo 8, 6 58 102 100, drop

  edit "", 6, 0 0 0 0, hide autohs

  button "OK", 99, 2 77 40 12, ok
  button "Cancel", 98, 71 77 40 12, cancel
}

on *:DIALOG:msn.roomgp:init:0: {
  did -c $dname 2
  var %l 1
  while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
    did -a $dname 8 $ini($scriptdir $+ vpassport.dat,%l)
    inc %l
  }
  if ($didwm($dname,8,%msnx.selpp) >= 1) did -c $dname 8 $didwm($dname,8,%msnx.selpp)
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
  if ($didwm($dname,8,%msnx.selpp) >= 1) did -c $dname 8 $didwm($dname,8,%msnx.selpp)
  else did -c $dname 8 1
  did -e $dname 8
}

on *:DIALOG:msn.roomgp:sclick:3: {
  did -b $dname 8
  did -r $dname 8
}

on *:DIALOG:msn.roomgp:sclick:4: {
  did -r $dname 8
  var %l 1
  while (%l <= $ini($scriptdir $+ vpassport.dat,0)) {
    var %pn = $ini($scriptdir $+ vpassport.dat,%l)
    var %pc = $msn.ppdata(%pn,cookie)
    var %pt = $msn.ppdata(%pn,ticket)
    var %pp = $msn.ppdata(%pn,profile)
    if ((%pc != $null) && (%pt != $null) && (%pp != $null)) {
      did -a $dname 8 %pn
    }
    inc %l
  }
  did -e $dname 8
  if ($didwm($dname,8,%msnx.selpp) >= 1) did -c $dname 8 $didwm($dname,8,%msnx.selpp)
  else did -c $dname 8 1
}

on *:DIALOG:msn.roomgp:sclick:5: {
  did -b $dname 8
  did -r $dname 8
}

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
  else {
    msn.msndojoin $me $joinurl($1) $2-
  }
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
    echo Loaded %p
  }

  write -c $+(",$scriptdir,vmsnroom.html") <HTML><BODY STYLE="margin:0" link="#000000" vlink="#000000" bgcolor="#A5B2CE">

  %x &nbsp;<a href="http://12345689/vinculaguest- $+ %r $+ "><font face="Tahoma" color="#2E3E5E" style="font-size: 10pt;"><b>Join this room in mIRC as a Guest</b</font></a> $chr(124)
  %x <a href="http://12345689/vinculapass- $+ %r $+ "><font face="Tahoma" color="#2E3E5E" style="font-size: 10pt;"><b>Join this room in mIRC using your Passport</b></font></a> $chr(124)
  %x <a href="javascript:window.open('vmsnopts.html','_blank','toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=0,height=420,width=630'); void('');"><font face="Tahoma" color="#2E3E5E" style="font-size: 10pt;"><b>Change Chatroom Options</b></font></a>
  if (%msnx.clsid) {
    %x <OBJECT ID="ChatFrame" $+(CLASSID="CLSID:,%msnx.clsid,") width="100%">
  }
  else {
    %x <OBJECT ID="ChatFrame" CLASSID="CLSID:7a32634b-029c-4836-a023-528983982a49" width="100%">
  }

  %x <PARAM NAME="HexRoomName" $+(VALUE=",%r,">)
  %x <PARAM NAME="NickName" $+(VALUE=",%n,">)
  %x <PARAM NAME="Server" VALUE="207.68.167.253:6667">
  %x <PARAM NAME="BaseURL" VALUE="http://chat.msn.com/">
  %x <PARAM NAME="BackColor" value="&h5E3E2E">
  %x <PARAM NAME="BackHighlightColor" value="&h9C654A">
  %x <PARAM NAME="ButtonTextColor" value="&hFFFFFF">
  %x <PARAM NAME="ButtonFrameColor" value="&h5E3E2E">
  %x <PARAM NAME="ButtonBackColor" value="&h5E3E2E">
  if (($1 != -g) && (%pc != $null) && (%pt != $null) && (%pp != $null) && (%pi != $null)) {
    %x <PARAM NAME="MSNREGCookie" $+(VALUE=",%pc,">)
    %x <PARAM NAME="PassportTicket" $+(VALUE=",%pt,">)
    %x <PARAM NAME="PassportProfile" $+(VALUE=",%pp,">)
    %x <PARAM NAME="MSNProfile" $+(VALUE=",%pi,">)
  }
  %x </OBJECT><script language="JavaScript"><!--
  %x function fnResize() $chr(123) newheight=document.body.clientHeight-35; if (newheight < 252) newheight=252; document.all("ChatFrame").style.pixelHeight=newheight; $chr(125)
  %x window.onresize=fnResize; fnResize();
  %x //--></script></BODY></HTML></BODY></HTML>

  write -c $+(",$scriptdir,vmsnopts.html,") <HTML><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><title>MSN Chat Options</title></head>
  write $+(",$scriptdir,vmsnopts.html,") <BODY STYLE="margin:0"><OBJECT ID="Settings" CLASSID="CLSID:71b8f2df-0032-48ba-a784-93d9caaab07d" alt="You need to download the control before you can set options" width=580 height=650></OBJECT></BODY></HTML>

  var %win $left(@VinculaChatroom�-� $+ $msn.unhex(%r),90)
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

;var %x $msn.ndll(detach,$window(@VinculaChatroom�-� $+ $msn.unhex($1-)).hwnd)
alias msn.gchatgo {
  window -c @VinculaChatroom�-� $+ $msn.unhex($1-)
  .timer 1 0 joinhex -g $1-
}

;var %x $msn.ndll(detach,$window(@VinculaChatroom�-� $+ $msn.unhex($1-)).hwnd)
alias msn.pchatgo {
  window -c @VinculaChatroom�-� $+ $msn.unhex($1-)
  .timer 1 0 joinhex $1-
}

;--- Change Room Language
;--- Uses msn.roomcat dialog
alias msn.newlang {
  dialog -m msn.roomlang. $+ $cid msn.roomcat
}

on *:DIALOG:msn.roomlang.*:init:0: {
  dialog -t $dname Vincula - Room Language
  did -ra $dname 1 Which language would you like to use?
  didtok $dname 2 44 English,French,German,Japanese,Swedish,Dutch,Korean,Chinese (Simplified),Portuguese,Finnish,Danish,Russian,Italian,Norwegian,Chinese (Traditional),Spanish,Czech,Greek,Hungarian,Polish,Slovene,Turkish,Slovak,Portuguese (Brazilian)
  did -c $dname 2 1
}

on *:DIALOG:msn.roomlang.*:sclick:99: {
  sockwrite -tn msn.server. $+ $cid PROP $msn.get($cid,room) Language $did(2).sel
}
