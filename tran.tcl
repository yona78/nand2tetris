#yona orunov 328178165
#Yakov Yedidya Ben Shaul 215702473

proc CreatevmFile {PathToFile } {
    set size [string length $PathToFile]  ;# Get the length of the provided file path
    set lastDot [string last . $PathToFile $size ]  ;# Find the index of the last occurrence of '.' in the file path
    set nameOfTxml [string range $PathToFile 0  [expr { $lastDot - 3 }] ]  ;# Extract the substring from the beginning of the path to the character before the last '.'
    set pathOfvmFile "$nameOfTxml"  ;# Set the initial path of the .vm file as the extracted substring
    append pathOfvmFile ".vm"  ;# Append the file extension ".vm" to the pathOfvmFile
    
    return [open $pathOfvmFile w]  ;# Open a file with the constructed path for writing and return the file object
}


proc class {} {
    global vmFile  ;# Access the global variable 'vmFile'
    global ListLine  ;# Access the global variable 'ListLine'
    global data  ;# Access the global variable 'data'
    global index  ;# Access the global variable 'index'
    global className  ;# Access the global variable 'className'
    global which_func  ;# Access the global variable 'which_func'
    global ifMone  ;# Access the global variable 'ifMone'
    global whileMone  ;# Access the global variable 'whileMone'
    global ClassScopeName  ;# Access the global variable 'ClassScopeName'
    global ClassScopeType  ;# Access the global variable 'ClassScopeType'
    global ClassScopeKind  ;# Access the global variable 'ClassScopeKind'
    global ClassScopeNumOfKind  ;# Access the global variable 'ClassScopeNumOfKind'
    global iScope  ;# Access the global variable 'iScope'
    global static_counter  ;# Access the global variable 'static_counter'
    global field_counter  ;# Access the global variable 'field_counter'

    set labelCounter 0  ;# Initialize a local variable 'labelCounter' to 0
    set static_counter 0  ;# Initialize a local variable 'static_counter' to 0
    set field_counter 0  ;# Initialize a local variable 'field_counter' to 0
    set ifMone 0  ;# Initialize a local variable 'ifMone' to 0
    set whileMone 0  ;# Initialize a local variable 'whileMone' to 0
    set ClassScopeName {}  ;# Initialize an empty list 'ClassScopeName'
    set ClassScopeType {}  ;# Initialize an empty list 'ClassScopeType'
    set ClassScopeKind {}  ;# Initialize an empty list 'ClassScopeKind'
    set ClassScopeNumOfKind {}  ;# Initialize an empty list 'ClassScopeNumOfKind'
    incr index  ;# Increment the value of the global variable 'index' by 1

    set className [lindex [split [lindex $ListLine $index]] 1]  ;# Extract the class name from the current line of 'ListLine' and store it in the global variable 'className'
    puts $className  ;# Print the value of 'className'

    incr index  ;# Increment the value of the global variable 'index' by 1
    set next_line [lindex $ListLine $index]  ;# Get the next line from 'ListLine' and store it in the variable 'next_line'
    puts $next_line  ;# Print the value of 'next_line'

    incr index  ;# Increment the value of the global variable 'index' by 1
    set next_line [lindex $ListLine $index]  ;# Get the next line from 'ListLine' and store it in the variable 'next_line'
    puts $next_line  ;# Print the value of 'next_line'
    set staticOrField [lindex [split $next_line] 1]  ;# Extract the static or field keyword from 'next_line' and store it in the variable 'staticOrField'

    while {[string eq $staticOrField static] || [string eq $staticOrField field]} {
        # Execute the following code while 'staticOrField' is either "static" or "field"
        ClassVarDec  ;# Call a function/procedure named 'ClassVarDec'
        puts "VarDec"  ;# Print "VarDec"

        incr index  ;# Increment the value of the global variable 'index' by 1
        set next_line [lindex $ListLine $index]  ;# Get the next line from 'ListLine' and store it in the variable 'next_line'
        set staticOrField [lindex [split $next_line] 1]  ;# Extract the static or field keyword from 'next_line' and store it in the variable 'staticOrField'
    }

    set next_line [lindex $ListLine $index]  ;# Get the next line from 'ListLine' and store it in the variable 'next_line'
    set which_func [lindex [split $next_line] 1]  ;# Extract the function type (constructor, function, or method) from 'next_line' and store it in the global variable 'which_func'

    while {[string eq $which_func constructor] || [string eq $which_func function] || [string eq $which_func method]} {
        # Execute the following code while 'which_func' is either "constructor", "function", or "method"
        SubrotineDec  ;# Call a function/procedure named 'SubrotineDec'

        set next_line [lindex $ListLine $index]  ;# Get the next line from 'ListLine' and store it in the variable 'next_line'
        set which_func [lindex [split $next_line] 1]  ;# Extract the function type (constructor, function, or method) from 'next_line' and store it in the global variable 'which_func'
    }
}


