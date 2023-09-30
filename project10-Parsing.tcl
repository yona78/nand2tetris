proc CreateXmlFile {PathToFile } {
    set size [string length $PathToFile]
    set lastDot [string last . $PathToFile $size ]
    set nameOfTxml [string range $PathToFile 0  [expr { $lastDot - 3 }] ]
    set pathOfXmlFile "$nameOfTxml"
    append pathOfXmlFile "F.xml"
    return [open $pathOfXmlFile w]
}

proc insert { text } {
    if {[string index $text 1] == "/"} {
	    backSpace
    }
    puts $::xmlFile "$::indent$text"
}

proc makeSpace {} {
    append ::indent "  "
}


proc backSpace {} {
    set size [string length $::indent]
    set ::indent [string range $::indent 0 [expr { $size - 3 }] ]
}

proc getTokenType { Token } {
    set firsto [string first < $Token  ]
    set firstc [string first > $Token ]
    set tokenType [string range $Token [expr { $firsto + 1 }] [expr { $firstc - 1 }] ]
    return $tokenType
}

proc getTokenContent { Token } {
    set firstc [string first > $Token  ]
    set lasto [string last < $Token ]
    set tokenType [string range $Token [expr { $firstc + 2 }] [expr { $lasto - 2 }] ]
    return $tokenType
}

proc getNextToken {} {
    if {$::globalIndex >  [expr {[string length $::tokens]-1}] } {
	return }
    set ::t [lindex $::tokens $::globalIndex]
    incr ::globalIndex
}

proc getNextTokenContent {} {
    showNextToken
    return [getTokenContent $::t]
}

proc showNextToken {} {
    getNextToken
    set ::globalIndex [expr { $::globalIndex - 1 }]
}

proc printNextToken {} {
    getNextToken
    insert $::t
}

proc runLoop {num} {
  for {set i 1} {$i <= $num} {incr i} {
    printNextToken
  }
}

proc class { } {
    insert <class>
    makeSpace
    runLoop 3
    set wordsList { "static" "field" }
    while { [getNextTokenContent] in $wordsList } {
	    classTitel
    }
    set wordsList { "constructor" "function" "method" }
    while { [getNextTokenContent] in $wordsList } {
	    functions
    }
    runLoop 1
    insert </class>
}

proc classTitel { } {
    insert <classVarDec>
    makeSpace
    runLoop 3
    while { [getNextTokenContent] ==","  } {
        runLoop 2
    }
    runLoop 1
    insert </classVarDec>
}

proc type { Token } {
    set wordsList { "int" "char" "boolean" }
    if {[getTokenContent $Token] in $wordsList  || [getTokenType $Token] == "identifier"} {
	    return 1
    }
    return 0
}

proc functions { } {
    insert <subroutineDec>
    makeSpace
    runLoop 4
    parameterList
    runLoop 1
    functionBody
    insert </subroutineDec>
}

proc parameterList { } {
    insert <parameterList>
    makeSpace
    showNextToken
    if { [type $::t] == 1 } {
	    runLoop 2
	    while { [getNextTokenContent] == ","  } {
	        runLoop 3
	    }
    }
    insert </parameterList>
}

proc functionBody { } {
    insert <subroutineBody>
    makeSpace
    runLoop 1
    while { [getNextTokenContent] =="var"  } {
	    variables 
    }
    statements 
    runLoop 1
    insert </subroutineBody>
}

proc variables {} {
    insert <varDec>
    makeSpace
    runLoop 3
    while { [getNextTokenContent] == ","  } {
	    runLoop 2
    }
    runLoop 1
    insert </varDec>
}

proc statements {} {
    insert <statements>
    makeSpace
    set wordsList {"let" "if" "do" "while" "return"}
    while { [getNextTokenContent] in $wordsList  } {
	    statement
    }
    insert </statements>
}

proc statement {} {
    switch [getNextTokenContent] {
	    "let" { letStatement }
	    "if" { ifStatement }
	    "while" { whileStatement }
	    "do" { doStatement }
	    "return" { returnStatement }
	    default { runLoop 1 }
    }
}

