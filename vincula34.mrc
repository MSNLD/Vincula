;Vincula v3.4 - eXonyte's MSN Chat connection script
;Vincula is a plural form of Vinculum, which means "A bond or tie"

;--- User editable display stuff

raw 818:*: {
  if ($3 == PUID) {
    echo $color(info2) -at *** Opening $msn.decode($2) $+ 's profile...
    var %m, %p = http://chat.msn.com/profile.msnw?epuid= $+ $4-
    %msn.stoppropend = $true
    run iexplore %p
    haltdef
  }
  elseif (($3 == MSNPROFILE) && ($msn.get($cid,doprof))) {
    if ($4 == 1) prop $2 PUID
    else echo $color(info2) -at *** $msn.decode($2) does not have a profile
    %msn.stoppropend = $true
    haltdef
  }
}

raw 819:*: {
  if (%msn.stoppropend) {
    unset %msn.stoppropend
    haltdef
  }
}

raw PROP:*: {
  echo $colour(info2) -ti2 $1 *** $msn.decode($nick sets $2 property to:  $3-)
  if ($2 == ownerkey) %msn.pass. [ $+ [ $right($1,-2) ] ] = $3-
}

raw 822:*: {
  echo $color(info2) -ti2 $1 *** $msn.decode($nick) is now away
  cline -l $color(grayed) $1 $fline($1,$nick,1,1)
  if ($window($nick) != $null) echo $color(info2) -t $nick *** $msn.decode($nick) is now away
  haltdef
}

raw 821:*: {
  echo $color(info2) -ti2 $1 *** $msn.decode($nick) has returned
  cline -lr $1 $fline($1,$nick,1,1)
  if ($window($nick) != $null) echo $color(info2) -t $nick *** $msn.decode($nick) has returned
  haltdef
}

raw KNOCK:*: {
  if ($2 == 913) echo $colour(info) -t $1 *** Knock:  $msn.decode($nick) ( $+ $address $+ ) (Access Ban): $nick
  elseif ($2 == 471) echo $colour(info) -t $1 *** Knock:  $msn.decode($nick) ( $+ $address $+ ) (Room is full): $nick
  elseif ($2 == 473) echo $colour(info) -t $1 *** Knock:  $msn.decode($nick) ( $+ $address $+ ) (Room is invite only): $nick
  elseif ($2 == 474) echo $colour(info) -t $1 *** Knock:  $msn.decode($nick) ( $+ $address $+ ) (Banned): $nick
  elseif ($2 == 475) echo $colour(info) -t $1 *** Knock:  $msn.decode($nick) ( $+ $address $+ ) (Need room key): $nick
  else echo $colour(info) -t $1 *** Knock:  $msn.decode($nick) ( $+ $address $+ ) (Numeric: $2 $+ ): $nick
  haltdef
}