proc ClassVarDec  {} {
    global vmFile
	global ListLine
	global data
	global index
	global ClassScopeName
	global ClassScopeType
	global ClassScopeKind
	global ClassScopeNumOfKind
	global iScope
	global className
	global static_counter
	global field_counter

    set staticOrField [lindex [split [lindex $ListLine $index] ] 1]
	puts $staticOrField
	set flag 0
    if {[string eq $staticOrField static]} {
        lappend ClassScopeKind static
		lappend ClassScopeNumOfKind $static_counter
		incr static_counter
		set flag 1     
    } elseif {[string eq $staticOrField field]} {
        lappend ClassScopeKind this
		    lappend ClassScopeNumOfKind $field_counter
		    incr field_counter
    }

    incr index

    set typeVar [lindex [split [lindex $ListLine $index] ] 1]
    lappend ClassScopeType $typeVar
    incr index

    set nameVar [lindex [split [lindex $ListLine $index] ] 1]
    lappend ClassScopeName $nameVar
	incr index
	set next_line [lindex $ListLine $index]
	set check_if_comma [lindex [split $next_line] 1]

    while {$check_if_comma =="," } {
		lappend ClassScopeType $typeVar
		if {$flag==1} {
		     lappend ClassScopeKind static
		     lappend ClassScopeNumOfKind $static_counter
		     incr static_counter
		} else {
		    lappend ClassScopeKind this
		    lappend ClassScopeNumOfKind $field_counter
		    incr field_counter
		}
		
		incr index
		set nameVar [lindex [split [lindex $ListLine $index] ] 1]
		lappend ClassScopeName $nameVar 
		incr index
		set next_line [lindex $ListLine $index]
		set check_if_comma [lindex [split $next_line] 1]
	}
}

proc SubrotineDec {} {
    global vmFile
	global ListLine
	global data
	global index
	global MethodScopeName
	global MethodScopeType
	global Method_scope_Kind
	global MethodScopeNumOfKind
	global iScope	
	global className
	global arg_counter
	global var_counter
	global subName
	global middleWord
	global typeRetVal	
	global ifMone 
	global whileMone 
    global func_scope_Name 
	global func_scope_Type

    set arg_counter 0
	set var_counter 0
	set iScope 0
    set ifMone 0
	set whileMone 0
	set MethodScopeName {}
	set MethodScopeType {}
	set Method_scope_Kind {}
	set MethodScopeNumOfKind {}
    set func_scope_Name {}
	set func_scope_Type {}

    set middleWord [lindex [split [lindex $ListLine $index] ] 1]
    lappend func_scope_Type $middleWord
	incr index

    set typeRetVal [lindex [split [lindex $ListLine $index] ] 1]
	incr index

    set subName [lindex [split [lindex $ListLine $index] ] 1]
	incr index
    lappend func_scope_Name $subName

    if {([string eq $middleWord method])} {	
		lappend MethodScopeName this
		lappend MethodScopeType $className
		lappend Method_scope_Kind argument 
		lappend MethodScopeNumOfKind $arg_counter
		incr arg_counter
	}
    incr index

    parameterList
    incr index

    subrutineBody

}

proc parameterList {} {
    global vmFile
	global ListLine
	global data
	global index
	global MethodScopeName
	global MethodScopeType
	global Method_scope_Kind
	global MethodScopeNumOfKind
	global iScope	
	global className
	global arg_counter
	global var_counter

	set next_line [lindex [split [lindex $ListLine $index] ] 1]
	puts $next_line

    if { $next_line != ")"} {

		lappend MethodScopeType [lindex [split [lindex $ListLine $index] ] 1]
		incr index

		lappend MethodScopeName [lindex [split [lindex $ListLine $index] ] 1]
		incr index

		lappend Method_scope_Kind argument 
		
		lappend MethodScopeNumOfKind $arg_counter
		incr arg_counter
		set next_line [lindex $ListLine $index]
		puts $next_line
	}

    set check_if_comma [lindex [split $next_line] 1]
	while {$check_if_comma =="," } {
		
		incr index
		lappend MethodScopeType [lindex [split [lindex $ListLine $index] ] 1]
		incr index
		lappend MethodScopeName [lindex [split [lindex $ListLine $index] ] 1]
		lappend Method_scope_Kind argument 
		lappend MethodScopeNumOfKind $arg_counter
		incr arg_counter
		incr index
		set next_line [lindex $ListLine $index]
		set check_if_comma [lindex [split $next_line] 1]
	}
}

