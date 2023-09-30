proc print_0 {type } {
    #set str "<$type> $::globalTok <\\$type>"
    #puts -inline $::xmlTFile $str
    puts -nonewline "$::globalTok "
    puts $::fileOut "<$type> $::globalTok </$type>"
    set ::globalTok ""
    return 0
}



proc addTock {} {
    set ::globalTok $::globalTok$::c
}

proc checkTok {} {
    if { [isKeyword] == 1} {
	print_0 keyword
    } else {
	print_0 identifier }
}

proc isKeyword {} {
    if { $::globalTok == "class" || $::globalTok == "constructor" || $::globalTok == "function" ||
	$::globalTok == "method" || $::globalTok == "field" || $::globalTok == "static" ||
	$::globalTok == "var" || $::globalTok == "int" || $::globalTok == "char" || $::globalTok == "boolean" ||
	$::globalTok == "void" || $::globalTok == "true" || $::globalTok == "false" || $::globalTok == "null" ||
	$::globalTok == "this" || $::globalTok == "let" || $::globalTok == "do" || $::globalTok == "if" ||
	$::globalTok == "else" || $::globalTok == "while" || $::globalTok == "return" } {
	return 1
    } else {
	return 0
    }
}


proc getNextChar {} {
    if {$::globalIndex >  [string length $::data] } {
	return 1 }
    set ::c [string index $::data $::globalIndex]
    incr ::globalIndex
    return 0
}

proc tar {state} {
    while { $state != -1} {
        switch $state {
	    0 { set state [ S0 ] }
	    1 { set state [ S1 ] }
	    2 {  set state [ S2 ] }
	    3 {  set state [ S3 ]  }
	    4 { set state [ S4 ] }
	    5 { set state [ S5 ] }
	    6 {  set state [ S6 ] }
	    7 { set state [ S7 ] }
	    8 {  set state [ S8 ] }
	    9 {  set state [ S9 ] }
	    10 { set state [ S10 ] }
	}
    }
}

proc S0 {} {
    if { [getNextChar] } { return -1 }
    if { [string trim $::c] == ""} { return 0
    } elseif {[regexp -all {[a-zA-Z]} $::c]} { return 1
    } elseif  {$::c == "_"} { return 2
    } elseif  {[regexp -all {[0-9]} $::c]} { return 3
    } elseif {$::c == "\""} { return 5
    } elseif {$::c == "/"} { return 7
    } else { return 4 }
}

proc S1 {} {
    if {[regexp -all {[a-zA-Z]} $::c]} {
	addTock
	if { [getNextChar] } { return -1 }
	return 1
	# c is a_,a0,a ,a*
    } else {
	# c is a_,a0
	if { $::c == "_" || [regexp -all {[0-9]} $::c] } {
	    addTock
	    if { [getNextChar] } { return -1 }
	    return 2
	    # c is a .
	} elseif { [string trim $::c] == "" } {
	    checkTok
	    # c is a*
	} else {
	    set ::globalIndex [expr { $::globalIndex - 1 }]
	    checkTok
	}
    }
}

proc S2 {} {
    if { [regexp -all {[a-zA-Z0-9]} $::c] } {
	addTock
	if { [getNextChar] } { return -1 }
	return 2
    } else {
	return [print_0 identifier]
    }
}

proc S3 {} {
    if {[regexp -all {[0-9]} $::c]} {
	addTock
	if { [getNextChar] } { return -1 }
	return 3
    } else {
	set ::globalIndex [expr { $::globalIndex - 1 }]
	return [print_0 integerConstant]
	}
}

proc S4 {} {
    addTock
    switch $::globalTok {
    < { set ::globalTok "&lt;" } 
    > { set ::globalTok "&gt;" } 
    "\"" { set ::globalTok "&quot;" }
    & { set ::globalTok "&amp;"	}
    }
    return [print_0 symbol]
}

proc S5 {} {
    if { [getNextChar] } { return -1 }
    if { $::c == "\"" } {
	    return 6
    } else { 
	    addTock
	    return 5 
    }
}

proc S6 {} {
    return [print_0 stringConstant]
}

proc S7 {} {
    if { [getNextChar] } { return -1 }
    if { $::c == "/" } {
	return 8
    } elseif { $::c == "*" } {
	# we assume that the char we skip is *
	incr ::globalIndex
	if { [getNextChar] } { return -1 }
	return 9
    } else {
	puts $::globalTok
	set ::globalIndex [expr { $::globalIndex - 2 }]
	#get the /
	getNextChar
	return 4 }
}

proc S8 {} {
    if { [getNextChar] } { return -1 }
    if {  [string trim $::c] != ""  || $::c == " "} { return 8
    } else {
	return 0 }
}

proc S9 {} {
    if { [getNextChar] } { return -1 }
    if { $::c == "*" } {
	return 10
    } else { return 9 }
}

proc S10 {} {
    if { [getNextChar] } { return -1 }
    if { $::c == "/" } {
	return 0
    } else { return 9 }
}

set userInput "" ;
puts "Enter a file or path:"
gets stdin userInput
set fa ""
if {[file exists $userInput]} {
    if {[file isdirectory $userInput]} {
        puts "$userInput is a directory"
        foreach fileD [glob -directory $userInput *] {
        set extension [file extension $fileD]
        set fa ""
        if {$extension eq ".jack"} {
            set f [split $fileD "."]
            append fa [lindex $f 0]
            append fa "Tr.xml"
            set fileOut [open $fa w]
            set readFile [open $fileD r]
            set data [read $readFile]
            set globalIndex 0
            set c ""
            set globalTok ""
            puts $fileOut "<tokens>"
            tar 0 
            puts $fileOut "</tokens>"
            close $fileOut
        }
    }
    } elseif {[file extension $userInput] eq ".jack"} {
        puts "$userInput is a .jack file"
        set f [split $userInput "."]
        append fa [lindex $f 0]
        append fa "Tr.xml"
        set fileOut [open $fa w]
        set readFile [open $userInput r]
        set data [read $readFile]
        set globalIndex 0
        set c ""
        set globalTok ""
        puts $fileOut "<tokens>"
        tar 0
        puts $fileOut "</tokens>"
        close $fileOut
    } else {
        puts "$userInput is not a .jack file"
        return ;# End the program if it's not a .jack file
    }
} else {
    puts "$userInput does not exist"
    return ;# End the program if the input doesn't exist
}