proc letStatement { } {
    insert <letStatement>
    makeSpace
    runLoop 2
    if { [getNextTokenContent] == "\[" } {
	    runLoop 1
	    expression
	    runLoop 1
    }
    runLoop 1
    expression
    runLoop 1
    insert </letStatement>
}

proc ifStatement { } {
    insert <ifStatement>
    makeSpace
    runLoop 2
    expression
    runLoop 2
    statements
    runLoop 1
    if { [getNextTokenContent] == "else" } {
	    runLoop 2
	    statements
	    runLoop 1
    }
    insert </ifStatement>
}

proc whileStatement { } {
    insert <whileStatement>
    makeSpace
    runLoop 2
    expression
    runLoop 2
    statements
    runLoop 1
    insert </whileStatement>
}

proc doStatement { } {
    insert <doStatement>
    makeSpace
    runLoop 2
    functionCall
    runLoop 1
    insert </doStatement>
}

proc returnStatement { } {
    insert <returnStatement>
    makeSpace
    runLoop 1
    if { [getNextTokenContent] != ";" } {
	    expression 
    }
    runLoop 1
    insert </returnStatement>
}

proc expression {} {
    insert <expression>
    makeSpace
    term
    set wordsList {"+" "-" "*" "/" "&" "|" "<" ">" "=" "&lt;" "&gt;" "&amp;"}
    while { [getNextTokenContent] in $wordsList  } {
	    runLoop 1
	    term
    }
    insert </expression>
}

proc term {} {
    insert <term>
    makeSpace
    showNextToken
    switch [getTokenType $::t] {
	    "integerConstant" { runLoop 1 }
	    "stringConstant" { runLoop 1 }
	    "identifier" {
	        runLoop 1
	        switch [getNextTokenContent] {
		        "\[" { 
                    runLoop 1
		            expression
		            runLoop 1
		        }
		        "(" {functionCall}
		        "." {functionCall}
	        }
	    }
	    "keyword" { runLoop 1 }
	    "symbol" {
	        switch [getNextTokenContent] {
		        "\(" { 
                    runLoop 1
		            expression
		            runLoop 1
		        }
		        "-" {
                     runLoop 1
		            term 
                }
                "~" { 
                    runLoop 1
		            term  
                }
	        }
	    }
	    default { }
    }
    insert </term>
}

proc functionCall {} {
    if {[getNextTokenContent]=="\("} {
	    runLoop 1
	    expressionList
	    runLoop 1
    } elseif {[getNextTokenContent]== "."} {
	    runLoop 3
	    expressionList
	    runLoop 1
    }
}

proc expressionList { } {
    insert <expressionList>
    makeSpace
    if { [getNextTokenContent] != "\)" } {
	    expression
	    while { [getNextTokenContent] == ","  } {
	        runLoop 1 
	        expression
	    }
    }
    insert </expressionList>
}

puts "Enter a path to a folder: "
gets stdin userInput
#gets stdin pathToFolder
puts $userInput
if {[file exists $userInput]} {
    if {[file isdirectory $userInput]} {
        puts "$userInput is a directory"
        set allTxmls [glob -directory $userInput -- "*Tr.xml"]
        foreach f $allTxmls {
            set xmlFile [CreateXmlFile $f]
            set lines [open $f r]
            set tokens [split [read $lines] "\n"]
            set indent ""
            set globalIndex 1
            set t ""
            class
        }
    } elseif {[string match "*Tr.xml" $userInput]} {
        set xmlFile [CreateXmlFile $userInput]
            set lines [open $userInput r]
            set tokens [split [read $lines] "\n"]
            set indent ""
            set globalIndex 1
            set t ""
            class
    } else {
        puts "$userInput is not a tokan file"
        return ;# End the program if it's not a .jack file
    }
} else {
    puts "$userInput does not exist"
    return ;# End the program if the input doesn't exist
}