proc subrutineBody {} {
    global vmFile
	global ListLine
	global data
	global index
	global className
	global var_counter
	global subName
	global middleWord
	global static_counter
	global field_counter

    set var_counter 0
    set F function
	set DOT .
	set SPACE " "
    incr index

    set next_line [lindex $ListLine $index]
	puts $next_line

	set check_if_var [lindex [split $next_line] 1]
    while {$check_if_var=="var"} {
	    varDec		   
	    set next_line [lindex $ListLine $index]
	    set check_if_var [lindex [split $next_line] 1]
	}

    puts $vmFile $F$SPACE$className$DOT$subName$SPACE$var_counter
	puts $F$SPACE$className$DOT$subName$SPACE$var_counter

    if {[string eq $middleWord method]} {
		    puts $vmFile "push argument 0"
		    puts $vmFile "pop pointer 0"
	} elseif {[string eq $middleWord constructor]} {
			puts $field_counter"FIELD_COUNTER"
			notminus $field_counter
			puts $vmFile "call Memory.alloc 1"
			puts $vmFile "pop pointer 0"
	}

	statements
	incr index
}

proc varDec	{} {
    global vmFile
	global ListLine
	global data
	global index
	global MethodScopeName
	global MethodScopeType
	global Method_scope_Kind
	global MethodScopeNumOfKind
	global iScope
	global className
	global arg_counter
	global var_counter

    incr index

    set tempType [lindex [split [lindex $ListLine $index] ] 1]
	lappend MethodScopeType $tempType
	incr index

    lappend MethodScopeName [lindex [split [lindex $ListLine $index] ] 1]
	incr index

    lappend Method_scope_Kind local 
	lappend MethodScopeNumOfKind $var_counter
	incr var_counter

    set next_line [lindex $ListLine $index]
	set check_if_comma [lindex [split $next_line] 1]

    while {$check_if_comma =="," } {	
		incr index
		
		lappend MethodScopeName [lindex [split [lindex $ListLine $index] ] 1]
		incr index
		lappend MethodScopeType $tempType
		lappend Method_scope_Kind local 
		lappend MethodScopeNumOfKind $var_counter
		incr var_counter
		set next_line [lindex $ListLine $index]
		set check_if_comma [lindex [split $next_line] 1]
	}
    incr index
}

proc notminus {len} {
	global vmFile
	set flag 0

	if {$len < 0} {
		set flag 1
		set len [expr $len*-1]
	}

	puts $vmFile "push constant $len"
	if {$flag == 1} {puts $vmFile "neg"}
}

proc statements {} {
    global vmFile
	global ListLine
	global data
	global index

    set index [expr $index -1]
	set next_line [lindex $ListLine $index]
	puts $next_line
	incr index

    set next_line [lindex $ListLine $index]
	puts $next_line
	set more_statements [lindex [split $next_line] 1]
	puts $more_statements

    while {[string eq $more_statements let] || [string eq $more_statements if] || [string eq $more_statements while] || [string eq $more_statements do] || [string eq $more_statements return]} {
	    puts $more_statements
		statement
	
		puts "FINISHED_parse_statement "	
	    set next_line [lindex $ListLine $index]
	    set more_statements [lindex [split $next_line] 1]
	}
}

proc statement {} {	
	global vmFile
	global ListLine
	global data
	global index
	
	set next_line [lindex $ListLine $index]
	set which_statement [lindex [split $next_line] 1]
	    
	if {[string eq $which_statement let]} {
		parse_let
	} elseif {[string eq $which_statement if]} {
		parse_if	
	} elseif {[string eq $which_statement while]} {
		parse_while	
	} elseif {[string eq $which_statement do]} {
		parse_do
	} elseif {[string eq $which_statement return]} {
		parse_return
	}
}

