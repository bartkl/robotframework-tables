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
    ...    Return from keyword  ${string}${part}
    ...  ELSE
    ...    Return from keyword  ${string}

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
    ...  ${row xpath cond}=${EMPTY}
    ...  ${col xpath cond}=${EMPTY}

    ${cells xpath}=  Format String  &{table xpaths}[cells]  row xpath cond=${row xpath cond}
    ...                                                     col xpath cond=${col xpath cond}
    ${value}=  SeleniumLibrary.Get Text  ${cells xpath}

    Return From Keyword  ${value}

Get Column Count
    [Documentation]  Calculates and returns the amount of columns in the table.
    [Arguments]
    ...  ${table xpaths}

    # If `column name cells' is defined.
    ${count}=  Run Keyword If  'column name cells' in ${table xpaths.keys()}
    ...    Get Element Count  &{table xpaths}[column name cells]

    Return From Keyword If  ${count} is not None  ${count}

    # Otherwise.
    ${cells xpath}=  Format String  &{table xpaths}[cells]  row xpath cond=[1]
    ...                                                     col xpath cond=${EMPTY}
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
    Return from keyword  ${col names}

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
    \  Return from keyword if   '${col name}' == '${name}'  ${i+1}

Get Row Count
    [Documentation]  Calculates and returns the amount of rows in the table.
    [Arguments]
    ...  ${table xpaths}

    ${rows xpath}=  Format String  &{table xpaths}[rows]  row xpath cond=${EMPTY}
    ${count}=  Get Element Count  ${rows xpath}

    Return From Keyword  ${count}

Prepare Table XPaths
    [Documentation]  @TODO.
    [Arguments]
    ...  ${table}
    ...  ${rows}
    ...  ${cells}
    ...  ${column name cells}=${NONE}

    # Append default placeholders for row and column XPath condition
    # epxressions if none are given. Apply this only for `rows` and `cells`.
    ${rows}=  Append To String If Not Contained  ${rows}  {row xpath cond}
    ${cells}=  Append To String If Not Contained  ${cells}  {col xpath cond}

    &{t}=  Create Dictionary
    ...  table=${table}
    ...  rows=${table}${rows}
    ...  cells=${table}${rows}${cells}
    Run Keyword If  ${column name cells != None}
    ...  Collections.Set To Dictionary  ${t}  column name cells=${table}${column name cells}

    Return From Keyword  ${t}