on *:INPUT:#: {
  if (($msn.get($cid,decode)) && ((/* !iswm $1) || (/me == $1))) {
    var %p
    if ($me isowner $chan) %p = .
    elseif ($me isop $chan) %p = @
    elseif ($me isvo $chan) %p = +
    if (/me != $1) {
      echo $color(own) -ti2 $chan $+(<,$msn.decode(%p $+ $me),>) $1-
      .msg $chan $1-
    }
    else {
      echo $color(own) -ti2 * $msn.decode(%p $+ $me) $2-
      .describe $chan $2-
    }
    haltdef
  }
}

on *:INPUT:?: {
  if (($msn.get($cid,decode)) && ((/* !iswm $1) || (/me == $1))) {
    var %p
    if ($me isowner $sock(msn.server. $+ $cid).mark) %p = .
    elseif ($me isop $sock(msn.server. $+ $cid).mark) %p = @
    elseif ($me isvo $sock(msn.server. $+ $cid).mark) %p = +
    if (/me != $1) {
      echo $color(own) -ti2 $target $+(<,$msn.decode(%p $+ $me),>) $1-
      .msg $target $1-
    }
    else {
      echo $color(own) -ti2 $target $+(<,$msn.decode(%p $+ $me),>) * $+ $2- $+ *
      .msg $target * $+ $2- $+ *
    }
    haltdef
  }
}

on ^*:JOIN:*: {
  if ($nick === $me) unset %msnc.*
  if ($msn.get($cid,decode)) {
    if ($nick === $me) {
      echo $color(join) -t $chan *** Now talking in $chan
      if (%msn.pass. [ $+ [ $right($chan,-2) ] ] ) echo $color(join) -t $chan *** Last stored room key is:  $msn.roompass($chan)
    }
    else {
      echo $color(join) -t $chan *** Joins:  $msn.decode($nick) ( $+ $address $+ ): $nick
      if ($window($nick) != $null) echo $color(join) -t $nick *** $msn.decode($nick) has joined the room
    }
    haltdef
  }
}

on ^*:PART:*: {
  if ($msn.get($cid,decode)) {
    echo $color(part) -t $chan *** Parts:  $msn.decode($nick) ( $+ $address $+ ) $+ $iif($1 != $null,( $+ $1- $+ )) $+ : $nick
    if ($window($nick) != $null) echo $color(part) -t $nick *** $msn.decode($nick) has left the room
    haltdef
  }
}

on ^*:TEXT:*:#: {
  if ($msn.get($cid,decode)) {
    var %p
    if ($nick isowner $chan) %p = .
    elseif ($nick isop $chan) %p = @
    elseif ($nick isvo $chan) %p = +
    echo $color(normal) -tmi2 $chan $msn.decode($+(<,%p,$nick,>) $1-)
    haltdef
  }
}

on ^*:ACTION:*:#: {
  if ($msn.get($cid,decode)) {
    var %p
    if ($nick isowner $chan) %p = .
    elseif ($nick isop $chan) %p = @
    elseif ($nick isvo $chan) %p = +
    echo $color(action) -tmi2 $chan $msn.decode(* %p $+ $nick $1-)
    haltdef
  }
}

on ^*:TEXT:*:?: {
  if ($msn.get($cid,decode)) {
    var %p
    if ($nick isowner $comchan($nick,1)) %p = .
    elseif ($nick isop $comchan($nick,1)) %p = @
    elseif ($nick isvo $comchan($nick,1)) %p = +
    echo $color(normal) -tmi2 $nick $msn.decode($+(<,%p,$nick,>) $1-)
    haltdef
  }
}

on ^*:NOTICE:*:#: {
  if ($msn.get($cid,decode)) {
    echo $color(notice) -tmi2 $chan $msn.decode($+(-,$nick,-) $1-)
    haltdef
  }
}

on ^*:NOTICE:*:?: {
  if ($msn.get($cid,decode)) {
    echo $color(notice) -tmi2 $comchan($nick,1) $msn.decode($+(-,$nick,-) $1-)
    haltdef
  }
}

on ^*:RAWMODE:*: {
  if ($msn.get($cid,decode)) {
    echo $color(mode) -ti2 $chan $msn.decode(*** $nick sets mode: $1-)
    haltdef
  }
}

on ^*:KICK:*: {
  if ($msn.get($cid,decode)) {
    echo $color(kick) -ti2 $chan $msn.decode(*** $knick was kicked by $nick $iif($1- != $null,$chr(40) $+ $1- $+ $chr(41))) $+ : $knick
    if ($window($nick) != $null) echo $color(kick) $nick -ti2 $msn.decode(*** $knick was kicked by $nick $iif($1- != $null,$chr(40) $+ $1- $+ $chr(41)))
    haltdef
  }
}

on ^*:QUIT: {
  if ($msn.get($cid,decode)) {
    echo $color(quit) -ti2 $msn.get($cid,room) $msn.decode(*** Quits: $nick ( $+ $address $+ ) $iif($1 != $null,$chr(40) $+ $1- $+ $chr(41))) $+ : $nick
    if ($window($nick) != $null) echo $color(quit) -ti2 $nick $msn.decode(*** $nick has left the room $chr(40) $+ Quit $+ $chr(41))
    haltdef
  }
}

on ^*:INVITE:#: {
  if ($msn.get($cid,decode)) {
    echo $color(invite) -ati2 *** $msn.decode($nick) ( $+ $address $+ ) invites you to join $chan
    haltdef
  }
}

ctcp *:ERR*:*: {
  if ($2 == NOUSERWHISPER) {
    echo $color(info2) -at *** $msn.decode($nick) is not accepting whispers
    haltdef
  }
  else echo $color(info2) -at *** Error recieved from $msn.decode($nick) $+ : $2-
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

alias msn.ison {
  if ($msn.encode($1) ison $2) return $fline($msn.encode($2,$msn.encode($1),1,1)
  else {
    %x = $replace($1,a,*,b,*,c,*,d,*,e,*,f,*,g,*,h,*,i,*,j,*,k,*,l,*,m,*,n,*,o,*,p,*,q,*,r,*,s,*,t,*,u,*,v,*,w,*,x,*,y,*,z,*)
    if ($line($chan,$fline($2,%x,1,1),1) != $me) return $true
  }
}

;--- Don't edit anything past these lines or you could screw up the script
;--- unless of course, you know what you're doing

;--- Aliases
alias msndebug {
  if ($1 == on) {
    %msnx.debug = $true
    window @MSN.debug
  }
  else { unset %msnx.debug }
  echo -ta MSN Debug is now $iif(%msnx.debug,on,off)
}

alias msn {
  var %x $1, %y $2, %g $false, %s, %n
  if ($1 == -g) {
    %n = $dialog(msn.name,msn.name)
    if (%n == $null) %n = $remove($me,>)
    %x = $2
    %y = $3
    %g = $true
    %s = 207.68.167.253
  }
  elseif ($1 == -c) {
    %n = $dialog(msn.name,msn.name)
    if (%n == $null) %n = $remove($me,>)
    %x = $2
    %y = $3
    %g = $true
    %s = 207.68.167.251
  }
  else {
    %n = $dialog(msn.name,msn.name)
    if ((!%msnx.unicodenick) && (%n != $null)) %n = $msn.encode(%n)
    unset %msnx.unicodenick
    %s = 207.68.167.253
  }

  if (?#* !iswm %x) %x = $+($chr(37),$chr(35),%x)

  if ($hget(msn.999)) hfree msn.999
  unset %msn*.999
  unset %msnc.*
  sockclose *.999

  hmake msn.999 1
  msn.set 999 guest %g
  if (%n != $null) msn.set 999 nick %n
  msn.set 999 room $left(%x,90)
  msn.set 999 fullroom %x
  msn.set 999 shortroom $left(%x,60)
  msn.set 999 pass %y
  msn.set 999 fname %msnf.font
  msn.set 999 fcolor %msnf.fcolor
  msn.set 999 fstyle %msnf.fstyle
  msn.set 999 decode %msnx.decode
  msn.set 999 encode %msnx.encode

  if (%n == $null) %n = the default passport nickname
  echo $color(info2) -at *** Joining %x as $iif(%g,Guest_ $+ %n,%n) $+ , $iif($gettok(%x,2,32),using the key $gettok(%x,2,32) $+ $chr(44)) please wait...

  var %l 999

  unset %msn*. [ $+ [ %l ] ]

  sockopen msn.servcon. $+ %l %s 6667
  sockmark msn.servcon. $+ %l %x
  if (%y) %msn.pass. [ $+ [ $right(%x,-2) ] ] = %y
}

alias joinhex {
  if (($1 == -g) || ($1 == -c)) msn $1 $msn.unhex($2) $3
  else msn $msn.unhex($1) $2
}

alias joins {
  if ($1 == -k) msn $replace($3-,$chr(32),\b) $2
  elseif (($1 == -g) || ($1 == -c)) msn $1 $replace($2-,$chr(32),\b)
  elseif (($1 == -gk) || ($1 == -kg)) msn -c $replace($3-,$chr(32),\b) $2
  elseif (($1 == -ck) || ($1 == -kc)) msn -c $replace($3-,$chr(32),\b) $2
  else msn $replace($1-,$chr(32),\b)
}

alias joinurl {
  if (($1 == -g) || ($1 == -c)) {
    var %x = $replace($msn.urldecode($2-),$chr(32),\b)
    if (rhx= isin $gettok(%x,2-,63)) joinhex $1 $remove($wildtok($gettok(%x,2-,63),rhx=*,1,38),rhx=) $2
    elseif (rm= isin $gettok(%x,2-,63)) msn $1 $remove($wildtok($gettok(%x,2-,63),rm=*,1,38),rm=) $2
    else echo $color(info) -ta *** Couldn't find a room name in the URL
  }
  else {
    var %x = $replace($msn.urldecode($1-),$chr(32),\b)
    if (rhx= isin $gettok(%x,2-,63)) joinhex $remove($wildtok($gettok(%x,2-,63),rhx=*,1,38),rhx=) $2
    elseif (rm= isin $gettok(%x,2-,63)) msn $remove($wildtok($gettok(%x,2-,63),rm=*,1,38),rm=) $2
    else echo $color(info) -ta *** Couldn't find a room name in the URL
  }
}

;This identifier was obtained from the mircscripts.org Snippets section.
;Very big thank you to Techster, who submitted it.  Dude, you saved me alot
;of time! :)
;URL: http://www.mircscripts.org/comments.php?id=1225
alias msn.urldecode {
  var %decode = $replace($eval($1-,1), +, $eval(%20,0))
  while ($regex($eval(%decode,1), /\%([a-fA-F0-9]{2})/)) {
    var %t = $regsub($eval(%decode,1), /\%([a-fA-F0-9]{2})/, $chr($base($regml(1),16,10)), %decode)
  }
  return $replace(%decode, $eval(%20,0), +)
}

;Also thanks to whoever it was that originally posted this, I won't get
;too much use out of it, but it'll help anyway :)
; Usage: //echo -a $msn.registry(<Key>\\<Value>)
; Returns $false on error.
alias msn.registry {
  Var %k = $1, %d = $msn.readreg(%k)
  return %d
}
alias -l msn.readreg {
  var %n = $+(regread,.,$ticks), %r, %v
  .comopen %n WScript.Shell
  %v = $com(%n,RegRead,3,bstr,$1)
  if (($comerr) || (!%v)) { .comclose %n | %r = $false }
  else { %r = $com(%n).result }
  .comclose %n
  return %r
}

on *:LOAD: {
  echo $color(info2) -ta *** You have just loaded Vincula v3.4 - eXonyte's MSN Chat Connection script
  if ($version < 6) {
    echo $color(info2) *** Vincula will not work on any mIRC lower than version 6.0.  Unloading now...
    .timer 1 0 .unload " $+ $script $+ "
    halt
  }
  elseif ($version != 6.01) echo $color(info2) *** Vincula was only tested on mIRC v6.01.  It should work on your version ( $+ $version $+ ) but it is untested and not supported.

  echo $color(info2) -ta *** Go read the instructions to see how to use this thing!
  echo $color(info2) -ta *** Importing initial font settings from the MSN Chat Control...
  if (%msnf.font == $null) %msnf.font = $gettok($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontName),1,59)
  if (%msnf.fcolor == $null) %msnf.fcolor = $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontColor)
  if (%msnf.fstyle == $null) %msnf.fstyle = $calc($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontStyle) + 1)
  if (%msnx.decode == $null) %msnx.decode = $true
  if (%msnx.usepass == $null) %msnx.usepass = $true
  if (%msnx.showprof == $null) %msnx.showprof = $true
  if (%msnx.encode == $null) %msnx.encode = $false
  echo $color(info2) -ta *** Building encoder library
  msn.enchash
  msn.updatefonts
  echo $color(info2) -ta *** Your current Userdata1 key is:  $msn.ud1
  echo $color(info2) -ta *** Opening the script options dialog...
  msn.setup
  set -u5 %msn.nostart $true
}

on *:START: {
  if (!%msn.nostart) {
    if (%msnf.font == $null) %msnf.font = $gettok($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontName),1,59)
    if (%msnf.fcolor == $null) %msnf.fcolor = $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontColor)
    if (%msnf.fstyle == $null) %msnf.fstyle = $calc($msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\FontStyle) + 1)
    if (%msnx.decode == $null) %msnx.decode = $true
    if (%msnx.usepass == $null) %msnx.usepass = $true
    if (%msnx.showprof == $null) %msnx.showprof = $true
    if (%msnx.encode == $null) %msnx.encode = $false
    hmake msn.fonts 30
    hload msn.fonts " $+ $scriptdir $+ vfcache.dat"
    msn.enchash
    echo $color(info2) *** Vincula v3.4 loaded - Current Userdata1 key is:  $msn.ud1
  }
}

alias msn.ud1 return $msn.registry(HKEY_CURRENT_USER\Software\Microsoft\MSNChat\4.0\\UserData1)

;Decodes text
alias msn.decode {
  var %r, %l 1
  if (($msn.get($cid,decode)) && ($sock(msn.*. $+ $cid,1) != $null)) {
    %r = $replace($1-,,B,,-,,-,,-,,E,,C,,A,,R,,K,,y,ﺘ,i,ﺉ,s,דּ,t,טּ,u,ﻉ,e,,k,,F,,u,,g,,<,,>,,$chr(37),,8,,d,,m,,h,ﻛ,s,,G,,M,,l,,s,,_,,T,,r,,a,,n,,c,,e,,N,,a,,t,,i,,o,,n,,f,,w,,\,,|,,@,,P,,D,,',,�,,$chr(40),,$chr(41),,*,,:,,[,,],,p,,.)
    %r = $replace(%r,ņ,n,Ω,n,��,y,р,p,Р,P,ř,r,х,x,Į,I,Ļ,L,Ф,o,Ĉ,C,ŏ,o,ũ,u,ń,n,Ģ,G,ŕ,r,ś,s,ķ,k,Ŗ,R,ז,i,ε,e,ק,r,ћ,h,м,m,،,�,ī,i,‘,�,’,�,ū,u,ē,e,¢,�,,S,,Y,,O,,I,Ά,A,ъ,b,��,T,Φ,o,Ђ,b,я,r,Ё,E,д,A,К,K,Ď,D,и,n,θ,o,М,M,Ї,I,Т,T,Є,e,Ǻ,A,ö,�,ä,�,–,�,·,�,Ö,�,Ü,�,Ë,�,ѕ,s,ą,a,ĭ,i,й,n,в,b,о,o,ш,w,Ğ,G,đ,d,з,e,Ŧ,T,α,a,ğ,g,ú,�,Ŕ,R,Ą,A,ć,c,Đ,�,Κ,K,ў,y,µ,�,Í,�,‹,�,¦,�,Õ,�,Ù,�,À,�,Π,N,ғ,f,ΰ,u,Ŀ,L,ō,o,ς,c,ċ,c,ħ,h,į,i,ŧ,t,Ζ,Z,Þ,�,þ,�,ç,�,á,�,¾,�,ž,�,Ç,�,� $+ $chr(173),-,Á,�,…,�,¨,�,ý,�,ˉ,�,”,�,Û,�,ì,�,ρ,p,έ,e,г,r,à,�,È,�,¼,�,ĵ,j,ã,�,ę,e,ş,s,º,�,Ñ,�,ã,�,Æ,�,˚,�,Я,R,˜,�,Î,�,Ê,�,Ý,�,Ï,�,É,�,‡,�,Ì,�,ª,�,ó,�,™,�,Ò,�,í,�,¿,�,Ä,�,¶,�,ü,�,ƒ,�,ð,�,ò,�,õ,�,¡,�,é,�,ß,�,¤,�,×,�,ô,�,Š,�,ø,�,›,�,â,�,î,�,€,�,š,�,ï,�,ÿ,�,å,�,©,�,®,�,û,�,†,�,°,�,§,�,±,�,²,�,»,�,è,�)
    %r = $replace(%r,۰,�,Ĵ,J,І,I,Σ,E,ι,i,Ő,O,δ,d,ץ,y,ν,v,ע,y,מ,n,Ž,�,ő,o,Č,C,ė,e,₤,L,Ō,O,ά,a,Ġ,G,Ω,O,Н,H,ể,e,ẵ,a,Ж,K,ề,e,ế,e,ỗ,o,۱,',₣,F,∆,a,Ắ,A,ủ,u,Ķ,K,Ť,T,Ş,S,Θ,O,Ш,W,Β,B,П,N,ẅ,w,ﻨ,i,ﯼ,s,џ,u,ђ,h,¹,�,Ỳ,Y,λ,a,С,C,� $+ $chr(173),E,Ű,U,Ī,I,č,c,Ĕ,E,Ŝ,S,Ị,I,ĝ,g,ŀ,l,ї,i,٭,*,ŉ,n,Ħ,H,Д,A,Μ,M,ё,e,Ц,U,э,e,“,�,ф,o,у,y,с,c,к,k,Å,�,Ƥ,P,℞,R,,I,ɳ,n,ʗ,c,▫,�,ѓ,r,ệ,e,ắ,a,ẳ,a,ů,u,Ľ,L,ư,u,·,�,˙,',η,n,ℓ,l,,�,,�,,�,׀,i,ġ,g,Ň,N,Ŵ,W,Δ,A,ﮊ,J,μ,�,Ÿ,�,ĥ,h,β,�,Ь,b,ų,u,є,e,ω,w,Ċ,C,і,i,ł,l,ǿ,o,∫,s,ż,z,ţ,t,æ,�,≈,=,Ł,L,ŋ,n,گ,S,ď,d,ψ,y,σ,o,ģ,g,Ή,H,ΐ,i,ґ,r,κ,k,Ŋ,N,�,\,,/,¬,�,щ,w,ە,o,ם,d,³,�,½,�,İ,I,ľ,l,ĕ,e,Ţ,T,ŝ,s,ŷ,y,ľ,l,ĩ,i,Ô,�,Ś,S,Ĺ,L,а,a,е,e,Ρ,P,Ј,J,Ν,N,ǻ,a,ђ,h,ή,n,ί,l,Œ,�,¯,�,ā,a,ŵ,w,Â,�,Ã,�,н,H,ˇ,',¸,�,̣,$chr(44),ط,b,Ó,�,Й,N,«,�,ù,�,Ø,�,ê,�)
    %r = $replace(%r,л,n,ы,bl,б,6,ש,w,―,-,Ϊ,I,,`,ŭ,u,ổ,o,Ǿ,�,ẫ,a,ầ,a,,q,Ẃ,W,Ĥ,H,ỏ,o,−,-,,^,ล,a,Ĝ,G,ﺯ,j,ى,s,Ѓ,r,ứ,u,●,�,ύ,u,,0,,7,,",ө,O,ǐ,i,Ǒ,O,Ơ,O,,2,ү,y,,v,А,A,≤,<,≥,>,ẩ,a,,H,٤,e,ﺂ,i,Ќ,K,Ū,U,,;,ă,a,ĸ,k,Ć,C,Ĭ,I,ň,n,Ĩ,I,Ń,N,Ι,I,Ϋ,Y,,J,,X,,$chr(125),,$chr(123),Ξ,E,ˆ,^,,V,,L,γ,y,ﺎ,i,Ώ,o,ỳ,y,Ć,C,Ĭ,I,ĸ,k,Ŷ,y,๛,c,ỡ,o,๓,m,ﺄ,i,פֿ,G,Ŭ,U,Ē,E,Ă,A,÷,�, ,�,‚,�,„,�,ˆ,�,‰,�,ă,a,,x,,=,ق,J,,?,￼,-,◊,o,т,T,Ā,A,קּ,P,Ė,E,Ę,E,χ,X,ο,o,ϋ,u,‼,!!,ט,v,ﮒ,S,Ч,y,Ґ,r,ě,e,Ę,E,ĺ,I,Λ,a,ο,o,Ú,�,Ř,R,Ư,U,œ,�,,-,—,�,ห,n,ส,a,ฐ,s,Ψ,Y,Ẫ,A,π,n,Ņ,N,�!,o,Ћ,h,ợ,o,ĉ,c,◦,�,ﮎ,S,Ų,U,Е,E,Ѕ,S,۵,o,ي,S,ب,u,ة,o,ئ,s,ļ,l,ı,i,ŗ,r,ж,x,΅,",ώ,w,▪,�,ζ,C,Щ,W,฿,B,ỹ,y,ϊ,i,ť,t,п,n,´,�,ک,s,ﱢ,*,ξ,E,ќ,k,√,v,τ,t,Ð,�,£,�,ñ,�,¥,�,•,�,ë,�,ǎ,a)
    %r = $replace(%r,ị,i,Α,A, ,�,ﻩ,o,ﻍ,E,ن,u,ẽ,e,ث,u,ㅓ,t,ӛ,e,Ә,E,ﻘ,o,۷,v,שׁ,w,ụ,u,Ŏ,O,,�,ự,u,Ｊ,J,ｅ,e,ａ,a,Ｎ,N,（,$chr(40),＠,@,｀,`,．,.,′,',）,$chr(41),▬,-,◄,<,►,>,∑,E,ֻ,$chr(44),‬,|,‎,|,‪,|,‫,|,Ộ,O,И,N,,W,,z,╳,X,٠,�,Ғ,F,υ,u,‏,�,ּ,�,ǔ,u,ผ,w,Ằ,A,Ấ,A)
  }
  else %r = $1-
  return %r
}

alias msndecode {
  if ($1 == on) msn.set $cid decode $true
  else msn.unset $cid decode
  echo $color(info2) -ta *** MSN Decode is now $iif($msn.get($cid,decode),on,off)
}

alias msnencode {
  if ($1 == on) msn.set $cid encode $true
  else msn.unset $cid encode
  echo $color(info2) -ta *** MSN Encode is now $iif($msn.get($cid,encode),on,off)
}

alias msncolor {
  if ($1 == on) msn.set $cid docolor $true
  else msn.unset $cid docolor
  echo $color(info2) -ta *** MSN Colorizing is now $iif($msn.get($cid,docolor),on,off)
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
    %r = %r $+ $base($asc($mid($1-,%l,1)),10,16)
    inc %l
  }
  return %r
}

alias msn.unhex {
  var %l 1, %r
  while (%l <= $len($1-)) {
    %r = %r $+ $chr($base($mid($1-,%l,2),16,10))
    inc %l 2
  }
  return %r
}

alias msn.roompass {
  if ($1) return %msn.pass. [ $+ [ $right($1,-2) ] ]
  else return %msn.pass. [ $+ [ $right($chan,-2) ] ]
}

; $msn.get($sockname,room) or $msn.get($cid,room)
alias msn.get {
  if (msn.*.* iswm $1) return $hget(msn. $+ $gettok($$1,3,46),$$2)
  else return $hget(msn. $+ $$1,$$2)
}

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
  if (msn.*.* iswm $1) hfree msn. $+ $gettok($$1,3,46)
  else hfree msn. $+ $$1
}

; "/msn.ren oldcid newcid" or whatever
alias msn.ren {
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
}

alias msn.geturl {
  var %x http://chat.msn.com/chatroom.msnw?rhx= $+ $msn.tohex($1)
  echo $color(info2) -t *** Room URL: %x
  clipboard %x
}

alias msn.getpass {
  echo $color(info2) -t *** Last stored Ownerkey is: $msn.roompass($1)
  clipboard $msn.roompass($1)
}

; $1 == Channelname
; $2 == Nickname ($me)
; $3 == Local port
alias msn.writehtml {
  var %x = write $+(",$scriptdir,msnchat.html,")

  if (((%msnpass.cookie == $null) || (%msnpass.ticket == $null) || (%msnpass.profile == $null)) && (!$msn.get(999,guest))) { msn.getpp }

  write -c $+(",$scriptdir,msnchat.html,") <HTML><BODY STYLE="margin:0">
  %x <OBJECT ID="ChatFrame" CLASSID="CLSID:7a32634b-029c-4836-a023-528983982a49" width="100%">
  %x <PARAM NAME="HexRoomName" VALUE=" $+ $msn.tohex($1) $+ ">
  if ($msn.get(999,nick) == $null) %x <PARAM NAME="NickName" VALUE="null">
  else %x <PARAM NAME="NickName" VALUE=" $+ $msn.get(999,nick) $+ ">
  %x <PARAM NAME="Server" VALUE="127.0.0.1: $+ $3 $+ ">
  %x <PARAM NAME="BaseURL" VALUE="http://chat.msn.com/">
  %x <PARAM NAME="MessageOfTheDay" VALUE="">
  if (!$msn.get(999,guest)) {
    %x <PARAM NAME="MSNREGCookie"  VALUE=" $+ %msnpass.cookie $+ ">
    %x <PARAM NAME="PassportTicket" VALUE=" $+ %msnpass.ticket $+ ">
    %x <PARAM NAME="PassportProfile" VALUE=" $+ %msnpass.profile $+ ">
  }
  if ((!$msn.get(999,guest)) && (%msnx.showprof)) %x <PARAM NAME="MSNPROFILE" VALUE="1">
  else %x <PARAM NAME="MSNPROFILE" VALUE="0">
  %x </OBJECT></BODY></HTML>
}

alias msn.getpp {
  var %f = " $+ $$sfile($scriptdir $+ *.*,Choose a saved MSN Chatroom webpage) $+ "
  unset %msnpass.*

  %msnpass.cookie = $gettok($read(%f,w,*MSNREGCookie*),4,34)
  %msnpass.ticket = $gettok($read(%f,w,*PassportTicket*),4,34)
  %msnpass.profile = $gettok($read(%f,w,*PassportProfile*),4,34)

  if ((%msnpass.cookie != $null) && (%msnpass.ticket != $null) && (%msnpass.profile != $null)) { goto found }
  echo $color(info2) -at *** Passport information was not found or was incomplete in the file $nopath(%f) $+ !
  unset %msnpass.*
  return

  :found
  echo $color(info2) -at *** Passport information was found in the file $nopath(%f)
}

alias msn.enchash {
  var %in � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � - � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �
  var %out € ‚ ƒ „ … † ‡ ˆ ‰ Š ‹ Œ Ž ‘ ’ “ ” • – — ˜ ™ š › œ ž Ÿ   ¡ ¢ £ ¤ ¥ ¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿ À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ
  var %l 1
  hmake msn.enc 13
  while (%l <= 123) {
    hadd msn.enc $gettok(%in,%l,32) $gettok(%out,%l,32)
    inc %l
  }
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

;Converts default mIRC color numbers to MSN color codes
alias msn.mrctomsn {
  if ($msn.get($cid,frand)) tokenize 32 $rand(0,7)

  if ($1 == 0) return $chr(1)
  elseif ($1 == 1)  return $chr(2)
  elseif ($1 == 2) return $chr(5)
  elseif ($1 == 3) return $chr(4)
  elseif ($1 == 4) return $chr(11)
  elseif ($1 == 5) return $chr(3)
  elseif ($1 == 6) return $chr(7)
  elseif ($1 == 7) return $chr(6)
  elseif ($1 == 8) return $chr(14)
  elseif ($1 == 9) return $chr(12)
  elseif ($1 == 10) return $chr(8)
  elseif ($1 == 11) return $chr(16)
  elseif ($1 == 12) return \r
  elseif ($1 == 13) return $chr(15)
  elseif ($1 == 14) return $chr(9)
  elseif ($1 == 15) return $chr(9)
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
  else return 1
}

alias pass {
  if ($1 != $null) mode $me +h $1-
  else mode $me +h $$input(Enter a password:,130,Password Entry)
}

alias msn.ndll return $dll($scriptdir $+ nHTMLn_2.9.dll,$$1,$$2)

alias msn.nhtmln {
  var %m
  window -ph @MSN.Client
  %m = $msn.ndll(attach,$window(@MSN.Client).hwnd)
  if (%m != S_OK) echo Error attaching to window: %m
  %m = $msn.ndll(navigate, $scriptdir $+ msnchat.html)
  if (%m != S_OK) echo Error navigating to msnchat.html: %m
}

alias msn.nhtmlnc {
  var %m = $msn.ndll(detach,$window(@MSN.Client).hwnd)
  if (%m != S_OK) echo Error detaching from window: %m
  window -c @MSN.Client
}

;--- Socket events

on *:SOCKOPEN:msn.servcon.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Directory server sockopen error: $sock($sockname).wsmsg
    return
  }
  if (%msnx.debug) echo -t @MSN.debug $sockname connection accepted...
  var %x msn.clicon. $+ $gettok($sockname,3,46)
  socklisten msn.clicon. $+ $gettok($sockname,3,46)
  msn.writehtml $sock($sockname).mark $iif(%msnc.nick != $null,%msnc.nick,null) $sock(%x).port
  msn.nhtmln
}

on *:SOCKREAD:msn.servcon.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Directory server read error: $sock($sockname).wsmsg
    return
  }

  var %x msn.client1. $+ $gettok($sockname,3,46)
  sockread -n &read

  while ($sockbr > 0) {
    tokenize 32 $bvar(&read,1,$bvar(&read,0)).text
    if (%msnx.debug) echo -ti2 @MSN.debug $sockname $1-

    if ($2 == 613) {
      echo $colour(info2) -at *** Chatroom $sock($sockname).mark found, joining...
      socklisten msn.mirccon. $+ $gettok($sockname,3,46)
      socklisten msn.clicon2. $+ $gettok($sockname,3,46)
      %msnc.newserver = $1 $2 $3 :127.0.0.1 $sock(msn.clicon2. $+ $gettok($sockname,3,46)).port
      %msnc.serveraddy = $right($4-,-1)
      if ($server == $null) {
        server 127.0.0.1 $sock(msn.mirccon. $+ $gettok($sockname,3,46)).port
      }
      else {
        server -m 127.0.0.1 $sock(msn.mirccon. $+ $gettok($sockname,3,46)).port
      }
    }

    ;Fake Nick Stuff
    elseif ((!$msn.get($sockname,guest)) && ($1- == NICK nick) && ($msn.get($sockname,nick) != $null)) sockwrite -tn $sockname NICK $msn.get($sockname,nick) $+ $lf

    ;  :TK2CHATWBB02 702 >eXonyte :Channel not found
    elseif ($2 == 702) {
      if (%msn.pass. [ $+ [ $right($sock($sockname).mark,-2) ] ] == $null) %msn.pass. [ $+ [ $right($sock($sockname).mark,-2) ] ] = $msn.pass(10)
      %msnc.made = $sock($sockname).mark
      .timer.noto. $+ $gettok($sockname,3,46) 0 5 sockwrite -tn $sockname NOTIMEOUT
      dialog -m msn.room. $+ $sockname msn.room
    }

    ;-------Errors
    elseif ($2 == 421) {
      ;Do nothing at all
    }

    elseif ($2 == 472) {
      sockclose $sockname
      sockclose %x
      msn.nhtmlnc
      echo $colour(info2) -at *** Unknown mode character, cannot create %msnc.join
      return
    }

    elseif ($2 == 701) {
      sockclose $sockname
      sockclose %x
      msn.nhtmlnc
      echo $colour(info2) -at *** Invalid channel category, cannot create %msnc.join
      return
    }

    elseif ($2 == 706) {
      sockclose $sockname
      sockclose %x
      msn.nhtmlnc
      echo $colour(info2) -at *** Invalid channel name, can't create channel %msnc.join
      return
    }

    elseif ((7?? iswm $2) || (9?? iswm $2)) {
      sockclose $sockname
      sockclose %x
      msn.nhtmlnc
      echo $colour(info2) -at *** Error $2 $+ : $right($4-,-1)
      return
    }

    else {
      sockwrite -n %x &read
      sockwrite -tn %x
    }
    sockread -n &read
  }
}

on *:SOCKCLOSE:msn.servcon.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Directory server close error: $sock($sockname).wsmsg
    sockclose msn.clicon.999
    return
  }

  if (%msnx.debug) echo -ti2 @MSN.debug $sockname was closed
}

on *:SOCKLISTEN:msn.clicon.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Client sockopen error: $sock($sockname).wsmsg
    return
  }

  sockaccept msn.client1. $+ $gettok($sockname,3,46)

  if (%msnx.debug) echo -ti2 @MSN.debug msn.client1. $+ $gettok($sockname,3,46) Accepted
}

on *:SOCKREAD:msn.client1.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Client read error: $sock($sockname).wsmsg
    return
  }

  var %x msn.servcon. $+ $gettok($sockname,3,46)

  sockread -n &read

  while ($sockbr > 0) {
    if (%msnx.debug) echo -ti2 @MSN.debug $sockname $bvar(&read,1,$bvar(&read,0)).text

    if ($sock(%x)) {
      sockwrite -n %x &read
      sockwrite -tn %x
    }
    sockread -n &read
  }
}

on *:SOCKLISTEN:msn.mirccon.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** mIRC accept error:  $sock($sockname).wsmsg
    return
  }

  sockaccept msn.mirc. $+ $gettok($sockname,3,46)
}

on *:SOCKREAD:msn.mirc.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** mIRC read error:  $sock($sockname).wsmsg
    return
  }

  var %read
  sockread %read

  while ($sockbr > 0) {
    if ($msn.get($sockname,room) isin %read) %read = $replace(%read,$msn.get($sockname,room),$msn.get($sockname,fullroom))
    elseif ($msn.get($sockname,shortroom) isin %read) %read = $replace(%read,$msn.get($sockname,shortroom),$msn.get($sockname,fullroom))

    tokenize 32 %read

    if (%msnx.debug) echo -ti2 @MSN.debug $sockname $1-

    if ($1 == NICK) {
      if ($msn.get($sockname,xuser)) {
        sockopen msn.server. $+ $gettok($sockname,3,46) %msnc.serveraddy
        msn.unset $sockname xnick
        msn.unset $sockname xuser
      }
      else msn.set $sockname xnick $true

      if ($msn.get($sockname,domirc)) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1-
    }
    elseif ($1 == USER) {
      if ($msn.get($sockname,xnick)) {
        sockopen msn.server. $+ $gettok($sockname,3,46) %msnc.serveraddy
        msn.unset $sockname xnick
        msn.unset $sockname xuser
      }
      else msn.set $sockname xuser $true
    }

    elseif ($1 == PRIVMSG) {
      if (:* !iswm $3) {
        if (?#* iswm $2) {
          if ($msn.get($sockname,encode)) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1 $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $msn.encode($right($3-,-1)) $+ 
          else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1 $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
        else {
          if ($msn.get($sockname,encode)) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) WHISPER $sock($sockname).mark $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $msn.encode($right($3-,-1)) $+ 
          else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) WHISPER $sock($sockname).mark $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
      }
      else {
        if (:ACTION == $3) {
          if ($msn.get($sockname,encode)) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1 $2 $3 $msn.encode($left($4-,-1)) $+ 
          else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1 $2 $3 $left($4-,-1) $+ 
        }
        else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1-
      }
    }
    elseif ($1 == NOTICE) {
      if (:* !iswm $3) {
        if (?#* !iswm $2) {
          if ($msn.get($sockname,encode)) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) PRIVMSG $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $msn.encode($right($3-,-1)) $+ 
          else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) PRIVMSG $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
        else {
          if ($msn.get($sockname,encode)) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) NOTICE $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $msn.encode($right($3-,-1)) $+ 
          else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) NOTICE $2 :S $msn.mrctomsn($msn.get($sockname,fcolor)) $+ $chr($msn.get($sockname,fstyle)) $+ $msn.get($sockname,fname) $+ ;0 $right($3-,-1) $+ 
        }
      }
      else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1-
    }

    elseif ($1 == JOIN) {
      if (($2 == $msn.get($sockname,room)) || ($2 == $msn.get($sockname,shortroom)) || ($2 == $msn.get($sockname,fullroom))) {
        if ($3 == $null) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1- $iif(%msnx.usepass,$msn.roompass($2))
        else sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1- $3
      }
      else {
        if (>* iswm $scid($gettok($sockname,3,46)).me) msn -g $2-
        else msn $2-
      }
    }

    else if ($msn.get($sockname,domirc)) sockwrite -tn msn.server. $+ $gettok($sockname,3,46) $1-
    sockread %read
  }
}

on *:SOCKCLOSE:msn.mirc.*: {
  msn.clear $sockname
  sockclose msn.*. $+ $gettok($sockname,3,46)
  msn.nhtmlnc $gettok($sockname,3,46)
}

on *:SOCKOPEN:msn.server.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Server sockopen error:  $sock($sockname).wsmsg
    return
  }
  sockwrite -tn msn.client1. $+ $gettok($sockname,3,46) %msnc.newserver
}

on *:SOCKREAD:msn.server.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Server read error:  $sock($sockname).wsmsg
    return
  }

  sockread -n &read

  while ($sockbr > 0) {
    tokenize 32 $bvar(&read,1,$bvar(&read,0)).text

    if ($msn.get($sockname,fullroom) isin $1-) tokenize 32 $replace($1-,$msn.get($sockname,fullroom),$msn.get($sockname,room))

    if (%msnx.debug) echo -ti2 @MSN.debug $sockname $1-

    if ($msn.get($sockname,domirc)) {

      if ($2 == PRIVMSG) {

        if ($4 == :S) {
          if (?#* !iswm $3) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 NOTICE $3 : $+ $remove($6-,$chr(1))
          else {
            var %color $left($5,1), %bold $mid($5,2,1)
            if (%color == \) {
              %color = \r
              %bold = $mid($5,3,1)
            }
            %color = $base($msn.msntomrc(%color),10,10,2)

            if (($msn.get($sockname,docolor)) && ((%bold == $chr(2)) || (%bold == $chr(4)))) %bold = 
            elseif (($msn.get($sockname,docolor)) && ((%bold == $chr(6)) || (%bold == $chr(8)))) %bold = 
            elseif (($msn.get($sockname,docolor)) && ((%bold == $chr(5)) || (%bold == $chr(7)))) %bold = 
            else unset %bold

            if (%color == $color(background)) %color = %color(normal)
            sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 $2 $3 : $+ $iif($msn.get($sockname,docolor), $+ %color) $+ %bold $+ $left($6-,-1)
          }
        }

        elseif (:* iswm $4) {
          if (:VERSION* iswm $4) {
            sockwrite -tn msn.server. $+ $gettok($sockname,3,46) NOTICE $right($gettok($1,1,33),-1) :VERSION Vincula v3.4, by eXonyte (mIRC $version on Win $+ $os $+ )
            scid $gettok($sockname,3,46) echo $color(ctcp) -t $msn.get($cid,room) [[ $+ $right($gettok($1,1,33),-1) VERSION]
          }
          else sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
        }

        else {
          if (?#* !iswm $3) {
            if ($4 == :S) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 NOTICE $3 : $+ $left($6-,-1)
            else sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 NOTICE $3 $4-
          }
          else sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
        }
      }

      ; :TK2CHATCHATA08 353 eXonyte = %#Christian :H,U,P,+†°§ŵ££†_Ģû®L°† H,U,P,+bchelmo H,U,P,@Loner7 H,U,P,+angel_of_victory G,U,R,@FaithKeep
      ; :TK2CHATCHATA08 353 eXonyte = %#Christian :G,U,G,+>logos3 H,U,P,+¤Shadow… G,U,P,+attitudepc H,U,R,@XBible G,U,P,+eXonyte H,U,P,.iSpy·

      ;Away ? ?
      ; G  ,U,P,+eXonyte
      ; H  ,U,P,.iSpy·
      ; H  ,U,R,@XBible

      elseif ($2 == 353) {
        var %nam = $right($6-,-1), %res, %nlp 1

        if (!$hget(msn.setaways)) hmake msn.setaways 2
        while (%nlp <= $numtok(%nam,32)) {
          %res = %res $gettok($gettok(%nam,%nlp,32),4,44)
          if ($gettok($gettok(%nam,%nlp,32),1,44) == G) {
            inc %msn.tmp.aa
            hadd msn.setaways %msn.tmp.aa $remove($gettok($gettok(%nam,%nlp,32),4,44),+,@,.)
          }
          else {
            inc %msn.tmp.aa
            hadd msn.setaways %msn.tmp.aa -r $remove($gettok($gettok(%nam,%nlp,32),4,44),+,@,.)
          }
          inc %nlp
        }
        sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-5 : $+ %res
      }
      elseif ($2 == 366) {
        unset %msn.tmp.aa
        .timer 1 1 msn.setaways $sockname
        sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
        if (%msnx.setmymode) {
          sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) %msnx.setmymode
          unset %msnx.setmymode
        }
      }

      ;  :>eXo!blah@GateKeeper JOIN H,U,G,+ :%#Christian
      elseif ($2 == JOIN) {
        if (:%#* iswm $4) {
          sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 $2 $4-
          var %tmp.room $right($4,-1)
        }
        else {
          sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
          var %tmp.room $right($3,-1)
        }
        if ($right($gettok($1,1,33),-1) == $scid($gettok($sockname,3,46)).me) {
          if ($gettok($3,4,44) == +) %msnx.setmymode = $1 MODE $right($4,-1) +v $right($gettok($1,1,33),-1)
          elseif ($gettok($3,4,44) == @) %msnx.setmymode = $1 MODE $right($4,-1) +o $right($gettok($1,1,33),-1)
          elseif ($gettok($3,4,44) == .) %msnx.setmymode = $1 MODE $right($4,-1) +q $right($gettok($1,1,33),-1)
        }

        ;  :eXonyte!4A63C43D06D38CB7@GateKeeperPassport JOIN H,U,P,. :%#Z-eXonyte
        else {
          if ($gettok($3,4,44) == +) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 MODE $right($4,-1) +v $right($gettok($1,1,33),-1)
          elseif ($gettok($3,4,44) == @) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 MODE $right($4,-1) +o $right($gettok($1,1,33),-1)
          elseif ($gettok($3,4,44) == .) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 MODE $right($4,-1) +q $right($gettok($1,1,33),-1)
        }
      }

      elseif ($2 == KICK) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-

      elseif ($2 == PART) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-

      elseif ($2 == WHISPER) {
        if ($5 == :S) {
          var %color $left($6,1), %bold $mid($6,2,1)
          if (%color == \) {
            %color = \r
            %bold = $mid($6,3,1)
          }
          %color = $base($msn.msntomrc(%color),10,10,2)

          if (%bold != ) unset %bold
          if (%color == $color(background)) %color = %color(normal)

          sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 PRIVMSG $me : $+ $iif($msn.get($sockname,docolor), $+ %color) $+ $left($7-,-1)
        }
        else sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 PRIVMSG $me $5-
      }

      elseif ($2 == 305) {
        scid $gettok($sockname,3,46)
        echo $color(info2) -t $sock($sockname).mark *** You are no longer away
        cline -lr $sock($sockname).mark $fline($sock($sockname).mark,$me,1,1)
        scid -r
      }

      elseif ($2 == 306) {
        scid $gettok($sockname,3,46)
        echo $color(info2) -t $sock($sockname).mark *** You are now away
        cline -l $color(grayed) $sock($sockname).mark $fline($sock($sockname).mark,$me,1,1)
        scid -r
      }

      elseif ($2 == 473) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-

      elseif ($2 == 821) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 $2 $sock($sockname).mark $3-

      elseif ($2 == 822) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 $2 $sock($sockname).mark $3-

      elseif ($2 == 923) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 404 $3 $4 :Whispers not permitted

      elseif ($2 == 932) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 404 $3 $4 :Profanity not permitted ( $+ $lower($5) $+ )

      elseif ($2 == 935) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) :chat.msn.com KICK $4 $me $5-

      elseif ($2 == 266) {
        sockclose msn.cli*
        sockmark $sockname $sock(msn.servcon. $+ $gettok($sockname,3,46)).mark
        sockmark msn.mirc. $+ $gettok($sockname,3,46) $sock(msn.servcon. $+ $gettok($sockname,3,46)).mark
        sockclose msn.*con.*
        if (%msnx.usepass) sockwrite -tn $sockname JOIN $sock($sockname).mark $msn.roompass($sock($sockname).mark)
        else sockwrite -tn $sockname JOIN $sock($sockname).mark
        sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
        msn.nhtmlnc
      }

      elseif ($2 == 004) {
        sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
        sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 005 $3 IRCX CHANTYPES=% PREFIX=(qov).@+ CHANMODES=b,k,l,imnpstuwW NETWORK=MSN :are supported by this server
      }

      elseif ($2 == 818) {
        if ($5 == MSNPROFILE) {
          if ($msn.get($sockname,doprof)) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
          else msn.set $sockname doprof $true
        }
        else sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
      }

      elseif ($2 == INVITE) sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1 $+ !unknown $2 $3 : $+ $5

      else sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
    }
    if ($2 == 001) {
      sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) : $+ $me $+ !0000@GateKeeperPassport NICK $3
      msn.set $sockname domirc $true
      sockclose msn.cli*
      msn.nhtmlnc $gettok($sockname,3,46)
      %msnc.cid = $gettok($sockname,3,46)
      sockwrite -tn msn.mirc. $+ $gettok($sockname,3,46) $1-
    }

    elseif ($2 == 910) {
      echo $color(kick) -at *** Couldn't join $msn.get($sockname,room) (Gatekeeper Authentication Failed)
      msn.clear $sockname
      sockclose msn*. $+ $gettok($sockname,3,46)
      msn.nhtmlnc
      return
    }

    elseif ($2 == 432) {
      echo $color(kick) -at *** Couldn't join $msn.get($sockname,room) ( $+ $3 $+ : $right($4-,-1) $+ )
      msn.clear $sockname
      sockclose msn*. $+ $gettok($sockname,3,46)
      msn.nhtmlnc
      return
    }

    elseif ($2 == 465) {
      echo $color(kick) -at *** Couldn't join $msn.get($sockname,room) ( $+ $3 $+ : $right($4-,-1) $+ )
      msn.clear $sockname
      sockclose msn*. $+ $gettok($sockname,3,46)
      msn.nhtmlnc
      return
    }

    elseif ((!$msn.get($sockname,guest)) && ($1 == AUTH) && ($3 == *) && ($msn.get($sockname,nick) != $null)) sockwrite -tn $sockname NICK $msn.get($sockname,nick)

    var %x msn.client2. $+ $gettok($sockname,3,46)

    if (($sock(%x)) && (!$msn.get($sockname,domirc))) {
      sockwrite -n %x &read
      sockwrite -tn %x
    }

    sockread -n &read
  }
}

on *:SOCKCLOSE:msn.server.*: {
  msn.clear $sockname
  sockclose msn.*. $+ $gettok($sockname,3,46)
  msn.nhtmlnc $gettok($sockname,3,46)
}

on *:SOCKLISTEN:msn.clicon2.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Client2 accept error:  $sock($sockname).wsmsg
    return
  }

  sockaccept msn.client2. $+ $gettok($sockname,3,46)
}

on *:SOCKREAD:msn.client2.*: {
  if ($sockerr > 0) {
    echo $color(info) -at *** Client2 accept error:  $sock($sockname).wsmsg
    return
  }

  sockread -n &read

  tokenize 32 $bvar(&read,1,$bvar(&read,0)).text

  if (%msnx.debug) echo -ti2 @MSN.debug $sockname $1-

  var %x msn.server. $+ $gettok($sockname,3,46)

  if ($sock(%x)) {
    sockwrite -n %x &read
    sockwrite -tn %x
  }
}

alias msn.setaways {
  scid $gettok($1,3,46)
  var %aa 1, %fline
  while ($hget(msn.setaways,%aa) != $null) {
    if (-r * iswm $hget(msn.setaways,%aa)) {
      %fline = $fline($sock($1).mark,$right($hget(msn.setaways,%aa),-3),1,1)
      if (%fline != $null) cline -lr $sock($1).mark %fline
    }
    else {
      %fline = $fline($sock($1).mark,$hget(msn.setaways,%aa),1,1)
      if (%fline != $null) cline -l $color(grayed) $sock($1).mark %fline
    }
    inc %aa
  }
  hfree msn.setaways
  scid -r
}

raw 001:*: {
  if ($cid != %msnc.cid) msn.ren 999 $cid
  .timer.noop. $+ $cid 0 60 .raw NOOP
  unset %msnc.cid
}

raw 421:*NOOP*: haltdef

ctcp *:TIME:*: {
  if ($sock(msn.*. $+ $cid,0) >= 2) {
    echo $color(ctcp) -t $msn.get($cid,room) [[ $+ $nick TIME]
    ctcpreply $nick TIME $asctime(m/dd/yyyy $+ $chr(44) h:nn:ss TT)
    haltdef
  }
}

on *:CTCPREPLY:�DT�E: {
  if (($sock(msn.*. $+ $cid,0) >= 2) && ($2- == $null)) {
    echo $color(ctcp) -t $msn.get($cid,room) [[ $+ $nick �DT�E]
    ctcpreply $nick �DT�E Vincula v3.4, by eXonyte (mIRC $version on Win $+ $os $+ )
    haltdef
  }
}

;--- Stuff for the O/H/P/S menus
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


menu nicklist {
  $iif($sock(msn.*. $+ $cid,0) != 2,$style(2)) $+ Vincula
  . $+ $msn.decode($$1)
  .. $+ $1 $+ :echo $color(info2) -at *** Decoded: $msn.decode($$1) / Undecoded: $$1 | clipboard $msn.decode($$1)
  .. $+ $address($1,6) $+ :echo $color(info2) -at *** Address:  $address($$1,6)
  .Check IRCDom Version:ctcpreply $$1 �DT�E
  . $+ $iif(>* iswm $1,$style(2)) View Profile: PROP $$1 MSNPROFILE
  . $+ $iif(>* iswm $1,$style(2)) Force View Profile: PROP $$1 PUID
  .-
  .$msn.pop.o($1,$chan) $+ Owner:mode $chan +q $$1
  .$msn.pop.h($1,$chan) $+ Host:mode $chan +o $$1
  .$msn.pop.p($1,$chan) $+ Participant:mode $chan -o+v $$1 $$1
  .$msn.pop.s($1,$chan) $+ Spectator:mode $chan -ov $$1 $$1
  .-
  .Kick and Ban
  ..15 Minutes: access $chan add deny $address($$1,1) 15 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 15 Minute Ban $+ $iif($! != $null,: $!)
  ..1 Hour: access $chan add deny $address($$1,1) 60 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 1 Hour Ban $+ $iif($! != $null,: $!)
  ..24 Hours: access $chan add deny $address($$1,1) 1440 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 24 Hour Ban $+ $iif($! != $null,: $!)
  ..Infinite: access $chan add deny $address($$1,1) 0 : $+ $$1 - $input(Enter a kick message $+ $chr(44) or leave blank for none:,129,Kick Message) | kick $chan $1 Infinite Ban $+ $iif($! != $null,: $!)
  ..-
  ..How long?: access $chan add deny $address($$1,1) $$input(How long in minutes would you like to ban for?,129,Ban length) | kick $chan $1 $! Minute Ban
}

menu channel {
  $iif($sock(msn.*. $+ $cid,0) != 2,$style(2)) $+ Vincula
  .Get the room's URL:msn.geturl $chan
  .$iif($msn.roompass($chan) == $null,$style(2) $+ Current Ownerkey is unknown,Stored Ownerkey $+ $chr(58) $msn.roompass($chan)) :msn.getpass $chan
  .-
  .Change Welcome Message:prop $chan onjoin : $+ $$input(Enter the welcome message:,129,Change Welcome Message)
  .Unset Welcome Message:prop $chan onjoin :
  .-
  .Change Gold Key:prop $chan ownerkey $$input(Enter the new gold $chr(40) $+ owner $+ $chr(41) key:,129,Change Gold Key)
  .Unset Gold Key:prop $chan ownerkey :
  .-
  .Change Brown Key:prop $chan hostkey $$input(Enter the new brown $chr(40) $+ host $+ $chr(41) key:,129,Change Brown Key)
  .Unset Brown Key:prop $chan hostkey :
  .-
  .$iif(u isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Knock Mode: mode $chan $iif(u isin $gettok($chan($chan).mode,1,32),-,+) $+ u
  .$iif(m isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Spectator (Moderated) Mode: mode $chan $iif(m isin $gettok($chan($chan).mode,1,32),-,+) $+ m
  .$iif(w !isincs $gettok($chan($chan).mode,1,32),$style(1)) $+ Whispers Enabled: mode $chan $iif(w isincs $gettok($chan($chan).mode,1,32),-,+) $+ w
  .$iif(W !isin $gettok($chan($chan).mode,1,32),$style(1)) $+ Guest Whispers Enabled: mode $chan $iif(W isincs $gettok($chan($chan).mode,1,32),-,+) $+ W
  .$iif(f isin $gettok($chan($chan).mode,1,32),$style(3),$style(2)) $+ MSN Profanity Filter Enabled: return
  .$iif(x isin $gettok($chan($chan).mode,1,32),$style(3),$style(2)) $+ Auditorium Mode Enabled: return
  .-
  .Change other room settings...:channel $chan
}

menu menubar,status {
  Vincula
  .Update Passport information...:msn.getpp
  .Change Vincula settings...:msn.setup
  .Current Userdata1 key $+ $chr(58) $msn.ud1 : echo $color(info2) -at *** Current Userdata1 key: $msn.ud1 | clipboard $msn.ud1
  .-
  .Join Room
  ..Normal...:joins $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)

  .Join Room (password)
  ..Normal...:joins $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname) $input(Enter a password for the room,130,Enter password)
  ..Hex name...:joinhex $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname) $input(Enter a password for the room,130,Enter password)
  ..URL...:joinurl $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname) $input(Enter a password for the room,130,Enter password)

  .Join Room (Guest)
  ..Normal...:joins -g $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -g $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex -g $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl -g $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)

  .Join Room (Guest, password)
  ..Normal...:joins -gk $$input(Enter a password for the room,130,Enter password) $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -g $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname) $input(Enter a password for the room,130,Enter password)
  ..Hex name...:joinhex -g $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname) $input(Enter a password for the room,130,Enter password)
  ..URL...:joinurl -g $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname) $input(Enter a password for the room,130,Enter password)

  .Join Room (Community)
  ..Normal...:joins -c $$input(Enter a room name $chr(40) $+ Only normal ASCII characters allowed $+ $chr(41),129,Enter Roomname)
  ..IRC name...:msn -c $$input(Enter a room name in IRC format $chr(40) $+ $chr(37) $+ #room\bname $+ $chr(41),129,Enter Roomname)
  ..Hex name...:joinhex -c $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
  ..URL...:joinurl -c $$input(Enter a room's hex name $chr(40) $+ rhx $+ $chr(41),129,Enter Hex Roomname)
}

;--- Font changing dialog

alias msn.setup dialog -m msn.setup. $+ $cid msn.setup

dialog msn.setup {
  title "Vincula - Setup"
  icon $mircexe , 5
  size -1 -1 150 102
  option dbu

  box "", 90, 2 0 146 51
  text "Font name:", 10, 3 8 29 7, right
  combo 20, 33 6 112 70, edit drop

  text "Font style:", 11, 3 20 29 7, right
  check "Bold", 71, 33 20 20 7
  check "Italic", 72, 33 30 22 7
  check "Underline", 73, 33 40 40 7

  text "Font color:", 12, 73 20 29 7, right
  combo 21, 103 19 42 130, drop
  check "Random", 31, 103 31 30 11

  box "", 91, 2 47 73 38
  check "Show profile icon", 32, 5 51 60 11
  check "Decode incoming text", 33, 5 61 60 11
  check "Show users' colors", 34, 5 71 60 11

  box "", 92, 74 47 74 38
  check "Auto password usage", 35, 77 51 65 11
  check "Encode outgoing text", 36, 77 61 65 11

  button "OK", 100, 65 88 40 12, ok default
  button "Cancel", 101, 108 88 40 12, cancel
}

on *:DIALOG:msn.setup*:init:*: {
  var %l 1
  while ($hget(msn.fonts,%l) != $null) {
    did -a $dname 20 $hget(msn.fonts,%l)
    inc %l
  }

  did -a $dname 21 Black
  did -a $dname 21 White
  did -a $dname 21 Dark Blue
  did -a $dname 21 Dark Green
  did -a $dname 21 Red
  did -a $dname 21 Dark Red
  did -a $dname 21 Purple
  did -a $dname 21 Dark Yellow
  did -a $dname 21 Yellow
  did -a $dname 21 Green
  did -a $dname 21 Teal
  did -a $dname 21 Cyan
  did -a $dname 21 Blue
  did -a $dname 21 Pink
  did -a $dname 21 Dark Gray
  did -a $dname 21 Gray

  if ($sock(*. $+ $gettok($dname,3,46),0) >= 1) {
    did -i $dname 20 0 $replace($msn.get($dname,fname),\b,$chr(32))
    did -c $dname 21 $calc($msn.get($dname,fcolor) + 1)
    var %f $calc($msn.get($dname,fstyle) - 1)
    if ($isbit(%f,1)) did -c $dname 71
    if ($isbit(%f,2)) did -c $dname 72
    if ($isbit(%f,3)) did -c $dname 73
    if ($msn.get($dname,frand)) did -c $dname 31
    if (%msnx.showprof) did -c $dname 32
    if ($msn.get($dname,decode)) did -c $dname 33
    if ($msn.get($dname,docolor)) did -c $dname 34
    if (%msnx.usepass) did -c $dname 35
    if ($msn.get($dname,encode)) did -c $dname 36
  }

  else {
    did -i $dname 20 0 $replace(%msnf.font,\b,$chr(32))
    did -c $dname 21 $calc(%msnf.fcolor + 1)
    var %f $calc(%msnf.fstyle - 1)
    if ($isbit(%f,1)) did -c $dname 71
    if ($isbit(%f,2)) did -c $dname 72
    if ($isbit(%f,3)) did -c $dname 73
    if (%msnf.rand) did -c $dname 31
    if (%msnx.showprof) did -c $dname 32
    if (%msnx.decode) did -c $dname 33
    if (%msnx.docolor) did -c $dname 34
    if (%msnx.usepass) did -c $dname 35
    if (%msnx.encode) did -c $dname 36
  }
}

on *:DIALOG:msn.setup*:sclick:100: {
  if ($sock(*. $+ $gettok($dname,3,46),0) >= 1) {
    msn.set $dname fname $replace($did($dname,20),$chr(32),\b)
    msn.set $dname fcolor $calc($did($dname,21).sel - 1)
    var %f 1
    if ($did($dname,71).state) %f = $calc(%f + 1)
    if ($did($dname,72).state) %f = $calc(%f + 2)
    if ($did($dname,73).state) %f = $calc(%f + 4)
    msn.set $dname fstyle %f
    if ($did($dname,31).state) msn.set $dname frand $true
    else msn.unset $dname frand
    if ($did($dname,33).state) msn.set $dname decode $true
    else msn.unset $dname decode
    if ($did($dname,34).state) msn.set $dname docolor $true
    else msn.unset $dname docolor
    if ($did($dname,36).state) msn.set $dname encode $true
    else msn.unset $dname encode
  }

  %msnf.font = $replace($did($dname,20),$chr(32),\b)
  %msnf.fcolor = $calc($did($dname,21).sel - 1)
  %msnf.fstyle = 1
  if ($did($dname,71).state) %msnf.fstyle = $calc(%msnf.fstyle + 1)
  if ($did($dname,72).state) %msnf.fstyle = $calc(%msnf.fstyle + 2)
  if ($did($dname,73).state) %msnf.fstyle = $calc(%msnf.fstyle + 4)
  if ($did($dname,31).state) %msnf.rand = $true
  else unset %msnf.rand
  if ($did($dname,32).state) %msnx.showprof = $true
  else unset %msnx.showprof
  if ($did($dname,33).state) %msnx.decode = $true
  else unset %msnx.decode
  if ($did($dname,34).state) %msnx.docolor = $true
  else unset %msnx.docolor
  if ($did($dname,35).state) %msnx.usepass = $true
  else unset %msnx.usepass
  if ($did($dname,36).state) %msnx.encode = $true
  else unset %msnx.encode
}

;--- Room creation dialog

alias msnroom dialog -m blah msn.room

dialog msn.room {
  title "Vincula - Room Creation"
  icon $mircexe , 5
  size -1 -1 150 100
  option dbu

  text "Name:", 11, 2 4 30 7, right
  edit "", 21, 35 2 113 11, read

  text "Password:", 12, 2 16 30 7, right
  edit "", 22, 35 14 113 11

  text "Category:", 13, 2 28 30 7, right
  combo 23, 35 26 113 100, drop

  text "Language:", 14, 2 40 30 7, right
  combo 24, 35 38 113 100, drop

  text "Topic:", 15, 2 52 30 7, right
  edit "", 25, 35 50 113 11

  text "User Limit:", 16, 2 64 30 7, right
  edit "50", 26, 35 62 113 11

  check "Enable Profanity Filter", 1, 35 73 113 11

  button "OK", 99, 33 85 40 12, ok
  button "Cancel", 98, 78 85 40 12, cancel
}

on *:DIALOG:msn.room*:init:*: {
  var %c did -a $dname 23, %l did -a $dname 24

  did -a $dname 21 %msnc.made
  did -a $dname 22 %msn.pass. [ $+ [ $right(%msnc.made,-2) ] ]

  %c UL - Unlisted
  %c GE - City Chats
  %c CP - Computing
  %c EA - Entertainment
  %c GN - General
  %c HE - Health
  %c II - Interests
  %c LF - Lifestyles
  %c MU - Music
  %c NW - News
  %c PR - Peers
  %c RL - Religion
  %c RM - Romance
  %c SP - Sports & Recreation
  %c TN - Teens
  did -c $dname 23 1

  %l English
  %l French
  %l German
  %l Japanese
  %l Swedish
  %l Dutch
  %l Korean
  %l Chinese (Simplified)
  %l Portuguese
  %l Finnish
  %l Danish
  %l Russian
  %l Italian
  %l Norwegian
  %l Chinese (Traditional)
  %l Spanish
  %l Czech
  %l Greek
  %l Hungarian
  %l Polish
  %l Slovene
  %l Turkish
  %l Slovak
  %l Portuguese (Brazilian)
  did -c $dname 24 1
}

on *:DIALOG:msn.room*:sclick:99: {
  if ($did(26) == $null) {
    var %p $input(You must include a user limit for the room,516,Need a User Limit)
    did -f $dname 26
    halt
  }
  elseif ($did(22) == $null) {
    var %p $input(You must include a password for the room,516,Need a Password)
    did -f $dname 22
    halt
  }
  var %x
  if ($did(25) != $null) %msnc.topic = $chr(37) $+ $replace($did(25),$chr(32),\b)
  else %msnc.topic = -
  if ($did(1).state == 1) %msnc.mode = fl $did(26)
  else %msnc.mode = l $did(26)
  if ($did(22) != $null) %x = $did(22)
  else %x = $msn.pass(10)
  %msn.pass. [ $+ [ $right(%msnc.made,-2) ] ] = %x
  .timer.noto. $+ $gettok($dname,5,46) off
  .sockwrite -tn $gettok($dname,3-,46) CREATE $gettok($did(23),1,32) %msnc.made %msnc.topic %msnc.mode EN-US $did(24).sel %x 0
}

on *:DIALOG:msn.room*:sclick:98: {
  .timer.noto. $+ $gettok($dname,5,46) off
  .sockclose msn*. $+ $gettok($dname,5,46)
  msn.nhtmlnc $gettok($dname,5,46)
  unset %msn*. [ $+ [ $gettok($dname,5,46) ] ]
  msn.clear $gettok($dname,5,46)
  echo $color(info2) -ta *** Room creation canceled
}

;--- Nickname entry
dialog msn.name {
  title "Vincula - Enter a nickname"
  icon $mircexe , 5
  size -1 -1 150 39
  option dbu

  text "Enter a nickname to use, leave blank for default name:", 1, 3 2 140 7
  edit "", 2, 2 10 146 11, autohs result
  check "Nickname is in Unicode Format", 3, 2 25 80 7 result

  button "OK", 99, 107 24 40 12, ok
}

on *:DIALOG:msn.name:sclick:99: {
  %msnx.unicodenick = $did($dname,3).state
}

alias msn.updatefonts {
  var %d " $+ $$sdir(C:\,Please choose your font folder $chr(40) $+ usually C:\Windows\Fonts $+ $chr(41)) $+ "
  echo $color(info2) -ta *** Scanning available Truetype fonts, please wait...
  if ($hget(msn.fonts)) hfree msn.fonts
  hmake msn.fonts 30
  %msnf.fontnum = 1
  var %x $findfile(%d,*.ttf,0,msn.upfont " $+ $1- $+ ")
  hsave -o msn.fonts $+(",$scriptdir,vfcache.dat")
  echo $color(info2) -ta *** Found %x Truetype fonts, names cached for future reference
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
;by Kamek.  Thanks Kamek, you da man :)
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