proc parse_let {} {	
	global vmFile
	global ListLine
	global data
	global index

	set spacy " "
	incr index

	set let_var  [lindex [split [lindex $ListLine $index] ] 1]
	set arrFlag 0
	incr index

	set next_line [lindex $ListLine $index]
	set exp [lindex [split $next_line] 1]
	if {![string eq $exp "="]} {
		set arrFlag 1
		set arr [searchVariable $let_var]
		incr index
		parse_expression
		set identifierToPrint [lindex $arr 2]$spacy[lindex $arr 3]
		puts $vmFile "push $identifierToPrint"
		puts $vmFile "add"
		
		incr index
	}
	
	incr index
	parse_expression
	if {$arrFlag==1} {
		puts $vmFile "pop temp 0"
		puts $vmFile "pop pointer 1"
		puts $vmFile "push temp 0"
		puts $vmFile "pop that 0"
	} else {
	#search the let_variable in the symbles tables and return to ans={name,type,kind,#}
	set ans [searchVariable $let_var]
	set spacy " "
	set  identifierToPrint [lindex $ans 2]$spacy[lindex $ans 3]
	#pop the data from the stack and push it into the the letVar
	puts $vmFile "pop $identifierToPrint"
	}
	#;
	incr index
}

proc searchVariable {nameVar} {
	global ClassScopeName
	global ClassScopeType
	global ClassScopeKind
	global ClassScopeNumOfKind
	global iScope
	global outputFile
	global ListLine
	global data
	global index
	global MethodScopeName
	global MethodScopeType
	global Method_scope_Kind
	global MethodScopeNumOfKind
	
	set dtlVar {}
	set iScope 0
	
	foreach name $ClassScopeName {
		if {[string eq $name $nameVar]} {
			puts $name	
			lappend dtlVar [lindex $ClassScopeName $iScope]	
			lappend dtlVar [lindex $ClassScopeType $iScope]
			lappend dtlVar [lindex $ClassScopeKind $iScope]
			lappend dtlVar [lindex $ClassScopeNumOfKind $iScope]
			
		    return $dtlVar	
		} else {
		     incr iScope	
		}  
	}
	set dtlVar {}
	set iScope 0
	
	foreach nami $MethodScopeName {	
		if {[string eq $nami $nameVar]} {
			lappend dtlVar [lindex $MethodScopeName $iScope]
			lappend dtlVar [lindex $MethodScopeType $iScope]
			lappend dtlVar [lindex $Method_scope_Kind $iScope]
			lappend dtlVar [lindex $MethodScopeNumOfKind $iScope]
			
		    return $dtlVar				
	    } else {      
		    incr iScope	
		}
	}
	set dtlVar NULL
}


proc parse_expression {} {
	global vmFile
	global ListLine
	global data
	global index
	global identifierToPrint	
	parse_term

	set next_line [lindex $ListLine $index]	
	set two [lindex [split $next_line] 1]
	
	while { [string eq $two "+"] || [string eq $two "-"] || [string eq $two "*"] || [string eq $two "/"] || [string eq $two "&amp;"] || [string eq $two "|"] || [string eq $two "&lt;" ] || [string eq $two "&gt;" ] || [string eq $two "=" ] } {
		if {[string eq $two "+"]} {
		    set op_to_print add
		} elseif {[string eq $two "-"]} {
		    set op_to_print sub 
		} elseif {[string eq $two "*"]} {
		    set op_to_print "call Math.multiply 2"
		} elseif {[string eq $two "/"]} {
		    set op_to_print "call Math.divide 2"
		} elseif {[string eq $two "&amp;"]} {
		    set op_to_print and
		} elseif {[string eq $two "|"]} {
		    set op_to_print or
		} elseif {[string eq $two "&lt;" ]} {
		    set op_to_print lt
		} elseif {[string eq $two "&gt;" ]} {
		    set op_to_print gt
		} elseif {[string eq $two "="]} {
		    set op_to_print eq	
		}
		
		incr index
		puts  $op_to_print
		parse_term
		puts $vmFile $op_to_print
		puts  $op_to_print
		set next_line [lindex $ListLine $index]
		set two [lindex [split $next_line] 1]
	}
}

