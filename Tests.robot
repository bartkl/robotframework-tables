*** Settings ***
Resource  Tables.robot
Suite Setup  Setup Suite
Suite Teardown  Teardown Suite

*** Test Cases ***
Get Cell Locator By Coordinates
    ${cell locator}=  Get Cell Locator By Coordinates  ${T}  1  2
    ${value}=  Get Text  ${cell locator}
    Should Be Equal  ${value}  Accountant

Get Cell Value
    ${value}=  Get Cell Value  ${T}  [1]  [starts-with(., 'T')]
    Should Be Equal  ${value}  Tokyo

Get Cell Value By Coordinates
    ${value}=  Get Cell Value By Coordinates  ${T}  10  6
    Should Be Equal  ${value}  $433,060

Get Cells Locator
    @{actual values}=  Create List   Cara Stevens  Sales Assistant               New York   46  2011/12/06  $145,600
    ...                              Cedric Kelly  Senior  Javascript Developer  Edinburgh  22  2012/03/29  $433,060
    ${cell locator}=  Get Cells Locator  ${T}  [position()>8]  # Deliberately ommit column condition to test if it can be empty.

    ${result count}=  Get Element Count  ${cell locator}
    Should Be Equal  ${result count}  ${12}

    :FOR  ${i}  IN RANGE  ${1}  ${6}
    \  ${value}=  Get Text  ${cell locator}\[${i}]
    \  Should Be Equal  ${value}  @{actual values}[${i-1}]

Get Column Count
    ${col count}=  Get Column Count  ${T}
    Should Be Equal  ${col count}  ${6}

Get Column Names
    @{actual col names}=  Create list  Name  Position  Office  Age  Start date  Salary
    @{fetched col names}=  Get Column Names  ${T}
    Should Be Equal  ${fetched col names}  ${actual col names}

Get Column Number By Name
    ${office col nr}  Get Column Number By Name  ${T}  Office
    Should Be Equal  ${office col nr}  ${3}

Get Row Count
    ${row count}=  Get Row Count  ${T}
    Should Be Equal  ${row count}  ${10}

Get Rows Locator
    ${first two rows locator}=  Get Rows Locator  ${T}  row condition=[position() < 3]
    ${row count}=  Get Element Count  ${first two rows locator}
    Should Be Equal  ${row count}  ${2}
    ${cell 1 1}=  Get Text  ${first two rows locator}\[1]/td[1]  # Hacky way to check it, but it's just for assertion purposes.
    ${cell 2 4}=  Get Text  ${first two rows locator}\[2]/td[4]
    Should Be Equal  ${cell 1 1}  Airi Satou
    Should Be Equal  ${cell 2 4}  47

    ${all rows locator}=  Get Rows Locator  ${T}
    ${row count}=  Get Element Count  ${all rows locator}
    Should Be Equal  ${row count}  ${10}
    ${cell 1 1}=  Get Text  ${all rows locator}\[1]/td[1]  # Hacky way to check it, but it's just for assertion purposes.
    ${cell 5 5}=  Get Text  ${all rows locator}\[5]/td[5]
    ${cell 10 6}=  Get Text  ${all rows locator}\[10]/td[6]
    Should Be Equal  ${cell 1 1}  Airi Satou
    Should Be Equal  ${cell 5 5}  2011/06/07
    Should Be Equal  ${cell 10 6}  $433,060

Get Row Locator By Number
    ${row locator}=  Get Row Locator By Number  ${T}  ${7}
    ${name}=  Get Text  ${row locator}/td[1]  # Again, hacky check.
    Should Be Equal  ${name}  Bruno Nash

Get Rows Locator Where Column Is
    ${rows locator}=  Get Rows Locator Where Column Is  ${T}  Office  London
    ${row count}=  Get Element Count  ${rows locator}
    Should Be Equal  ${row count}  ${3}
    ${result cell 1 1}=  Get Text  ${rows locator}\[1]/td[1]  # Again, hacky check.
    ${result cell 2 1}=  Get Text  ${rows locator}\[2]/td[1]
    ${result cell 3 1}=  Get Text  ${rows locator}\[3]/td[1]
    Should Be Equal  ${result cell 1 1}  Angelica Ramos
    Should Be Equal  ${result cell 2 1}  Bradley Greer
    Should Be Equal  ${result cell 3 1}  Bruno Nash

# @TODO:
#   1. Decide whether to write unit tests for `Prepare Table XPaths` and `Parse XPath`.
#   2. You may want to implement more edge cases and fault paths to improve coverage.



*** Keywords ***
Setup Suite
    Open Browser  about:blank  chrome
    Go To  https://datatables.net/examples/data_sources/dom

    # This table does not require manual specification of row and column
    # XPath conditions.
    &{T}=  Prepare Table XPaths
    ...  table=//table[@id='example']
    ...  rows=/tbody/tr[@role='row']
    ...  cells=/td
    ...  column name cells=/thead/tr/th

    Set Suite Variable  ${T}

Teardown Suite
    Close All Browsers
