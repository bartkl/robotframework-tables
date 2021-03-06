*** Settings ***
Library  String
Library  Collections
Library  SeleniumLibrary



*** Keywords ***
Append To String If Not Contained
    [Documentation]  Determines whether `${part}` is contained in `${string}`.
    ...  If this is not the case, `${part}` gets appended to `${string}`,
    ...  otherwise the original `${string}` is returned.
    [Arguments]  ${string}  ${part}

    ${is contained}=  Run Keyword And Return Status
    ...                   Should Contain  ${string}  ${part}
    Run Keyword If   not ${is contained}
    ...    Return From Keyword  ${string}${part}
    ...  ELSE
    ...    Return From Keyword  ${string}

Get Cell Locator By Coordinates
    [Arguments]
    ...  ${table xpaths}
    ...  ${row nr}
    ...  ${col nr}

    ${cell xpath}=  Get Cells Locator  ${table xpaths}  row condition=[${row nr}]
    ...                                                 col condition=[${col nr}]

    Return From Keyword  ${cell xpath}

Get Cell Value
    [Documentation]  Gets the value from the cell identified by the supplied
    ...  conditions:
    ...
    ...  * `${row xpath cond}` for rows,
    ...  * `${col xpath cond}` for columns.
    ...
    ...  These conditions must be valid XPath condition expressions, including
    ...  the surrounding square brackets. They will be injected in the XPath
    ...  locators in the table dictionary.
    ...
    ...  Examples can be found in the tests file.
    ...
    ...  @TODO: Improve this documentation.
    [Arguments]
    ...  ${table xpaths}
    ...  ${row condition}=${EMPTY}
    ...  ${col condition}=${EMPTY}

    ${cell xpath}=  Get Cells Locator  ${table xpaths}  row condition=${row condition}
    ...                                                 col condition=${col condition}
    ${value}=  SeleniumLibrary.Get Text  ${cell xpath}
    Return From Keyword  ${value}

Get Cell Value By Coordinates
    [Documentation]  Gets the value of the cell identified by the supplied
    ...  coordinates:
    ...
    ...  `${row nr}` is the row number, starting from 1.
    ...  `${col nr}` is the column number, starting from 1.
    ...
    [Arguments]
    ...  ${table xpaths}
    ...  ${row nr}
    ...  ${col nr}

    ${cell xpath}=  Get Cell Locator By Coordinates  ${table xpaths}  ${row nr}  ${col nr}
    ${value}=  SeleniumLibrary.Get Text  ${cell xpath}
    Return From Keyword  ${value}

Get Cells Locator
    [Arguments]
    ...  ${table xpaths}
    ...  ${row condition}=${EMPTY}
    ...  ${col condition}=${EMPTY}

    ${cells xpath}=  Parse XPath  &{table xpaths}[cells]  row xpath cond=${row condition}
    ...                                                   col xpath cond=${col condition}

    Return From Keyword  ${cells xpath}

Get Column Count
    [Documentation]  Calculates and returns the amount of columns in the table.
    [Arguments]
    ...  ${table xpaths}

    # If `column name cells' is defined.
    ${count}=  Run Keyword If  'column name cells' in ${table xpaths.keys()}
    ...    Get Element Count  &{table xpaths}[column name cells]

    Return From Keyword If  ${count} is not None  ${count}

    # Otherwise.
    ${cells xpath}=  Parse XPath  &{table xpaths}[cells]  row xpath cond=[1]
    ...                                                   col xpath cond=${EMPTY}
    ${count}=  Get Element Count  ${cells xpath}

    Return From Keyword  ${count}

Get Column Names
    [Documentation]  Fetches the names of the columsn of the table and returns
    ...  them in a list.
    ...
    ...  *NOTE*: This requires a `column name cells` locator in the table
    ...  dictionary.
    [Arguments]
    ...  ${table xpaths}

    ${col count}=  Get Column Count  ${table xpaths}

    @{col names}=  Create list
    :FOR  ${i}  IN RANGE  1  ${col count+1}
    \  ${value}=  SeleniumLibrary.Get Text  &{table xpaths}[column name cells][${i}]
    \  Append To List  ${col names}  ${value}
    Return From Keyword  ${col names}

Get Column Number By Name
    [Documentation]  Determines the column number of the column identified by
    ...  `${name}` and returns it.
    ...
    ...  *NOTE*: This requires a `column name cells` locator in the table
    ...  dictionary.
    ...
    ...  Also, numbering starts from 1.
    [Arguments]
    ...  ${table xpaths}
    ...  ${name}

    @{col names}=  Get Column Names  ${table xpaths}

    :FOR  ${i}  ${col name}  IN ENUMERATE  @{col names}
    \  Return From Keyword If   '${col name}' == '${name}'  ${i+1}

Get Row Count
    [Documentation]  Calculates and returns the amount of rows in the table.
    [Arguments]
    ...  ${table xpaths}

    ${rows xpath}=  Get Rows Locator  ${table xpaths}  row condition=${EMPTY}
    ${count}=  Get Element Count  ${rows xpath}

    Return From Keyword  ${count}

Get Rows Locator
    [Arguments]
    ...  ${table xpaths}
    ...  ${row condition}=${EMPTY}

    ${rows xpath}=  Parse XPath  &{table xpaths}[rows]  row xpath cond=${row condition}
    Return From Keyword  ${rows xpath}

Get Row Locator By Number
    [Arguments]
    ...  ${table xpaths}
    ...  ${row nr}

    ${row xpath}=  Get Rows Locator  ${table xpaths}  row condition=[${row nr}]
    Return From Keyword  ${row xpath}

Get Rows Locator Where Column Is
    [Arguments]
    ...  ${table xpaths}
    ...  ${col name}=${EMPTY}
    ...  ${col value}=${EMPTY}

    ${col nr}=  Get Column Number By Name  ${table xpaths}  ${col name}

    ${row parsed}=  Parse XPath  &{table xpaths}[cells rel]  col xpath cond=[position()=${col nr} and .='${col value}']
    ${rows xpath}=  Parse XPath  &{table xpaths}[rows]  row xpath cond=[.${row parsed}]

    Return From Keyword  ${rows xpath}

Prepare Table XPaths
    [Documentation]  @TODO.
    [Arguments]
    ...  ${table}=${EMPTY}
    ...  ${rows}=${EMPTY}
    ...  ${cells}=${EMPTY}
    ...  ${column name cells}=${NONE}

    # Append default placeholders for row and column XPath condition
    # epxressions if none are given. Apply this only for `rows` and `cells`.
    ${rows}=  Append To String If Not Contained  ${rows}  {row xpath cond}
    ${cells}=  Append To String If Not Contained  ${cells}  {col xpath cond}

    &{t}=  Create Dictionary
    ...  table=${table}
    ...  rows=${table}${rows}
    ...  cells=${table}${rows}${cells}
    ...  rows rel=${rows}
    ...  cells rel=${cells}
    Run Keyword If  ${column name cells != None}
    ...  Run Keywords
    ...    Collections.Set To Dictionary  ${t}  column name cells=${table}${column name cells}  AND
    ...    Collections.Set To Dictionary  ${t}  column name cells rel=${column name cells}

    Return From Keyword  ${t}

Parse XPath
    [Arguments]
    ...  ${xpath tmpl str}
    ...  ${row xpath cond}=${EMPTY}
    ...  ${col xpath cond}=${EMPTY}

    ${xpath expr}=  Format String  ${xpath tmpl str}  row xpath cond=${row xpath cond}
    ...                                               col xpath cond=${col xpath cond}
    Return From Keyword  ${xpath expr}