proc parse_term {} {
	global vmFile
	global ListLine
	global data
	global index
	global identifierToPrint
	global MethodScopeName
	global MethodScopeType
	global Method_scope_Kind
	global MethodScopeNumOfKind                                      
	
	set spacy " "
	set next_line [lindex $ListLine $index]
	set tag [lindex [split $next_line] 0]
	set inside [lindex [split $next_line] 1]
	
	if {[string eq $tag "<integerConstant>"] || [string eq $tag "<stringConstant>"] || [string eq $tag "<keyword>"] } {	   
		if {[string eq $tag "<integerConstant>"]} {
			notminus $inside
			puts  "push constant $inside"
		} elseif {[string eq $tag "<stringConstant>"]} {
			set i 2
			set r [lindex [split $next_line] $i]
			while { ![string eq $r </stringConstant>] } {
				set inside $inside$spacy$r
				incr i
				set r [lindex [split $next_line] $i]
			}
			set len [string length $inside] 
			puts $inside			
			notminus $len
			puts $vmFile "call String.new 1"
			for {set i 0} {$i < [string length $inside] } {incr i} {
			    set inte [scan [string index $inside $i] %c]				
				notminus $inte
				puts $vmFile "call String.appendChar 2"
			}
		} elseif {[string eq $tag "<keyword>"]} {
				if {[string eq $inside "false"]} {
					puts $vmFile "push constant 0"
					set type boolean
				} elseif {[string eq $inside "this"]} {
				    puts $vmFile "push pointer 0"
				} elseif {[string eq $inside "true"]} {
					puts $vmFile "push constant 0"
					puts $vmFile "not"
					set type boolean    
				} elseif {[string eq $inside "null"]} {
					puts $vmFile "push constant 0"
				}
		}
		#;
		incr index
		
	} elseif {[string eq $tag "<identifier>"]} {
		set arr $inside
		incr index
		set next_line [lindex $ListLine $index]
		set inside [lindex [split $next_line] 1]
			 
		if {[string eq $inside "\["] } {
			set index [expr $index - 1]
			incr index
			incr index
			parse_expression
			set arri [searchVariable $arr]
			set identifierToPrint [lindex $arri 2]$spacy[lindex $arri 3]
			puts $vmFile "push $identifierToPrint"
			puts $vmFile "add"
			puts $vmFile "pop pointer 1"
			puts $vmFile "push that 0"
			incr index
				
		} elseif {[string eq $inside "."] || [string eq $inside "("] } {
			set index [expr $index - 1]
			subroutineCall
		} else {
			set index [expr $index - 1]
			set prev_line [lindex $ListLine $index]
			set identi [lindex [split $prev_line] 1]
			
			set ans [searchVariable $identi]
			set identifierToPrint [lindex $ans 2]$spacy[lindex $ans 3]
			puts $vmFile push$spacy$identifierToPrint
		    incr index
		}
	} elseif {[string eq $inside "("] } {
		puts [lindex $ListLine $index]
		incr index
		parse_expression	
		incr index	  
	} elseif {[string eq $inside "-"] || [string eq $inside "~"] } {     
		if {[string eq $inside "-"]} {      
			set onary_to_print neg
			puts $onary_to_print"OP_MINUS"    
		} elseif {[string eq $inside "~"]} {
			set onary_to_print not
			puts $onary_to_print"OP_NOT"     
		}      
		incr index
		puts $onary_to_print"ONARY"
		parse_term	
		puts $vmFile $onary_to_print
		puts $onary_to_print"ONARY"
		    
	} 
}

proc parse_if {} {	
	global vmFile
	global ListLine
	global data
	global index
	global ifMone 

	set labelCounter_if $ifMone
	incr ifMone
	incr index
	incr index
	parse_expression
	incr index
	
	puts $vmFile "if-goto IF_TRUE$labelCounter_if"
	puts $vmFile "goto IF_FALSE$labelCounter_if"
	puts $vmFile "label IF_TRUE$labelCounter_if"
	
	incr index
	statements
	
	incr index

	set next_line [lindex $ListLine $index]
	puts $next_line
	set else_state [lindex [split $next_line] 1]
	puts $else_state
	
	if {[string eq $else_state else]} {
        puts $vmFile "goto IF_END$labelCounter_if"
	    puts $vmFile "label IF_FALSE$labelCounter_if"
		
	    incr index
	
	    incr index
	    statements
	
	    incr index	
	    puts $vmFile "label IF_END$labelCounter_if"
	} else {
		puts $vmFile "label IF_FALSE$labelCounter_if"
	}
}

proc parse_while {} {	
	global vmFile
	global ListLine
	global data
	global index
	global whileMone
	global labelCounter

	set labelCounter_while $whileMone
	incr whileMone
	puts $vmFile "label WHILE_EXP$labelCounter_while"
	incr index
	incr index
	parse_expression
	puts $vmFile "not"
	puts $vmFile "if-goto WHILE_END$labelCounter_while"
	incr index
	incr index
	statements
	puts $vmFile "goto WHILE_EXP$labelCounter_while"
	puts $vmFile "label WHILE_END$labelCounter_while"
	incr index
}

proc parse_do {} {	
	global vmFile
	global ListLine
	global data
	global index

	incr index
	subroutineCall
	puts $vmFile "pop temp 0"
	
	incr index
}

proc parse_return {} {	
	global vmFile
	global ListLine
	global data
	global index
	global which_func
	
	incr index
	set next_line [lindex $ListLine $index]
	set exp_state [lindex [split $next_line] 1]

	if {[string eq $exp_state "\;"]} {
		
		puts $vmFile "push constant 0"
		puts $vmFile "return"
		incr index	
	} else {
		parse_expression
		puts $vmFile "return"		
		incr index
	}
}

proc subroutineCall {} {
	global vmFile
	global ListLine
	global data
	global index
	global moneParams
	global className
	global which
	
	set moneParams 0
	
	set lineToPrint [lindex [split [lindex $ListLine $index] ] 1]
	set which [searchFunc $lineToPrint]
	
	incr index
	
	set next_line [lindex $ListLine $index]
	set dot [lindex [split $next_line] 1]
	if {[string eq $dot "("]} {
		puts  $vmFile "push pointer 0"
		set inClass true
		incr moneParams
	} elseif {[string eq $dot "."]} {
		set inClass false
	
		set ans [searchVariable $lineToPrint]
		if {$ans!= "NULL"} {
			set lineToPrint [lindex $ans 1]
			set k [lindex $ans 2]
			set n [lindex $ans 3]
			if {[string match $k "constant"]} {
			    notminus $n
			} else {
				puts $vmFile "push $k $n"
			}
			incr moneParams
		}
		set lineToPrint $lineToPrint$dot
		incr index
		
		set subrotineName [lindex [split [lindex $ListLine $index] ] 1]
		set lineToPrint $lineToPrint$subrotineName
		incr index	
	}
	
	incr index
	parse_expressionList
	if { [string eq $inClass true]} {
	    puts $vmFile "call $className.$lineToPrint $moneParams"
	} else {
		puts $vmFile "call $lineToPrint $moneParams"
	}
	
	incr index
}

proc searchFunc {nameFunc} { 	
	global func_scope_Name 
	global func_scope_Type
	set iScope 0

	foreach nami $func_scope_Name  {
		if {[string eq $nami $nameFunc]} {
			return [lindex $func_scope_Type $iScope] 
		} else {
			incr iScope
		}	   
	}
}

proc parse_expressionList {} {
	global vmFile
	global ListLine
	global data
	global index
	global moneParams
	global which
		
	set next_line [lindex $ListLine $index]
	set exp [lindex [split $next_line] 1]
	
	if {![string eq $exp ")"]} {
	    incr moneParams
		parse_expression
	}
	set next_line [lindex $ListLine $index]
	set check_if_comma [lindex [split $next_line] 1]
	while {$check_if_comma =="," } {
		incr moneParams	
		incr index
	    parse_expression
		set next_line [lindex $ListLine $index]
		set check_if_comma [lindex [split $next_line] 1]
	}
}

puts "Enter a path to a folder: "
gets stdin userInput
puts $userInput

if {[file exists $userInput]} {
    if {[file isdirectory $userInput]} {
        puts "$userInput is a directory"
        set allTxmls [glob -directory $userInput -- "*Tr.xml"]
        
        # Iterate over each file with extension "Tr.xml" in the directory
        foreach f $allTxmls {
            set vmFile [CreatevmFile $f]  ;# Call a function CreatevmFile with the current file as an argument
            set lines [open $f r]  ;# Open the current file for reading
            set data [read $lines]  ;# Read the contents of the file
            set ListLine [split $data "\n"]  ;# Split the file contents into a list of lines
            set index 1
            class  ;# Call a function
        }
    } elseif {[string match "*Tr.xml" $userInput]} {
        set vmFile [CreatevmFile $userInput]  ;# Call a function CreatevmFile with the provided file as an argument
        set lines [open $userInput r]  ;# Open the provided file for reading
        set data [read $lines]  ;# Read the contents of the file
        set ListLine [split $data "\n"]  ;# Split the file contents into a list of lines
        set index 1
        class  ;# Call a function)
    } else {
        puts "$userInput is not a tokan file"
        return ;# End the program if it's not a Tr.xml file
    }
} else {
    puts "$userInput does not exist"
    return ;# End the program if the input doesn't exist
}
